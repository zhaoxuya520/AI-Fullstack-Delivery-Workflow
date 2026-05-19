# API 设计 Skills 总控

本目录收录 API 设计工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [resource-modeling](resource-modeling/SKILL.md) | REST 资源建模 | REST 架构 + Roy Fielding |
| [endpoint-design](endpoint-design/SKILL.md) | 端点设计 | RFC 7231 / GitHub REST Guidelines |
| [request-response](request-response/SKILL.md) | 请求响应结构 | JSON:API / OpenAPI |
| [error-handling](error-handling/SKILL.md) | 错误码设计 | RFC 7807 Problem Details |
| [auth-permission](auth-permission/SKILL.md) | 认证鉴权 | OAuth 2.0 / RBAC |
| [pagination-filtering](pagination-filtering/SKILL.md) | 分页筛选排序 | Stripe / GitHub 风格 |
| [versioning](versioning/SKILL.md) | API 版本管理 | Stripe 版本策略 |
| [idempotency-retry](idempotency-retry/SKILL.md) | 幂等和重试 | Stripe Idempotency |
| [webhook-async](webhook-async/SKILL.md) | Webhook 和异步 | Stripe Webhooks / SVIX |
| [openapi-mock](openapi-mock/SKILL.md) | OpenAPI 契约和 Mock | OpenAPI 3.1 |

## 统一入口

1. 先读 `routing.md` — 按 API 任务路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到需求 → 先建模
   - resource-modeling（资源建模）

2. 设计端点 → 列清单
   - endpoint-design（端点设计）
   - request-response（请求响应）

3. 处理错误和权限
   - error-handling（错误码）
   - auth-permission（认证鉴权）

4. 高级功能
   - pagination-filtering（分页筛选）
   - idempotency-retry（幂等重试）
   - webhook-async（异步通信）

5. 输出和演进
   - openapi-mock（OpenAPI + Mock）
   - versioning（版本管理）
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成 API 设计任务后，回写经验到 `../field-journal/`。
