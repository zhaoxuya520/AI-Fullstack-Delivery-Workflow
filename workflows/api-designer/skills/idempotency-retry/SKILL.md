---
name: idempotency-retry
description: 设计幂等接口和重试策略时使用。适用于支付、扣减、订单、关键写操作。优先使用 Idempotency-Key + 业务去重键 + 并发冲突处理（ETag/版本号）。
---

# 幂等、重试和并发

参考来源：[Stripe Idempotency](https://stripe.com/docs/idempotency)、[GitHub API Conditional Requests](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#conditional-requests)

## 适用场景

- 支付 / 扣减 / 转账接口
- 订单创建 / 提交 / 审批
- 关键的写操作
- 高并发场景的并发冲突
- 限流和重试设计

## 核心问题

```text
问题：网络不可靠，客户端重试会重复创建/扣款

例：
  1. 客户端 POST /charge 扣款 100 元
  2. 服务端处理成功，返回响应中
  3. 网络中断，客户端没收到响应
  4. 客户端重试 POST /charge → 又扣 100 元
  5. 用户被扣 200 元 ❌
```

## 幂等性

```text
幂等：多次执行相同请求，结果一致

天然幂等：
  - GET（查询）
  - PUT（完全替换，结果一致）
  - DELETE（删除一次后再删返回 404 或 204）

非幂等：
  - POST（每次创建新资源）
  - PATCH（部分更新，多次执行可能不同）

需要设计幂等的：
  - POST 创建（订单、支付、扣减）
  - 触发动作（POST /orders/{id}/refund）
```

## Idempotency-Key 模式（Stripe 风格）

```text
请求：
POST /charges
Idempotency-Key: <uuid-generated-by-client>

服务端逻辑：
1. 收到请求，提取 Idempotency-Key
2. 检查 (Idempotency-Key, endpoint) 是否已处理过
   - 已处理 → 返回上次的响应（不再执行）
   - 未处理 → 处理 + 存储 (key, response)
3. 重复请求都返回同一响应

存储期限：通常 24 小时

客户端责任：
  - 每个独立操作生成唯一 Key
  - 重试时复用同一 Key（关键！）
  - Key 通常用 UUID v4
```

## 业务去重键（替代方案）

```text
某些场景天然有业务去重键：

订单去重：
  POST /orders
  Body: { "user_id": "usr_1", "external_order_id": "shop_order_123" }
  服务端用 (user_id, external_order_id) 去重

支付去重：
  POST /payments
  Body: { "order_id": "ord_1", "amount": 100 }
  服务端用 (order_id) 去重（一个订单只能支付一次）

优点：业务规则天然防重
缺点：需要业务字段支持
```

## 并发冲突处理

### 1. ETag / If-Match（乐观锁）

```text
读取资源：
GET /users/{id}
→ Header: ETag: "v123"
→ Body: { ... }

更新资源：
PATCH /users/{id}
Header: If-Match: "v123"
Body: { "name": "新名字" }

服务端逻辑：
- 检查 ETag 是否匹配当前版本
- 不匹配 → 409 Conflict
- 匹配 → 更新 + 生成新 ETag

错误响应：
HTTP 409 Conflict
{
  "code": "version_conflict",
  "message": "Resource has been modified by another request",
  "current_etag": "v124"
}
```

### 2. version 字段（数据库乐观锁）

```text
请求：
PATCH /users/{id}
Body: {
  "name": "新名字",
  "version": 5
}

服务端：
UPDATE users SET name = ?, version = version + 1
WHERE id = ? AND version = 5

如果影响行数 = 0 → 冲突 → 返回 409
```

### 3. 锁（悲观锁）

```text
适用：竞争激烈的资源

实现：
- Redis 锁（SET NX EX）
- 数据库行锁（SELECT FOR UPDATE）

API 层：
- 通常不暴露锁
- 内部实现处理
```

## 重试策略

### 客户端重试

```text
什么情况可以重试：
  ✅ 网络错误（连接超时、断开）
  ✅ 5xx 错误
  ✅ 429 Too Many Requests（按 Retry-After）

什么情况不可以重试：
  ❌ 4xx（客户端错误，重试也是错的）
  ❌ 业务错误（如余额不足）

指数退避：
  第 1 次失败：等待 1s
  第 2 次失败：等待 2s
  第 3 次失败：等待 4s
  第 N 次失败：等待 min(2^N, max_delay)
  
  + 抖动（避免雪崩）：等待 ± 30% 随机
  
最大重试次数：3~5 次
```

### 服务端 Retry-After

```text
HTTP 429 Too Many Requests
Retry-After: 60          ← 秒数
或：
Retry-After: Wed, 21 Oct 2026 07:28:00 GMT  ← HTTP-date

HTTP 503 Service Unavailable
Retry-After: 120

客户端必须遵循 Retry-After
```

### 限流相关

```text
Rate Limit Headers（GitHub 风格）：
X-RateLimit-Limit: 100        ← 限制
X-RateLimit-Remaining: 75     ← 剩余
X-RateLimit-Reset: 1611331200 ← 重置时间（Unix）
X-RateLimit-Reset-After: 60   ← 多少秒后重置

或自定义：
Retry-After: 60
```

## 完整设计示例

```markdown
## 支付接口幂等设计

### 接口
POST /payments

### 请求
Headers:
  Idempotency-Key: <uuid>     ← 必须

Body:
{
  "order_id": "ord_123",
  "amount": 9999,
  "currency": "CNY",
  "method": "wechat"
}

### 双重防护
1. Idempotency-Key（客户端层）
2. order_id 去重（业务层）

### 服务端逻辑
1. 提取 Idempotency-Key
2. 检查 redis：key=idem:<key>:payments
   - 存在 → 返回缓存响应
   - 不存在 → 继续
3. 检查业务去重：order_id 是否已支付
   - 已支付 → 返回已存在的支付记录
   - 未支付 → 继续
4. 处理支付
5. 缓存响应（24h）+ 返回

### 错误响应
HTTP 409 Conflict
{
  "code": "duplicate_payment",
  "message": "Payment for this order already exists",
  "existing_payment_id": "pay_xxx"
}

### 客户端重试
- 网络错误：相同 Idempotency-Key 重试
- 5xx：相同 Idempotency-Key 重试
- 200/201：完成
- 4xx：不重试
- 409 duplicate_payment：使用 existing_payment_id
```

## 工作流程

```text
1. 识别需要幂等的端点
   - 创建：POST /resources
   - 触发动作：POST /resources/{id}/action
   - 涉及金额/扣减/审批的操作

2. 选择幂等机制
   - Idempotency-Key（通用）
   - 业务去重键（如有自然 ID）

3. 识别需要并发控制的端点
   - 多人编辑同一资源
   - 库存扣减

4. 选择并发机制
   - ETag / If-Match
   - version 字段
   - 锁

5. 设计重试策略
   - Retry-After
   - Rate Limit Headers
   - 客户端指数退避建议

6. 写入文档：
   - 哪些端点支持 Idempotency-Key
   - 哪些必须传 Idempotency-Key
   - 重试策略
   - 限流策略
```

## 质量自检

```text
□ POST 创建/扣减接口是否有幂等设计
□ Idempotency-Key 是否必填还是可选
□ 服务端是否真的实现了幂等存储
□ 是否同时有业务去重键（双重防护）
□ 并发冲突是否有处理（ETag / version）
□ 限流是否返回 Retry-After
□ Rate Limit Headers 是否完整
□ 文档是否说明哪些错误可重试
```

## 常见坑

1. **POST 创建无幂等**——网络抖动重复扣款
2. **Idempotency-Key 服务端不存储**——无效的"伪幂等"
3. **Key 复用太严**——不同操作用同一 Key 互相干扰
4. **不同 Key 但重复请求**——客户端每次都生成新 Key（应该重试用同一 Key）
5. **限流不返回 Retry-After**——客户端不知道何时重试
6. **5xx 不重试**——服务端临时问题不应让用户失败
7. **重试无指数退避**——立即重试导致雪崩
8. **没有最大重试次数**——无限重试

## 配套模板

- `templates/idempotency-retry-template.md` — 幂等设计 + 重试策略 + 限流规范模板

## 与其他 skill 的协作

```text
上游：
  endpoint-design → 标注哪些端点需要幂等

平行：
  error-handling → 409 Conflict / 429 错误码
  request-response → Idempotency-Key Header

下游：
  openapi-mock → OpenAPI 中标注幂等
  转交后端 → 实现幂等存储和并发控制
```
