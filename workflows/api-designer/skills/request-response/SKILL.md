---
name: request-response
description: 设计请求和响应结构时使用。适用于字段定义、校验规则、响应格式。优先使用 JSON:API 风格 + 字段稳定性 + 完整校验规则。
---

# 请求响应结构

## 适用场景

- 端点的请求字段设计
- 响应字段定义
- 校验规则编写
- 字段命名规范

## 核心原则

```text
1. 字段稳定性
   公开字段一旦发布不能轻易改语义
   能扩展，不能删

2. 字段含义清晰
   命名见名知意，不需要查文档

3. 命名一致
   全 API 用同一种风格（snake_case 或 camelCase）

4. 默认不返回敏感信息
   密码哈希、内部 ID、调试信息默认不返回
```

## 请求结构

### Path 参数（资源标识）

```text
GET /users/{user_id}/orders/{order_id}

- user_id: string (UUID)
- order_id: string (UUID)
```

### Query 参数（筛选/分页/选项）

```text
GET /users?page=1&page_size=20&status=active&sort=-created_at

- page: integer, default=1
- page_size: integer, default=20, max=100
- status: enum [active, inactive, banned]
- sort: string, prefix - means desc
- keyword: string, optional
```

### Header（横切信息）

```text
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
Idempotency-Key: <uuid>      # POST 时
X-Request-Id: <trace-id>     # 追踪
If-Match: "<etag>"           # 并发控制
Accept-Language: zh-CN
```

### Body（创建/修改数据）

```json
POST /users
Content-Type: application/json

{
  "email": "user@example.com",
  "name": "张三",
  "phone": "+8613800138000",
  "metadata": {
    "source": "web"
  }
}
```

## 校验规则

每个字段必须定义：

```text
- 类型（string / integer / boolean / array / object）
- 必填 / 可选
- 长度限制（min/max）
- 范围限制（min/max for numbers）
- 格式（email / url / uuid / date / regex）
- 枚举值
- 默认值（如有）
- 跨字段规则（如 password === password_confirm）
```

### OpenAPI 校验示例

```yaml
properties:
  email:
    type: string
    format: email
    minLength: 5
    maxLength: 100
    required: true
  age:
    type: integer
    minimum: 0
    maximum: 150
    required: false
  status:
    type: string
    enum: [active, inactive, banned]
    default: active
  tags:
    type: array
    items:
      type: string
    minItems: 0
    maxItems: 10
    uniqueItems: true
```

## 响应结构

### 单资源响应

```json
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "张三",
  "created_at": "2026-01-15T10:30:00Z",
  "updated_at": "2026-01-15T10:30:00Z"
}
```

### 列表响应（推荐结构）

```json
{
  "data": [
    { "id": "usr_001", "name": "张三" },
    { "id": "usr_002", "name": "李四" }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 156,
    "total_pages": 8
  }
}
```

### 嵌套关系（避免过度嵌套）

```json
{
  "id": "ord_001",
  "user": {
    "id": "usr_123",
    "name": "张三"
  },
  "items": [
    { "id": "itm_001", "product_id": "prd_a", "quantity": 2 }
  ],
  "total": 199.50,
  "status": "paid"
}
```

不要超过 3 层嵌套，超过用 ID + 单独 GET。

## 字段命名规范

```text
风格选一种坚持：
  snake_case：created_at, user_id, total_amount（推荐，可读性强）
  camelCase：createdAt, userId, totalAmount

ID 字段：
  - 前缀化：usr_abc123 / ord_xyz789（Stripe 风格）
  - 或纯 UUID：550e8400-e29b-41d4-a716-446655440000

时间字段：
  - 永远 ISO 8601 + UTC：2026-01-15T10:30:00Z
  - 不要 Unix 时间戳（除非性能极致需求）
  - 不要本地时间（时区混乱）

布尔字段：
  - is_active / has_subscription（is/has 前缀）
  - 不要 active = 1（混淆类型）

枚举：
  - 字符串：status: "active"
  - 不要数字：status: 1
```

## 字段稳定性策略

```text
新增字段（兼容）：
  - 客户端忽略未知字段
  - 老客户端不受影响

删除字段（不兼容）：
  - 必须升级版本
  - 不能直接删

改字段类型（不兼容）：
  - 必须升级版本

改字段语义（不兼容）：
  - 必须升级版本
  - 即使字段名不变

废弃字段：
  - 在响应中保留但标注 deprecated
  - 提供新字段
  - 在 OpenAPI 文档标注
```

## 输出格式

```markdown
## 请求响应：POST /users

### 请求

**Headers**：
```
Authorization: Bearer <token>
Content-Type: application/json
Idempotency-Key: <uuid>
```

**Body**：
```json
{
  "email": "user@example.com",
  "name": "张三",
  "phone": "+8613800138000"
}
```

**字段定义**：

| 字段 | 类型 | 必填 | 校验 | 说明 |
|------|------|------|------|------|
| email | string | ✅ | email format, max 100 | 邮箱 |
| name | string | ✅ | 1~50 chars | 姓名 |
| phone | string | ❌ | E.164 format | 手机号 |

### 响应（成功 201）

```json
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "张三",
  "phone": "+8613800138000",
  "status": "active",
  "created_at": "2026-01-15T10:30:00Z",
  "updated_at": "2026-01-15T10:30:00Z"
}
```

**字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 用户 ID（usr_ 前缀） |
| status | enum | active / inactive / banned |
| created_at | ISO 8601 | UTC 时间 |
```

## 工作流程

```text
1. 读取端点清单（来自 endpoint-design）
2. 对每个端点定义请求结构
3. 定义所有字段的类型 / 校验
4. 定义响应结构（成功 + 失败）
5. 检查字段命名一致性
6. 检查时间格式 / 布尔 / 枚举规范
7. 输出请求响应说明
```

## 质量自检

```text
□ 字段命名风格一致（不混用 snake/camel）
□ 时间字段 ISO 8601 + UTC
□ 布尔用 true/false 不用 1/0
□ 枚举用字符串不用数字
□ 必填字段标注清楚
□ 校验规则完整（类型/长度/范围/格式）
□ 响应不返回敏感字段（密码哈希等）
□ 列表响应有分页信息
□ 嵌套不超过 3 层
```

## 常见坑

1. **命名混用**——createdAt 和 created_at 同时出现
2. **时间格式不一**——有的 Unix 时间戳，有的 ISO 8601
3. **布尔用 1/0**——增加客户端解析成本
4. **POST 后只返回 id**——前端被迫再 GET
5. **列表无 total**——前端无法精确分页
6. **敏感字段泄露**——password_hash 在响应里
7. **字段命名不见名知意**——data1 / val / field2
8. **过度嵌套**——5 层嵌套，前端解析困难

## 配套模板

- `templates/request-response-template.md` — 请求结构 + 响应结构 + 校验规则模板

## 与其他 skill 的协作

```text
上游：
  endpoint-design → 提供端点清单
  resource-modeling → 提供资源结构

平行：
  error-handling → 错误响应结构
  pagination-filtering → 列表响应结构

下游：
  openapi-mock → 写入 OpenAPI Schema
```

## 相关参考

- `references/request-response-guide.md` — 命名风格、字段类型规范、标准字段、列表/错误统一结构、字段稳定性、可选字段 vs null、校验规则、大厂示例（Stripe Charge / GitHub Issue）
