---
name: container-orchestration
description: 容器编排与部署时使用。覆盖 Docker/Docker Compose/K8s/Helm 实操。
---

# 容器编排与部署（Container Orchestration）

## 适用场景

- Docker 镜像构建优化
- Docker Compose 本地编排
- Kubernetes 部署配置
- Helm Chart 编写
- 镜像仓库管理
- 容器安全加固

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| 容器构建 / K8s 部署 | **本 skill** |
| CI/CD 流水线 | `ci-cd-pipeline/` |
| 发布策略（灰度/蓝绿） | `release-strategy/` |
| 监控告警 | sre-operations 工作流 |
| 容器安全扫描 | security-engineer 工作流 |

---

## 核心命令速查

### Docker

```bash
# 构建镜像
docker build -t myapp:v1.0 .
docker build -t myapp:v1.0 --target runner .  # 多阶段指定目标

# 运行
docker run -d -p 3000:3000 --name myapp myapp:v1.0
docker run --rm -it myapp:v1.0 sh  # 进入容器调试

# 日志
docker logs -f myapp
docker logs --tail 100 myapp

# 清理
docker system prune -af  # 清理所有未使用镜像/容器/网络
docker image prune -af   # 只清镜像

# 镜像体积分析
docker history myapp:v1.0
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### Docker Compose

```bash
# 启动
docker compose up -d
docker compose up -d --build  # 强制重建

# 查看状态
docker compose ps
docker compose logs -f app

# 停止
docker compose down
docker compose down -v  # 含数据卷（危险！）

# 单服务重建
docker compose up -d --build app
```

### Kubernetes (kubectl)

```bash
# 部署
kubectl apply -f deployment.yaml
kubectl apply -f .  # 应用目录下所有 YAML

# 状态查看
kubectl get pods
kubectl get pods -w  # 实时监控
kubectl describe pod <pod-name>
kubectl logs -f <pod-name>
kubectl logs -f <pod-name> --previous  # 上次崩溃日志

# 扩缩容
kubectl scale deployment myapp --replicas=5

# 回滚
kubectl rollout undo deployment/myapp
kubectl rollout history deployment/myapp

# 进入容器调试
kubectl exec -it <pod-name> -- sh

# 端口转发（本地调试）
kubectl port-forward svc/myapp 3000:80

# 查看资源使用
kubectl top pods
kubectl top nodes
```

---

## Dockerfile 最佳实践决策

```text
语言        │ 基础镜像          │ 预期大小    │ 注意事项
────────────┼───────────────────┼─────────────┼─────────────────
Node.js     │ node:20-alpine    │ 80~150MB    │ 多阶段, pnpm
Java        │ eclipse-temurin   │ 200~350MB   │ JRE only, -alpine
Python      │ python:3.12-slim  │ 100~200MB   │ 多阶段, pip install
Go          │ scratch/distroless│ 5~20MB      │ CGO=0 静态编译
Rust        │ scratch/distroless│ 5~15MB      │ 静态编译
```

---

## 配套模板

- `templates/container-orchestration-template.md`

## 常见坑

```text
1. 用 latest 标签 → 不可复现
2. 不用多阶段构建 → 镜像 1GB+
3. root 运行 → 安全风险
4. 不设 HEALTHCHECK → K8s 不知状态
5. 不限制资源 → OOM Kill
6. 不用 .dockerignore → 构建上下文巨大
7. 数据卷不持久化 → 容器重启数据丢
8. 不设 restart policy → 崩溃后不自愈
9. compose 里用 host network → 端口冲突
10. 不分环境 → dev 镜像直接上生产
```

## 与其他 skill 的协作

```text
上游：backend-engineer / frontend-engineer → 构建产物
下游：ci-cd-pipeline → 流水线集成
      release-strategy → 发布策略
      sre-operations → 运行时监控
```
