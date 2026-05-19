# Docker & Kubernetes 实战指南

> AI 工作流参考文件。覆盖容器化最佳实践、K8s 部署模式、生产级配置。

## 1. Dockerfile 最佳实践

### 多阶段构建（减少镜像体积 60~80%）

```dockerfile
# ─── 阶段1：构建 ───
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# ─── 阶段2：运行 ───
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# 安全：非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/main.js"]
```

### Java Spring Boot 多阶段

```dockerfile
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN ./gradlew bootJar -x test

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=builder /app/build/libs/*.jar app.jar
USER spring
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --spider http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

### Dockerfile 检查清单

```text
□ 使用多阶段构建（builder + runner）
□ 基础镜像用 alpine/slim（非 full）
□ 固定版本号（不用 latest）
□ .dockerignore 排除 node_modules/.git/dist
□ 非 root 用户运行（USER appuser）
□ HEALTHCHECK 配置
□ 只复制必要文件（不 COPY .）
□ 利用层缓存（依赖文件先复制再 install）
□ 不在镜像中存密钥/Token
□ 镜像大小 < 200MB（Node）/ < 300MB（Java）
```

---

## 2. Docker Compose 生产配置

```yaml
# docker-compose.yml — 开发环境
version: "3.9"
services:
  app:
    build:
      context: .
      target: builder  # 开发用 builder 阶段
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules  # 排除 node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru

volumes:
  pgdata:
```

---

## 3. Kubernetes 部署模式

### Deployment + Service + Ingress（最常用）

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # 零停机
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: registry.example.com/myapp:v1.2.3
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          env:
            - name: NODE_ENV
              value: production
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: database-url
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP
---
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - app.example.com
      secretName: myapp-tls
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

### HPA（水平自动扩缩容）

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

---

## 4. 部署策略决策表

| 策略 | 适用场景 | 风险 | 回滚速度 |
|------|----------|------|---------|
| **Rolling Update** | 大部分场景（默认） | 低 | 1~2 分钟 |
| **Blue/Green** | 零停机 + 即时回滚 | 中（资源翻倍） | 秒级 |
| **Canary** | 高风险变更 + 灰度验证 | 低 | 秒级 |
| **Recreate** | 不兼容升级（DB schema） | 高（短暂停机） | 1~2 分钟 |

---

## 5. 常见坑

```text
1. Dockerfile 用 latest 标签 → 不可复现
2. 没有 .dockerignore → 镜像 1GB+
3. root 用户运行容器 → 安全风险
4. 没有 HEALTHCHECK → K8s 不知道服务是否就绪
5. resources 不设 limits → OOM Kill 随机 Pod
6. 没有 readinessProbe → 请求打到未就绪实例
7. Secret 硬编码在 YAML → 泄露
8. 不设 maxUnavailable: 0 → 更新时有请求失败
9. 单副本部署 → 更新时服务中断
10. 不限制镜像拉取策略 → 生产用到开发镜像
```

---

## 6. 资源估算参考

```text
Node.js 应用（无状态 API）：
  requests: cpu=100m, memory=256Mi
  limits:   cpu=500m, memory=512Mi
  replicas: 2~5

Java Spring Boot：
  requests: cpu=200m, memory=512Mi
  limits:   cpu=1000m, memory=1Gi
  replicas: 2~4

Python FastAPI：
  requests: cpu=100m, memory=128Mi
  limits:   cpu=500m, memory=384Mi
  replicas: 2~6

PostgreSQL（有状态）：
  requests: cpu=500m, memory=1Gi
  limits:   cpu=2000m, memory=4Gi
  replicas: 1（主）+ 1~2（从）

Redis：
  requests: cpu=100m, memory=128Mi
  limits:   cpu=500m, memory=256Mi
```
