# 后端工程师工具索引

## 使用原则

1. 优先复用当前项目已有工具链。
2. 不为一次性任务引入新依赖。
3. 涉及生产、数据、安全时先确认影响面和回滚路径。
4. 工具缺失时先检查本文件和根 `../../tool-index.md`。
5. 不写死密钥、Token、密码、连接串。

## 核心工具

详见 `references/backend-frameworks-2026.md` 和 `references/backend-tech-stack-guide.md`。

### 框架

| 语言 | 框架 | 适合 |
|---|---|---|
| Java/Kotlin | Spring Boot 3 | 企业级 |
| TypeScript | NestJS / Fastify / Hono | 中大型 TS |
| Python | FastAPI / Django | AI / CRUD |
| Go | Gin / Fiber | 高并发 |
| C# | ASP.NET Core | 企业级 |
| Ruby | Rails | 快速 MVP |
| PHP | Laravel | PHP 生态 |

### ORM

| 语言 | 方案 |
|---|---|
| Java | JPA/Hibernate / jOOQ / MyBatis |
| TS | Prisma / TypeORM / Drizzle / Kysely |
| Python | SQLAlchemy / Django ORM |
| Go | GORM / Ent / sqlc |
| Ruby | ActiveRecord |
| C# | EF Core |

### 测试

| 类型 | 工具 |
|---|---|
| 单元 | JUnit 5 / Jest / Vitest / pytest / Go testing |
| 集成 | Testcontainers / WireMock / MockServer |
| 契约 | Pact / Spring Cloud Contract |
| 性能 | k6 / JMeter / Locust |

### 可观测

| 类型 | 工具 |
|---|---|
| 追踪 | OpenTelemetry / Jaeger / Datadog APM |
| 日志 | ELK / Loki / Datadog Logs |
| 指标 | Prometheus + Grafana / Datadog |
| 错误 | Sentry |

### 缓存 / 队列

| 类型 | 工具 |
|---|---|
| 缓存 | Redis / Memcached / Caffeine |
| 队列 | RabbitMQ / Kafka / BullMQ / Celery / Asynq |
| 工作流 | Temporal |

### 认证

| 类型 | 工具 |
|---|---|
| 自建 | Spring Security / NestJS Guards / Django Auth |
| SaaS | Auth0 / Clerk / Supabase Auth / Keycloak |
| 权限 | Casbin / CASL |

### 代码质量

| 类型 | 工具 |
|---|---|
| Lint | ESLint / Checkstyle / pylint / golangci-lint |
| Format | Prettier / Black / gofmt |
| 静态分析 | SonarQube / Semgrep |
| 安全扫描 | Snyk / Dependabot / Trivy |

## 模板入口

各 skill 的模板在 `skills/<skill-name>/templates/`。

## 参考资料入口

- `references/backend-frameworks-2026.md` — 16 个框架完整对比
- `references/backend-tech-stack-guide.md` — 15 类组件全景

## 脚本入口

| 脚本 | 用途 |
|---|---|
| `scripts/README.md` | 后续自动化脚本 |

## 高风险工具边界

以下操作必须先确认授权、备份和回滚：
- 生产数据库操作
- 密钥 / Token 轮换
- 依赖大版本升级
- 框架迁移
