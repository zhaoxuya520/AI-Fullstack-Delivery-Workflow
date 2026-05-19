# 大厂后端工程实践参考

> 来源：公开技术博客、架构大会分享、开源项目。面向 APP/小程序/网页后端。

## 1. 阿里巴巴 Java 开发手册精华

### 分层架构（强制）
```text
Controller 层 → 参数校验 + 转换 + 调用 Service
Service 层   → 业务逻辑（核心价值在这里）
DAO 层       → 数据访问（MyBatis-Plus / JPA）
Manager 层   → 通用业务处理（缓存/MQ/第三方调用）

禁止跨层调用：Controller 不能直接调 DAO
```

### 命名规范
```text
类名：UpperCamelCase（UserService）
方法名：lowerCamelCase（getUserById）
常量：UPPER_SNAKE_CASE（MAX_RETRY_COUNT）
包名：全小写（com.example.user.service）

DAO 层：XxxMapper / XxxRepository
Service 层：XxxService（接口）/ XxxServiceImpl（实现）
Controller 层：XxxController
DTO：XxxRequest / XxxResponse / XxxDTO
```

### 异常处理（强制）
```java
// ❌ 错误：catch 后只打日志
try {
    userService.create(user);
} catch (Exception e) {
    log.error("创建用户失败", e);  // 然后呢？调用方不知道失败了！
}

// ✅ 正确：统一业务异常
public class BizException extends RuntimeException {
    private final String code;
    private final String message;
}

// 全局异常处理器
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BizException.class)
    public Result<?> handleBiz(BizException e) {
        return Result.fail(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(Exception.class)
    public Result<?> handleUnknown(Exception e) {
        log.error("未知异常", e);
        return Result.fail("INTERNAL_ERROR", "系统繁忙，请稍后重试");
    }
}
```

### 统一返回格式
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": { ... },
  "traceId": "abc123"
}

{
  "code": "USER_NOT_FOUND",
  "message": "用户不存在",
  "data": null,
  "traceId": "abc123"
}
```

---

## 2. Spring Boot 生产配置

### 必备依赖
```xml
<!-- 生产项目必备 starter -->
spring-boot-starter-web
spring-boot-starter-validation    <!-- 参数校验 -->
spring-boot-starter-data-redis    <!-- 缓存 -->
spring-boot-starter-actuator      <!-- 健康检查+指标 -->
micrometer-registry-prometheus    <!-- Prometheus 指标 -->
springdoc-openapi-starter-webmvc  <!-- OpenAPI 文档 -->
mybatis-plus-spring-boot3-starter <!-- ORM -->
sa-token-spring-boot3-starter    <!-- 轻量认证 -->
```

### 配置分环境
```yaml
# application.yml — 公共配置
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: Asia/Shanghai
    default-property-inclusion: non_null

# application-dev.yml
# application-staging.yml
# application-prod.yml（敏感信息用环境变量）
```

---

## 3. NestJS 生产模式

### 项目结构
```text
src/
├── main.ts
├── app.module.ts
├── common/
│   ├── decorators/         # 自定义装饰器
│   ├── filters/            # 异常过滤器
│   ├── guards/             # 认证守卫
│   ├── interceptors/       # 拦截器（日志/transform）
│   └── pipes/              # 校验管道
├── modules/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   ├── dto/
│   │   └── guards/
│   ├── user/
│   └── order/
├── prisma/                 # Prisma schema + migrations
└── config/                 # 环境配置
```

### 统一响应拦截器
```typescript
// common/interceptors/transform.interceptor.ts
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Result<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Result<T>> {
    return next.handle().pipe(
      map(data => ({
        code: 'SUCCESS',
        message: '操作成功',
        data,
        traceId: context.switchToHttp().getRequest().id,
      })),
    );
  }
}
```

---

## 4. 高并发场景范式

### 接口幂等性（支付/扣款必须）
```text
方案选择：
  Token 机制  → 前端获取 token，后端消费一次
  唯一索引   → 业务唯一键（订单号+操作类型）
  状态机     → 只允许特定状态转换
  乐观锁     → version 字段 + CAS 更新

推荐：唯一索引（最简单可靠）
  INSERT INTO payment_records (order_id, type, amount)
  VALUES ('ORD001', 'PAY', 9900)
  ON CONFLICT (order_id, type) DO NOTHING;
```

### 分布式锁（防并发竞争）
```java
// Redis 分布式锁（Redisson）
@Autowired
private RedissonClient redisson;

public void deductStock(String productId, int quantity) {
    RLock lock = redisson.getLock("stock:" + productId);
    try {
        if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
            // 扣减库存
            int stock = getStock(productId);
            if (stock < quantity) throw new BizException("INSUFFICIENT_STOCK");
            updateStock(productId, stock - quantity);
        } else {
            throw new BizException("SYSTEM_BUSY", "系统繁忙，请重试");
        }
    } finally {
        lock.unlock();
    }
}
```

### 限流方案
```text
层级          │ 工具              │ 粒度
─────────────┼───────────────────┼──────────────
网关层        │ Nginx limit_req   │ IP 级
应用层        │ Guava RateLimiter │ 接口级
Redis 层      │ Lua 脚本滑动窗口  │ 用户+接口级
中间件层      │ Sentinel / Hystrix │ 服务级

生产推荐：网关 + Redis Lua 双层限流
```

---

## 5. 数据库最佳实践

### 索引规范
```text
1. 主键用自增 Long 或 UUID（不用业务字段做主键）
2. 频繁查询的字段建索引
3. 联合索引最左匹配原则
4. 索引字段不超过 5 个
5. 不在大字段（TEXT/BLOB）上建索引
6. 覆盖索引减少回表

命名：idx_表名_字段1_字段2
```

### 分页查询（大数据量）
```sql
-- ❌ 错误：OFFSET 大时极慢
SELECT * FROM orders ORDER BY id LIMIT 10 OFFSET 1000000;

-- ✅ 正确：游标分页（Cursor-based）
SELECT * FROM orders WHERE id > :lastId ORDER BY id LIMIT 10;

-- ✅ 正确：Keyset 分页
SELECT * FROM orders 
WHERE (created_at, id) < (:lastDate, :lastId)
ORDER BY created_at DESC, id DESC
LIMIT 10;
```

---

## 6. 认证方案对比

| 方案 | 适合 | 优势 | 劣势 |
|------|------|------|------|
| **JWT（无状态）** | APP/小程序/SPA | 不需要 Session 存储，分布式友好 | 无法主动失效，payload 可解码 |
| **JWT + Redis** | 生产推荐 | 可主动失效 + 无状态优势 | 多一层 Redis |
| **Session + Cookie** | 传统 Web（MPA） | 服务端控制，可主动失效 | 不适合移动端 |
| **OAuth 2.0** | 第三方登录（微信/GitHub） | 标准协议 | 流程复杂 |
| **Sa-Token** | 国内 Java 项目 | 简单好用，功能丰富 | Java Only |

### JWT + Redis 生产方案
```text
登录：
  1. 验证用户名密码
  2. 生成 access_token（15min）+ refresh_token（7d）
  3. 将 refresh_token 存 Redis（key=user_id）
  4. 返回双 token

请求：
  1. 请求头 Authorization: Bearer <access_token>
  2. 验证签名 + 过期时间
  3. 过期 → 用 refresh_token 换新 access_token

登出：
  1. 删除 Redis 中的 refresh_token
  2. 将 access_token 加入黑名单（TTL=剩余有效期）
```

---

## 7. 缓存策略

```text
┌─ 缓存决策 ────────────────────────────────────────────────┐
│                                                            │
│  数据特征        │ 缓存策略        │ TTL                   │
│  ─────────────────────────────────────────────────────── │
│  高频读低频写    │ Cache-Aside     │ 5~30 min              │
│  实时性要求高    │ Write-Through   │ 短 TTL + 主动失效     │
│  容忍短暂不一致  │ Cache-Aside     │ 1~5 min               │
│  热点数据        │ 本地缓存+Redis  │ 本地 30s + Redis 5min │
│  计算密集结果    │ 缓存结果        │ 按场景                │
│                                                            │
│  Cache-Aside 标准流程：                                    │
│  读：查缓存 → 命中返回 → 未命中查 DB → 写入缓存           │
│  写：更新 DB → 删除缓存（不是更新缓存！）                  │
└────────────────────────────────────────────────────────────┘
```

---

## 8. 常见坑（大厂总结）

```text
1. N+1 查询：ORM 关联查询默认懒加载
   解法：eager loading / join fetch / batch fetch

2. 缓存穿透：查不存在的数据每次打 DB
   解法：布隆过滤器 / 缓存空值（TTL 短）

3. 缓存雪崩：大量 key 同时过期
   解法：TTL 加随机值 / 热点永不过期 + 异步更新

4. 缓存击穿：热点 key 过期瞬间大量请求
   解法：互斥锁 / 逻辑过期

5. 分布式事务：跨服务数据一致性
   解法：最终一致（MQ + 重试）/ Saga / TCC

6. 大事务：事务内做 HTTP/MQ 调用
   解法：缩小事务范围 / 编程式事务 / 事务外发消息

7. 慢查询：未加索引 / 全表扫描
   解法：EXPLAIN ANALYZE + 加索引 / 分页优化

8. 接口超时级联：上游慢拖垮下游
   解法：超时+重试+熔断（Resilience4j/Sentinel）

9. 日志无 traceId：问题定位困难
   解法：MDC + 全链路 traceId 透传

10. 密钥硬编码：代码泄露 = 密钥泄露
    解法：环境变量 / Vault / KMS
```
