# 全栈 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "做一个完整功能" / "端到端" / "从页面到数据库" | [e2e-feature-delivery](e2e-feature-delivery/SKILL.md) |
| "联调" / "前后端对接" / "Mock 切真实" | [api-frontend-integration](api-frontend-integration/SKILL.md) |
| "用什么框架" / "Next.js 还是 Nuxt" / "T3" | [fullstack-architecture](fullstack-architecture/SKILL.md) |
| "建表" / "ORM" / "Prisma" / "数据模型" | [database-schema-impl](database-schema-impl/SKILL.md) |
| "登录" / "注册" / "JWT" / "权限" / "认证" | [auth-e2e](auth-e2e/SKILL.md) |
| "部署" / "上线" / "Preview" / "Vercel" / "Docker" | [deploy-preview](deploy-preview/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单页面 CRUD（S 级） | e2e-feature-delivery + database-schema-impl |
| 多页面功能（M 级） | + api-frontend-integration + auth-e2e + deploy-preview |
| 完整 MVP（L 级） | 全部 6 skills |
| 超出全栈能力（XL） | 拆分到 backend + frontend + database |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 30min~2h | e2e-feature-delivery + database-schema-impl |
| M | 2~8h | + api-frontend-integration + auth-e2e + deploy-preview |
| L | 1~3 天 | 全部 + 路由到 backend/frontend 深度 |
| XL | 3 天+ | 拆分到专业工作流 |

## 路径交叉

```text
MVP 交付：
  fullstack-architecture（选型）
  → database-schema-impl（建表）
  → e2e-feature-delivery（实现）
  → api-frontend-integration（联调）
  → auth-e2e（认证）
  → deploy-preview（部署）

快速原型：
  fullstack-architecture（选型）
  → e2e-feature-delivery（实现）
  → deploy-preview（部署）

认证模块：
  auth-e2e（端到端认证）
  → database-schema-impl（users 表）
  → api-frontend-integration（Token 联调）
```

## 深度路由（超出全栈范围时）

| 需要深度 | 路由到 |
|---|---|
| 后端性能 / 缓存 / 队列 | backend-engineer/skills/* |
| 前端性能 / a11y / 设计系统 | frontend-engineer/skills/* |
| 数据库迁移 / 大表 / 索引 | database-engineer/skills/* |
| CI/CD 正式化 | devops-engineer |
| 安全审计 | security-engineer |

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增。
