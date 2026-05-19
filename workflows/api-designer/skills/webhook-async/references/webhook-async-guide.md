# Webhook 和异步 API 指南

## 1. 适用场景

```text
处理耗时长
调用方不需要同步等待
需要通知第三方系统
结果由后台任务产生
需要可查询任务状态
```

## 2. 异步任务模式

```text
POST /exports → 202 Accepted + taskId
GET /exports/{taskId} → 查询状态
GET /exports/{taskId}/result → 获取结果
```

## 3. Webhook 事件

必须定义：

```text
event id
event type
createdAt
payload schema
resource id
版本
```

## 4. 安全

```text
签名 Header
签名算法
时间戳
重放窗口
事件 ID 去重
HTTPS 要求
密钥轮换
```

## 5. 重试和可靠性

```text
2xx 视为成功。
非 2xx 按退避策略重试。
达到最大次数进入死信或人工补偿。
接收方必须按 event id 幂等处理。
不默认保证顺序，若需要顺序必须明确说明。
```

## 6. 调试和交接

```text
提供示例 payload。
提供签名验证示例。
提供测试事件发送方式。
提供失败重试日志或查看入口。
```
