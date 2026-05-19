# 韧性配置检查清单

## 1. 模块信息

```text
模块：
外部依赖：[列表]
韧性库：Resilience4j / opossum / tenacity / gobreaker
负责人：
```

---

## 2. 外部依赖清单

| 依赖 | 类型 | 协议 | 关键性 |
|---|---|---|---|
| Payment API | 第三方 | HTTPS | 核心 |
| Mail Service | 第三方 | SMTP | 非核心 |
| Redis | 缓存 | TCP | 重要 |
| Postgres | DB | TCP | 核心 |
| Kafka | 队列 | TCP | 重要 |

---

## 3. 超时配置

| 依赖 | 连接超时 | 读超时 | 总超时 |
|---|---|---|---|
| Payment API | 2s | 10s | 15s |
| Mail Service | 1s | 5s | 10s |
| Redis | 500ms | 1s | - |
| Postgres | 2s | 30s | - |

---

## 4. 重试策略

| 依赖 | 最大次数 | 间隔 | 退避 | 抖动 | 可重试错误 |
|---|---|---|---|---|---|
| Payment API | 3 | 1s | 指数 | 0.5x | 5xx, 网络超时 |
| Mail Service | 5 | 30s | 指数 | 0.5x | 5xx, 限流 |

---

## 5. 熔断配置

| 依赖 | 滑动窗口 | 失败率阈值 | 慢调用阈值 | Open 时长 | 半开探测 |
|---|---|---|---|---|---|
| Payment API | 100 | 50% | 5s / 50% | 30s | 3 |
| Mail Service | 50 | 60% | - | 60s | 2 |

---

## 6. 降级方案

| 场景 | 降级策略 | 实现 |
|---|---|---|
| Payment 挂了 | 异步入队列稍后扣款 | Outbox + 后台 worker |
| Mail 挂了 | 写到死信队列 | DLQ + 告警 |
| Redis 挂了 | 直接查 DB | 双层 try-catch |
| 推荐服务挂了 | 返回热门列表 | 静态兜底 |

---

## 7. 异常映射

| 异常类型 | HTTP 状态 | Error Code | 是否暴露细节 |
|---|---|---|---|
| ResourceNotFoundException | 404 | RESOURCE_NOT_FOUND | message |
| ValidationException | 400 | VALIDATION_ERROR | fields |
| AuthenticationException | 401 | UNAUTHORIZED | 通用 |
| AuthorizationException | 403 | FORBIDDEN | 通用 |
| ConflictException | 409 | RESOURCE_CONFLICT | message |
| RateLimitException | 429 | RATE_LIMITED | retry-after |
| Exception（兜底） | 500 | INTERNAL_ERROR | 通用 |

---

## 8. 限流配置

| 维度 | 限制 | 时间窗口 | 实现 |
|---|---|---|---|
| 全局 | 10000 req/s | 1s | Bucket4j / nginx |
| 单 IP | 100 req/min | 1min | Redis ZSET |
| 单用户 | 1000 req/min | 1min | Redis |
| 接口 /api/login | 5 req/min | 1min | Redis |

---

## 9. 监控指标

```text
□ 错误率（按类型）
□ 重试次数 / 成功率
□ 熔断器状态（Open/Closed/HalfOpen）
□ 限流触发次数
□ 超时次数
□ 降级使用率
□ P99 / P50 延迟
```

---

## 10. 测试

```text
□ 单元测试：异常映射
□ 集成测试：超时模拟
□ 故障注入：
  - 第三方挂了
  - 数据库不可达
  - 缓存超时
□ 限流压测
□ 熔断恢复验证
```

---

## 11. 自检

```text
□ 所有外部调用有超时
□ 重试 + 退避 + 抖动
□ 熔断 + 降级
□ 全局错误处理器
□ 异常 → HTTP 状态映射统一
□ 不暴露内部细节
□ 监控完整
□ 故障演练
```
