# 可观测性实战指南

> 覆盖监控、日志、追踪三大支柱。面向 APP/小程序/网页后端服务。

## 1. 三大支柱概览

```text
┌─────────────────────────────────────────────────────────────┐
│                     可观测性三支柱                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Metrics（指标）        Logs（日志）        Traces（追踪）    │
│  "发生了什么？"         "为什么发生？"      "怎么发生的？"    │
│                                                              │
│  Prometheus/Grafana     Loki/ELK           Jaeger/Tempo      │
│  数值型/可聚合         文本型/可搜索       请求链路/因果关系  │
│                                                              │
│  告警 → 定位问题       → 查看上下文         → 追踪全链路    │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 关键指标（Golden Signals）

```text
Google SRE 四大黄金信号：

1. Latency（延迟）
   - P50 / P95 / P99 响应时间
   - 区分成功请求和失败请求的延迟

2. Traffic（流量）
   - HTTP 请求数/秒（QPS）
   - 按端点/方法/状态码分组

3. Errors（错误率）
   - 5xx 比例
   - 业务错误比例
   - 超时比例

4. Saturation（饱和度）
   - CPU 利用率
   - 内存利用率
   - 连接池使用率
   - 队列深度
```

### 推荐告警阈值

| 指标 | 警告 | 严重 | 说明 |
|------|------|------|------|
| P99 延迟 | > 1s | > 3s | 按 SLA 调整 |
| 错误率 | > 1% | > 5% | 5分钟滑动窗口 |
| CPU | > 70% | > 90% | 持续 5 分钟 |
| 内存 | > 80% | > 95% | OOM 前告警 |
| 磁盘 | > 80% | > 90% | 剩余空间 |
| 连接池 | > 80% | > 95% | DB/Redis 连接 |

---

## 3. Prometheus + Grafana 配置

### Node.js 应用埋点

```typescript
// 使用 prom-client
import { Registry, Counter, Histogram, collectDefaultMetrics } from 'prom-client';

const register = new Registry();
collectDefaultMetrics({ register });

// HTTP 请求计数
const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

// 请求延迟
const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [register],
});

// Express 中间件
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const labels = { method: req.method, route: req.route?.path || 'unknown', status_code: res.statusCode };
    httpRequestsTotal.inc(labels);
    end(labels);
  });
  next();
});

// /metrics 端点
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Spring Boot Actuator + Micrometer

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,prometheus,info
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: myapp
      environment: ${SPRING_PROFILES_ACTIVE:dev}
```

---

## 4. 结构化日志

### 格式标准（JSON）

```json
{
  "timestamp": "2026-05-19T10:30:00.123Z",
  "level": "ERROR",
  "service": "order-service",
  "trace_id": "abc123def456",
  "span_id": "789ghi",
  "user_id": "u_12345",
  "method": "POST",
  "path": "/api/orders",
  "status": 500,
  "duration_ms": 1234,
  "error": "Connection refused",
  "message": "Failed to create order"
}
```

### Node.js 日志配置（Pino）

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: ['req.headers.authorization', 'password', 'token'],  // 脱敏
});

// 请求日志中间件
app.use((req, res, next) => {
  req.log = logger.child({ trace_id: req.headers['x-trace-id'] || crypto.randomUUID() });
  req.log.info({ method: req.method, path: req.path }, 'request started');
  next();
});
```

---

## 5. 事故响应流程

```text
┌─ 事故响应（IMOC）─────────────────────────────────────────┐
│                                                            │
│  1. 检测（Detect）                                         │
│     - 告警触发 → 值班人收到通知                            │
│     - 确认是否为真实事故（排除误报）                       │
│                                                            │
│  2. 响应（Respond）                                        │
│     - 评估影响范围（用户数/功能/金额）                     │
│     - 严重度分级：P0(全站)/P1(核心)/P2(非核心)/P3(低影响) │
│     - 拉群/开战情室                                        │
│                                                            │
│  3. 缓解（Mitigate）                                       │
│     - 优先恢复服务（回滚/降级/限流）                       │
│     - 不要在恢复前搞清根因（先救火）                       │
│                                                            │
│  4. 修复（Fix）                                            │
│     - 确认根因                                             │
│     - 实施永久修复                                         │
│     - 验证修复有效                                         │
│                                                            │
│  5. 复盘（Review）                                         │
│     - 48h 内完成复盘文档                                   │
│     - 时间线 + 根因 + 改进项 + 责任人 + 截止日            │
│     - 不追责，追改进                                       │
└────────────────────────────────────────────────────────────┘
```

---

## 6. SLI / SLO / SLA 定义

```text
SLI（指标）：可用性 = 成功请求数 / 总请求数
SLO（目标）：99.9%（每月允许 43 分钟停机）
SLA（协议）：99.5%（对外承诺，低于 SLO）

常见 SLO 模板：
  API 可用性    ≥ 99.9%    (30天滚动)
  P99 延迟      ≤ 500ms    (5分钟窗口)
  错误率        ≤ 0.1%     (1小时窗口)
  
Error Budget = 1 - SLO
  99.9% SLO → 0.1% error budget → 每月 43 分钟
  用完 → 冻结新功能发布，专注稳定性
```
