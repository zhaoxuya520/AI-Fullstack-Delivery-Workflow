# 数据库迁移与上线深度指引

参考：Martin Fowler / Pramod Sadalage《Refactoring Databases》、GitHub gh-ost 文档、Percona pt-online-schema-change、PostgreSQL Online DDL 实践、Stripe / Shopify / GitHub 公开案例。

## 1. Expand / Contract 模式深度

### 模式核心

```text
Expand：扩展（添加新结构，不破坏旧的）
Migrate：迁移数据 + 切换流量
Contract：收缩（删除旧结构）

任何 schema 变更都可以拆成这三步。
```

### 7 类常见变更的 Expand/Contract

| 变更类型 | Expand | Migrate | Contract |
|---|---|---|---|
| 重命名列 | 加新列 | 双写 + 回填 + 切读 | 删旧列 |
| 改类型 | 加新列（新类型） | 双写 + 回填 + 切读 | 删旧列 |
| 拆列（name → first/last） | 加 first/last 列 | 双写 + 回填 + 切读 | 删 name 列 |
| 合列（first/last → name） | 加 name 列 | 双写 + 回填 + 切读 | 删 first/last 列 |
| 拆表（user → user + profile） | 创建 profile 表 | 双写 + 回填 + 切读 | 删 user 中字段 |
| 合表 | 创建合表 | 双写 + 回填 + 切读 | 删旧两表 |
| 改约束（NOT NULL） | 加默认值 | 回填 NULL 行 | 添 NOT NULL 约束 |

### 时间窗口

```text
小变更（< 1 万行）：
  Expand → Migrate → Contract 总共 1 小时

中变更（1 万 ~ 100 万行）：
  Expand 立即 → Migrate 1~6 小时 → 等 24 小时 → Contract

大变更（> 100 万行）：
  Expand 立即 → Migrate 数小时 → 等 1 周 → Contract
```

## 2. PostgreSQL 在线 DDL 详解

### ADD COLUMN（PG 11+）

```sql
-- PG 11 之前：DEFAULT 常量也重写整表 → 锁表很久
-- PG 11+：DEFAULT 常量利用元数据 → 极快

-- 安全（PG 11+）
ALTER TABLE orders ADD COLUMN currency varchar(3) NOT NULL DEFAULT 'USD';

-- PG 10 及以下，分两步：
ALTER TABLE orders ADD COLUMN currency varchar(3);
UPDATE orders SET currency = 'USD' WHERE currency IS NULL;  -- 分批
ALTER TABLE orders ALTER COLUMN currency SET NOT NULL;
ALTER TABLE orders ALTER COLUMN currency SET DEFAULT 'USD';
```

### ADD CONSTRAINT NOT VALID

```sql
-- 锁少的约束添加
ALTER TABLE orders ADD CONSTRAINT chk_amount_positive
  CHECK (amount > 0) NOT VALID;  -- 立即生效（仅新数据）

-- 后台慢慢验证历史数据（不阻塞写）
ALTER TABLE orders VALIDATE CONSTRAINT chk_amount_positive;
```

### ADD FOREIGN KEY

```sql
-- 同上 NOT VALID 模式
ALTER TABLE orders ADD CONSTRAINT fk_orders_user
  FOREIGN KEY (user_id) REFERENCES users(id) NOT VALID;

ALTER TABLE orders VALIDATE CONSTRAINT fk_orders_user;
```

### CREATE INDEX CONCURRENTLY

```sql
-- 不阻塞写（多花 2~3 倍时间）
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- 失败处理
SELECT * FROM pg_indexes WHERE indexname = 'idx_orders_user_id';
-- 如果 INVALID：
DROP INDEX idx_orders_user_id;
-- 重新建
```

### REINDEX CONCURRENTLY（PG 12+）

```sql
-- 重建索引不锁表
REINDEX INDEX CONCURRENTLY idx_orders_user_id;
REINDEX TABLE CONCURRENTLY orders;
```

## 3. MySQL Online DDL 详解

### Online DDL 三种算法

```sql
-- COPY：复制整表（旧）
ALTER TABLE orders ADD COLUMN status varchar(32), ALGORITHM=COPY;

-- INPLACE：原地修改
ALTER TABLE orders ADD COLUMN status varchar(32), ALGORITHM=INPLACE, LOCK=NONE;

-- INSTANT（8.0+）：仅元数据
ALTER TABLE orders ADD COLUMN status varchar(32), ALGORITHM=INSTANT;
```

### 速查表（MySQL 8.0）

| 操作 | INSTANT | INPLACE | COPY |
|---|---|---|---|
| ADD COLUMN（末尾） | ✅ 8.0+ | ✅ | ✅ |
| ADD COLUMN（中间） | ❌ | ✅ | ✅ |
| DROP COLUMN | ❌ | ✅ | ✅ |
| MODIFY COLUMN（兼容） | ❌ | ✅ | ✅ |
| MODIFY COLUMN（不兼容） | ❌ | ❌ | ✅ |
| RENAME COLUMN | ✅ 8.0+ | ✅ | ✅ |
| ADD INDEX | ❌ | ✅ | ✅ |
| DROP INDEX | ❌ | ✅ | - |
| RENAME INDEX | ✅ | ✅ | - |

### gh-ost 详解

```text
原理：
  1. 创建影子表（带新 schema）
  2. 从 binlog 获取主库写入
  3. 应用到影子表（异步）
  4. 切换：rename old → backup, shadow → main

优势：
  - 无触发器（不影响主库性能）
  - 可暂停 / 限速
  - 可控

使用：
  gh-ost \
    --host=localhost --user=root --password=xxx \
    --database=mydb --table=orders \
    --alter="ADD COLUMN status varchar(32)" \
    --execute
```

### pt-online-schema-change

```text
原理：
  1. 创建影子表
  2. 触发器同步主表写入
  3. 分批拷贝旧数据
  4. RENAME 切换

劣势：
  - 触发器影响主表
  - 大表触发器拖慢主库
```

## 4. 大表迁移真实案例

### 案例 1：GitHub 重构 issues 表

```text
背景：4 亿行 issues 表添加 type 字段
方案：
  1. 用 gh-ost 添加 type 列（NULL）—— 12 小时
  2. 双写：新创建的 issue 同时写 type
  3. 回填：分批 UPDATE，10 万/批，限速
  4. 切换读
  5. 1 周观察
  6. ALTER 添加 NOT NULL（NOT VALID + VALIDATE）

总时间：3 周
影响：0 服务中断
```

### 案例 2：Stripe 拆分 events 表

```text
背景：events 表 100 亿行，单表性能瓶颈
方案：
  1. 创建分区表（按时间）
  2. 应用双写（旧表 + 新分区表）
  3. 后台逐月迁移历史数据
  4. 验证一致性（多个月份）
  5. 切换读
  6. 删除旧表

总时间：6 个月
关键：app 层抽象隔离
```

## 5. 回填脚本最佳实践

### 模板（PostgreSQL）

```sql
DO $$
DECLARE
  batch_size INT := 1000;
  total_processed BIGINT := 0;
  rows_updated INT;
  start_id BIGINT;
  end_id BIGINT;
BEGIN
  -- 取最大 ID
  SELECT COALESCE(MAX(id), 0) INTO end_id FROM orders;
  start_id := 0;

  WHILE start_id < end_id LOOP
    UPDATE orders
    SET source = COALESCE(source, 'unknown')
    WHERE id > start_id AND id <= start_id + batch_size
      AND source IS NULL;
    
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    total_processed := total_processed + rows_updated;
    
    -- 进度记录
    UPDATE migration_progress
    SET processed_rows = total_processed,
        updated_at = now()
    WHERE job_name = 'backfill_orders_source';
    
    start_id := start_id + batch_size;
    PERFORM pg_sleep(0.05);  -- 限速
  END LOOP;
END $$;
```

### 限速策略

```text
固定间隔（简单）：
  每 1000 行 sleep 50ms

自适应（高级）：
  监控复制延迟 → 延迟 > 5s 则 sleep 1s
  监控锁等待 → 锁等待 > 100ms 则减小批次
  监控磁盘 IO → 接近上限则 sleep
```

## 6. 复制延迟监控

### PostgreSQL

```sql
-- 主库
SELECT
  pg_current_wal_lsn() - sent_lsn AS sent_lag,
  pg_current_wal_lsn() - flush_lsn AS flush_lag,
  pg_current_wal_lsn() - replay_lsn AS replay_lag,
  client_addr, application_name
FROM pg_stat_replication;

-- 备库（看落后多少）
SELECT
  CASE WHEN pg_is_in_recovery()
    THEN EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))::INT
    ELSE 0 END AS lag_seconds;
```

### MySQL

```sql
-- 备库执行
SHOW REPLICA STATUS\G

-- 关键字段：
-- Seconds_Behind_Source（秒数）
-- 0 = 不落后
-- NULL = 复制断了
```

## 7. 灰度发布策略

### 按租户灰度

```python
# 应用层判断
def use_new_schema(tenant_id):
    canary_tenants = get_canary_tenants()  # 从配置获取
    rollout_percentage = get_rollout_percentage()  # 从配置获取
    
    if tenant_id in canary_tenants:
        return True
    
    return hash(tenant_id) % 100 < rollout_percentage
```

### 按 ID 哈希灰度

```sql
-- 5% 用户
WHERE crc32(user_id::text) % 20 = 0

-- 50% 用户
WHERE crc32(user_id::text) % 2 = 0
```

### 监控指标（每个灰度阶段）

```text
□ 错误率（vs 基线）
□ P99 响应时间（vs 基线）
□ 数据库 CPU / IO / 锁等待
□ 主从复制延迟
□ 队列堆积
□ 业务指标（订单数 / 注册数 / 收入）
```

## 8. 回滚决策矩阵

| 症状 | 严重度 | 行动 |
|---|---|---|
| 错误率 > 5% | 高 | 立即回滚 |
| 错误率 1~5% | 中 | 暂停灰度，查根因 |
| P99 退化 > 50% | 高 | 立即回滚 |
| 主从延迟 > 5 分钟 | 中 | 暂停回填 |
| 磁盘使用 > 90% | 高 | 暂停回填，扩容 |
| 业务指标退化 | 高 | 立即回滚 |

## 9. 灾难恢复（备份 + PITR）

### 备份层级

```text
1. 全量备份（每天）
   pg_dump / mysqldump
   
2. WAL 归档 / binlog（持续）
   Point-In-Time Recovery 基础
   
3. 物理复制（实时）
   pg_basebackup / xtrabackup

4. 跨区域复制（容灾）
   异地从库
```

### 恢复演练（必做）

```text
每季度演练：
  1. 选一个表 / 时间点
  2. 在隔离环境恢复
  3. 验证数据一致
  4. 测量恢复时间（RTO）
  5. 测量数据丢失（RPO）

未演练的备份 = 没有备份
```

## 10. 自检清单（资深视角）

```text
□ 用 Expand/Contract 模式
□ 应用代码与 schema 解耦发布
□ 大表识别（≥ 100 万行 / ≥ 1GB）
□ 用合适的工具（CONCURRENTLY / gh-ost）
□ 回填分批 / 幂等 / 可暂停
□ 进度可观测（migration_progress 表）
□ 复制延迟监控
□ 磁盘空间监控
□ 灰度 5% → 50% → 100%
□ 每个阶段有明确退出条件
□ 回滚方案三层（代码 / Schema / 数据）
□ 不可逆操作有备份
□ 至少 1 周观察期
□ 灾难恢复演练（季度）
□ Migration 脚本进版本控制
□ 与应用部署协调发布顺序
```
