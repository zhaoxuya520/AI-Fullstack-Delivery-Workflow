---
name: fullstack-architecture
description: 选择全栈技术栈时使用。适用于新项目启动、框架选型、Monorepo vs 分仓决策。覆盖 Next.js / Nuxt / T3 / SvelteKit / Rails / Laravel / Django。
---

# 全栈架构选型（Fullstack Architecture）

## 适用场景

- 新项目技术栈选型
- 全栈框架对比
- Monorepo vs 分仓决策
- 项目初始化模板

## 核心原则

```text
1. 选熟悉的 > 选最新的
2. 选生态大的 > 选性能最高的
3. 全栈框架 > 自己拼装
4. TypeScript 端到端 > 多语言
5. 部署简单 > 架构复杂
```

## 全栈框架速查

| 框架 | 语言 | 前端 | 后端 | DB | 部署 | 适合 |
|---|---|---|---|---|---|---|
| **Next.js 15** | TS | React | Server Actions / API Routes | Prisma | Vercel | SaaS / 内容 |
| **T3 Stack** | TS | Next.js | tRPC | Prisma | Vercel | 类型安全极致 |
| **Nuxt 3** | TS | Vue 3 | Nitro | Prisma / Drizzle | Vercel / CF | 国内 / 中小 |
| **SvelteKit** | TS | Svelte | Endpoints | Prisma | Vercel / CF | 性能 |
| **Remix** | TS | React | Loaders / Actions | Prisma | Fly.io | 表单密集 |
| **Rails 8** | Ruby | Hotwire | Rails | ActiveRecord | Render / Fly | 快速 MVP |
| **Laravel 11** | PHP | Livewire / Inertia | Laravel | Eloquent | Forge / Vapor | PHP |
| **Django** | Python | HTMX / React | Django | Django ORM | Railway | AI / 数据 |

## 选型决策树

```text
TypeScript 团队？
  YES → 类型安全重要？
    极致 → T3 Stack
    一般 → Next.js / Nuxt
  NO → Ruby → Rails / Python → Django / PHP → Laravel

SEO 重要？
  YES → Next.js / Nuxt / SvelteKit（SSR）
  NO → 任意

交付时间 < 1 周？
  YES → Rails / Laravel / Django（约定多、脚手架快）
  NO → Next.js / Nuxt / T3

团队 > 5 人？
  YES → 考虑拆分 backend + frontend
  NO → 全栈框架 OK
```

## Monorepo vs 分仓

```text
Monorepo（推荐小团队）：
  ✅ 类型共享方便
  ✅ 一次 PR 改前后端
  ✅ 统一 CI
  工具：pnpm workspaces + Turborepo

分仓（大团队）：
  ✅ 独立部署
  ✅ 独立版本
  ✅ 团队边界清晰
  工具：独立 repo + OpenAPI 契约
```

## 项目初始化模板

### Next.js + Prisma + Tailwind

```bash
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir
cd my-app
pnpm add prisma @prisma/client
pnpm add -D @types/node
npx prisma init
```

### T3 Stack

```bash
pnpm create t3-app@latest my-app
# 选：TypeScript + tRPC + Prisma + Tailwind + NextAuth
```

### Nuxt 3

```bash
npx nuxi@latest init my-app
cd my-app
pnpm add @prisma/client
pnpm add -D prisma
```

## 配套模板

- `templates/architecture-decision.md` — 选型决策记录 + 对比表 + 理由

## 质量自检

```text
□ 选型有明确理由（不是"最火"）
□ 团队熟悉度评估
□ 生态评估（Stars / 维护 / 文档）
□ 部署方案确定
□ TypeScript 端到端
□ 项目初始化完成
□ 基础配置（Lint / Format / Git hooks）
□ 第一天就部署
```

## 常见坑

1. **自己拼装**——浪费时间在胶水代码
2. **选不熟的框架**——学习成本 > 收益
3. **不用 TypeScript**——联调地狱
4. **不用 ORM**——手写 SQL 容易注入
5. **过早微服务**——1 人团队不需要
6. **不评估部署**——选了框架部署不了

## 与其他 skill 的协作

```text
下游：
  e2e-feature-delivery → 用选定的栈实现
  database-schema-impl → ORM 选型
  deploy-preview → 部署平台
```
