# 请求响应设计指引（Request & Response Guide）

参考：JSON:API 规范、RFC 8259（JSON）、RFC 3339（时间）、Google AIP-141（数字字段）、AIP-148（标准字段）、Stripe API、GitHub REST API。

## 1. 命名风格

```text
路径：kebab-case            /user-profiles/{id}
字段：snake_case 或 camelCase（项目内统一）
布尔字段：is_/has_/can_ 前缀     ✅ is_active   ❌ active
时间字段：_at 后缀（时间点） / _on（日期）  ✅ created_at, due_on
ID 字段：_id 后缀                ✅ user_id, order_id
枚举：UPPER_SNAKE_CASE         ✅ PAYMENT_STATUS_PAID
```

不要混用：选定 snake_case 或 camelCase 后整个项目统一。

## 2. 字段类型规范

| 类型 | JSON 表示 | 注意事项 |
|---|---|---|
| 字符串 | string | 最大长度必须明确（防 DoS） |
| 整数 | number | JSON 安全整数上限 2^53-1，超出用 string（如订单号、雪花 ID） |
| 浮点 / 金额 | string（推荐）/ 整数最小单位（分） | 永远不用 float 表示金额 |
| 布尔 | boolean | 不用 0/1 |
| 时间 | string ISO 8601 | `2026-05-18T10:30:00Z`，统一 UTC |
| 日期 | string `YYYY-MM-DD` | - |
| 枚举 | string 大写 | 文档列出所有可能值 |
| ID | string | 即使内部是数字，对外也用 string（避免 JSON 精度问题） |
| 货币金额 | `{amount: 1099, currency: "USD"}` | Stripe 风格：分为单位的整数 |

## 3. 标准字段（建议每个资源都有）

```json
{
  "id": "ord_abc123",
  "object": "order",                    // 类型标记（Stripe 风格）
  "created_at": "2026-05-18T10:00:00Z",
  "updated_at": "2026-05-18T10:30:00Z",
  "version": 3                          // 乐观锁
}
```

## 4. 列表响应统一结构

```json
{
  "data": [...],
  "pagination": {
    "total": 152,
    "page": 1,
    "page_size": 20,
    "has_more": true,
    "next_cursor": "xxx"
  }
}
```

或 cursor 风格（Stripe）：

```json
{
  "object": "list",
  "data": [...],
  "has_more": true,
  "url": "/v1/orders"
}
```

## 5. 错误响应统一结构

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Field 'email' is invalid",
    "details": [
      {"field": "email", "code": "INVALID_FORMAT", "message": "..."}
    ],
    "request_id": "req_xxx"
  }
}
```

## 6. 字段稳定性约定

| 等级 | 含义 | 演进策略 |
|---|---|---|
| stable | 稳定字段 | 不可删 / 不可改类型 |
| beta | 早期访问 | 可能调整，需公告 |
| internal | 内部字段 | 默认不返回，需特殊权限 |
| deprecated | 已弃用 | 仍返回但标注，X 月后删除 |

OpenAPI 中用 `x-stability: stable` 或 `deprecated: true` 标注。

## 7. 可选字段 vs null

```text
推荐：永远返回字段，不存在时用 null
  ✅ {"phone": null}
  ❌ {}（缺少字段，前端要判断 hasOwnProperty）

例外：列表 / 嵌套对象，可省略空数组：
  ✅ {"items": []}
```

## 8. 校验规则

| 校验类型 | 实现 | 错误码 |
|---|---|---|
| 必填 | required | VALIDATION_ERROR |
| 格式 | regex / format | INVALID_FORMAT |
| 长度 | minLength / maxLength | LENGTH_OUT_OF_RANGE |
| 数值范围 | minimum / maximum | VALUE_OUT_OF_RANGE |
| 枚举 | enum | INVALID_ENUM |
| 跨字段 | 自定义 | LOGIC_VIOLATION |
| 业务唯一 | 数据库 | RESOURCE_CONFLICT |

## 9. 请求体设计原则

```text
1. 幂等性靠 Idempotency-Key Header（详见 idempotency-retry）
2. 大量字段考虑分组：
   {
     "basic": {...},
     "settings": {...},
     "metadata": {...}
   }
3. 批量操作明确上限（最大 100 条）
4. 写操作返回完整资源（节省一次 GET）
5. 不接受不认识的字段（strict mode）或忽略（lenient mode）—— 项目内统一
```

## 10. 响应设计原则

```text
1. 不暴露内部字段（DB 主键、内部状态、软删除标记）
2. 敏感字段按角色筛选（详见 auth-permission）
3. 大字段考虑独立端点（avatar_url 而非 avatar_base64）
4. 时间统一 UTC + ISO 8601
5. 不返回前端不需要的字段（用 fields 参数控制）
6. 嵌套深度不超过 3 层（超出考虑独立资源）
```

## 11. 大厂示例

### Stripe Charge（响应字段示例）
```json
{
  "id": "ch_xxx",
  "object": "charge",
  "amount": 2000,
  "currency": "usd",
  "created": 1716000000,
  "status": "succeeded",
  "metadata": {}
}
```
特点：`object` 类型标记、金额用最小单位整数、metadata 留扩展位。

### GitHub Issue
```json
{
  "id": 1234567890,
  "number": 42,
  "title": "...",
  "state": "open",
  "labels": [...],
  "assignee": null,
  "created_at": "2026-05-18T10:00:00Z"
}
```
特点：snake_case、null 显式返回、嵌套对象（labels）。

## 12. 自检清单

```text
□ 字段命名风格全项目统一
□ 时间字段统一 UTC + ISO 8601
□ ID 字段统一 string（不直接用 number）
□ 金额字段不用 float
□ 列表响应有 pagination 块
□ 错误响应有 error.code + error.message + request_id
□ 必填、可选、null 字段约定清楚
□ 大字段单独端点
□ 嵌套深度合理
□ OpenAPI Schema 与示例一致
```
