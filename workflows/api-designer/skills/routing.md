# API 设计 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "建模" / "资源怎么定义" | [resource-modeling](resource-modeling/SKILL.md) |
| "列接口" / "端点清单" | [endpoint-design](endpoint-design/SKILL.md) |
| "字段定义" / "请求响应" | [request-response](request-response/SKILL.md) |
| "错误码" / "状态码" | [error-handling](error-handling/SKILL.md) |
| "权限" / "鉴权" / "JWT/OAuth" | [auth-permission](auth-permission/SKILL.md) |
| "分页" / "筛选" / "排序" | [pagination-filtering](pagination-filtering/SKILL.md) |
| "版本" / "兼容" / "弃用" | [versioning](versioning/SKILL.md) |
| "幂等" / "重试" / "并发冲突" | [idempotency-retry](idempotency-retry/SKILL.md) |
| "Webhook" / "异步" / "回调" | [webhook-async](webhook-async/SKILL.md) |
| "OpenAPI" / "Swagger" / "Mock" | [openapi-mock](openapi-mock/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单端点设计（S 级） | endpoint-design + request-response |
| CRUD 模块（M 级） | resource-modeling + endpoint-design + request-response + error-handling + auth-permission + pagination-filtering + openapi-mock |
| 复杂业务模块（L 级） | 全部 10 个 skills |
| 平台级 API（XL 级） | 全部 + versioning 重点 + webhook-async |
| 后台管理 API | resource-modeling + endpoint-design + auth-permission + pagination-filtering + error-handling |
| 开放 API | 全部 + 重点 versioning + auth-permission（OAuth）+ webhook-async |
| 支付/订单 API | + idempotency-retry 重点 |
| 异步任务 API | + webhook-async 重点 |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 10~30min | endpoint-design + request-response |
| M | 30~90min | + resource-modeling + error-handling + auth-permission + openapi-mock |
| L | 1~3h | + pagination-filtering + idempotency-retry + webhook-async |
| XL | 3h+ | 全部 + versioning |

## 路径交叉

```text
新功能模块 API 设计：
  resource-modeling（建模）
  → endpoint-design（端点）
  → request-response（结构）
  → error-handling（错误）
  → auth-permission（权限）
  → pagination-filtering（如有列表）
  → openapi-mock（输出）

支付/扣减类 API：
  resource-modeling（建模）
  → endpoint-design（端点）
  → idempotency-retry（重点：幂等键）
  → error-handling（业务错误码）
  → openapi-mock（输出）

第三方集成 API：
  webhook-async（事件订阅）
  → auth-permission（API Key / OAuth）
  → versioning（兼容策略）
  → openapi-mock（公开文档）

API 升级：
  versioning（评估变更）
  → endpoint-design（新端点 / 弃用旧的）
  → openapi-mock（更新文档）
```

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增。
