# 查询优化深度指引

参考：Markus Winand《SQL Performance Explained》、PostgreSQL Internals、MySQL 8.0 优化器文档、High Performance MySQL（O'Reilly）。

## 1. 优化器工作原理

### 基于成本的优化（CBO）

```text
查询 → 解析 → 重写 → 优化器（CBO）→ 执行计划

优化器评估每个候选计划的成本：
  - IO 成本（磁盘读 / 缓存读）
  - CPU 成本（比较 / 排序 / 哈希）
  - 网络成本（跨节点）

选择成本最低的计划。

成本依赖统计信息：
  - 表行数
  - 列基数（distinct 值数）
  - 列分布（直方图）
  - 数据相关性
```

### 统计信息更新

```sql
-- PostgreSQL
ANALYZE orders;                              -- 单表
ANALYZE;                                     -- 全库
SELECT * FROM pg_stats WHERE tablename = 'orders';  -- 查看

-- 自动 ANALYZE（默认开启）
SELECT * FROM pg_settings WHERE name LIKE 'autovacuum%';

-- MySQL
ANALYZE TABLE orders;
SHOW INDEX FROM orders;
```

### 统计信息过期症状

```text
EXPLAIN 显示：
  rows=100 (estimated)
  actual rows=10000

→ 估算与实际差 100 倍
→ 优化器选了错误的计划
→ 需要 ANALYZE
```

## 2. Join 算法详解

### Nested Loop（嵌套循环）

```text
for each row in outer:
  for each row in inner where matches:
    output

适合：
  - 小表 join
  - 内表有索引可快速查找
  - LIMIT 少量结果

示例：
  SELECT * FROM orders o JOIN users u ON o.user_id = u.id LIMIT 10;
  → 取 10 个订单，每个查 user（用 index）
```

### Hash Join（哈希连接）

```text
1. 扫描小表，建立哈希表
2. 扫描大表，每行查哈希

适合：
  - 中等大小表 join
  - 等值连接
  - 内存够用

示例：
  SELECT * FROM orders JOIN users ON orders.user_id = users.id;
  → users 建 hash，orders 扫描时查
```

### Merge Join（合并连接）

```text
1. 两个表按 join 键排序
2. 同时扫描，匹配输出

适合：
  - 两表已有相同顺序的索引
  - 大表 join

代价：如果未排序则要 sort，可能慢
```

### Join 顺序选择

```sql
-- 优化器默认选择最小驱动表
EXPLAIN
SELECT * FROM small_table s JOIN huge_table h ON s.id = h.id;

-- 强制顺序（PG 9.5+）
SET join_collapse_limit = 1;
SET from_collapse_limit = 1;

-- MySQL hint
SELECT /*+ JOIN_ORDER(s, h) */ * FROM small_table s JOIN huge_table h ON ...;
```

## 3. 慢查询识别工具

### PostgreSQL pg_stat_statements

```sql
-- 启用
CREATE EXTENSION pg_stat_statements;

-- 查询：top 10 慢查询
SELECT
  substring(query, 1, 60) AS query,
  calls,
  mean_exec_time::int AS avg_ms,
  total_exec_time::int AS total_ms,
  rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

### MySQL slow_query_log

```ini
# my.cnf
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1.0
log_queries_not_using_indexes = 1
```

```bash
# 分析工具
mysqldumpslow /var/log/mysql/slow.log
pt-query-digest /var/log/mysql/slow.log
```

### sqlcommenter（追踪 ORM 来源）

```python
# Django / SQLAlchemy / Hibernate 都支持
# SQL 中带应用注释，方便定位代码位置

# Django
SELECT * FROM orders /*controller='OrderListView',action='get'*/
```

## 4. 完整 SQL 优化案例库

### 案例 1：用户订单分页（高频）

```sql
-- 问题：100ms / 次，10000 QPS → 数据库 CPU 100%
SELECT * FROM orders
WHERE user_id = ?
ORDER BY created_at DESC
LIMIT 20 OFFSET 100;

-- EXPLAIN 显示
-- Index Scan using idx_user_id
-- Sort (filesort)              ← 问题
-- Limit

-- 解决：复合索引含排序
CREATE INDEX idx_orders_user_created
  ON orders(user_id, created_at DESC);

-- 现在：直接索引取最近 20，无需 sort
```

### 案例 2：仪表盘聚合（中频）

```sql
-- 问题：3 秒 / 次，但只有 100 QPS，主库压力大
SELECT
  DATE_TRUNC('day', created_at) AS day,
  COUNT(*),
  SUM(amount)
FROM orders
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY day;

-- 解决 1：物化视图（每小时刷新）
CREATE MATERIALIZED VIEW daily_order_summary AS
SELECT DATE_TRUNC('day', created_at) AS day, COUNT(*), SUM(amount)
FROM orders
GROUP BY day;

REFRESH MATERIALIZED VIEW CONCURRENTLY daily_order_summary;

-- 解决 2：报表库分离
-- 主库 → 复制 → 报表库（专用聚合）
```

### 案例 3：搜索（中后台）

```sql
-- 问题：ILIKE 全表扫
SELECT * FROM products WHERE name ILIKE '%abc%';

-- 解决：GIN trigram
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_products_name_trgm
  ON products USING gin(name gin_trgm_ops);

SELECT * FROM products WHERE name ILIKE '%abc%';
-- 自动用上 trigram 索引
```

### 案例 4：递归层级

```sql
-- 问题：循环查询父级
WITH RECURSIVE parents AS (
  SELECT id, parent_id, name FROM categories WHERE id = ?
  UNION ALL
  SELECT c.id, c.parent_id, c.name
  FROM categories c JOIN parents p ON c.id = p.parent_id
)
SELECT * FROM parents;
```

### 案例 5：批量插入

```sql
-- 错：循环 INSERT
for each item:
  INSERT INTO orders VALUES (...)
-- 1000 条 = 1000 次网络往返

-- 对：批量 INSERT
INSERT INTO orders VALUES
  (...),
  (...),
  ...
-- 1 次往返

-- 更对（PG）：COPY
COPY orders FROM STDIN WITH CSV;
```

## 5. 索引提示（Hint）使用

```sql
-- PostgreSQL（pg_hint_plan 扩展）
/*+ IndexScan(orders idx_user_id) */
SELECT * FROM orders WHERE user_id = 1;

-- MySQL
SELECT * FROM orders USE INDEX (idx_user_id) WHERE user_id = 1;
SELECT * FROM orders FORCE INDEX (idx_user_id) WHERE user_id = 1;
SELECT * FROM orders IGNORE INDEX (idx_user_id) WHERE user_id = 1;

-- 注意：hint 是兜底，依赖 hint 说明优化器选错了
```

## 6. 锁等待诊断

### PostgreSQL

```sql
-- 看锁等待
SELECT
  blocked.pid AS blocked_pid,
  blocked.query AS blocked_query,
  blocking.pid AS blocking_pid,
  blocking.query AS blocking_query,
  blocked.state, blocked.wait_event
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
  ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));

-- 杀死阻塞会话
SELECT pg_cancel_backend(pid);     -- 优雅
SELECT pg_terminate_backend(pid);  -- 强制
```

### MySQL

```sql
-- 看锁等待
SELECT * FROM performance_schema.data_lock_waits;

-- 看持有锁的会话
SELECT
  ENGINE_TRANSACTION_ID,
  THREAD_ID,
  EVENT_ID,
  OBJECT_NAME,
  LOCK_TYPE,
  LOCK_MODE,
  LOCK_STATUS
FROM performance_schema.data_locks;

-- 杀死会话
KILL [thread_id];
```

## 7. 常见反模式速查

```text
1. SELECT *
   → 内存浪费 / 网络浪费
   → 明确字段

2. ORDER BY RAND()
   → 全表扫 + 文件排序
   → 用 OFFSET random_int 或单独抽样表

3. HAVING 不带 GROUP BY 的过滤
   → HAVING 后 SQL 处理慢
   → 改 WHERE

4. 大量 UNION（非 UNION ALL）
   → 隐式去重
   → 用 UNION ALL（如果数据本就不重复）

5. NOT IN 子查询
   → 慢
   → 改 NOT EXISTS

6. 子查询代替 JOIN
   → 优化器有时不能改写
   → 显式 JOIN

7. WHERE 1=1 + 拼接条件
   → 优化器不能预编译
   → 用 prepared statement

8. CASE WHEN 多层
   → 性能差
   → 用映射表 / 视图
```

## 8. 性能预算（设计阶段就考虑）

```text
单查询 P99 预算：
  - 列表分页：< 100ms
  - 详情查询：< 50ms
  - 聚合：< 500ms（或异步）

总数据库延迟（一次 API 请求）：
  - 简单查询：< 10ms
  - 中等业务：< 100ms
  - 复杂业务：< 500ms

QPS 预算：
  单实例 PG/MySQL：5000~20000 QPS
  超过 → 扩容 / 缓存 / 分片
```

## 9. 缓存层策略

```text
何时引入缓存：
  - 读 >> 写（10x+）
  - 数据可接受短暂不一致
  - 数据库已优化但仍慢

缓存方案：
  - 应用内（LRU）
  - Redis / Memcached
  - 数据库查询缓存（PG 无 / MySQL 8.0 移除）
  - CDN（静态内容）

失效策略：
  - TTL（最简单）
  - 主动失效（更新时清缓存）
  - 写穿（write-through）
  - 写后异步（write-behind）
```

## 10. 自检清单（资深视角）

```text
□ 有 EXPLAIN ANALYZE 实测
□ 区分估算 rows 与实际 rows
□ 统计信息最近更新过
□ 关注 actual_time 非 cost
□ 看缓存命中（Buffers）
□ 识别 N+1 模式（频率监控）
□ OFFSET 深分页转 cursor
□ ORDER BY 有支撑索引
□ JSON 字段索引（GIN / 表达式）
□ LIKE '%xxx%' 用 GIN trigram
□ COUNT(*) 大表用估算或物化
□ 大事务拆分
□ 锁等待监控
□ 慢查询日志开启
□ 报表查询与在线业务隔离
□ 缓存策略合理
□ 性能预算明确
```
