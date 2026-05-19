---
name: caching-strategy
description: 设计和实现缓存策略时使用。覆盖 Redis / Memcached / Caffeine（Java）/ NestJS Cache / Spring Cache / Django Cache。融合 5 种缓存模式 + 三大缓存问题 + 失效策略。
---

# 缓存策略（Caching Strategy）

参考来源：Martin Fowler《Patterns of Enterprise Application Architecture》Cache、Stripe / Netflix / Twitter 缓存实践、Redis 官方最佳实践、Spring Cache / NestJS Cache 文档。

## 适用场景

- 高频读 / 低频写场景
- 复杂查询结果缓存
- 第三方 API 响应缓存
- 会话 / 配置数据
- 分布式锁 / 限流计数器
- 验证码 / 短期 Token 存储

## 核心原则

```text
1. 不为过早优化引入缓存
   先确认 DB 真的是瓶颈

2. 缓存必须可失效 / 可清除
   有缓存就有不一致

3. 缓存 Key 设计要稳定 + 唯一
   不要用查询参数随便拼

4. TTL 必须设置
   永不过期 = 内存泄漏

5. 接受最终一致性
   "实时" 和 "缓存" 二选一

6. 防三大问题：穿透 / 击穿 / 雪崩
   每个高并发缓存都要考虑

7. 缓存 hit 率 > 80% 才有意义
   < 50% 增加复杂度无收益
```

## 5 种缓存模式

### 1. Cache-Aside（最常用）

```text
应用控制：
  读：先查缓存，未命中查 DB，回填缓存
  写：写 DB，失效缓存

优点：简单、可控
缺点：首次请求慢
```

```java
// Spring 范式
@Service
public class ProductService {
  @Cacheable(value = "products", key = "#id")
  public Product getById(Long id) {
    return productRepo.findById(id).orElse(null);
  }
  
  @CacheEvict(value = "products", key = "#product.id")
  public void update(Product product) {
    productRepo.save(product);
  }
  
  @CacheEvict(value = "products", allEntries = true)
  public void clearAll() { /* 批量失效 */ }
}
```

```typescript
// NestJS 范式
@Injectable()
export class ProductService {
  constructor(
    @Inject(CACHE_MANAGER) private cache: Cache,
    private productRepo: ProductRepository,
  ) {}

  async getById(id: number): Promise<Product> {
    const cacheKey = `product:${id}`;
    const cached = await this.cache.get<Product>(cacheKey);
    if (cached) return cached;
    
    const product = await this.productRepo.findById(id);
    if (product) {
      await this.cache.set(cacheKey, product, 600);  // 10 min TTL
    }
    return product;
  }
  
  async update(product: Product): Promise<Product> {
    const updated = await this.productRepo.update(product);
    await this.cache.del(`product:${product.id}`);
    return updated;
  }
}
```

```python
# Django
from django.core.cache import cache

def get_product(product_id):
    cache_key = f'product:{product_id}'
    product = cache.get(cache_key)
    if product is None:
        product = Product.objects.get(id=product_id)
        cache.set(cache_key, product, 600)  # 10 min
    return product

def update_product(product):
    product.save()
    cache.delete(f'product:{product.id}')
```

### 2. Read-Through

```text
缓存层负责加载：
  读：先查缓存，未命中由缓存层加载
  
特点：应用代码不知道是否未命中
```

### 3. Write-Through

```text
写穿：
  写：同时写缓存和 DB，都成功才返回

优点：缓存与 DB 强一致
缺点：写慢一倍
```

### 4. Write-Behind / Write-Back

```text
写后异步：
  写：先写缓存，异步刷 DB

优点：写极快
缺点：DB 故障可能丢数据
```

### 5. Refresh-Ahead

```text
预测刷新：
  快过期前主动刷新（避免缓存击穿）

适合：热点数据 + 读非常多
```

## 三大缓存问题

### 1. 缓存穿透

```text
症状：查询不存在的数据，每次都打 DB
攻击：恶意构造大量不存在的 ID 查询

解决：
  方案 A：缓存空值（短 TTL）
    cache.set('user:999999', null, 60);
  
  方案 B：布隆过滤器（Bloom Filter）
    if (!bloomFilter.mightContain(id)) return null;
```

```java
// Spring + 缓存空值
@Cacheable(value = "products", key = "#id", unless = "#result == null")
// unless 控制不缓存 null

// 但要主动缓存"已知不存在"
public Product getById(Long id) {
  Product product = productRepo.findById(id).orElse(null);
  if (product == null) {
    cache.put("products::" + id, NULL_PLACEHOLDER, Duration.ofMinutes(1));
  }
  return product;
}
```

### 2. 缓存击穿

```text
症状：热点 key 过期瞬间，大量请求穿透到 DB
影响：DB 瞬间压力 100x

解决：
  方案 A：互斥锁（Mutex Lock）
    只让 1 个请求重建缓存
  
  方案 B：永不过期 + 异步刷新
    缓存自身不过期，定时后台刷新
  
  方案 C：Refresh-Ahead
    临近过期时主动刷新
```

```typescript
// 互斥锁示例（Redis）
async function getWithMutex(key: string): Promise<any> {
  let value = await redis.get(key);
  if (value) return value;
  
  // 尝试拿锁（30 秒超时）
  const lock = await redis.set(`lock:${key}`, '1', 'PX', 30000, 'NX');
  if (!lock) {
    // 其他人在重建，等一下再读
    await sleep(50);
    return getWithMutex(key);
  }
  
  try {
    value = await loadFromDB(key);
    await redis.set(key, value, 'EX', 600);
    return value;
  } finally {
    await redis.del(`lock:${key}`);
  }
}
```

### 3. 缓存雪崩

```text
症状：大量 key 同时过期 / 缓存服务挂了
影响：DB 瞬间压力爆炸

解决：
  方案 A：TTL 加随机抖动
    expire = base + random(0, 300)  // 防同时过期
  
  方案 B：多级缓存（Caffeine + Redis）
    L1 进程内 + L2 分布式
  
  方案 C：限流 + 熔断
    DB 压力大时降级返回兜底数据
  
  方案 D：缓存预热
    上线前手动 warm up 关键 key
```

## 缓存 Key 设计

```text
✅ 推荐：
  product:123                          # 简单实体
  user:123:profile                     # 实体 + 字段
  list:orders:user:123:status:paid:p1  # 列表查询
  count:active_users:tenant:5          # 计数器

❌ 反例：
  user_123_profile (用 _ 容易冲突)
  user-123-profile (-/_ 不一致)
  $user:123:profile (特殊字符问题)
  USER:123 (大小写混用)
```

### 命名规范

```text
1. 用 ":" 分隔层次（Redis 习惯）
2. 小写
3. 业务前缀 + 实体类型 + ID + 字段
4. 列表查询带过滤参数
5. 长度 < 128 字节
```

## TTL 策略

```text
不同数据 TTL 不同：

会话 / Token：     30 分钟 ~ 24 小时
配置数据：         1 小时 ~ 1 天
实体详情：         10 分钟 ~ 1 小时
列表查询：         1 ~ 10 分钟
计数器：           短期（秒级）
排行榜：           5 ~ 60 分钟
统计聚合：         1 ~ 24 小时

防雪崩：
  TTL = base + jitter
  base = 600 秒
  jitter = random(0, 300) 秒
```

## 缓存失效策略

### 1. 主动失效（写时清理）

```typescript
// 数据更新时同步失效
async function updateProduct(product: Product) {
  await productRepo.update(product);
  await cache.del([
    `product:${product.id}`,
    `product:list:*`,  // 通配符失效（慎用）
  ]);
}
```

### 2. 被动失效（TTL）

```typescript
await cache.set(key, value, 'EX', 600);  // 10 min 后过期
```

### 3. 版本号失效

```typescript
// 不删除缓存，改版本号
const version = await cache.incr(`product:list:version`);

// 读
async function getList() {
  const version = await cache.get('product:list:version');
  return cache.get(`product:list:${version}`);
}

// 写
async function update() {
  await productRepo.update();
  await cache.incr('product:list:version');  // 版本号 +1
}
```

### 4. 标签失效（Tag-based）

```typescript
// 缓存时打标签
await cache.set('product:1', data, { tags: ['products', 'category:electronics'] });

// 失效某标签下全部
await cache.invalidateTag('category:electronics');
```

## 多级缓存（L1 + L2）

```text
L1：进程内（Caffeine / Map / LRU）
  - 极低延迟（< 1μs）
  - 容量小
  - 实例间不一致

L2：分布式（Redis）
  - 实例间一致
  - 网络延迟（~ 1ms）

读流程：
  L1 命中 → 返回
  L1 未命中 → 查 L2
  L2 命中 → 写 L1，返回
  L2 未命中 → 查 DB，写 L1 + L2
```

```java
// Spring + Caffeine + Redis 多级
@Configuration
public class CacheConfig {
  @Bean
  public CacheManager cacheManager() {
    CompositeCacheManager composite = new CompositeCacheManager(
      caffeineCacheManager(),  // L1
      redisCacheManager()      // L2
    );
    composite.setFallbackToNoOpCache(true);
    return composite;
  }
}
```

## 分布式锁（Redis）

```typescript
// 单实例锁（SET NX）
async function acquireLock(key: string, ttl: number): Promise<boolean> {
  const result = await redis.set(`lock:${key}`, '1', 'PX', ttl, 'NX');
  return result === 'OK';
}

// Redlock（多实例）：用 Redlock 库
import Redlock from 'redlock';
const redlock = new Redlock([redis1, redis2, redis3]);
const lock = await redlock.acquire(['resource'], 5000);
try {
  // 临界区
} finally {
  await lock.release();
}
```

## 限流（Rate Limit）

```typescript
// 滑动窗口限流
async function checkRateLimit(userId: string, limit: number, windowMs: number): Promise<boolean> {
  const key = `ratelimit:${userId}`;
  const now = Date.now();
  
  // 移除过期记录
  await redis.zremrangebyscore(key, 0, now - windowMs);
  
  // 计数
  const count = await redis.zcard(key);
  if (count >= limit) return false;
  
  // 加入新记录
  await redis.zadd(key, now, `${now}-${randomUUID()}`);
  await redis.expire(key, Math.ceil(windowMs / 1000));
  return true;
}
```

## 工作流程

```text
1. 评估是否需要缓存
   - DB 真的是瓶颈吗？
   - 数据更新频率？
   - 一致性要求？

2. 选择缓存模式
   - Cache-Aside（默认）
   - Write-Through（强一致）
   - Read-Through（封装好）

3. 设计 Key
   - 命名规范
   - 长度合理
   - 唯一可识别

4. 设计 TTL
   - 业务可接受的不一致时长
   - 加随机抖动

5. 设计失效
   - 写时主动清理
   - 或：版本号
   - 或：标签

6. 防三大问题
   - 穿透：缓存空值 / 布隆
   - 击穿：互斥锁 / 永不过期
   - 雪崩：TTL 抖动 / 多级 / 限流

7. 监控
   - hit rate
   - 内存使用
   - 慢查询
   - 连接池

8. 验证
   - 压测对比 with/without 缓存
   - hit rate > 80%
```

## 配套模板

- `templates/cache-strategy-template.md` — 缓存方案 + Key 命名 + TTL + 失效 + 防三大问题 + 监控

## 质量自检

```text
□ 缓存有明确收益（DB 是瓶颈）
□ Key 命名规范（业务 : 实体 : ID）
□ TTL 设置（不能永不过期）
□ TTL 加随机抖动防雪崩
□ 写时同步失效
□ 防穿透：缓存空值或布隆
□ 防击穿：互斥锁或永不过期
□ 防雪崩：多级缓存或限流
□ hit rate 监控
□ 内存使用监控
□ 不缓存 PII / 敏感数据
□ 用结构化命名（前缀分隔）
□ 大对象考虑序列化效率
□ 不滥用通配符 KEYS（生产禁用）
```

## 常见坑

1. **TTL 永不过期**——内存泄漏
2. **大量 key 同时过期**——雪崩
3. **缓存穿透**——攻击者构造不存在 ID
4. **击穿**——热点 key 过期瞬间打爆 DB
5. **Key 命名不规范**——冲突 / 找不到
6. **缓存与 DB 不一致**——业务用过期数据
7. **Redis KEYS \***——生产环境锁全库
8. **缓存大对象**——一个 key 占 100MB
9. **不监控 hit rate**——缓存命中率 10% 在浪费
10. **Mock 数据进生产缓存**——用户看到测试数据
11. **不防止缓存击穿**——一个 key 失效压垮 DB
12. **TTL 设错单位**——secs vs ms 搞错
13. **批量删除用 KEYS**——应该用 SCAN
14. **缓存里存 Token**——日志泄露

## 与其他 skill 的协作

```text
上游：
  data-access → 数据访问 + 缓存层
  observability → 缓存监控

下游：
  error-handling-resilience → 缓存挂了的降级
  async-jobs → 异步刷新缓存
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — 缓存方案对比
