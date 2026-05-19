---
name: error-handling-resilience
description: 设计错误处理 / 重试 / 熔断 / 限流 / 降级时使用。覆盖 Resilience4j（Java）/ Polly（.NET）/ opossum（Node）/ tenacity（Python）/ Sentinel（阿里）。融合 Netflix Hystrix 模式 + 故障隔离 + 优雅降级。
---

# 错误处理与韧性（Error Handling & Resilience）

参考来源：Michael Nygard《Release It!》、Netflix Hystrix Wiki、Resilience4j 文档、Google SRE Workbook、AWS Well-Architected Framework Reliability Pillar。

## 适用场景

- 第三方 API 调用容错
- 跨服务调用韧性
- 上游故障隔离
- 重试 / 熔断 / 降级 / 限流
- 全局错误处理 / 异常映射
- 故障注入 / Chaos Engineering

## 核心原则

```text
1. 不信任任何外部依赖
   网络 / DB / 第三方都会失败

2. Fail Fast（快速失败）
   超时不能无限大，配置合理超时

3. Fail Safe（安全失败）
   下游挂了不能拖垮上游
   降级返回兜底数据

4. 区分可重试 vs 不可重试错误
   网络超时 → 可重试
   401 / 400 → 不重试

5. 重试要有边界
   最大次数 + 指数退避 + 抖动

6. 熔断防止级联崩溃
   下游持续失败 → 主动熔断
   恢复后半开探测

7. 错误信息分内外
   外部：友好错误码
   内部：完整堆栈 + trace
```

## 异常分类

```text
1. 业务异常（Business Exception）
   - 资源不存在、状态冲突、校验失败
   - 不重试，返回 4xx

2. 系统异常（System Exception）
   - 数据库挂了、第三方超时、内存溢出
   - 可能重试，返回 5xx

3. 编程错误（Programming Error）
   - 空指针、数组越界、类型错误
   - Bug，不重试，告警

异常分层：
  Domain Exception          → 业务规则违反
  Application Exception     → 业务逻辑失败（如订单不存在）
  Infrastructure Exception  → 基础设施失败（DB / Redis）
  System Exception          → 不可预期
```

## 全局错误处理

### Spring Boot

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
  // 业务异常
  @ExceptionHandler(BusinessException.class)
  public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
    return ResponseEntity.status(e.getStatus())
      .body(new ErrorResponse(e.getCode(), e.getMessage(), TraceContext.getTraceId()));
  }
  
  // 校验失败
  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException e) {
    List<FieldError> fieldErrors = e.getBindingResult().getFieldErrors().stream()
      .map(fe -> new FieldError(fe.getField(), fe.getDefaultMessage()))
      .toList();
    return ResponseEntity.badRequest()
      .body(new ErrorResponse("VALIDATION_ERROR", "Validation failed", fieldErrors));
  }
  
  // 兜底（Programming Error）
  @ExceptionHandler(Exception.class)
  public ResponseEntity<ErrorResponse> handleGeneric(Exception e) {
    log.error("Unhandled exception", e);  // 完整堆栈
    return ResponseEntity.status(500)
      .body(new ErrorResponse("INTERNAL_ERROR", "Internal server error"));
    // 不暴露内部信息！
  }
}
```

### NestJS

```typescript
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    
    let status = 500;
    let code = 'INTERNAL_ERROR';
    let message = 'Internal server error';
    
    if (exception instanceof BusinessException) {
      status = exception.status;
      code = exception.code;
      message = exception.message;
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      message = exception.message;
    } else {
      // Programming Error
      logger.error('Unhandled exception', exception);
      // 不返回内部细节
    }
    
    response.status(status).json({
      error: {
        code,
        message,
        request_id: request.id,
        timestamp: new Date().toISOString(),
      },
    });
  }
}
```

## 超时设置（必须）

```text
HTTP 客户端超时：
  - 连接超时（connect）：1~5s
  - 读超时（read）：5~30s
  - 总超时：根据业务

数据库：
  - 连接超时：1~5s
  - 查询超时：根据业务

Redis：
  - 连接超时：500ms
  - 命令超时：1s

外部服务调用：
  - 整体不超过用户可接受等待时间
```

```java
// Spring：RestTemplate / WebClient
@Bean
public RestTemplate restTemplate() {
  return new RestTemplateBuilder()
    .setConnectTimeout(Duration.ofSeconds(2))
    .setReadTimeout(Duration.ofSeconds(5))
    .build();
}

// WebClient
WebClient client = WebClient.builder()
  .clientConnector(new ReactorClientHttpConnector(
    HttpClient.create()
      .responseTimeout(Duration.ofSeconds(5))
      .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 2000)
  ))
  .build();
```

```typescript
// axios
const client = axios.create({
  timeout: 5000,
  baseURL: 'https://api.example.com',
});

// fetch（Node 18+）
const response = await fetch(url, {
  signal: AbortSignal.timeout(5000),
});
```

## 重试模式

### Spring + Resilience4j

```java
@Retry(name = "paymentApi", fallbackMethod = "paymentFallback")
@CircuitBreaker(name = "paymentApi", fallbackMethod = "paymentFallback")
@TimeLimiter(name = "paymentApi")
public CompletableFuture<PaymentResult> charge(ChargeRequest req) {
  return CompletableFuture.supplyAsync(() -> 
    paymentClient.charge(req)
  );
}

public CompletableFuture<PaymentResult> paymentFallback(ChargeRequest req, Throwable t) {
  log.warn("Payment failed, fallback", t);
  return CompletableFuture.completedFuture(PaymentResult.queued(req));
}
```

```yaml
# application.yml
resilience4j:
  retry:
    instances:
      paymentApi:
        max-attempts: 3
        wait-duration: 1s
        retry-exceptions:
          - java.io.IOException
          - org.springframework.web.client.HttpServerErrorException
        ignore-exceptions:
          - com.example.BusinessException
        exponential-backoff-multiplier: 2
        random-wait-factor: 0.5  # 抖动
  
  circuitbreaker:
    instances:
      paymentApi:
        sliding-window-size: 100
        failure-rate-threshold: 50
        slow-call-rate-threshold: 50
        slow-call-duration-threshold: 5s
        wait-duration-in-open-state: 30s
        permitted-number-of-calls-in-half-open-state: 3
```

### NestJS + opossum

```typescript
import CircuitBreaker from 'opossum';

const breaker = new CircuitBreaker(paymentApi, {
  timeout: 5000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
});

breaker.fallback(() => ({ status: 'queued', message: 'Payment queued for retry' }));

breaker.on('open', () => logger.warn('Payment circuit opened'));
breaker.on('halfOpen', () => logger.info('Payment circuit half-open'));

// 用法
const result = await breaker.fire(req);
```

### Python + tenacity

```python
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type(RetryableError),
    reraise=True,
)
def call_payment_api(req):
    response = requests.post('https://api.example.com', json=req, timeout=5)
    if response.status_code >= 500:
        raise RetryableError(...)
    return response.json()
```

### Go

```go
import "github.com/sony/gobreaker"

cb := gobreaker.NewCircuitBreaker(gobreaker.Settings{
    Name:        "paymentApi",
    MaxRequests: 3,
    Interval:    10 * time.Second,
    Timeout:     30 * time.Second,
    ReadyToTrip: func(counts gobreaker.Counts) bool {
        return counts.ConsecutiveFailures > 5
    },
})

result, err := cb.Execute(func() (interface{}, error) {
    return paymentClient.Charge(ctx, req)
})
```

## 熔断器三态

```text
Closed（关闭）：正常调用
   ↓ 失败率超阈值
Open（打开）：快速失败，不调用
   ↓ 等待时间到
Half-Open（半开）：少量探测
   ↓ 成功 → Closed
   ↓ 失败 → Open
```

## 降级策略

```text
1. 静态降级：返回固定数据
   user.country → 默认 "Unknown"

2. 缓存降级：返回过期缓存
   原本 5 分钟过期 → 出错时用 1 小时内的

3. 简化降级：返回简化版数据
   推荐列表 → 热门列表

4. 异步降级：放队列稍后处理
   下单 → 支付服务挂了 → 进队列稍后扣款

5. 限流降级：超过容量直接返回
   "系统繁忙，请稍后再试"
```

## 限流（Rate Limit）

```typescript
// Redis 滑动窗口
async function rateLimit(key: string, limit: number, windowMs: number): Promise<boolean> {
  const now = Date.now();
  const windowKey = `rl:${key}`;
  
  const pipeline = redis.pipeline();
  pipeline.zremrangebyscore(windowKey, 0, now - windowMs);
  pipeline.zcard(windowKey);
  pipeline.zadd(windowKey, now, `${now}-${randomUUID()}`);
  pipeline.expire(windowKey, Math.ceil(windowMs / 1000));
  
  const results = await pipeline.exec();
  const count = results[1][1] as number;
  
  return count < limit;
}
```

```java
// Spring + Bucket4j
@Bean
public Bucket bucket() {
  return Bucket.builder()
    .addLimit(Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1))))
    .build();
}

@RestController
public class ApiController {
  @Autowired private Bucket bucket;
  
  @GetMapping("/api/data")
  public ResponseEntity<?> getData() {
    if (!bucket.tryConsume(1)) {
      return ResponseEntity.status(429)
        .header("Retry-After", "60")
        .body(new ErrorResponse("RATE_LIMITED", "Too many requests"));
    }
    return ResponseEntity.ok(data);
  }
}
```

## 舱壁隔离（Bulkhead）

```text
为不同业务分配独立线程池 / 连接池：
  - Critical（核心）：50 连接
  - Normal（普通）：30 连接
  - Background（后台）：20 连接

避免一个业务把池吃完拖死其他业务
```

```java
// Resilience4j Bulkhead
@Bulkhead(name = "paymentApi", fallbackMethod = "paymentBulkheadFallback")
public PaymentResult charge(...) { ... }
```

## 工作流程

```text
1. 列出所有外部依赖
   - 第三方 API
   - 数据库
   - 缓存
   - 消息队列
   - 文件存储

2. 每个依赖配置：
   - 超时
   - 重试策略
   - 熔断阈值
   - 降级方案

3. 全局错误处理
   - 异常分类
   - 状态码映射
   - 不暴露内部细节

4. 限流策略
   - 接入网关层 / 应用层
   - 用户级 / IP 级 / 接口级

5. 监控
   - 错误率
   - 重试次数
   - 熔断状态
   - 限流触发率

6. 测试
   - 故障注入（Chaos）
   - 超时模拟
   - 连接池耗尽
```

## 配套模板

- `templates/resilience-checklist.md` — 韧性配置清单 + 异常映射 + 重试 + 熔断 + 降级 + 限流

## 质量自检

```text
□ 所有外部调用有超时
□ 重试策略明确（次数 + 退避 + 抖动）
□ 区分可重试 vs 不可重试错误
□ 熔断器配置（阈值 + 恢复）
□ 降级方案存在
□ 全局错误处理器
□ 错误码统一
□ 不暴露内部细节给前端
□ 异常完整记日志
□ 限流配置（接口级 / 用户级）
□ 监控关键指标
□ 故障注入测试
```

## 常见坑

1. **不设超时**——一个慢调用拖垮整个服务
2. **catch 不抛**——隐藏 Bug
3. **catch all + log**——业务异常被吞
4. **重试无上限**——僵尸请求
5. **重试不区分错误类型**——4xx 也重试
6. **不抖动**——惊群效应
7. **熔断阈值过严**——正常波动也触发
8. **熔断没有降级**——熔了用户看到错
9. **错误信息暴露内部**——SQL / 堆栈外泄
10. **限流只看 IP**——NAT 后多用户共享
11. **限流粒度太粗**——一接口限流影响全平台
12. **不监控错误率**——故障扩散无感
13. **错误码乱**——前端处理混乱
14. **不做故障演练**——上线才发现

## 与其他 skill 的协作

```text
上游：
  api-implementation → 全局错误处理器
  async-jobs → 任务重试策略
  caching-strategy → 缓存挂了的降级

下游：
  observability → 错误监控
  testing-implementation → 故障测试
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — 韧性库选型
