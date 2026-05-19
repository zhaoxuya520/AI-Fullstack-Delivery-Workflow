# API 文档模板

## 基本信息

| 项目 | 说明 |
|------|------|
| 服务名 | `{{service_name}}` |
| Base URL | `{{base_url}}` |
| API 版本 | `{{version}}` |
| 认证方式 | `{{auth_type}}` |
| 最后更新 | `{{last_updated}}` |

---

## 认证

```text
方式：Bearer Token
获取方式：POST /auth/token
Header：Authorization: Bearer <token>
Token 有效期：{{token_ttl}}
```

---

## 端点列表

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/v1/{{resource}} | 获取列表 |
| GET | /api/v1/{{resource}}/:id | 获取详情 |
| POST | /api/v1/{{resource}} | 创建 |
| PUT | /api/v1/{{resource}}/:id | 更新 |
| DELETE | /api/v1/{{resource}}/:id | 删除 |

---

## 端点详情

### GET /api/v1/{{resource}}

**说明**：获取 {{resource}} 列表

**请求参数**：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| page_size | int | 否 | 20 | 每页条数（最大 100） |
| sort | string | 否 | created_at | 排序字段 |
| order | string | 否 | desc | 排序方向：asc / desc |

**请求示例**：

```bash
curl -X GET "{{base_url}}/api/v1/{{resource}}?page=1&page_size=20" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json"
```

**成功响应（200）**：

```json
{
  "data": [
    {
      "id": "abc123",
      "name": "示例名称",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 42,
    "total_pages": 3
  }
}
```

**错误响应**：

| 状态码 | 错误码 | 说明 | 解决方案 |
|--------|--------|------|----------|
| 401 | UNAUTHORIZED | Token 无效或过期 | 重新获取 Token |
| 403 | FORBIDDEN | 无权限访问该资源 | 确认角色权限 |
| 429 | RATE_LIMITED | 请求频率超限 | 等待后重试，参考 Retry-After 头 |

---

## 错误码总览

| HTTP 状态码 | 错误码 | 含义 | 常见原因 |
|-------------|--------|------|----------|
| 400 | INVALID_PARAM | 参数校验失败 | 参数类型错误 / 缺少必填项 |
| 401 | UNAUTHORIZED | 认证失败 | Token 过期 / 格式错误 |
| 403 | FORBIDDEN | 权限不足 | 角色无对应权限 |
| 404 | NOT_FOUND | 资源不存在 | ID 错误 / 已删除 |
| 409 | CONFLICT | 资源冲突 | 重复创建 / 并发修改 |
| 422 | VALIDATION_ERROR | 业务校验失败 | 不满足业务规则 |
| 429 | RATE_LIMITED | 限流 | 超过 QPS 限制 |
| 500 | INTERNAL_ERROR | 服务端错误 | 联系开发排查 |

---

## 限流说明

```text
默认限制：100 请求/分钟/用户
响应头：
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 87
  X-RateLimit-Reset: 1705312800
超限处理：返回 429 + Retry-After 头
```

---

## 版本变更记录

| 版本 | 日期 | 变更内容 | 是否 Breaking |
|------|------|----------|---------------|
| v1.2 | 2024-01-15 | 新增分页参数 | 否 |
| v1.1 | 2024-01-01 | 修改响应格式 | 是 |
