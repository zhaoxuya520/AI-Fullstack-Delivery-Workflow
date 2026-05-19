# 后端工程师工作流（Backend Engineer Workflow）

## 定位

后端工程师工作流负责把 PRD、API 契约、数据模型和业务规则，转化为 **可运行、可测试、可观测、可演进** 的服务端实现：业务逻辑、接口实现、领域模型、持久化、缓存、异步任务、第三方集成、错误处理、安全防护、可观测性。

它不替代 API 设计工作流（契约定义）、数据库工程师工作流（DDL）、QA 工作流（验收）、DevOps 工作流（部署）。它负责 **把契约变成代码**。

本工作流采用 **skills 模块化架构**：总控负责路由、技术栈选型和通用规则，具体方法论拆分成独立 skills，按需加载。**支持所有主流后端技术栈**（Spring Boot / Django / FastAPI / NestJS / Express / Fastify / Hono / Go Gin/Fiber / Rails / Laravel / .NET Core）。

---

## 适用场景

```text
业务逻辑实现 / 服务层 / 领域模型
API 端点实现（按 OpenAPI 契约落地）
数据持久化（ORM / 仓储模式）
缓存策略（Redis / 本地 / CDN）
异步任务（消息队列 / 后台 worker）
第三方集成（HTTP / SDK / Webhook）
错误处理 / 重试 / 降级 / 熔断
认证鉴权实现（JWT / OAuth / RBAC）
日志 / 指标 / 链路追踪
单元测试 / 集成测试
代码质量 / Code Review
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 需求 / 验收标准不清 | 产品经理工作流 |
| API 契约未定 | API 设计工作流 |
| 数据库 schema / 索引 / 迁移 | 数据库工程师工作流 |
| 前端页面 / 状态管理 | 前端工程师工作流 |
| 单元 / 集成测试用例设计（不是实现） | QA 工作流 |
| CI/CD / Docker / Kubernetes | DevOps 工程师工作流 |
| 监控告警 / 线上事故 | SRE/运维工作流 |
| 攻击面 / 漏洞挖掘 | 安全工程师工作流 |

---

## 技术栈选型矩阵（2026）

按业务场景选型，不要"哪个最火用哪个"：

| 业务类型 | 首选 | 备选 | 不推荐 |
|---|---|---|---|
| **企业级 SaaS / 金融** | Spring Boot 3 (Java/Kotlin)、ASP.NET Core | Django、NestJS | Express、Flask |
| **快速 MVP / 创业** | NestJS、Django、Rails、Laravel | FastAPI、Hono | Spring Boot（重）|
| **AI / 数据驱动** | FastAPI（Python）、Django | NestJS（接 LangChain） | - |
| **高并发 / 实时** | Go (Gin/Fiber/Echo)、Rust (Axum)、Bun (Hono) | NestJS + Fastify | Django、Rails |
| **微服务架构** | Go、Spring Boot、Encore.ts、NestJS | FastAPI、ASP.NET | Express |
| **边缘函数 / Serverless** | Hono、Cloudflare Workers、Vercel Functions | AWS Lambda + FastAPI | Spring Boot |
| **GraphQL** | NestJS + Apollo、Hasura、PostGraphile | Spring Boot + GraphQL Java | - |
| **CRUD 后台 / 内部工具** | Django Admin、Laravel Nova、Rails | NestJS + AdminJS | - |

### 性能基准（仅供参考，非选型唯一标准）

```text
TechEmpower Round 23（每秒请求数）：
  ASP.NET Core Minimal API   ~1,000,000 req/s
  Go Fiber                    ~12,000,000 (微基准)
  Spring Boot WebFlux         ~170,000 req/s
  NestJS + Fastify            ~180,000 req/s
  Express                     ~46,000 req/s
  Django (sync)               ~20,000 req/s
  FastAPI (async)             ~120,000 req/s

实际业务：
  - 90% 后端瓶颈在数据库 / 第三方调用，不在框架
  - 选熟悉的栈 + 优化 SQL > 换框架
```

### 主流框架特点速查

| 框架 | 语言 | 风格 | 特点 |
|---|---|---|---|
| **Spring Boot 3** | Java/Kotlin | 重量级、约定大于配置 | 企业级、生态丰富、DI 强大、AOT 编译（Native）|
| **NestJS** | TypeScript | Angular 风格分层 | DI、装饰器、模块化、可换 Express/Fastify |
| **Express** | JavaScript | 极简、中间件链 | 老牌、生态最大、性能一般 |
| **Fastify** | TypeScript | Express 替代 | 2-3x Express 性能、内置 JSON Schema |
| **Hono** | TypeScript | Edge 优先 | 14KB、跨运行时（Bun/Deno/CF Workers）|
| **Encore.ts** | TypeScript | 全栈一体化 | 9x Express、自动基础设施 |
| **Django** | Python | Batteries-included | ORM 强、Admin 自带、生态大 |
| **FastAPI** | Python | 现代、async | 类型注解、自动 OpenAPI、性能好 |
| **Flask** | Python | 微框架 | 灵活、需自己拼装 |
| **Gin** | Go | 极简高性能 | 简洁路由、生态丰富 |
| **Fiber** | Go | Express 风格 | Express API、Go 性能 |
| **Echo** | Go | 中间件友好 | 类似 Gin |
| **Rails** | Ruby | 约定大于配置 | 快速 CRUD、ActiveRecord |
| **Laravel** | PHP | 全栈 + Eloquent | PHP 生态主力 |
| **ASP.NET Core** | C# | 高性能、跨平台 | TechEmpower 顶级、企业级 |
| **Axum** | Rust | 类型安全、零成本 | Tokio 生态 |
| **Phoenix** | Elixir | 实时 / WebSocket | LiveView 实时 UI |

---

## 输入

### 必需输入

```text
PRD 或功能范围
API 契约（OpenAPI / 接口文档）
数据模型（DDL / ORM 定义）
业务规则（计算 / 状态流转 / 校验）
权限矩阵（角色 / 资源 / 操作）
非功能要求（性能 / 一致性 / SLA）
技术栈（语言 / 框架 / 数据库 / 中间件）
```

### 可选输入

```text
UI/UX 流程（理解前端调用顺序）
历史代码 / 现有架构
第三方 API 文档
监控告警要求
合规要求（GDPR / PCI / 等保）
```

### 输入不足时先补问

```text
1. API 契约 OpenAPI 在哪？（不是接口列表，是真契约）
2. 数据库 schema 是否冻结？还是仍在演进？
3. 错误码表是否已定义？还是要现写？
4. 权限粒度（角色/字段/租户）边界？
5. 性能目标 P99 是多少？QPS 多少？
6. 是否需要异步处理？哪些操作？
7. 是否有已有的依赖注入 / 仓储 / 服务层规范？
8. 技术栈是否已锁定？还是可选？
```

---

## 完整行为链（硬性流程）

```text
1. 读取 PRD / API 契约 / 数据模型 / 业务规则
   ↓
2. 检查 field-journal/_index.md → 是否有同类业务实现经验可复用
   ↓
3. 确认技术栈 → 不一致先转项目经理决策
   ↓
4. 读取 skills/routing.md → 路由到需要的 skills
   ↓
5. 判断实现复杂度（S/M/L/XL）→ 选择产出粒度
   ↓
6. 设计 → 实现 → 单元测试 → 集成测试 → Code Review
   ↓
7. 加载命中的 skills → 按 skill 内方法 + 框架范式执行
   ↓
8. 输出代码 + 测试 + 接口文档 + 配置说明
   ↓
9. 转交 QA / DevOps / 文档工作流
   ↓
10. 按 EVOLUTION.md 沉淀经验 → 回写 field-journal
```

---

## Skills 模块总览

每个 skill 独立可用，按需组合。**每个 skill 都覆盖多语言/多框架范式**。详细路由见 `skills/routing.md`。

| Skill | 适用场景 | 覆盖框架 |
|-------|---------|---------|
| [api-implementation](skills/api-implementation/SKILL.md) | API 端点实现 / 分层 | Spring Boot / NestJS / Django / FastAPI / Gin / Express |
| [domain-modeling](skills/domain-modeling/SKILL.md) | 领域模型 / DDD | 通用方法论 + 各 ORM 映射 |
| [data-access](skills/data-access/SKILL.md) | ORM / 持久化 | JPA/Hibernate / TypeORM / Prisma / Django ORM / SQLAlchemy / GORM |
| [caching-strategy](skills/caching-strategy/SKILL.md) | 缓存策略 | Redis / Caffeine / Memcached + Spring Cache / NestJS Cache |
| [async-jobs](skills/async-jobs/SKILL.md) | 异步任务 / 队列 | RabbitMQ / Kafka / Bull / Celery / Sidekiq / Spring @Async |
| [error-handling-resilience](skills/error-handling-resilience/SKILL.md) | 重试 / 熔断 / 降级 | Resilience4j / Polly / opossum / tenacity |
| [auth-implementation](skills/auth-implementation/SKILL.md) | 认证鉴权实现 | Spring Security / NestJS Guards / Django Auth / FastAPI Depends |
| [observability](skills/observability/SKILL.md) | 日志 / 指标 / 追踪 | OpenTelemetry / Micrometer / Prometheus / Jaeger |
| [testing-implementation](skills/testing-implementation/SKILL.md) | 测试实现 | JUnit / Jest / pytest / Go testing / Pact 契约 |
| [code-quality](skills/code-quality/SKILL.md) | 代码质量 | SOLID / Lint / Code Review 标准 |
| [microservice-design](skills/microservice-design/SKILL.md) | 微服务架构设计 | 服务拆分 / 通信 / 网关 / 分布式事务 |

---

## 禁止行为

```text
❌ 不要在 API 契约不清时直接实现（会返工 50%）
❌ 不要把业务逻辑写在 Controller / Route Handler 里
❌ 不要用 ORM 默认懒加载导致 N+1
❌ 不要在事务内做 HTTP / 邮件 / 第三方调用
❌ 不要 catch Exception 后只记日志不抛
❌ 不要硬编码密钥、Token、密码、连接串
❌ 不要把内部错误信息暴露给前端
❌ 不要忽略幂等性（创建/支付/扣减接口必须幂等）
❌ 不要让接口没有超时（HTTP / DB / Redis 都要）
❌ 不要写没有单元测试的核心业务
❌ 不要日志输出 PII / Token / 密码
❌ 不要在生产代码里用 print / console.log / System.out
❌ 不要跳过 Code Review 直接合并
❌ 不要不打日志就发布
❌ 不要追新框架而不评估稳定性
❌ 不要跳过工作流交接和经验沉淀
```

---

## 任务复杂度分级

```text
S 级（10~30 分钟）：单端点 / 单字段修改 / 简单 Bug 修复
  → api-implementation + testing-implementation

M 级（30~120 分钟）：单功能模块（CRUD + 业务规则）
  → api-implementation + domain-modeling + data-access + auth-implementation + testing-implementation

L 级（2~6 小时）：多模块联动 / 跨服务集成 / 性能优化
  → 加 caching-strategy + async-jobs + error-handling-resilience + observability

XL 级（6 小时+）：核心服务 / 重构 / 架构演进
  → 全部 10 个 skills + code-quality 重点
```

---

## 通用质量检查

```text
□ API 契约完全实现（不多不少）
□ 业务逻辑在服务层，不在 Controller
□ 数据访问通过 Repository / DAO，不直接裸写 SQL
□ 所有外部调用有超时和重试策略
□ 写接口幂等（POST 创建 / 支付 / 扣减必须）
□ 错误码统一，不暴露内部细节
□ 认证鉴权按权限矩阵实现
□ 日志结构化 + 含 trace_id
□ 不输出敏感信息（密钥 / Token / PII）
□ 单元测试覆盖核心业务逻辑（≥ 70%）
□ 集成测试覆盖主路径
□ Code Review 通过
□ 不引入未审视的依赖
□ 性能验证（满足 SLA）
□ 与 QA / DevOps 交接清单完整
```

---

## 常见坑（跨 skill 通用）

```text
1. 业务逻辑写 Controller 里 → 难测、难复用
2. ORM 懒加载 N+1 → 性能崩溃
3. 事务包外部调用 → 长事务锁死
4. catch Exception 只 log 不 throw → 隐藏问题
5. 硬编码密钥 → 安全事故
6. 内部错误暴露给前端 → 信息泄露
7. 写接口无幂等 → 重复扣款
8. HTTP / DB 无超时 → 雪崩
9. 没单元测试就上线 → 回归慢
10. print / console.log / System.out 进生产 → 泄露 / 性能
11. 日志输出敏感信息 → 合规问题
12. 全局变量 / 单例滥用 → 测试难
13. 不跑 Lint / Format → 代码风格不一致
14. PR 不写描述 → Review 困难
15. 跳过 Code Review → Bug 进生产
16. 追新框架不评估生态 → 维护人少
```

具体 skill 内的坑见各 SKILL.md。

---

## 与其他工作流的协作

### 上游

| 上游工作流 | 后端需要的输入 |
|---|---|
| 产品经理工作流 | PRD、用户故事、验收标准、业务规则 |
| API 设计工作流 | OpenAPI 契约、错误码、Mock 数据 |
| 数据库工程师工作流 | DDL、索引、迁移说明、ORM 模型 |
| UI/UX 设计工作流 | 页面流程（理解前端调用顺序） |
| 项目经理工作流 | 任务拆解、里程碑、依赖 |

### 下游

| 下游工作流 | 后端交付内容 |
|---|---|
| 前端工程师工作流 | 实现的接口、Mock 升级为真实、错误码示例 |
| QA 工作流 | 接口文档、测试环境、可测性钩子 |
| 自动化测试工作流 | 单元 + 集成测试用例代码 |
| DevOps 工作流 | Dockerfile、配置、健康检查、迁移命令 |
| SRE 工作流 | 日志格式、关键指标、告警规则建议 |
| 安全工程师工作流 | 接口清单、依赖清单、权限点 |
| 技术文档工作流 | 接口实现说明、部署文档、运维手册 |

---

## 多任务与中断处理

```text
1. 多模块并行：每个独立分支 + 独立测试，避免冲突
2. 中途中断：保存当前进度（已完成端点 + 待实现 + 阻塞）
3. API 契约变更：先评估影响 → 同步前端 / QA → 重新实现
4. 紧急 Bug 修复：按 risk-based-testing 优先级抢占
```

---

## 自进化要求

任务完成后按 `EVOLUTION.md` 检查：

```text
是否形成新的实现模板？→ 加入对应 skill 的 templates/
是否发现新的反模式？→ 更新 pitfalls.md 和对应 skill
是否需要新增中间件 / 库？→ 更新 tool-index.md
是否需要补充缓存 / 异步 / 错误处理经验？→ 更新对应 skill
是否引入新框架？→ 更新技术栈选型矩阵
是否需要写入 field-journal？
是否需要新增 skill？→ 按 CONTRIBUTING.md 流程
```

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow backend-engineer
```

支持自动安装：Java JDK 17+、Maven、Gradle、Node.js、Python、Docker

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |
| 框架版本不兼容 | 检查 tool-index.json 确认推荐版本 |

---

## 相关参考

- `references/backend-frameworks-2026.md` — 16 个主流后端框架完整对比 + 性能基准 + 选型决策树 + 大厂案例
- `references/backend-tech-stack-guide.md` — 数据库 / 缓存 / 队列 / 网关 / 认证组件全景图
- `tool-index.json` — 机器可读工具索引（框架/ORM/认证/缓存/MQ/测试/可观测性）
