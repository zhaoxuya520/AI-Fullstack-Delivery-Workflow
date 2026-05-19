---
name: async-jobs
description: 实现异步任务 / 消息队列 / 定时任务 / 后台 worker 时使用。覆盖 RabbitMQ / Kafka / Redis Streams / Bull / Celery / Sidekiq / Spring @Async / Temporal。融合 At-least-once + 幂等 + 死信 + Outbox 模式。
---

# 异步任务（Async Jobs）

参考来源：Gregor Hohpe《Enterprise Integration Patterns》、Stripe Workflows 实践、Uber Cadence/Temporal、Outbox Pattern（Chris Richardson）。

## 适用场景

- 耗时操作（发邮件、生成报表、视频转码）
- 第三方 API 集成（异步重试）
- 解耦服务（事件驱动）
- 削峰填谷
- 定时任务（cron）
- 工作流编排（多步骤业务流程）

## 核心原则

```text
1. 任务必须幂等
   At-least-once 投递 = 至少一次 = 可能多次

2. 任务必须可重试
   有最大次数 + 重试间隔策略

3. 任务必须有死信队列
   超过最大重试进死信，人工介入

4. 任务参数小（< 256KB）
   大对象用 ID 引用，不传完整数据

5. 不在事务内发消息
   用 Outbox 模式保证 DB + MQ 一致

6. 区分实时性要求
   延迟 < 1s：内存队列
   延迟 < 10s：Redis Streams
   延迟可接受：RabbitMQ / Kafka

7. 监控核心指标
   队列深度 / 处理延迟 / 失败率 / 死信数
```

## 消息队列选型

| 方案 | 适合场景 | 吞吐 | 持久化 | 事务 |
|---|---|---|---|---|
| **RabbitMQ** | 业务任务、复杂路由 | 万级 | ✅ | ✅ |
| **Apache Kafka** | 事件流、大数据 | 百万级 | ✅ | ✅ |
| **Redis Streams** | 轻量、Redis 一站式 | 十万级 | ✅ | 弱 |
| **AWS SQS** | 托管、Serverless | 万级 | ✅ | - |
| **NATS** | 微服务间通信 | 百万级 | 可选 | - |
| **Apache Pulsar** | 多租户、Kafka 替代 | 百万级 | ✅ | ✅ |

## 任务队列框架

| 框架 | 语言 | 后端 | 特点 |
|---|---|---|---|
| **Bull / BullMQ** | TS | Redis | NestJS 友好、UI 好 |
| **Celery** | Python | Redis / RabbitMQ | Python 标杆、生态全 |
| **Sidekiq** | Ruby | Redis | Rails 标配 |
| **Spring Batch** | Java | DB-based | 企业级批处理 |
| **Spring @Async** | Java | 内存（默认）/ MQ | 轻量异步 |
| **Asynq** | Go | Redis | Go 任务队列 |
| **Hangfire** | C# | DB-based | .NET 标配 |
| **Temporal** | 多语言 | 自建 | 工作流引擎、复杂编排 |

## NestJS + BullMQ 范式

```typescript
// 1. 配置队列
@Module({
  imports: [
    BullModule.registerQueue({
      name: 'email',
      defaultJobOptions: {
        attempts: 3,
        backoff: { type: 'exponential', delay: 1000 },
        removeOnComplete: 100,
        removeOnFail: 1000,
      },
    }),
  ],
})
export class AppModule {}

// 2. 生产者
@Injectable()
export class OrderService {
  constructor(@InjectQueue('email') private emailQueue: Queue) {}
  
  async createOrder(dto: CreateOrderDto) {
    const order = await this.repo.create(dto);
    
    // 发送任务（不阻塞主流程）
    await this.emailQueue.add('send-confirmation', {
      orderId: order.id,
      userEmail: order.user.email,
    }, {
      jobId: `email:${order.id}`,  // 幂等键
      delay: 5000,  // 5 秒后执行
    });
    
    return order;
  }
}

// 3. 消费者
@Processor('email')
export class EmailProcessor {
  constructor(private mailService: MailService) {}
  
  @Process('send-confirmation')
  async handleSendConfirmation(job: Job<{orderId: number; userEmail: string}>) {
    const { orderId, userEmail } = job.data;
    
    // 幂等检查
    const sent = await this.checkSent(orderId);
    if (sent) {
      return { skipped: true };
    }
    
    await this.mailService.sendConfirmation(userEmail, orderId);
    await this.markSent(orderId);
  }
  
  @OnQueueFailed()
  onFailed(job: Job, err: Error) {
    if (job.attemptsMade >= job.opts.attempts) {
      // 进入死信，告警
      this.alertService.notify('Email job failed after retries', { jobId: job.id, err });
    }
  }
}
```

## Spring + RabbitMQ 范式

```java
// 1. 配置
@Configuration
public class RabbitConfig {
  @Bean
  public Queue emailQueue() {
    return QueueBuilder.durable("email.queue")
      .withArgument("x-dead-letter-exchange", "dlx")
      .withArgument("x-dead-letter-routing-key", "email.dead")
      .withArgument("x-message-ttl", 3600000)
      .build();
  }
  
  @Bean
  public Queue emailDeadLetterQueue() {
    return QueueBuilder.durable("email.dead").build();
  }
}

// 2. 生产者
@Service
public class OrderService {
  @Autowired
  private RabbitTemplate rabbitTemplate;
  
  @Transactional
  public Order createOrder(CreateOrderRequest req) {
    Order order = orderRepo.save(...);
    
    // 用 Outbox 模式（详见下文）
    outboxRepo.save(new OutboxEvent("email.send", order.getId()));
    return order;
  }
}

// 3. 消费者
@Component
public class EmailListener {
  @RabbitListener(queues = "email.queue")
  public void handleEmail(EmailMessage message) {
    try {
      // 幂等检查
      if (isAlreadySent(message.getJobId())) return;
      
      mailService.send(message);
      markSent(message.getJobId());
    } catch (RetryableException e) {
      throw new AmqpRejectAndDontRequeueException(e);  // 进死信
    }
  }
  
  @RabbitListener(queues = "email.dead")
  public void handleDeadLetter(EmailMessage message) {
    log.error("Dead letter: {}", message);
    alertService.notify("Email DLQ", message);
  }
}
```

## Python + Celery 范式

```python
# 1. 配置
from celery import Celery

app = Celery('myapp', broker='redis://localhost:6379/0', backend='redis://localhost:6379/1')

app.conf.update(
    task_acks_late=True,  # 任务完成后才 ack（防丢）
    task_reject_on_worker_lost=True,
    worker_prefetch_multiplier=1,  # 公平分发
    task_default_retry_delay=60,
    task_max_retries=3,
)

# 2. 任务定义
@app.task(
    bind=True,
    autoretry_for=(RetryableError,),
    retry_backoff=True,
    retry_backoff_max=300,
    max_retries=5,
)
def send_email(self, order_id: int, user_email: str):
    if is_already_sent(order_id):
        return {'skipped': True}
    
    try:
        mail_service.send(user_email, order_id)
        mark_sent(order_id)
    except SmtpTransientError as e:
        # 重试
        raise self.retry(exc=e)
    except SmtpPermanentError as e:
        # 不重试，进死信
        log.error(f'Permanent error: {e}')
        raise

# 3. 生产
@transaction.atomic
def create_order(...):
    order = Order.objects.create(...)
    # 用 transaction.on_commit 保证 DB 提交后才发任务
    transaction.on_commit(
        lambda: send_email.apply_async(
            args=[order.id, order.user.email],
            countdown=5,  # 5 秒后
        )
    )
    return order
```

## Go + Asynq 范式

```go
// 任务定义
type EmailTask struct {
    OrderID int64
    Email   string
}

// 生产
func (s *OrderService) CreateOrder(ctx context.Context, req CreateOrderRequest) error {
    // 在事务里
    return s.db.Transaction(func(tx *gorm.DB) error {
        order := &Order{...}
        if err := tx.Create(order).Error; err != nil {
            return err
        }
        
        // Outbox：写到事件表
        return tx.Create(&Outbox{
            Type:    "email.send",
            Payload: mustJson(EmailTask{OrderID: order.ID, Email: order.Email}),
        }).Error
    })
}

// 消费（独立进程）
func handleEmail(ctx context.Context, t *asynq.Task) error {
    var task EmailTask
    if err := json.Unmarshal(t.Payload(), &task); err != nil {
        return fmt.Errorf("unmarshal: %w", err)
    }
    
    // 幂等
    if alreadySent(task.OrderID) {
        return nil
    }
    
    if err := mailService.Send(task.Email, task.OrderID); err != nil {
        return fmt.Errorf("send: %w", err)  // 自动重试
    }
    return markSent(task.OrderID)
}

// Worker
srv := asynq.NewServer(redisOpt, asynq.Config{
    Concurrency: 10,
    Queues: map[string]int{"critical": 6, "default": 3, "low": 1},
})
mux := asynq.NewServeMux()
mux.HandleFunc("email.send", handleEmail)
srv.Run(mux)
```

## Outbox 模式（解决事务一致性）

```text
问题：
  在事务里 send 消息：
    BEGIN;
    INSERT order;
    SEND email message;  ← 如果发送失败但 commit 了，怎么办？
    COMMIT;
  
  消息发送和事务无法原子化。

Outbox 解决：
  1. 业务操作 + 写入 outbox 表（同一事务）
     BEGIN;
     INSERT order;
     INSERT outbox(type='email', payload=...);
     COMMIT;
  
  2. 独立进程定期扫 outbox 表，发送消息
     SELECT * FROM outbox WHERE published_at IS NULL;
     SEND message;
     UPDATE outbox SET published_at = NOW() WHERE id = ?;
  
  3. 也可用 CDC（Debezium 监听 binlog）

优势：
  - 业务和消息原子一致
  - 消息发送失败可重试
  - 可审计
```

```sql
CREATE TABLE outbox (
  id bigserial PRIMARY KEY,
  event_type varchar(64) NOT NULL,
  payload jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  published_at timestamptz,
  attempts integer DEFAULT 0
);

CREATE INDEX idx_outbox_unpublished ON outbox(created_at) 
WHERE published_at IS NULL;
```

## 工作流编排（Temporal / Cadence）

复杂多步骤流程（如订单 → 支付 → 库存 → 物流）用 Temporal：

```typescript
// Workflow 定义
export async function orderFulfillment(orderId: number): Promise<void> {
  await wf.workflowInfo();
  
  try {
    await wf.executeActivity('reserveInventory', { orderId, scheduleToCloseTimeout: '1m' });
    await wf.executeActivity('processPayment', { orderId, scheduleToCloseTimeout: '5m' });
    await wf.executeActivity('shipOrder', { orderId, scheduleToCloseTimeout: '1d' });
  } catch (err) {
    // 自动补偿
    await wf.executeActivity('refund', { orderId });
    await wf.executeActivity('releaseInventory', { orderId });
    throw err;
  }
}
```

## 重试策略

```text
立即重试：1 次
指数退避：
  attempt 1: wait 1s
  attempt 2: wait 4s
  attempt 3: wait 16s
  attempt 4: wait 64s
  attempt 5: 进死信

抖动（防雷鸣）：
  wait = base * 2^attempt + random(0, 1000ms)
```

```typescript
// BullMQ 配置
{
  attempts: 5,
  backoff: { type: 'exponential', delay: 1000 },  // 1s, 2s, 4s, 8s, 16s
}
```

## 定时任务

```typescript
// NestJS Schedule
@Injectable()
export class CronService {
  @Cron('0 0 * * *')  // 每天 0 点
  async dailyReport() {
    await this.reportService.generate();
  }
  
  @Interval(60000)  // 每分钟
  async healthCheck() {
    await this.checkUpstream();
  }
}
```

```python
# Celery Beat
app.conf.beat_schedule = {
    'daily-report': {
        'task': 'tasks.daily_report',
        'schedule': crontab(hour=0, minute=0),
    },
}
```

## 工作流程

```text
1. 评估是否需要异步
   - 主流程实时性？
   - 失败可接受性？
   - 用户感知？

2. 选择队列方案
   - 简单 → BullMQ / Asynq / Sidekiq
   - 复杂 → RabbitMQ / Kafka
   - 工作流 → Temporal

3. 设计任务
   - 参数小（用 ID 引用）
   - 幂等（用业务唯一键）
   - 可重试

4. 设计死信处理
   - 监控告警
   - 人工介入流程

5. 选择事务一致性方案
   - 简单：transaction.on_commit
   - 严格：Outbox 模式

6. 监控
   - 队列深度
   - 处理延迟 P99
   - 失败率
   - 死信积压

7. 测试
   - 重试场景
   - 并发场景
   - 死信场景
```

## 配套模板

- `templates/async-job-template.md` — 任务设计 + 幂等 + 重试 + 死信 + Outbox + 监控

## 质量自检

```text
□ 任务幂等（同任务多次执行结果一致）
□ 重试策略明确（次数 + 间隔）
□ 死信队列存在 + 告警
□ 任务参数 < 256KB
□ 大数据用 ID 引用
□ 不在事务里发消息（用 Outbox 或 on_commit）
□ 监控：队列深度 / 延迟 / 失败率
□ 优雅关闭（Worker 处理完再退出）
□ 任务超时设置
□ 队列分级（critical / default / low）
```

## 常见坑

1. **任务不幂等**——重复执行扣款两次
2. **不用死信队列**——失败任务丢失
3. **任务参数太大**——队列爆炸
4. **事务里发消息**——DB 回滚但消息已发
5. **不监控队列深度**——堆积到爆才发现
6. **重试无上限**——僵尸任务
7. **不区分可重试 vs 不可重试错误**——SMTP 拒收一直重试
8. **Worker 不优雅关闭**——任务被 kill 一半
9. **不限制并发**——OOM
10. **同一队列混合长短任务**——长任务堵塞
11. **定时任务多实例重复执行**——加分布式锁
12. **任务无超时**——一直挂着不释放
13. **Mock 任务不发到测试环境**——线上才发现

## 与其他 skill 的协作

```text
上游：
  api-implementation → 接口提交任务
  data-access → Outbox 写库

下游：
  error-handling-resilience → 重试 / 熔断
  observability → 任务监控
  testing-implementation → Mock 队列
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — 队列选型
