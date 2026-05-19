# Webhook 和异步 API 模板

## 1. 异步场景

```text
触发端点：
任务类型：
为什么需要异步：
结果获取方式：Webhook / 轮询 / Server-Sent Events / 消息队列
```

---

## 2. 异步任务状态

| 状态 | 含义 | 下一步 | 终态 |
|---|---|---|---|
| pending | 已创建 | processing | 否 |
| processing | 处理中 | succeeded / failed | 否 |
| succeeded | 成功 | - | 是 |
| failed | 失败 | - | 是 |

---

## 3. Webhook 事件清单

| Event | 触发条件 | Payload Schema | 是否重试 | 备注 |
|---|---|---|---|---|
|  |  |  |  |  |

---

## 4. 安全规则

```text
签名 Header：
签名算法：
时间戳 Header：
重放窗口：
事件 ID：
幂等处理：
```

---

## 5. 重试策略

```text
成功确认：2xx
重试间隔：
最大重试次数：
死信处理：
人工补偿入口：
```

---

## 6. Payload 示例

```json
{
  "id": "evt_xxx",
  "type": "resource.updated",
  "createdAt": "2026-05-18T00:00:00Z",
  "data": {}
}
```
