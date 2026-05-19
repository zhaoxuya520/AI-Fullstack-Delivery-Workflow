# 缓存策略模板

## 1. 模块信息

```text
模块：
缓存方案：Redis / Memcached / Caffeine / 多级
框架集成：Spring Cache / NestJS Cache / django-cache / 自定义
负责人：
```

---

## 2. 缓存目标

```text
为什么要缓存：
  □ DB 是瓶颈（QPS / 延迟）
  □ 复杂查询结果复用
  □ 第三方 API 限流
  □ 减少 N 次到 1 次

KPI：
  hit rate 目标：≥ 80%
  P99 延迟改善：从 X ms → Y ms
  DB QPS 降低：%
```

---

## 3. 缓存清单

| Key 模式 | 数据 | 模式 | TTL | 失效方式 | 大小预估 |
|---|---|---|---|---|---|
| product:{id} | 商品详情 | Cache-Aside | 600s + jitter | 写时清理 | 5KB |
| user:{id}:profile | 用户资料 | Cache-Aside | 1800s | 写时清理 | 2KB |
| list:products:p{page} | 分页列表 | Read-Through | 60s | 版本号 | 10KB |
| session:{token} | 会话 | Cache-Aside | 1800s | 主动 + TTL | 1KB |
| ratelimit:{user}:{api} | 限流计数 | - | 60s | 自动 | 100B |

---

## 4. 防三大问题

### 防穿透

```text
方案：缓存空值 / 布隆过滤器
实现：[代码片段]
TTL：60s（短）
```

### 防击穿

```text
方案：互斥锁 / 永不过期 + 异步刷新
热点 key：[列表]
实现：[代码片段]
```

### 防雪崩

```text
方案：TTL 抖动 + 多级缓存 + 限流
TTL 公式：base + random(0, base * 0.5)
多级：L1 Caffeine + L2 Redis
```

---

## 5. 失效策略

### 写时失效

| 操作 | 影响的 Key |
|---|---|
| updateProduct(id) | `product:{id}`, `list:products:*` |
| deleteProduct(id) | 同上 |
| createOrder | `user:{userId}:order_count` |

### TTL 兜底

```text
默认 TTL 表：
  - 实体详情：10 min
  - 列表：1 min
  - 配置：1 day
  - 会话：30 min
```

---

## 6. 容量规划

```text
预计 key 数：
预计每 key 大小：
总内存需求：
峰值 QPS：
连接数：

实例规格：
  - Redis 实例：4 vCPU + 8GB
  - 集群模式：是 / 否
  - 副本：1 主 1 从
```

---

## 7. 监控指标

```text
□ hit rate（命中率）
□ ops/sec（操作数）
□ 内存使用 / 上限
□ 慢命令（slowlog）
□ 连接数
□ 网络流量
□ 主从延迟（如集群）
```

---

## 8. 灾难处理

```text
缓存挂了：
  □ 服务降级方案
  □ DB 是否能扛？
  □ 限流策略
  □ 报警阈值

缓存满了：
  □ 淘汰策略：LRU / LFU / TTL
  □ 监控告警

数据不一致：
  □ 失效策略漏洞排查
  □ 双写一致性方案
```

---

## 9. 测试

```text
□ 单元测试：Mock 缓存
□ 集成测试：用真 Redis（Testcontainers）
□ 压测：with vs without 缓存对比
□ 故障注入：缓存挂了行为
□ 一致性验证：写后读
```

---

## 10. 自检

```text
□ Key 命名规范
□ TTL 全部设置
□ TTL 加随机抖动
□ 写时同步失效
□ 三大问题防御
□ hit rate 监控
□ 不缓存 PII
□ 不用 KEYS *
□ 大对象考虑分片
□ 灾难方案
□ 测试覆盖
```
