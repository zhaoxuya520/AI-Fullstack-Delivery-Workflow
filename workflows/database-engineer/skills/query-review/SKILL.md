---
name: query-review
description: 审查 SQL、分析慢查询和提出查询优化建议时使用。适用于执行计划分析、N+1、分页排序、聚合过滤和查询重写。融合 EXPLAIN 解读、ESR 反推、ORM 陷阱识别。
---

# SQL 审查与查询优化（Query Review）

参考来源：Markus Winand《SQL Performance Explained》、Bruce Momjian《Mastering PostgreSQL》、High Performance MySQL（O'Reilly）、PostgreSQL 优化器文档、MySQL 8.0 优化器文档。

## 适用场景

- 审查后端提交的 SQL 或 ORM 查询
- 分析慢查询、超时、CPU/IO 异常
- 识别 N+1、全表扫描、低效 join、低效分页
- 优化聚合、排序、过滤、模糊搜索
- 为新增索引或 schema 调整提供证据

## 核心原则

```text
1. 先定位真实瓶颈，再改 SQL 或索引
   不看执行计划就加索引 = 瞎猜

2. EXPLAIN ANALYZE 是真相
   优化器估算可能错，实际执行才算

3. 看调用频率 × 单次成本
   100 次/天 × 10 秒 vs 100000 次/天 × 100 毫秒
   后者总成本是前者的 30 倍

4. 区分查询重写 vs 索引变更
   能改 SQL 不动索引：优先
   只能加索引：评估写入成本

5. 关注 actual rows vs estimated rows
   差异 10x+ → 统计信息可能过期 → ANALYZE

6. ORM 是黑盒，要看真 SQL
   开 SQL 日志 / 用 sqlcommenter
```

## 审查输入

```text
SQL 或 ORM 查询
表结构和索引
参数样例（实际生产值）
数据量级
调用路径和频率
执行计划（EXPLAIN ANALYZE）
慢日志样本
性能目标（P99）
```

## EXPLAIN 解读速查

### PostgreSQL EXPLAIN ANALYZE

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 1 AND status = 'paid';
```

```text
关键节点（从下往上读）：

Seq Scan on orders               <- 全表扫描（小表 OK，大表 = 问题）
  cost=0.00..1234.56
  rows=100  (估算)
  actual rows=95 (实际)         <- 估算与实际差距大 = 统计信息过期
  loops=1
  Buffers: shared hit=50

Index Scan using idx_user_id     <- 用上索引（好）
  Index Cond: (user_id = 1)      <- 过滤条件用了索引
  Filter: (status = 'paid')      <- 注意：过滤但未用索引（status 不在索引）
  Rows Removed by Filter: 50    <- 索引取了 50 条又过滤掉

Bitmap Heap Scan                 <- 多索引或低选择性
  Recheck Cond: ...

Sort                             <- 内存排序（大数据 = 问题）
  Sort Method: external merge   <- 用磁盘排序（更慢）
  Sort Key: created_at desc

Hash Join                        <- 大表 join
  Hash Cond: (a.id = b.id)
  Buffers: shared hit=10000     <- 看 IO 评估

Nested Loop                      <- 循环 join（小表 OK）
```

### MySQL EXPLAIN

```sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 1 AND status = 'paid';
```

```text
关键字段：

type=ALL          → 全表扫描（最差）
type=index        → 索引扫描（不是用索引快速定位）
type=range        → 范围扫描
type=ref          → 用索引定位多行
type=eq_ref       → 用唯一索引定位单行
type=const        → 主键 / 唯一索引等值（最好）

key=...           → 用了哪个索引
rows=100          → 估算扫描行数
filtered=10%      → 索引取出后过滤剩余比例

Extra=Using temporary    → 用临时表
Extra=Using filesort     → 文件排序
Extra=Using index        → 覆盖索引（好）
Extra=Using where        → 索引取出后还要过滤
```

## 常见问题诊断库

### 1. 全表扫描

**症状**：`Seq Scan` / `type=ALL`，actual rows 接近表总行数

**原因**：
- 缺索引
- 索引被函数包裹：`WHERE LOWER(email) = ?`
- 类型隐式转换：`WHERE varchar_col = 123`
- 优化器选错（统计信息过期）

**解决**：
```sql
-- 表达式索引
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- 类型对齐
WHERE varchar_col = '123'  -- 加引号

-- 更新统计信息（PG）
ANALYZE orders;

-- MySQL
ANALYZE TABLE orders;
```

### 2. N+1 查询

**症状**：1 个主查询 + N 个子查询（ORM 懒加载）

**示例（错）**：
```python
# Django
orders = Order.objects.all()
for order in orders:
    print(order.user.name)  # 每次都查一次 users
# 1 + N 次查询
```

**解决**：
```python
# Django: prefetch_related / select_related
orders = Order.objects.select_related('user').all()

# SQLAlchemy: joinedload
orders = session.query(Order).options(joinedload(Order.user)).all()

# Prisma: include
const orders = await prisma.order.findMany({ include: { user: true } });
```

**SQL 直接写法**：
```sql
SELECT o.*, u.name AS user_name
FROM orders o
JOIN users u ON o.user_id = u.id;
```

### 3. OFFSET 深分页

**症状**：`OFFSET 100000 LIMIT 20` 越来越慢

**原因**：OFFSET 仍要扫前 100000 行才能跳过

**解决**：用 cursor 分页

```sql
-- 错
SELECT * FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 100000;

-- 对（用上次最后一条的 cursor）
SELECT * FROM orders
WHERE (created_at, id) < ('2026-05-18 10:00', 9999)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

### 4. ORDER BY 文件排序

**症状**：`Sort Method: external merge` / `Using filesort`

**原因**：排序字段无索引或不在索引末尾

**解决**：建立排序友好索引

```sql
-- 错
CREATE INDEX ON orders(user_id);
-- ORDER BY created_at DESC → 文件排序

-- 对
CREATE INDEX ON orders(user_id, created_at DESC);
```

### 5. LIKE '%xxx%' 全表扫

**症状**：模糊匹配 + 大表

**解决**：
- PostgreSQL：GIN trigram
```sql
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_users_name_trgm ON users USING gin(name gin_trgm_ops);
SELECT * FROM users WHERE name LIKE '%abc%';  -- 用上索引
```
- MySQL：FULLTEXT
```sql
ALTER TABLE users ADD FULLTEXT INDEX ft_name(name);
SELECT * FROM users WHERE MATCH(name) AGAINST('abc' IN NATURAL LANGUAGE MODE);
```

### 6. COUNT(*) 慢

**症状**：大表 `SELECT COUNT(*)` 数秒

**原因**：MVCC 模型必须扫表

**解决**：
- 估算（适合用户体验）
```sql
-- PostgreSQL：从统计表读
SELECT reltuples::BIGINT AS approximate_count
FROM pg_class WHERE relname = 'orders';
```
- 物化（适合精确）
```sql
-- 维护单独计数表
CREATE TABLE order_counters (key varchar PRIMARY KEY, count bigint);
-- 触发器或异步更新
```

### 7. JSON 字段查询慢

**症状**：`metadata->>'status' = 'paid'` 全表扫

**解决**：
```sql
-- PostgreSQL：表达式索引
CREATE INDEX idx_orders_status_meta ON orders((metadata->>'status'));

-- 或 GIN 索引
CREATE INDEX idx_orders_meta_gin ON orders USING gin(metadata);
SELECT * FROM orders WHERE metadata @> '{"status": "paid"}';
```

### 8. 大事务锁等待

**症状**：单条 SQL 不慢，但等待时间长

**诊断**：
```sql
-- PG：找锁等待
SELECT * FROM pg_locks WHERE NOT granted;
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- MySQL
SELECT * FROM performance_schema.events_waits_current
WHERE event_name LIKE 'wait/lock%';
```

**解决**：缩小事务范围、避免长事务

## 标准流程

```text
1. 明确业务场景和性能目标
   - SLA：P99 < ? ms
   - 频率：QPS = ?
   ↓
2. 收集 SQL、schema、索引、数据量、执行计划
   - 真实参数（不是 SELECT 1=1）
   - EXPLAIN ANALYZE 输出
   - 调用频率（监控数据）
   ↓
3. 判断瓶颈
   - 扫描：Seq Scan / type=ALL
   - 排序：filesort / external merge
   - join：错误算法 / 大表笛卡尔
   - 锁：等待锁 / 长事务
   - N+1：1 + N 模式
   - 网络往返：批量改单查
   ↓
4. 给出查询重写或索引建议
   - 改 SQL（不影响 schema）：优先
   - 加索引：评估写入成本
   - 改 schema：极少（除非根本设计错）
   ↓
5. 验证
   - 重跑 EXPLAIN ANALYZE 对比
   - 监控生产指标改善
   - 评估写入退化
```

## 输出格式

| 问题 | 证据（EXPLAIN） | 频率 | 单次耗时 | 建议 | 验证方式 | 风险 |
|------|------|------|------|------|----------|------|
| 全表扫描 orders | actual rows=1M | 1000 QPS | 800ms | 加索引 (user_id, status, created_at) | EXPLAIN 看 Index Scan | 写入慢 ~10% |

## ORM 陷阱速查

### Django

```python
# 反模式：lazy load
orders = Order.objects.all()
for o in orders:
    print(o.user.name)  # N+1

# 解决
orders = Order.objects.select_related('user')

# 反模式：count() 慢
Order.objects.filter(...).count()

# 解决（估算）
Order.objects.filter(...).explain()  # 看真实查询
```

### SQLAlchemy

```python
# 反模式：lazy load
for order in session.query(Order):
    print(order.user.name)

# 解决
session.query(Order).options(joinedload(Order.user))
```

### Prisma

```typescript
// 反模式：findMany 不 include
const orders = await prisma.order.findMany();
// 然后循环查 user → N+1

// 解决
const orders = await prisma.order.findMany({ include: { user: true } });
```

## 配套模板

- `templates/sql-review-template.md` — SQL 审查报告（场景 / 当前 SQL / 执行计划 / 问题 / 建议 / 验证 / 风险）

## 质量自检

```text
□ 有真实 SQL 或 ORM 查询
□ 说明数据量和调用频率
□ 基于 EXPLAIN ANALYZE，不是猜测
□ 区分查询重写 vs 索引变更
□ 评估分页、排序、join、聚合成本
□ 看 actual rows vs estimated rows
□ 检查 N+1 模式
□ OFFSET 深分页改 cursor
□ 文件排序加排序友好索引
□ JSON 字段查询用表达式索引或 GIN
□ 模糊匹配用 GIN trigram / FULLTEXT
□ 给出可验证指标
□ 评估写入退化
```

## 常见坑

1. **没 EXPLAIN 就加索引**——加错索引或冗余
2. **只优化单次耗时**——忽略高频调用总成本
3. **OFFSET 深分页**——offset 100000 时仍要扫前 100000
4. **ORM 懒加载 N+1**——1 + N 次查询
5. **聚合查询和在线业务混链路**——大查询拖慢主库
6. **统计信息过期**——优化器估算错
7. **隐式类型转换**——索引失效
8. **函数包裹索引字段**——索引失效
9. **OR 多条件**——可能退化为全表扫
10. **NOT IN 大子查询**——性能差，改 NOT EXISTS
11. **COUNT(*) 大表**——MVCC 必须扫
12. **不限制 LIMIT**——查到撑死
13. **SELECT \***——传输 + 内存浪费
14. **DISTINCT 大数据**——内存爆炸

## 与其他 skill 的协作

```text
上游：
  schema-design → 表结构和约束
  index-access-pattern → 索引设计
  api-designer → 查询模式（pagination / filter）

下游：
  index-access-pattern → 根据证据设计索引
  schema-design → 必要时调整字段或表结构
  migration-rollout → 涉及结构或索引变更时设计上线方案
  backend-engineer → 改 ORM 写法
```

## 相关参考

- `references/query-optimization-guide.md` — 优化器内部、统计信息、Join 算法（NL/Hash/Merge）、ORM 陷阱完整库、慢日志分析
