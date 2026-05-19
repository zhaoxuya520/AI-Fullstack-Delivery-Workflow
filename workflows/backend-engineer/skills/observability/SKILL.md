---
name: observability
description: 实现日志 / 指标 / 追踪三大支柱时使用。覆盖 OpenTelemetry / Prometheus / Grafana / Jaeger / Datadog / Sentry 集成。融合 Google SRE 三支柱 + 结构化日志 + Trace Context 传播。
---

# 可观测性（Observability）

参考来源：Google《Site Reliability Engineering》、《Distributed Systems Observability》(Cindy Sridharan)、OpenTelemetry 官方文档、Honeycomb 高基数追踪、Stripe 可观测性实践。

## 适用场景

- 接入日志 / 指标 / 追踪（三大支柱）
- 排查线上问题
- 性能监控
- SLO / SLI 度量
- 错误跟踪（Sentry / Datadog Errors）
- 业务指标埋点

## 核心原则

```text
1. 三大支柱缺一不可
   日志（Logs）：发生了什么
   指标（Metrics）：当前状态
   追踪（Traces）：请求路径

2. 结构化日志
   不用纯文本，用 JSON / key-value

3. Trace ID 贯穿全链路
   从入口生成，所有日志 / 调用都带

4. 关键业务指标必埋
   订单数 / 支付成功率 / 注册量

5. 用 OpenTelemetry 标准
   厂商无关，可切换后端

6. 不日志输出 PII / Token
   用 [REDACTED] 占位

7. 采样率合理
   全采样压垮系统，1% 又看不清

8. 告警 ≠ 监控
   监控全采集，告警仅必报
```

## 三大支柱

### 1. 日志（Logs）

```text
作用：发生了什么的离散事件
适合：排查具体问题

特点：
  - 结构化（JSON）
  - 含 trace_id
  - 不输出敏感信息
  - 分级（DEBUG/INFO/WARN/ERROR）
```

### 2. 指标（Metrics）

```text
作用：当前状态的数值聚合
适合：监控告警

类型：
  - Counter（累加，如请求数）
  - Gauge（瞬时，如内存使用）
  - Histogram（分布，如响应时间 P99）
  - Summary（quantile）

四个黄金信号（Google SRE）：
  Latency（延迟）
  Traffic（流量）
  Errors（错误率）
  Saturation（饱和度）
```

### 3. 追踪（Traces）

```text
作用：请求经过哪些服务
适合：分布式系统排查、性能定位

概念：
  Trace：一次完整请求
  Span：trace 中的一段（一个服务一个 span）
  Parent / Child：调用关系
```

## 结构化日志

### Spring Boot

```java
// logback-spring.xml 配置 JSON 格式
<configuration>
  <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder">
      <includeMdcKeyName>traceId</includeMdcKeyName>
      <includeMdcKeyName>spanId</includeMdcKeyName>
      <includeMdcKeyName>userId</includeMdcKeyName>
    </encoder>
  </appender>
</configuration>
```

```java
// 用法
@Slf4j
@RestController
public class OrderController {
  @PostMapping("/orders")
  public Order create(@RequestBody CreateOrderRequest req) {
    MDC.put("userId", String.valueOf(req.getUserId()));
    
    log.info("Creating order, items={}", req.getItems().size());
    
    try {
      Order order = orderService.create(req);
      log.info("Order created, orderId={}, amount={}", order.getId(), order.getTotal());
      return order;
    } catch (Exception e) {
      log.error("Failed to create order", e);
      throw e;
    } finally {
      MDC.clear();
    }
  }
}
```

### NestJS

```typescript
// 用 nestjs-pino 或 winston
import { Logger as PinoLogger } from 'nestjs-pino';

@Injectable()
export class OrderService {
  constructor(private logger: PinoLogger) {}
  
  async create(dto: CreateOrderDto, user: User) {
    this.logger.info({ userId: user.id, items: dto.items.length }, 'Creating order');
    
    try {
      const order = await this.repo.create(dto);
      this.logger.info({ orderId: order.id, amount: order.total }, 'Order created');
      return order;
    } catch (err) {
      this.logger.error({ err, userId: user.id }, 'Failed to create order');
      throw err;
    }
  }
}
```

### Python

```python
import structlog

logger = structlog.get_logger()

def create_order(dto, user):
    log = logger.bind(user_id=user.id, items=len(dto.items))
    log.info('creating_order')
    
    try:
        order = repo.create(dto)
        log.info('order_created', order_id=order.id, amount=order.total)
        return order
    except Exception as e:
        log.error('order_creation_failed', error=str(e))
        raise
```

### Go

```go
import "go.uber.org/zap"

logger, _ := zap.NewProduction()

func CreateOrder(ctx context.Context, dto CreateOrderDto, user User) (*Order, error) {
    log := logger.With(
        zap.Int64("user_id", user.ID),
        zap.Int("items", len(dto.Items)),
        zap.String("trace_id", trace.GetTraceID(ctx)),
    )
    log.Info("creating_order")
    
    order, err := repo.Create(dto)
    if err != nil {
        log.Error("order_creation_failed", zap.Error(err))
        return nil, err
    }
    log.Info("order_created", zap.Int64("order_id", order.ID))
    return order, nil
}
```

## OpenTelemetry 集成（统一标准）

### Spring Boot

```yaml
# application.yml
otel:
  service:
    name: order-service
  exporter:
    otlp:
      endpoint: http://otel-collector:4317
  traces:
    sampler: parentbased_traceidratio
    sampler-arg: 0.1  # 10% 采样
```

```java
// 自动追踪（用 micrometer-tracing）
@RestController
public class OrderController {
  @Autowired
  private Tracer tracer;
  
  @PostMapping("/orders")
  public Order create(@RequestBody CreateOrderRequest req) {
    Span span = tracer.spanBuilder("createOrder")
      .setAttribute("user.id", req.getUserId())
      .startSpan();
    try (Scope scope = span.makeCurrent()) {
      return orderService.create(req);
    } finally {
      span.end();
    }
  }
}
```

### NestJS

```typescript
// 用 @opentelemetry/sdk-node
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://otel-collector:4318/v1/traces',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```

### Python

```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

provider = TracerProvider()
provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

@app.post('/orders')
async def create_order(dto: CreateOrderDto, user: User = Depends(get_current_user)):
    with tracer.start_as_current_span('createOrder') as span:
        span.set_attribute('user.id', user.id)
        span.set_attribute('items.count', len(dto.items))
        return await order_service.create(dto, user)
```

## 关键指标（必埋）

### 通用指标

```text
HTTP 层：
  http_requests_total{method, endpoint, status}        # Counter
  http_request_duration_seconds{method, endpoint}      # Histogram
  http_requests_in_flight                              # Gauge

DB 层：
  db_queries_total{operation, table}
  db_query_duration_seconds{operation, table}
  db_connections_active

Cache 层：
  cache_operations_total{operation, status}
  cache_hit_rate

Queue 层：
  queue_depth{queue_name}
  queue_processing_duration_seconds{queue_name}
  queue_failed_total{queue_name}
```

### 业务指标

```text
orders_created_total                       # 订单数
payments_succeeded_total                   # 支付成功
payments_failed_total{reason}              # 支付失败（按原因）
user_signups_total{source}                 # 注册（按来源）
revenue_total{currency}                    # 收入
```

### Spring Boot + Micrometer

```java
@RestController
public class OrderController {
  @Autowired private MeterRegistry meterRegistry;
  
  @PostMapping("/orders")
  public Order create(@RequestBody CreateOrderRequest req) {
    Timer.Sample sample = Timer.start(meterRegistry);
    try {
      Order order = orderService.create(req);
      meterRegistry.counter("orders.created.total", 
        "user_type", req.getUserType()).increment();
      return order;
    } finally {
      sample.stop(meterRegistry.timer("orders.create.duration"));
    }
  }
}
```

### NestJS + prom-client

```typescript
import { Counter, Histogram } from 'prom-client';

const orderCreatedCounter = new Counter({
  name: 'orders_created_total',
  help: 'Total orders created',
  labelNames: ['user_type'],
});

const orderDuration = new Histogram({
  name: 'order_create_duration_seconds',
  help: 'Order creation duration',
  buckets: [0.1, 0.5, 1, 2, 5],
});

@Injectable()
export class OrderService {
  async create(dto: CreateOrderDto, user: User) {
    const end = orderDuration.startTimer();
    try {
      const order = await this.repo.create(dto);
      orderCreatedCounter.labels(user.type).inc();
      return order;
    } finally {
      end();
    }
  }
}

// 暴露 /metrics 端点（Prometheus 抓取）
@Controller()
export class MetricsController {
  @Get('metrics')
  async metrics(@Res() res: Response) {
    res.set('Content-Type', register.contentType);
    res.send(await register.metrics());
  }
}
```

## Trace ID 传播

```text
入口（API Gateway / Controller）：
  生成 trace_id（如未有）
  注入 MDC / AsyncLocalStorage / context

下游调用：
  HTTP：传播 X-Request-Id / traceparent header
  消息队列：放进消息 metadata
  数据库：可选

日志：
  每行日志带 trace_id

监控：
  追踪图自动串联
```

```typescript
// NestJS 中间件
@Injectable()
export class TraceMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const traceId = req.headers['x-request-id'] || uuidv4();
    AsyncLocalStorage.run({ traceId }, () => {
      res.setHeader('X-Request-Id', traceId);
      next();
    });
  }
}
```

## 错误跟踪（Sentry）

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,  // 10% 性能追踪
  beforeSend(event) {
    // 过滤敏感信息
    if (event.request?.headers) {
      delete event.request.headers['authorization'];
      delete event.request.headers['cookie'];
    }
    return event;
  },
});

// 用法
try {
  await orderService.create(...);
} catch (err) {
  Sentry.captureException(err, {
    user: { id: user.id },
    extra: { orderId: order.id },
  });
  throw err;
}
```

## 健康检查端点

```typescript
@Controller()
export class HealthController {
  @Get('health')
  async health() {
    return { status: 'ok', timestamp: Date.now() };
  }
  
  @Get('health/ready')  // K8s readiness
  async ready() {
    const checks = await Promise.all([
      this.checkDatabase(),
      this.checkRedis(),
    ]);
    if (checks.every(c => c.ok)) {
      return { status: 'ready', checks };
    }
    throw new ServiceUnavailableException({ status: 'not_ready', checks });
  }
  
  @Get('health/live')  // K8s liveness
  async live() {
    return { status: 'alive' };
  }
}
```

## 工作流程

```text
1. 接入 OpenTelemetry SDK
   - 自动追踪 HTTP / DB / Redis / 消息队列

2. 配置结构化日志
   - JSON 格式
   - 含 trace_id / user_id

3. 埋点关键指标
   - HTTP 黄金信号
   - 业务指标
   - 资源使用

4. Trace ID 传播
   - 入口生成
   - 下游传递

5. 错误跟踪接入（Sentry）
   - 过滤敏感信息

6. 配置健康检查
   - liveness / readiness

7. 接入 APM 平台
   - Datadog / Prometheus + Grafana / 自建

8. 设计告警
   - SLO 偏离
   - 错误率突增
   - 延迟退化
```

## 配套模板

- `templates/observability-checklist.md` — 三大支柱 + 关键指标 + Trace ID + Sentry + 健康检查 + 告警

## 质量自检

```text
□ 日志结构化（JSON）
□ 日志含 trace_id
□ 日志不输出 PII / Token
□ 关键业务指标埋点
□ HTTP 黄金信号采集
□ Trace 串联全链路
□ OpenTelemetry 标准
□ 错误跟踪（Sentry）
□ 健康检查（liveness + readiness）
□ 采样率合理（不全采）
□ 监控覆盖率 > 80%
□ 告警基于 SLO 不基于 alert fatigue
```

## 常见坑

1. **纯文本日志**——无法搜索 / 聚合
2. **不带 trace_id**——分布式排错困难
3. **日志输出密码 / Token**——合规问题
4. **指标 cardinality 爆炸**——userId 当 label
5. **全采样追踪**——性能 / 存储压垮
6. **不区分 INFO / DEBUG**——日志爆炸
7. **告警过多**——alert fatigue，重要的被忽略
8. **不监控业务指标**——只盯技术指标，业务退化无感
9. **采样率太低**——关键链路追不到
10. **不集成 OpenTelemetry**——锁定厂商
11. **错误日志不带堆栈**——排查困难
12. **指标命名不统一**——查询难
13. **不用结构化错误**——Sentry 看不出聚合
14. **健康检查 = 假死检查**——liveness 检查 DB 拖死自己

## 与其他 skill 的协作

```text
上游：
  api-implementation → 中间件埋点
  data-access → SQL 监控
  caching-strategy → 缓存监控
  async-jobs → 队列监控
  error-handling-resilience → 错误监控

下游：
  sre-ops 工作流 → 告警 / SLO
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — 可观测性方案
