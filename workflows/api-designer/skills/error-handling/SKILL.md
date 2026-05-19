---
name: error-handling
description: 设计 API 错误码和错误结构时使用。适用于错误响应规范、调用方错误处理、调试可观测。优先使用 RFC 7807 Problem Details + 业务错误码 + 调用方处理建议。
---

# 错误码设计

参考来源：[RFC 7807 Problem Details](https://www.rfc-editor.org/rfc/rfc7807)、Stripe / GitHub API 错误规范

## 适用场景

- API 错误响应结构设计
- 错误码体系建立
- 给调用方的错误处理指南
- 调试和可观测性

## 核心原则

```text
1. 错误必须能指导调用方恢复
   不只是说"出错了"，要说"怎么办"

2. 区分 HTTP 状态码和业务错误码
   HTTP：协议层级错误（认证、格式、服务器）
   业务码：业务逻辑层级错误（库存不足、状态不允许）

3. 不要 200 包装错误
   破坏 HTTP 语义

4. 不要泄露敏感信息
   错误信息不能暴露内部架构
```

## 错误响应标准结构（RFC 7807）

```json
{
  "type": "https://api.example.com/errors/insufficient_funds",
  "title": "Insufficient Funds",
  "status": 402,
  "detail": "Your account balance is insufficient for this operation.",
  "instance": "/orders/123",
  "code": "insufficient_funds",
  "trace_id": "req_abc123",
  "errors": [
    {
      "field": "amount",
      "message": "Amount exceeds available balance",
      "current_balance": 50.00,
      "required": 100.00
    }
  ]
}
```

## 简化结构（推荐）

```json
{
  "code": "insufficient_funds",
  "message": "Your account balance is insufficient",
  "trace_id": "req_abc123",
  "details": {
    "current_balance": 50.00,
    "required": 100.00
  }
}
```

## 错误必备字段

```text
1. code（业务错误码）
   - 字符串，下划线命名
   - 例：insufficient_funds / invalid_email / order_not_found

2. message（用户可见信息）
   - 简短可读
   - 中文项目用中文
   - 不暴露技术细节

3. trace_id（追踪 ID）
   - 用于客服 / 工程师查日志
   - 必须有

4. details（详细信息，可选）
   - 字段级错误（表单校验）
   - 上下文数据（库存数量、当前余额）
```

## HTTP 状态码 vs 业务错误码

```text
HTTP 状态码（粗粒度）：
  400 Bad Request - 请求格式错误
  401 Unauthorized - 未认证
  403 Forbidden - 无权限
  404 Not Found - 资源不存在
  409 Conflict - 冲突
  422 Unprocessable - 校验失败
  429 Too Many Requests - 限流

业务错误码（细粒度）：
  在同一个 HTTP 状态码下区分具体原因

  HTTP 422 + code:
    - "invalid_email"
    - "weak_password"
    - "username_taken"

  HTTP 409 + code:
    - "duplicate_order"
    - "concurrent_modification"
    - "resource_locked"
```

## 错误码命名规范

```text
风格：snake_case
长度：≤ 30 字符
结构：[资源]_[原因] 或 [原因]

示例：
  ✅ insufficient_funds
  ✅ order_not_found
  ✅ invalid_email
  ✅ rate_limit_exceeded
  ✅ payment_method_required

  ❌ ERR001（无语义）
  ❌ Error.InsufficientFunds（驼峰）
  ❌ NSF（缩写难懂）
```

## 表单校验错误（多字段）

```json
HTTP 422 Unprocessable Entity

{
  "code": "validation_failed",
  "message": "Request validation failed",
  "trace_id": "req_abc123",
  "errors": [
    {
      "field": "email",
      "code": "invalid_format",
      "message": "邮箱格式不正确"
    },
    {
      "field": "password",
      "code": "too_short",
      "message": "密码至少 8 位",
      "min_length": 8,
      "actual_length": 5
    }
  ]
}
```

## 限流错误（必备字段）

```json
HTTP 429 Too Many Requests
Retry-After: 60

{
  "code": "rate_limit_exceeded",
  "message": "Rate limit exceeded. Retry after 60 seconds.",
  "trace_id": "req_abc123",
  "limit": 100,
  "remaining": 0,
  "reset_at": "2026-01-15T10:31:00Z"
}
```

## 错误码表

```markdown
## 错误码表：[模块名]

| HTTP | 业务码 | 触发条件 | 用户提示 | 调用方处理 | 可重试 |
|------|--------|---------|---------|-----------|--------|
| 400 | invalid_email | 邮箱格式错误 | "邮箱格式不正确" | 检查并提示用户 | ❌ |
| 401 | token_expired | Token 过期 | "登录已过期" | 引导重新登录 | ❌ |
| 401 | token_invalid | Token 无效 | "登录信息异常" | 引导重新登录 | ❌ |
| 403 | permission_denied | 无权限 | "无权访问" | 提示联系管理员 | ❌ |
| 404 | order_not_found | 订单不存在 | "订单不存在" | 检查 ID 或刷新列表 | ❌ |
| 409 | duplicate_order | 重复创建 | "订单已存在" | 提示重复，跳转到已有订单 | ❌ |
| 422 | validation_failed | 字段校验失败 | 见 errors 字段 | 高亮错误字段 | ❌ |
| 429 | rate_limit_exceeded | 调用过频 | "请稍后再试" | 按 Retry-After 等待重试 | ✅ |
| 500 | internal_error | 服务异常 | "系统异常，请稍后" | 显示通用错误 + 重试 | ✅ |
| 503 | service_unavailable | 服务不可用 | "服务繁忙" | 显示通用错误 + 重试 | ✅ |
| 402 | insufficient_funds | 余额不足 | "余额不足" | 引导充值 | ❌ |
| 409 | order_already_paid | 订单已支付 | "订单已支付" | 跳转到订单详情 | ❌ |
| 410 | resource_deleted | 资源已删除 | "资源不存在" | 返回列表 | ❌ |
```

## 工作流程

```text
1. 列出端点清单
2. 对每个端点列出可能的失败场景
3. 对每个失败场景：
   - 选 HTTP 状态码
   - 设计业务错误码（snake_case）
   - 写用户可见消息
   - 写调用方处理建议
   - 标注是否可重试
4. 输出错误码表
5. 在 OpenAPI 中定义错误响应 Schema
```

## 质量自检

```text
□ HTTP 状态码使用正确
□ 业务错误码命名规范（snake_case）
□ 每个错误码有触发条件说明
□ 每个错误码有用户提示
□ 每个错误码有调用方处理建议
□ 是否标注了可重试
□ 表单校验返回字段级错误
□ 限流返回 Retry-After 和限额信息
□ 错误信息不泄露内部架构
□ 所有错误都有 trace_id
```

## 常见坑

1. **200 包装错误**——HTTP 200 + body 里 success: false
2. **错误信息只有英文**——中文项目用户看不懂
3. **trace_id 缺失**——无法排查
4. **限流返回 429 但没 Retry-After**——客户端不知道何时重试
5. **校验失败只返回 1 条**——有 5 个错误字段只看到 1 个
6. **错误信息暴露技术细节**——"Database connection failed"
7. **不区分 401 和 403**——已登录但无权限返回 401
8. **404 隐藏权限**（隐私考虑）但不一致

## 配套模板

- `templates/error-code-template.md` — 错误码表 + 错误响应结构模板

## 与其他 skill 的协作

```text
上游：
  endpoint-design → 端点清单
  request-response → 校验规则触发的错误

平行：
  auth-permission → 401/403 错误细分
  idempotency-retry → 重试相关错误（409/429）

下游：
  openapi-mock → 错误响应写入 OpenAPI
  转交前端 → 错误处理实现
  转交 QA → 错误场景测试
```
