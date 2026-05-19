# API 设计工作流工具索引

## 1. 契约和文档工具

| 工具 | 用途 | 备注 |
|---|---|---|
| OpenAPI / Swagger | 描述端点、Schema、认证、示例和错误响应 | 主契约格式 |
| Swagger Editor | 编辑和预览 OpenAPI | 如项目已有则优先使用 |
| Swagger UI | 浏览 API 文档和试调 | 适合联调预览 |
| Redoc | 生成可读 API 文档 | 适合文档发布 |
| Markdown 表格 | 端点清单、错误码表、权限矩阵 | 与 OpenAPI 互补 |

---

## 2. Schema 和建模工具

| 工具 | 用途 |
|---|---|
| JSON Schema | 定义请求响应字段、类型、校验和示例 |
| Mermaid flowchart | 资源状态流转、业务流程 |
| Mermaid sequenceDiagram | 调用链、Webhook、异步任务流程 |
| Mermaid mindmap | 资源模型和模块关系 |

---

## 3. Mock 和联调工具

| 工具 | 用途 | 原则 |
|---|---|---|
| Postman | 接口集合、示例、联调 | 不替代契约设计 |
| Apifox | API 文档、Mock、测试集合 | 如项目已有优先使用 |
| Insomnia | API 调试和集合管理 | 可选 |
| Prism / WireMock | Mock Server | 不为一次性任务强制安装 |
| 项目已有 Mock 工具 | 前端独立联调 | 优先复用 |

---

## 4. 模板工具

| 模板 | 用途 | 位置 |
|---|---|---|
| API 设计 Brief 模板 | 澄清 API 输入、调用方、约束和待确认问题 | `templates/api-design-brief-template.md` |
| 资源模型模板 | 定义 REST 资源、关系、状态和生命周期 | `templates/resource-model-template.md` |
| 端点清单模板 | 汇总 method、path、权限、状态码、幂等和 Mock | `templates/endpoint-inventory-template.md` |
| 请求响应模板 | 定义参数、Body、响应字段、示例和校验 | `templates/request-response-template.md` |
| 错误码模板 | 设计 HTTP 状态码、业务错误码和调用方处理 | `templates/error-code-template.md` |
| 认证鉴权模板 | 角色、资源范围、租户、字段级权限矩阵 | `templates/auth-permission-template.md` |
| 分页筛选排序模板 | 统一分页、筛选、排序、搜索和字段选择 | `templates/pagination-filter-sort-template.md` |
| 版本变更模板 | 兼容变更、不兼容变更、弃用和迁移 | `templates/api-version-change-template.md` |
| 幂等重试模板 | 幂等键、重试安全、限流和并发冲突 | `templates/idempotency-retry-template.md` |
| Webhook/异步模板 | 事件、签名、重试、重放防护和状态查询 | `templates/webhook-async-template.md` |
| Mock 契约模板 | Mock 数据、Mock Server 和联调验收 | `templates/mock-contract-template.md` |
| OpenAPI 交接模板 | API 契约向前端、后端、QA、安全、文档交接 | `templates/openapi-handoff-template.md` |

---

## 5. 参考资料

| 资料 | 用途 | 位置 |
|---|---|---|
| 公开资料索引 | OpenAPI、HTTP、JSON Schema、OAuth 等公开来源 | `references/public-source-index.md` |
| API 方法指南 | API-first、契约优先、端点设计和交接方法 | `references/api-methods.md` |
| REST 资源建模指南 | 资源、子资源、集合、状态和动作例外 | `references/rest-resource-modeling-guide.md` |
| OpenAPI 风格指南 | tags、operationId、schemas、securitySchemes 和 examples | `references/openapi-style-guide.md` |
| 错误和权限指南 | HTTP 状态码、错误结构、认证鉴权和敏感字段 | `references/error-auth-guide.md` |
| 分页筛选排序指南 | offset、cursor、filter、sort、search、fields | `references/pagination-filter-sort-guide.md` |
| 版本兼容指南 | 兼容变更、破坏性变更、弃用和迁移 | `references/versioning-compatibility-guide.md` |
| 幂等重试指南 | Idempotency-Key、超时、限流、并发冲突 | `references/idempotency-retry-guide.md` |
| Webhook/异步指南 | 签名、事件 ID、重放防护、重试和任务状态 | `references/webhook-async-guide.md` |
| Mock 和交接指南 | Mock 数据、联调、契约验收和工作流交接 | `references/mock-handoff-guide.md` |

---

## 6. 脚本工具

| 脚本 | 用途 | 位置 |
|---|---|---|
| API 设计说明检查脚本 | 检查 API 设计说明是否包含核心章节 | `scripts/check-api-spec.ps1` |

---

## 7. 使用原则

```text
1. 优先使用项目已有 API 工具链，不为一次性检查安装新依赖。
2. OpenAPI 是机器可读契约，Markdown 是说明和交接，不要互相矛盾。
3. 先定义资源模型，再列端点。
4. 每个端点必须定义请求、响应、错误、权限和示例。
5. 错误码必须可恢复、可测试、可定位。
6. 认证、鉴权、租户和字段级权限要分开说明。
7. 分页、筛选、排序必须统一。
8. 创建、提交、支付、扣减类接口必须考虑幂等和重试。
9. Webhook 必须定义签名、事件 ID、重放防护和重试策略。
10. Mock 必须与 Schema 一致，并覆盖失败路径。
```
