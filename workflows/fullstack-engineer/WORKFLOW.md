# 全栈工程师工作流（Fullstack Engineer Workflow）

## 定位

全栈工程师工作流负责 **一人端到端交付**：从 PRD 到数据库、后端、前端、联调、测试、部署的完整闭环。

它不是 backend + frontend 的简单叠加，而是一个 **编排 + 联调 + 快速交付** 的角色。当任务需要跨前后端但团队小（1~3 人）或时间紧（MVP / POC / 内部工具）时，用全栈工作流。

当任务复杂度超过全栈能力时（如需要深度 DBA 优化、专业安全审计、大规模性能调优），应拆分到专业工作流。

本工作流采用 **skills 模块化架构**。全栈 skill 聚焦"端到端"视角，深度实现细节路由到 backend-engineer / frontend-engineer 的 skill。

---

## 适用场景

```text
MVP / POC 快速交付（1~3 人团队）
内部工具 / 管理后台
小型 SaaS 功能模块
端到端功能（从页面到数据库）
前后端联调
快速原型验证
Hackathon / 技术验证
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 需求不清 | product-manager |
| 纯前端（不涉及后端） | frontend-engineer |
| 纯后端（不涉及前端） | backend-engineer |
| 深度数据库优化 / 迁移 | database-engineer |
| 专业安全审计 | security-engineer |
| 大规模性能调优 | 拆分到 backend + frontend |
| CI/CD 流水线深度 | devops-engineer |
| 线上监控告警 | sre-operations |

---

## 技术栈选型（全栈视角）

### 全栈框架（一体化）

| 框架 | 语言 | 前端 | 后端 | 数据库 | 适合 |
|---|---|---|---|---|---|
| **Next.js 15** | TS | React | API Routes / Server Actions | Prisma / Drizzle | SaaS / 内容 |
| **Nuxt 3** | TS | Vue 3 | Nitro Server | Prisma / Drizzle | 国内 / 中小 |
| **SvelteKit** | TS | Svelte | Endpoints / Actions | Prisma | 性能敏感 |
| **T3 Stack** | TS | Next.js + tRPC + Tailwind | tRPC | Prisma | 类型安全极致 |
| **Remix** | TS | React | Loaders / Actions | Prisma | 表单密集 |
| **Rails 8** | Ruby | Hotwire | Rails | ActiveRecord | 快速 MVP |
| **Laravel 11** | PHP | Livewire / Inertia | Laravel | Eloquent | PHP 全栈 |
| **Django** | Python | HTMX / React | Django | Django ORM | AI / 数据 |
| **Encore.ts** | TS | React | Encore | 自动 | 微服务 |

### 选型决策

```text
Q1：团队语言？
  TypeScript → Next.js / Nuxt / T3 / SvelteKit
  Ruby → Rails
  PHP → Laravel
  Python → Django

Q2：交付时间？
  < 1 周 → Rails / Laravel / Django + Admin
  1~4 周 → Next.js / Nuxt / T3
  > 1 月 → 拆分到 backend + frontend

Q3：类型安全重要？
  极致 → T3 Stack（tRPC 端到端类型）
  一般 → Next.js / Nuxt

Q4：SEO 重要？
  是 → Next.js / Nuxt / SvelteKit（SSR）
  否 → 任意
```

---

## 输入

### 必需输入

```text
PRD 或功能范围
验收标准
用户角色和权限
核心业务流程
技术栈（已定 or 可选）
部署目标（Vercel / Railway / 自建）
```

### 可选输入

```text
设计稿（Figma）
API 契约（如已有）
现有代码库
第三方集成需求
性能 / SLA 要求
```

### 输入不足时先补问

```text
1. 这个功能的核心用户流程是什么？（从哪个页面开始到哪里结束）
2. 涉及哪些数据实体？（用户 / 订单 / 商品 ...）
3. 权限边界？（谁能看 / 谁能改）
4. 技术栈是否已锁定？
5. 部署到哪里？（Vercel / Railway / Docker / 自建）
6. 是否需要第三方集成？（支付 / 邮件 / 存储）
7. 交付时间？
```

---

## 完整行为链（硬性流程）

```text
1. 读取 PRD / 验收标准 / 用户流程
   ↓
2. 检查 field-journal → 是否有同类全栈经验
   ↓
3. 选定技术栈（全栈框架 + DB + 部署）
   ↓
4. 判断复杂度（S/M/L/XL）
   ↓
5. 设计数据模型（schema）
   ↓
6. 实现后端（API / Server Actions）
   ↓
7. 实现前端（页面 / 组件 / 状态）
   ↓
8. 联调（前后端对接 + 错误处理）
   ↓
9. 测试（单元 + 集成 + E2E 关键路径）
   ↓
10. 部署（Preview + Production）
    ↓
11. 验收 + 交接
    ↓
12. 沉淀经验 → field-journal
```

---

## Skills 模块总览

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [e2e-feature-delivery](skills/e2e-feature-delivery/SKILL.md) | 端到端功能交付 | PRD → Schema → API → UI → 联调 → 部署 |
| [api-frontend-integration](skills/api-frontend-integration/SKILL.md) | 前后端联调 | Mock → 真实 → 错误处理 → 验证 |
| [fullstack-architecture](skills/fullstack-architecture/SKILL.md) | 全栈架构选型 | Next.js / Nuxt / T3 / Rails / Laravel 对比 |
| [database-schema-impl](skills/database-schema-impl/SKILL.md) | 快速建表 + ORM | Prisma / TypeORM / Django ORM / ActiveRecord |
| [auth-e2e](skills/auth-e2e/SKILL.md) | 端到端认证 | 注册 → 登录 → Token → 权限 → 前端守卫 |
| [deploy-preview](skills/deploy-preview/SKILL.md) | 快速部署 + 预览 | Vercel / Railway / Docker Compose / Fly.io |

**深度实现**路由到专业工作流 skill：
- 后端深度 → `backend-engineer/skills/*`
- 前端深度 → `frontend-engineer/skills/*`
- 数据库深度 → `database-engineer/skills/*`

---

## 禁止行为

```text
❌ 不要在需求不清时直接写代码
❌ 不要跳过数据模型设计直接写 UI
❌ 不要前后端分别写完再联调（应该边写边调）
❌ 不要忽略错误处理（loading / error / empty）
❌ 不要硬编码密钥
❌ 不要跳过测试直接部署
❌ 不要在复杂度超出全栈能力时硬撑（应拆分）
❌ 不要把全栈当"什么都自己做"——该转交就转交
```

---

## 任务复杂度分级

```text
S 级（30 分钟~2 小时）：单页面 CRUD
  → e2e-feature-delivery + database-schema-impl

M 级（2~8 小时）：多页面功能模块
  → + api-frontend-integration + auth-e2e + deploy-preview

L 级（1~3 天）：完整小产品 / MVP
  → 全部 6 skills + 路由到 backend/frontend 深度 skill

XL 级（3 天+）：应拆分到专业工作流
  → 拆分为 backend + frontend + database + devops 协作
```

---

## 通用质量检查

```text
□ 数据模型设计完成（schema + 关系 + 约束）
□ API 端点实现完整（CRUD + 错误码）
□ 前端页面实现（含 loading / error / empty）
□ 前后端联调通过（真实数据）
□ 认证鉴权端到端（注册 → 登录 → 权限）
□ 单元测试覆盖核心逻辑
□ E2E 测试覆盖关键路径
□ 部署成功（Preview 可访问）
□ 验收标准全部满足
□ 不硬编码密钥
□ 性能可接受（首屏 < 3s）
□ 移动端响应式
□ 基本可访问性（键盘 + 对比度）
```

---

## 常见坑

```text
1. 先写 UI 再想数据模型 → 返工
2. 前后端分别写完再联调 → 字段不一致
3. 不用 TypeScript → 联调时类型错误
4. 不处理错误状态 → 用户看到白屏
5. 认证只做前端 → 后端裸奔
6. 不写测试 → 改一处坏三处
7. 不部署 Preview → 验收靠截图
8. 复杂度超出硬撑 → 质量崩溃
9. 不用全栈框架 → 自己拼装浪费时间
10. 不用 ORM → 手写 SQL 容易注入
```

---

## 与其他工作流的协作

### 上游

| 上游 | 全栈需要的输入 |
|---|---|
| product-manager | PRD、验收标准、用户故事 |
| ui-ux-designer | 设计稿（如有）|
| project-manager | 任务拆解、里程碑 |

### 下游

| 下游 | 全栈交付内容 |
|---|---|
| qa-engineer | 可测试的部署环境 + 接口文档 |
| devops-engineer | Dockerfile / 部署配置（如需正式化）|
| technical-writer | 功能说明 / API 文档 |

### 路由到专业工作流

| 场景 | 路由到 |
|---|---|
| 后端深度优化 | backend-engineer |
| 前端深度优化 | frontend-engineer |
| 数据库迁移 / 大表 | database-engineer |
| 安全审计 | security-engineer |
| CI/CD 正式化 | devops-engineer |

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow fullstack-engineer
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

```text
是否形成新的全栈模板？→ 加入对应 skill 的 templates/
是否发现新的联调坑？→ 更新 pitfalls.md
是否需要新增全栈框架？→ 更新 fullstack-architecture
是否需要写入 field-journal？
```
