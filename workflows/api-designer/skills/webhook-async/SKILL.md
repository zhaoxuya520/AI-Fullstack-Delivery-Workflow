---
name: webhook-async
description: 设计 Webhook 和异步 API 时使用。适用于事件订阅、长任务、第三方集成。优先使用 HMAC 签名 + event_id 去重 + 重试策略 + 异步任务状态查询。
---

# Webhook 和异步 API

参考来源：[Stripe Webhooks](https://stripe.com/docs/webhooks)、[SVIX Webhook Guide](https://www.svix.com/resources/guides/webhooks/)

## 适用场景

- 事件驱动通知（订单状态变化、支付成功）
- 第三方集成（GitHub Actions、CI/CD）
- 长时间任务（导出报表、视频转码）
- 异步处理（消息队列）

## 核心原则

```text
1. 不可信网络
   - 必须签名验证
   - 必须防重放

2. At-least-once 投递
   - 接收方必须幂等
   - 提供 event_id 去重

3. 异步状态可查询
   - 不能"提交完就消失"
   - 提供任务 ID + 查询接口

4. 失败可重试
   - 重试策略明确
   - 失败有上限
```

## Webhook 设计

### 事件 Payload 结构

```json
{
  "id": "evt_abc123",                         ← 事件 ID（去重用）
  "type": "order.paid",                        ← 事件类型
  "created_at": "2026-01-15T10:30:00Z",       ← 触发时间
  "version": "2026-01-01",                     ← API 版本（用于兼容）
  "data": {
    "order_id": "ord_xyz789",
    "amount": 9999,
    "currency": "CNY",
    "user_id": "usr_001"
  },
  "previous": {                                ← 可选：变更前的值
    "status": "pending"
  },
  "metadata": {
    "ip": "1.2.3.4",
    "user_agent": "..."
  }
}
```

### 事件命名规范

```text
[资源].[动作]

✅ 好的：
  order.created
  order.paid
  order.cancelled
  payment.failed
  user.signed_up
  subscription.expired

❌ 差的：
  newOrder（驼峰）
  order_paid_event（冗余 _event）
  notification_1（无语义）
```

### HMAC 签名（必备）

```text
请求 Header：
X-Webhook-Signature: t=1611331200,v1=abc123def456
X-Webhook-Timestamp: 1611331200

签名生成（服务端）：
  signed_payload = f"{timestamp}.{request_body}"
  signature = HMAC-SHA256(webhook_secret, signed_payload)

接收方验证：
  1. 检查 timestamp（防重放，5 分钟内）
  2. 用相同算法计算签名
  3. 与 Header 中的签名对比
  4. 不一致 → 拒绝

代码示例（Python）：
import hmac, hashlib

def verify(payload, signature_header, secret):
    timestamp = parse_timestamp(signature_header)
    if abs(time.time() - timestamp) > 300:  # 5 分钟
        return False
    
    expected = hmac.new(
        secret.encode(),
        f"{timestamp}.{payload}".encode(),
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(expected, signature_from_header)
```

### 重试策略

```text
失败定义：
  - 接收方返回非 2xx
  - 超时（通常 10s）
  - 网络错误

重试时间表（指数退避 + 抖动）：
  第 1 次失败：1 分钟后重试
  第 2 次失败：5 分钟后
  第 3 次失败：30 分钟后
  第 4 次失败：2 小时后
  第 5 次失败：12 小时后
  第 6 次失败：24 小时后
  最多重试：N 次（如 10 次）

接收方建议：
  - 收到立即返回 200（哪怕处理失败）
  - 把处理推到队列
  - 处理失败由接收方自己重试

为什么？
  发送方按 200 判定成功
  如果接收方阻塞处理，会被发送方判定失败而重发
```

### 接收方实现要点

```text
1. 立即返回 200
   不要等业务处理完
   防止超时被重发

2. 验证签名
   不验证 = 任何人都能伪造事件

3. 检查 event_id 去重
   存数据库或 Redis
   防止 at-least-once 导致的重复处理

4. 处理失败时重新入队
   不依赖发送方重试

5. 处理超时控制
   不要长任务阻塞 webhook 端点
```

### 端点设计

```text
为接收方提供 Webhook 端点：
POST https://customer.com/webhooks/example

接收方注册端点：
POST /webhook-endpoints
{
  "url": "https://customer.com/webhooks/example",
  "events": ["order.paid", "order.cancelled"],
  "secret": "whsec_xxx"   ← 用于签名
}

测试 Webhook：
POST /webhook-endpoints/{id}/test
触发一个测试事件
```

## 异步 API 设计

### 长任务模式

```text
1. 提交任务（立即返回）
POST /reports/export
Body: { "type": "user_list", "format": "csv" }

→ HTTP 202 Accepted
{
  "task_id": "task_abc123",
  "status": "pending",
  "status_url": "/tasks/task_abc123"
}

2. 查询状态
GET /tasks/task_abc123
→ {
  "id": "task_abc123",
  "status": "running",
  "progress": 60,
  "estimated_completion": "2026-01-15T10:35:00Z"
}

3. 完成
GET /tasks/task_abc123
→ {
  "id": "task_abc123",
  "status": "completed",
  "result_url": "/files/report_xyz.csv",
  "completed_at": "2026-01-15T10:35:30Z"
}

4. 失败
GET /tasks/task_abc123
→ {
  "id": "task_abc123",
  "status": "failed",
  "error": {
    "code": "data_too_large",
    "message": "Export exceeds 1M rows"
  }
}
```

### 任务状态机

```text
pending → running → completed
                  → failed
                  → cancelled
```

### 状态获取方式

```text
方式 1：轮询（Polling）
  客户端定时查询 status_url
  简单但低效
  适合：短任务（< 1 分钟）

方式 2：Webhook（推送）
  完成后推送给客户端
  高效但需要接收方有 webhook
  适合：长任务

方式 3：Server-Sent Events（SSE）
  服务端持续推送进度
  适合：实时进度（如 AI 生成）

方式 4：WebSocket
  双向通信
  适合：实时交互
```

## 输出格式

```markdown
## Webhook 设计：[业务模块]

### 事件清单

| 事件 | 触发条件 | Payload | 用途 |
|------|---------|---------|------|
| order.created | 订单创建 | { order_id, ... } | 通知接入方 |
| order.paid | 订单支付完成 | { order_id, amount } | 触发发货 |
| order.cancelled | 订单取消 | { order_id, reason } | 解锁库存 |

### 签名规范

- 算法：HMAC-SHA256
- Header：X-Webhook-Signature
- Secret：注册端点时生成

### 重试策略

- 失败：返回非 2xx 或超时（10s）
- 重试时间表：1m / 5m / 30m / 2h / 12h / 24h
- 最大重试：10 次

### 端点管理

- POST /webhook-endpoints   注册
- GET  /webhook-endpoints   列出
- DELETE /webhook-endpoints/{id}  删除
- POST /webhook-endpoints/{id}/test  测试

## 异步 API 设计：[业务模块]

### 长任务清单

| 接口 | 任务类型 | 预期耗时 | 状态查询 |
|------|---------|---------|---------|
| POST /reports/export | 导出报表 | 1~10 分钟 | GET /tasks/{id} |
| POST /videos/transcode | 视频转码 | 10~60 分钟 | Webhook 通知 |
| POST /jobs/sync | 数据同步 | 1~30 分钟 | SSE 进度推送 |

### 任务状态机

pending → running → completed / failed / cancelled

### 状态查询响应

[标准响应格式见上方]
```

## 工作流程

```text
1. 识别哪些场景需要 Webhook（事件通知）
2. 识别哪些场景需要异步（长任务）
3. 列事件清单 + 命名
4. 设计 Payload 结构
5. 设计签名机制
6. 设计重试策略
7. 设计任务状态查询
8. 提供测试方式
9. 输出 Webhook + 异步 API 文档
```

## 质量自检

```text
□ 事件命名一致（resource.action）
□ 事件 Payload 包含 event_id（去重用）
□ Payload 包含 timestamp 和 version
□ HMAC 签名机制设计
□ Timestamp 防重放（5 分钟内）
□ 重试策略明确
□ 异步任务有 status_url
□ 任务状态机清晰
□ 任务失败有错误信息
□ 提供测试 / 调试方式
```

## 常见坑

1. **Webhook 没签名**——任何人都能伪造事件
2. **签名缺 timestamp**——重放攻击风险
3. **没有 event_id**——接收方无法去重
4. **接收方处理慢导致重发**——应立即返回 200
5. **重试无上限**——失败的端点收到无限请求
6. **异步任务无状态查询**——客户端不知道好没好
7. **任务失败无错误信息**——调试困难
8. **Payload 不带版本**——升级时接收方崩溃

## 配套模板

- `templates/webhook-async-template.md` — 事件 Payload + 签名规范 + 异步任务设计模板

## 与其他 skill 的协作

```text
上游：
  resource-modeling → 资源的状态变更触发事件

平行：
  auth-permission → Webhook 端点鉴权
  idempotency-retry → 重试机制
  error-handling → 错误码

下游：
  openapi-mock → 写入 OpenAPI（含 Webhook schema）
  转交后端 → 实现签名 + 重试 + 队列
  转交安全 → 评审签名机制
```
