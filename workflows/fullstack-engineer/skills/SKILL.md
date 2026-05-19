# 全栈工程师 Skills 总控

本目录收录全栈工程师工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [e2e-feature-delivery](e2e-feature-delivery/SKILL.md) | 端到端功能交付 | 全栈闭环方法 |
| [api-frontend-integration](api-frontend-integration/SKILL.md) | 前后端联调 | Mock → 真实 → 验证 |
| [fullstack-architecture](fullstack-architecture/SKILL.md) | 全栈架构选型 | Next.js / Nuxt / T3 / Rails / Laravel |
| [database-schema-impl](database-schema-impl/SKILL.md) | 快速建表 + ORM | Prisma / TypeORM / Django ORM |
| [auth-e2e](auth-e2e/SKILL.md) | 端到端认证 | JWT + 前端守卫 + DB |
| [deploy-preview](deploy-preview/SKILL.md) | 快速部署 + 预览 | Vercel / Railway / Docker Compose |

## 统一入口

1. 先读 `routing.md` — 按全栈任务路由
2. 再进入对应 SKILL.md
3. 深度实现路由到 backend-engineer / frontend-engineer 的 skill

## 工作思路

```text
1. 拿到需求 → 选架构
   - fullstack-architecture

2. 设计数据 → 建表
   - database-schema-impl

3. 实现后端 + 前端 → 联调
   - e2e-feature-delivery
   - api-frontend-integration

4. 认证
   - auth-e2e

5. 部署
   - deploy-preview
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成全栈任务后，回写经验到 `../field-journal/`。
