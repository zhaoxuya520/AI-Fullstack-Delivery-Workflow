# 错误码设计模板

## 1. 错误结构

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "资源不存在",
    "details": [],
    "requestId": "req_xxx"
  }
}
```

---

## 2. 错误码表

| HTTP Status | Error Code | Message | 触发条件 | 调用方处理 | 是否可重试 | 日志/追踪 |
|---|---|---|---|---|---|---|
| 400 | VALIDATION_ERROR | 参数校验失败 | 请求字段无效 | 高亮错误字段 | 否 | requestId |
| 401 | UNAUTHORIZED | 未认证 | Token 缺失或无效 | 引导登录 | 否 | requestId |
| 403 | FORBIDDEN | 无权限 | 无资源权限 | 隐藏或禁用入口 | 否 | requestId |
| 404 | RESOURCE_NOT_FOUND | 资源不存在 | ID 不存在或不可见 | 展示不存在状态 | 否 | requestId |
| 409 | RESOURCE_CONFLICT | 资源冲突 | 状态或版本冲突 | 刷新后重试 | 视场景 | requestId |
| 429 | RATE_LIMITED | 请求过于频繁 | 触发限流 | 等待后重试 | 是 | requestId |
| 500 | INTERNAL_ERROR | 服务异常 | 未预期错误 | 稍后重试或联系支持 | 是 | requestId |

---

## 3. 字段级错误

| 字段 | Error Code | Message | 修正建议 |
|---|---|---|---|
|  |  |  |  |

---

## 4. 错误设计原则

```text
错误码稳定，不随文案变化。
message 可展示给用户时必须清晰可恢复。
debug 信息不能包含敏感数据。
所有错误响应都带 requestId 或 traceId。
```
