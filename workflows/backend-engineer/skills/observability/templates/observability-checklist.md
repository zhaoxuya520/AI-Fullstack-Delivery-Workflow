# 可观测性接入检查清单

## 1. 项目信息

```text
服务名：
追踪后端：OpenTelemetry → Jaeger / Datadog / Honeycomb
日志后端：ELK / Loki / Datadog Logs
指标后端：Prometheus + Grafana / Datadog
错误跟踪：Sentry / Datadog Errors
负责人：
```

---

## 2. 日志接入

```text
□ 结构化（JSON）
□ 必带字段：timestamp / level / message / trace_id / span_id / service / env
□ 业务字段：user_id / tenant_id / request_id
□ 分级：DEBUG（关闭生产）/ INFO / WARN / ERROR
□ 不输出敏感字段（用 [REDACTED]）
□ 错误日志带完整堆栈
□ 异步写日志（高并发）
```

### 敏感字段过滤清单

```text
绝不输出：
  □ password / password_hash
  □ token / access_token / refresh_token
  □ api_key / secret_key
  □ credit_card / cvv
  □ ssn / id_card
  □ phone / email（视场景）
```

---

## 3. 指标接入

### HTTP 黄金信号

| 指标 | 类型 | Labels |
|---|---|---|
| http_requests_total | Counter | method, endpoint, status |
| http_request_duration_seconds | Histogram | method, endpoint |
| http_requests_in_flight | Gauge | - |
| http_errors_total | Counter | method, endpoint, error_code |

### 业务指标

| 指标 | 类型 | 用途 |
|---|---|---|
| orders_created_total | Counter | 订单创建量 |
| orders_amount_total | Counter | 订单金额 |
| payments_succeeded_total | Counter | 支付成功 |
| payments_failed_total | Counter | 支付失败（按原因 label） |
| signups_total | Counter | 注册（按来源） |

### 资源指标

```text
□ JVM / Node 进程
  - 内存使用
  - GC 次数 / 时长（Java）
  - 线程数 / 文件描述符

□ DB 连接池
  - 活跃连接
  - 等待数
  - 最大数

□ 缓存
  - hit rate
  - 内存使用

□ 队列
  - depth
  - 处理延迟
  - 失败率
```

---

## 4. 追踪接入

```text
□ OpenTelemetry SDK
□ 自动 instrumentation：HTTP / DB / Redis / Queue
□ 自定义 span：关键业务方法
□ Trace Context 传播：HTTP / 消息 metadata
□ 采样策略：
  - dev/staging：100%
  - production：1%~10%
  - 错误：100%（tail-based）
□ Span 属性：user.id / order.id / amount 等业务字段
```

### Span 命名规范

```text
HTTP：{method} {route}              GET /orders/{id}
DB：{operation} {table}              SELECT orders
Cache：{operation} {key_pattern}    GET cache:product:*
Queue：{operation} {queue_name}     publish email-queue
业务：{class}.{method}               OrderService.createOrder
```

---

## 5. Trace ID 传播

```text
□ 中间件：入口生成 / 提取
□ 写到日志 MDC / context
□ HTTP 客户端：注入 traceparent header
□ 消息队列：注入 metadata
□ DB 查询：可选（看支持）
□ 响应 header：X-Request-Id 给客户端
```

---

## 6. 错误跟踪（Sentry / 等）

```text
□ DSN 配置
□ 环境标签（dev/staging/prod）
□ 用户上下文（user_id）
□ 业务上下文（order_id 等）
□ 过滤敏感信息（before send）
□ 采样率：错误 100%，性能 10%
□ 未捕获异常自动上报
□ release 标签（版本号）
```

---

## 7. 健康检查

| 端点 | 用途 | 检查内容 |
|---|---|---|
| /health | 总体存活 | 进程在跑 |
| /health/live | K8s liveness | 不死锁 / 不阻塞 |
| /health/ready | K8s readiness | DB / Redis / 关键依赖 |
| /metrics | Prometheus 抓取 | 全部指标 |

注意：
- liveness 不查重依赖（避免连锁挂）
- readiness 查依赖
- /metrics 不需要认证（内部网络）

---

## 8. 告警配置

### 基于 SLO 的告警（推荐）

```text
SLO：99.9% 请求 P99 < 500ms

告警：
  - 5 分钟错误率 > 1% → P1
  - 1 小时错误率 > 0.5% → P2
  - 1 天错误预算消耗 > 50% → P3

告警阈值用 burn rate：
  - 1h burn > 14.4 → 立即
  - 6h burn > 6 → 较快
```

### 业务告警

```text
□ 订单数突降（< 50% 上周同时段）
□ 支付失败率 > 5%
□ 注册数异常
□ 限流触发率突增
```

---

## 9. 监控仪表盘（Grafana）

```text
推荐 5 个 Dashboard：
  1. 服务总览（黄金信号）
  2. 业务指标（订单 / 支付 / 注册）
  3. 资源使用（CPU / Memory / DB / Cache）
  4. 错误分析（Top errors）
  5. 链路追踪（Top slow endpoints）
```

---

## 10. 性能验证

```text
□ 日志写入开销 < 5%
□ 指标采集开销 < 1%
□ 追踪采样后开销 < 5%
□ 总体可观测开销 < 10%
```

---

## 11. 自检

```text
□ 日志结构化
□ Trace ID 全链路
□ 关键指标埋点
□ 业务指标埋点
□ 错误跟踪
□ 健康检查（live + ready）
□ 不输出敏感信息
□ 采样合理
□ 告警基于 SLO
□ 仪表盘可用
□ 文档化（运行手册）
```
