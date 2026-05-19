---
name: deploy-preview
description: 快速部署 + 预览环境时使用。适用于 Vercel / Railway / Fly.io / Cloudflare / Docker Compose 快速上线。融合 Preview 环境 + 环境变量 + 数据库连接 + 域名。
---

# 快速部署 + 预览（Deploy & Preview）

## 适用场景

- 全栈项目快速部署
- PR 预览环境
- MVP 上线
- Demo 环境
- 内部工具部署

## 核心原则

```text
1. 第一天就部署
   空项目也要部署，验证流水线

2. Preview 环境必备
   每个 PR 自动部署预览

3. 环境变量分级
   dev / staging / prod 分开

4. 数据库连接安全
   不硬编码，用环境变量

5. 一键回滚
   出问题 5 分钟内回滚
```

## 部署平台速查

| 平台 | 适合 | 免费额度 | 数据库 |
|---|---|---|---|
| **Vercel** | Next.js / Nuxt | 慷慨 | 需外部（Neon / Supabase）|
| **Railway** | 全栈（含 DB） | $5/月 | 内置 PG / Redis |
| **Fly.io** | Docker / 全球 | 有限 | 内置 PG |
| **Cloudflare Pages** | 静态 + Workers | 慷慨 | D1 / Turso |
| **Render** | 全栈 | 有限 | 内置 PG |
| **Supabase** | BaaS | 慷慨 | 内置 PG |
| **Docker Compose** | 自建 | - | 自建 |

## Vercel 部署（Next.js 推荐）

```bash
# 1. 安装 CLI
npm i -g vercel

# 2. 登录
vercel login

# 3. 部署（自动检测 Next.js）
vercel

# 4. 生产部署
vercel --prod

# 5. 环境变量
vercel env add DATABASE_URL production
vercel env add JWT_SECRET production
```

```json
// vercel.json（可选）
{
  "buildCommand": "prisma generate && next build",
  "framework": "nextjs"
}
```

## Railway 部署（含数据库）

```bash
# 1. 安装 CLI
npm i -g @railway/cli

# 2. 登录
railway login

# 3. 初始化
railway init

# 4. 添加 PostgreSQL
railway add --plugin postgresql

# 5. 部署
railway up

# 6. 环境变量自动注入 DATABASE_URL
```

## Docker Compose（自建 / 本地）

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
      - redis

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

```dockerfile
# Dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN pnpm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
```

## 数据库连接

```text
Vercel + Neon（推荐）：
  DATABASE_URL=postgresql://user:pass@ep-xxx.neon.tech/mydb?sslmode=require

Vercel + Supabase：
  DATABASE_URL=postgresql://postgres:pass@db.xxx.supabase.co:5432/postgres

Railway（自动注入）：
  DATABASE_URL 自动设置

Docker Compose：
  DATABASE_URL=postgresql://user:pass@db:5432/mydb
```

## 环境变量清单

```text
必需：
  DATABASE_URL          数据库连接
  JWT_SECRET            JWT 签名密钥
  NEXTAUTH_SECRET       NextAuth 密钥（如用）
  NEXTAUTH_URL          应用 URL

可选：
  GOOGLE_CLIENT_ID      社交登录
  GOOGLE_CLIENT_SECRET
  SMTP_HOST             邮件
  SMTP_USER
  SMTP_PASS
  S3_BUCKET             文件存储
  SENTRY_DSN            错误追踪
  REDIS_URL             缓存
```

## 部署流程

```text
1. 选平台（Vercel / Railway / Docker）
   ↓
2. 配置环境变量
   ↓
3. 连接数据库
   ↓
4. 部署空项目（验证流水线）
   ↓
5. 运行 Migration
   ↓
6. 验证（健康检查 + 首页可访问）
   ↓
7. 配置域名（如需）
   ↓
8. 配置 Preview 环境（PR 自动部署）
```

## 配套模板

- `templates/deploy-checklist.md` — 部署清单 + 环境变量 + 数据库 + 域名

## 质量自检

```text
□ 第一天就部署成功
□ Preview 环境可用
□ 环境变量不硬编码
□ 数据库连接正常
□ Migration 已执行
□ 健康检查通过
□ HTTPS 启用
□ 域名配置（如需）
□ 一键回滚可用
□ 监控接入（Sentry）
```

## 常见坑

1. **最后才部署**——环境问题堆积
2. **环境变量硬编码**——泄露
3. **数据库连接不加 SSL**——中间人攻击
4. **不跑 Migration**——表不存在
5. **Preview 环境共享生产 DB**——数据污染
6. **Docker 镜像太大**——> 1GB
7. **不配 HTTPS**——不安全
8. **回滚流程不清**——故障时慌

## 与其他 skill 的协作

```text
上游：
  fullstack-architecture → 部署平台选型
  e2e-feature-delivery → 部署是交付的最后一步

下游：
  devops-engineer（深度）→ CI/CD 正式化
  sre-operations → 监控告警
```
