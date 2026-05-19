# 索引设计深度指引

参考：Markus Winand《Use The Index, Luke!》、Bruce Momjian《Mastering PostgreSQL》、High Performance MySQL（O'Reilly）、PostgreSQL 官方文档、MySQL 8.0 优化器文档。

## 1. B-tree 内部结构（理解索引行为的基础）

```text
B-tree 是平衡树：
  - 根节点（1 页）
  - 中间节点（多层）
  - 叶子节点（含数据指针）

每页 8KB（PG 默认）
每页存约 100~300 个键

3 层 B-tree：100^3 = 100 万行
4 层 B-tree：100^4 = 1 亿行
5 层 B-tree：100^5 = 100 亿行

→ 索引访问 = 3~5 次页 IO
→ 全表扫描 = N/300 次页 IO

→ 1 万行：差异不大
→ 100 万行：差 1000 倍
→ 1 亿行：差 100000 倍
```

## 2. ESR 原则深度

```text
Equality（等值）放最前：
  WHERE tenant_id = 1 AND status = 'paid' AND created_at > '...'
  → INDEX (tenant_id, status, ...)
  
  原理：等值过滤后剩下的行才需要排序/范围
  减少索引树扫描深度

Sort（排序）放中间：
  ORDER BY created_at DESC
  → INDEX (..., ..., created_at DESC)
  
  原理：索引天然有序，跟随 ESR 最后字段时可省 sort

Range（范围）放最后：
  WHERE created_at > '...' AND created_at < '...'
  → INDEX (..., ..., created_at)
  
  原理：范围扫描后无法继续利用后续字段
```

### 反例

```sql
-- 错：范围放前
CREATE INDEX bad ON orders(created_at, tenant_id, status);

-- 查询：tenant_id = 1 AND status = 'paid' AND created_at > '...'
-- 用 bad 索引：跳跃扫描，效率差

-- 对：ESR 顺序
CREATE INDEX good ON orders(tenant_id, status, created_at);
```

### 同字段不同方向

```sql
-- 多字段排序方向不同
ORDER BY priority ASC, created_at DESC

-- PG 9.2+ 支持
CREATE INDEX idx_tasks ON tasks(priority ASC, created_at DESC);

-- MySQL 8.0+ 支持降序索引
```

## 3. PostgreSQL 索引类型完整对比

| 类型 | 使用场景 | 不适合 | 大小 |
|---|---|---|---|
| **B-tree** | 等值 / 范围 / 排序 / LIKE 'a%' | 后缀 / 全文 | 100% |
| **Hash** | 仅等值（PG 10+ 持久化） | 范围 / 排序 | 较小 |
| **GIN** | 数组 / JSON / tsvector / 多值 | 简单字段 | 大（200%+） |
| **GiST** | 空间 / 范围 / 全文 | 等值 | 中 |
| **SP-GiST** | 非平衡空间数据 | 通用 | 中 |
| **BRIN** | 大表时间序列（亿级） | 随机访问 | 极小（1%） |
| **Bloom** | 多字段等值 OR | 排序 | 中 |

### GIN 子选项（性能 vs 空间权衡）

```sql
-- jsonb 路径查询
CREATE INDEX ON orders USING gin(metadata);             -- 全字段索引（大）
CREATE INDEX ON orders USING gin(metadata jsonb_path_ops);  -- 仅路径（小，但功能少）

-- 文本 trigram（模糊查询神器）
CREATE EXTENSION pg_trgm;
CREATE INDEX ON users USING gin(name gin_trgm_ops);
SELECT * FROM users WHERE name LIKE '%abc%';  -- 用上索引
SELECT * FROM users WHERE name % 'abc';        -- 相似度搜索
```

## 4. MySQL 索引类型

| 类型 | 使用场景 |
|---|---|
| **B+tree（默认）** | 通用 |
| **HASH（Memory 引擎）** | 等值 |
| **FULLTEXT** | 全文搜索（中文需 ngram） |
| **SPATIAL** | 空间索引 |
| **倒排（反向键）** | DESC 索引模拟 |

### MySQL 索引限制

```text
- 单索引最多 16 个字段
- 单表最多 64 个索引
- 索引前缀长度限制：
  - utf8mb4: 191 字符（5.7 默认）
  - utf8mb4: 3072 字节 / 4 = 768 字符（8.0+）
```

## 5. 慢查询索引诊断流程

### 步骤 1：拿到执行计划

```sql
-- PostgreSQL
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 1 AND status = 'paid';

-- MySQL
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 1 AND status = 'paid';
```

### 步骤 2：识别问题

```text
关键指标：

PostgreSQL：
  Seq Scan         → 全表扫描（小表 OK，大表 = 问题）
  Index Scan       → 用上索引
  Bitmap Heap Scan → 多索引或低选择性
  Sort             → 内存排序（大数据量 = 问题）
  Hash Join        → 看 Buffers 评估
  rows= ... actual rows= ... → 估算 vs 实际

MySQL：
  type=ALL         → 全表扫描
  type=index       → 索引扫描（不是用索引快速定位）
  type=range       → 范围
  type=ref / eq_ref → 等值（好）
  type=const       → 常量（最好）
  Extra=Using temporary → 用临时表
  Extra=Using filesort  → 文件排序
```

### 步骤 3：判断索引

```text
没用上索引的常见原因：
1. 索引字段被函数包裹：WHERE LOWER(email) = ?
   → 改用表达式索引
2. 数据类型不匹配：WHERE varchar_col = 123（隐式转换）
   → 类型对齐
3. 复合索引顺序错（ESR 违反）
   → 重建索引
4. NULL 值在 IS NULL（PG 默认不索引 NULL）
   → CREATE INDEX ... WHERE col IS NULL
5. 优化器估算错（统计信息过期）
   → ANALYZE table
6. LIKE '%xxx%'
   → GIN trigram
7. OR 多条件（PG 支持差，MySQL 也常退化）
   → 改 UNION ALL
```

## 6. 索引设计案例库

### 列表分页（最常见）

```sql
-- 场景：GET /orders?status=paid&page=1
-- 高频，每秒数千次

CREATE INDEX idx_orders_list
  ON orders(tenant_id, status, created_at DESC)
  INCLUDE (total, user_id);

-- ESR：tenant_id（等值）+ status（等值）+ created_at（排序）
-- INCLUDE：避免回表
```

### Cursor 分页（无 OFFSET 性能问题）

```sql
-- 场景：游标分页，避免 OFFSET 100000

-- 第一页：
SELECT * FROM orders
WHERE tenant_id = 1
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- 后续页：用上次最后一条的 (created_at, id)
SELECT * FROM orders
WHERE tenant_id = 1
  AND (created_at, id) < ('2026-05-18 10:00:00', 9999)
ORDER BY created_at DESC, id DESC
LIMIT 20;

CREATE INDEX idx_orders_cursor
  ON orders(tenant_id, created_at DESC, id DESC);
```

### 范围 + 排序（时间窗口）

```sql
-- 场景：查 7 天内的订单

CREATE INDEX idx_orders_recent
  ON orders(tenant_id, created_at DESC)
  WHERE created_at > NOW() - INTERVAL '90 days';

-- 部分索引节省 90% 空间
```

### 多条件搜索（中后台）

```sql
-- 场景：搜索框 + 多过滤

-- ❌ 反模式：全字段索引（组合爆炸）
-- CREATE INDEX ON orders(status);
-- CREATE INDEX ON orders(user_id);
-- CREATE INDEX ON orders(date);
-- CREATE INDEX ON orders(...);

-- ✅ 主索引 + 过滤后缀
CREATE INDEX idx_orders_main ON orders(tenant_id, created_at DESC);

-- 业务允许"先过滤大分类再搜索"，性能足够
```

### 唯一约束 + 软删除

```sql
-- 场景：用户邮箱唯一，但允许删除后重新注册

CREATE UNIQUE INDEX uq_users_email_active
  ON users(email)
  WHERE deleted_at IS NULL;
```

### 全文搜索

```sql
-- PostgreSQL
CREATE INDEX idx_posts_search
  ON posts USING gin(to_tsvector('simple', title || ' ' || body));

SELECT * FROM posts
WHERE to_tsvector('simple', title || ' ' || body) @@ plainto_tsquery('PostgreSQL');

-- MySQL
ALTER TABLE posts ADD FULLTEXT INDEX ft_posts_search(title, body);

SELECT * FROM posts
WHERE MATCH(title, body) AGAINST('PostgreSQL' IN NATURAL LANGUAGE MODE);
```

### JSON 字段索引

```sql
-- PostgreSQL：jsonb + GIN
CREATE INDEX idx_orders_metadata ON orders USING gin(metadata);

SELECT * FROM orders WHERE metadata @> '{"source": "mobile"}';

-- MySQL 8.0：虚拟列 + 索引
ALTER TABLE orders
ADD COLUMN source varchar(32) GENERATED ALWAYS AS (metadata->>'$.source') VIRTUAL,
ADD INDEX idx_source(source);
```

## 7. 大表索引重建策略

### PostgreSQL

```sql
-- 大表（亿级）建索引：CONCURRENTLY 不锁表
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- 失败时会留 INVALID 索引，需手动 DROP

-- REINDEX（重建已有索引）
REINDEX INDEX CONCURRENTLY idx_orders_user_id;
```

### MySQL

```sql
-- ALGORITHM=INPLACE 不重建表（5.6+ Online DDL）
ALTER TABLE orders
  ADD INDEX idx_user_id (user_id),
  ALGORITHM=INPLACE,
  LOCK=NONE;

-- 注意：某些类型变更仍需 COPY 算法（重建表）
```

### 大表索引时间估算

```text
PostgreSQL CREATE INDEX：
  - 单核处理（10+ 用 maintenance_work_mem 调多核）
  - 经验值：1 亿行 / 单字段 ≈ 30~60 分钟
  - 用 SSD 比 HDD 快 5~10 倍

MySQL ALTER TABLE：
  - 单核处理
  - 同上
```

## 8. 索引监控

### PostgreSQL

```sql
-- 索引使用统计
SELECT
  schemaname, tablename, indexname,
  idx_scan, idx_tup_read, idx_tup_fetch,
  pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- 找未使用索引
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;

-- 找索引膨胀（pg_repack 重建）
SELECT * FROM pgstattuple_approx('orders'::regclass);
```

### MySQL

```sql
-- 索引使用统计（performance_schema）
SELECT
  object_schema, object_name, index_name,
  count_fetch, count_insert, count_update, count_delete
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema = 'mydb'
ORDER BY count_fetch DESC;

-- 未使用索引
SELECT * FROM sys.schema_unused_indexes;
```

## 9. 索引设计反模式

```text
❌ 字段越多越好：CREATE INDEX (a, b, c, d, e)
   → 复合索引超过 4 字段一般无用

❌ 给每个外键自动建索引：
   → 必加，但要看选择性

❌ 全字段 SELECT * 后建覆盖索引：
   → INCLUDE 字段越多索引越大，得不偿失

❌ 索引重建在线上业务高峰：
   → REINDEX / 大索引建立期间影响性能

❌ 唯一约束 + 同字段普通索引：
   → 唯一约束自带唯一索引，重复浪费

❌ 频繁更新字段建索引：
   → 每次更新触发索引维护

❌ NULL 字段 IS NULL 查询无索引：
   → PG 默认不索引 NULL，要 WHERE clause 部分索引
```

## 10. 自检清单（资深视角）

```text
□ 每个索引对应一个真实查询模式
□ ESR 原则贯彻
□ 复合索引字段不超过 4 个
□ 高频查询有覆盖索引
□ 软删除有部分唯一索引
□ 全文搜索 / JSON / 数组 用 GIN
□ 时间序列大表评估 BRIN
□ 唯一约束等于唯一索引（不重复建）
□ 单表索引 ≤ 5
□ 索引总大小 ≤ 表大小
□ 大表建索引用 CONCURRENTLY / ONLINE
□ EXPLAIN ANALYZE 验证用上索引
□ 监控未使用索引（每月清理）
□ 监控索引膨胀（每季度重建）
□ 索引变更进入 migration 流程
```
