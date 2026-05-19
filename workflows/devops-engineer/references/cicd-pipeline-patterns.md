# CI/CD Pipeline 模式速查

> 覆盖 GitHub Actions / GitLab CI 实战配置，面向 APP/小程序/网页项目。

## 1. GitHub Actions 标准模板

### Node.js 前端（含缓存+并行）

```yaml
name: Frontend CI/CD
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint-and-type:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm type-check

  test:
    runs-on: ubuntu-latest
    needs: lint-and-type
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm test -- --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/download-artifact@v4
        with: { name: dist }
      # 根据部署目标选择：Vercel / Cloudflare / 自建服务器
      - run: echo "Deploy to production"
```

### Java Spring Boot

```yaml
name: Backend CI/CD
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_PASSWORD: testpass
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
          cache: gradle
      - run: ./gradlew test
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/testdb
      - run: ./gradlew bootJar

  docker:
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## 2. 分支策略

```text
┌─ 推荐：GitHub Flow（简单项目）────────────────────────┐
│                                                        │
│  main ──────●────────●────────●──────── (生产)        │
│              ╲      ╱ ╲      ╱                        │
│  feature/xxx  ●──●─╱   ●──●─╱  (短命分支)            │
│                                                        │
│  规则：                                                │
│  - main 永远可部署                                     │
│  - feature 分支从 main 切，PR 合回 main                │
│  - PR 必须通过 CI + Code Review                       │
│  - 合并后自动部署                                      │
└────────────────────────────────────────────────────────┘

┌─ 备选：Git Flow（复杂版本管理）────────────────────────┐
│                                                        │
│  main ──────●─────────────────●────── (发布)          │
│  develop ───●────●────●───────●────── (集成)          │
│  feature/    ╲──╱     ╲──╱                            │
│  release/              ╲─────╱                        │
│                                                        │
│  适合：移动端 APP / 多版本并行维护                      │
└────────────────────────────────────────────────────────┘
```

---

## 3. 环境管理

```text
环境           │ 用途           │ 部署触发          │ 数据
───────────────┼────────────────┼───────────────────┼──────────
development    │ 开发联调       │ push develop      │ 模拟数据
staging        │ 预发布验证     │ push main (自动)  │ 生产脱敏
production     │ 正式上线       │ 手动审批/tag      │ 真实数据
```

---

## 4. 回滚方案

```text
策略 1：镜像回滚（推荐）
  kubectl rollout undo deployment/myapp
  或指定版本：
  kubectl rollout undo deployment/myapp --to-revision=3

策略 2：Git Revert
  git revert <commit> && git push
  CI 自动触发新部署

策略 3：Blue/Green 切换
  修改 Service selector 指向旧版 Deployment

黄金法则：
  - 每次部署记录版本号（镜像 tag = git sha）
  - 保留最近 5 个可用镜像
  - 数据库迁移必须向后兼容（先加列，后删列）
```

---

## 5. Nginx 反向代理配置

```nginx
# /etc/nginx/conf.d/app.conf
upstream app_backend {
    server 127.0.0.1:3000;
    keepalive 32;
}

server {
    listen 80;
    server_name app.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.example.com;

    ssl_certificate     /etc/letsencrypt/live/app.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.example.com/privkey.pem;

    # 安全头
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    # 静态资源（前端构建产物）
    location / {
        root /var/www/app/dist;
        try_files $uri $uri/ /index.html;  # SPA fallback
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API 代理
    location /api/ {
        proxy_pass http://app_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout 30s;
    }

    # 健康检查（不记日志）
    location /health {
        proxy_pass http://app_backend;
        access_log off;
    }

    # Gzip
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
    gzip_min_length 1000;
}
```
