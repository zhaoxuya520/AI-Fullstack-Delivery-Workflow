---
name: index-access-pattern
description: 根据真实查询场景设计索引和访问路径时使用。适用于索引设计、读写权衡、分页排序、唯一索引和性能评审。融合 B-tree / Hash / GIN / BRIN 选型 + 复合索引顺序 + 覆盖索引 + 部分索引。
---

# 索引与访问模式（Index & Access Pattern）

参考来源：Markus Winand《Use The Index, Luke!》、PostgreSQL Indexes 官方文档、High Performance MySQL（O'Reilly）、Stripe / GitHub 索引实战。

## 适用场景

- 新表上线前设计索引
- 根据 API 列表页、筛选、排序、搜索设计访问路径
- 判断复合索引字段顺序
- 评估唯一索引、覆盖索引、局部索引、前缀索引
- 排查索引缺失或过度索引
- 大表索引重建 / 在线建索引

## 核心原则

```text
1. 索引来自真实访问模式，不来自字段清单
   先列查询场景，再决定索引

2. 索引不是越多越好
   每加一个索引：
   - 写入慢 5%~30%
   - 占空间（约表大小 30%~100%）
   - 维护成本（重建 / 迁移）

3. 复合索引顺序：等值 → 范围 → 排序
   遵循 ESR（Equality, Sort, Range）

4. 覆盖索引省一次表查
   把高频查询字段都放进 INCLUDE

5. 部分索引省空间
   `WHERE deleted_at IS NULL` 的查询用部分索引

6. 不为低选择性字段单独建索引
   性别、布尔、状态值少 → 单独建索引几乎无用

7. 唯一约束 = 唯一索引（自动）
   不要重复建

8. 高并发写入慎用 UUID v4 主键
   B-tree 写放大严重，用 ULID / UUID v7
```

## 索引类型对比

### B-tree（默认 / 最常用）

```sql
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

适合：
- 等值（=）
- 范围（<, >, BETWEEN）
- 排序（ORDER BY）
- 前缀匹配（LIKE 'abc%'）

不适合：
- 后缀匹配（LIKE '%abc'）→ 改用 GIN trigram
- 全文搜索 → 用 GIN tsvector

### Hash（PostgreSQL 10+）

```sql
CREATE INDEX idx_users_email_hash ON users USING hash(email);
```

适合：
- 仅等值查找
- 大字段（hash 后只占 4~8 字节）

不适合：
- 范围查询
- 排序

### GIN（倒排索引，PG 专用）

```sql
-- 数组
CREATE INDEX idx_post_tags ON posts USING gin(tags);
SELECT * FROM posts WHERE tags @> ARRAY['rust'];

-- JSON
CREATE INDEX idx_metadata ON orders USING gin(metadata);
SELECT * FROM orders WHERE metadata @> '{"source": "mobile"}';

-- 全文搜索
CREATE INDEX idx_post_search ON posts USING gin(to_tsvector('english', body));
SELECT * FROM posts WHERE to_tsvector('english', body) @@ plainto_tsquery('rust');
```

适合：
- 数组 / JSON 字段
- 全文搜索
- 多值字段

### BRIN（块范围索引，PG）

```sql
CREATE INDEX idx_logs_created_at ON logs USING brin(created_at);
```

适合：
- 时间序列数据（自然有序）
- 超大表（占空间极小）
- 范围扫描

不适合：
- 随机访问

### 空间索引（GiST）

```sql
CREATE INDEX idx_locations_geom ON locations USING gist(geom);
```

适合：
- 地理位置（PostGIS）
- 范围查询（点在多边形内）

## ESR 复合索引顺序原则

```text
原则：Equality → Sort → Range

示例：
  SELECT * FROM orders
  WHERE tenant_id = ? AND status = ? AND created_at > ?
  ORDER BY created_at DESC
  LIMIT 20;

错误索引：
  CREATE INDEX ON orders(created_at, tenant_id, status);
  → 范围放前面，过滤时还要扫大量行

正确索引：
  CREATE INDEX ON orders(tenant_id, status, created_at DESC);
  ↑等值        ↑等值     ↑排序+范围
```

## 查询-索引映射模板

| 查询场景 | 过滤条件 | 排序 | 分页 | 频率 | 建议索引 | 风险 |
|----------|----------|------|------|------|----------|------|
| 列表查询 | tenant_id, status | created_at desc | cursor | 高 | `(tenant_id, status, created_at DESC)` | 写入慢 |
| 详情查询 | id | - | - | 极高 | 主键自带 | - |
| 搜索 | name LIKE '%xxx%' | - | - | 中 | `gin(name gin_trgm_ops)` | 占空间 |
| 时间范围 | created_at > '...' | created_at | - | 低 | `(created_at)` 或 BRIN | - |
| 关联查询 | user_id | - | - | 高 | `(user_id)` 必加 | - |

## 高级索引技巧

### 覆盖索引（INCLUDE）

```sql
-- 查询：SELECT id, status, total FROM orders WHERE user_id = ?
-- 普通索引：还要回表查 status, total
-- 覆盖索引：包含所有需要的字段，避免回表

CREATE INDEX idx_orders_user_covering
  ON orders(user_id) INCLUDE (status, total);
```

### 部分索引（Partial Index）

```sql
-- 只有 5% 的订单是 pending，但查询 99% 找的就是 pending
CREATE INDEX idx_orders_pending
  ON orders(created_at)
  WHERE status = 'pending';

-- 软删除常用
CREATE UNIQUE INDEX uq_users_email
  ON users(email)
  WHERE deleted_at IS NULL;
```

### 表达式索引（Expression Index）

```sql
-- 大小写不敏感搜索
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
SELECT * FROM users WHERE LOWER(email) = LOWER(?);

-- JSON 字段索引
CREATE INDEX idx_orders_status ON orders((metadata->>'status'));
```

### 反向索引（Descending）

```sql
-- 时间倒序分页
CREATE INDEX idx_orders_created_desc ON orders(created_at DESC);
```

### 部分覆盖索引（PG 专属神器）

```sql
-- 只对活跃用户的查询建索引
CREATE INDEX idx_users_active_name
  ON users(name)
  INCLUDE (email, avatar_url)
  WHERE is_active = true;
```

## 标准流程

```text
1. 收集读写路径和频率
   - API 端点 → SQL 模式
   - 查询频率 / 写入频率
   ↓
2. 标注每个查询的：
   - 过滤条件（等值 / 范围 / IN / LIKE）
   - 排序字段和方向
   - 分页方式（offset / cursor）
   - join 关系
   - SELECT 字段（用于覆盖索引）
   ↓
3. 识别唯一性约束和业务去重需求
   ↓
4. 设计候选索引
   - 主键 / 外键 自带或必加
   - 高频查询的复合索引（ESR 原则）
   - 唯一约束 → 唯一索引
   - 部分 / 覆盖 / 表达式索引（看情况）
   ↓
5. 评估写入成本、存储成本和迁移成本
   - 单表索引数 ≤ 5（经验值）
   - 总索引大小 ≤ 表大小（经验值）
   ↓
6. 输出索引清单和验证方式
   - EXPLAIN 验证用上索引
   - 大表用 CREATE INDEX CONCURRENTLY（PG）
```

## 索引选择性分析

```sql
-- 选择性 = distinct 值数 / 总行数
-- 越接近 1 越好（每个索引值定位行少）

SELECT
  COUNT(DISTINCT status) * 1.0 / COUNT(*) AS selectivity_status,  -- 0.0001（差）
  COUNT(DISTINCT user_id) * 1.0 / COUNT(*) AS selectivity_user_id,  -- 0.5（中）
  COUNT(DISTINCT id) * 1.0 / COUNT(*) AS selectivity_id  -- 1（满）
FROM orders;

-- 选择性 < 0.001 一般不单独建索引
-- 但放复合索引前面 + 等值过滤 OK
```

## 索引维护

### 找无用索引

```sql
-- PostgreSQL：找从未使用的索引
SELECT
  schemaname, tablename, indexname,
  idx_scan, pg_size_pretty(pg_relation_size(indexrelid))
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;
```

### 找重复索引

```sql
-- 同一字段被多个索引覆盖，可能有冗余
SELECT
  indrelid::regclass AS table_name,
  array_agg(indexrelid::regclass) AS indexes,
  indkey
FROM pg_index
GROUP BY indrelid, indkey
HAVING COUNT(*) > 1;
```

### 在线建索引（PostgreSQL）

```sql
-- 不锁表
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- 注意：失败时会留下 INVALID 状态索引，需手动清理
```

### 在线建索引（MySQL 5.6+）

```sql
-- 大部分情况自动 ONLINE
ALTER TABLE orders ADD INDEX idx_user_id (user_id), ALGORITHM=INPLACE, LOCK=NONE;
```

## 配套模板

- `templates/index-review-template.md` — 索引方案 + 查询场景映射 + 选择性分析 + 验证方式

## 质量自检

```text
□ 每个索引对应明确查询场景或唯一约束
□ 复合索引顺序符合 ESR（等值 → 排序 → 范围）
□ 高频列表查询有覆盖索引（INCLUDE）
□ 软删除场景用部分索引保留唯一性
□ 全文搜索用 GIN（PG）/ FULLTEXT（MySQL）
□ 时间序列大表评估 BRIN
□ 没有重复索引
□ 单表索引数 ≤ 5
□ 索引总大小 ≤ 表大小（经验值）
□ 大表建索引用 CONCURRENTLY / ONLINE=ALGORITHM
□ 标注可删除或需观察的冗余索引
□ 验证指标：执行计划 / 耗时 / 扫描行数
```

## 常见坑

1. **为每个查询字段建单列索引**——写入慢、空间大、优化器选错
2. **复合索引顺序错**——范围放前面，过滤效果差
3. **忽略排序和分页**——filesort / 大范围扫描
4. **OFFSET 深分页**——offset 100000 时仍要扫 100000 行
5. **只优化读，忽略写**——TPS 砍半
6. **新增索引没有迁移窗口**——大表建索引锁 30 分钟
7. **JSON 字段未建 GIN 索引**——`metadata->>'k'` 全表扫
8. **LIKE '%xxx%' 用 B-tree**——必须 GIN trigram
9. **低选择性字段单独建索引**——is_active 索引几乎无效
10. **唯一约束 + 唯一索引重复建**——浪费空间
11. **不用 EXPLAIN 验证**——以为用上了实际没用
12. **CREATE INDEX 默认锁表**——PG 必须 CONCURRENTLY
13. **UUID v4 主键写放大**——B-tree 大量页分裂
14. **索引建好不维护**——半年后冗余 / 无用索引堆积

## 与其他 skill 的协作

```text
上游：
  schema-design → 提供表结构和约束
  query-review → 提供真实 SQL 和执行路径
  api-designer → 提供查询模式（pagination / filter / sort）

下游：
  migration-rollout → 处理新增/删除索引的上线计划
  data-operations-safety → 评估生产建索引风险
  query-review → 验证索引被用上
```

## 相关参考

- `references/index-design-guide.md` — B-tree 内部结构、ESR 原则深度、PostgreSQL 索引类型完整对比、大表索引重建策略、慢查询索引诊断流程
