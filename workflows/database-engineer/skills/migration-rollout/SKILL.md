---
name: migration-rollout
description: 设计数据库迁移、回填、灰度切换和回滚方案时使用。适用于生产表结构变更、大表迁移、数据修复和上线前评审。融合 Strangler Pattern + Expand/Contract + 双写校验 + 在线 DDL。
---

# 迁移与上线（Migration & Rollout）

参考来源：Martin Fowler《Refactoring Databases》Expand/Contract 模式、Sam Newman《Building Microservices》、GitHub gh-ost、Percona pt-online-schema-change、Stripe / Shopify 大表迁移实践。

## 适用场景

- 新增、修改、删除表和字段
- 大表回填、数据修复、历史数据清洗
- 新旧字段双写、灰度切换、兼容窗口
- 新增或删除索引、约束、外键
- 库间数据迁移（拆库 / 合库 / 跨数据中心）
- 输出上线计划、回滚计划和验证清单

## 核心原则

```text
1. 生产迁移不是单条 DDL
   先兼容 → 再切换 → 最后清理

2. 先备份，再变更，最后验证
   任何不可逆操作都必须拆阶段

3. Expand/Contract 模式（数据库重构核心思想）
   Expand：加新字段，新旧并存
   切换：双写、回填、双读
   Contract：删旧字段

4. 应用代码与 schema 解耦发布
   schema 变更应能独立于代码部署

5. 大表 = 数据库 ≥ 1GB 或 ≥ 1000 万行
   大表迁移必须考虑锁表 / 复制延迟 / 磁盘

6. 灰度先于全量
   关键变更：5% → 50% → 100%

7. 回滚永远可执行
   不可逆操作必须有数据备份
```

## Expand / Contract 模式（重命名列示例）

```text
目标：把 user.username 重命名为 user.display_name

阶段 1：Expand（兼容变更）
  ALTER TABLE users ADD COLUMN display_name varchar(100);
  -- 老代码继续读写 username
  -- 新代码同时写两列

阶段 2：双写
  -- 部署新代码
  -- 触发器或应用层同步：username → display_name
  CREATE TRIGGER sync_username_display_name
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION sync_user_names();

阶段 3：回填
  -- 分批回填历史数据
  UPDATE users SET display_name = username
  WHERE display_name IS NULL AND id BETWEEN ? AND ?;

阶段 4：切换读
  -- 应用代码改读 display_name
  -- 持续观察一段时间（一周）

阶段 5：Contract（清理）
  -- 移除触发器
  DROP TRIGGER sync_username_display_name ON users;
  -- 应用停写 username
  -- 删除旧列
  ALTER TABLE users DROP COLUMN username;
```

## 标准迁移阶段

```text
1. 现状确认
   □ 表大小（行数 + 占空间）
   □ 写入频率（QPS）
   □ 依赖服务（哪些应用读 / 写）
   □ 备份状态（最近备份时间 + 已验证恢复）
   □ 复制拓扑（主从延迟 / 半同步）
   ↓
2. 兼容变更（Expand）
   □ 新增字段 / 表 / 索引
   □ 不破坏旧代码
   □ 默认 NULL 或安全默认值
   ↓
3. 回填
   □ 分批
   □ 限速
   □ 幂等（可重试）
   □ 可观测进度
   □ 可暂停
   ↓
4. 双读 / 双写或灰度切换
   □ 验证新旧数据一致
   □ 监控错误率
   □ 灰度比例：5% / 50% / 100%
   ↓
5. 清理（Contract）
   □ 删除旧字段 / 旧索引 / 旧逻辑
   □ 至少灰度全量后等 1 周
   ↓
6. 回滚和复盘
   □ 记录风险与经验
```

## 危险 DDL 操作清单

### PostgreSQL

| 操作 | 锁级别 | 锁表? | 替代方案 |
|---|---|---|---|
| `ADD COLUMN`（NULL） | ACCESS EXCLUSIVE | 极短 | 安全 |
| `ADD COLUMN ... DEFAULT`（PG 11+ 常量） | ACCESS EXCLUSIVE | 极短 | 安全 |
| `ADD COLUMN NOT NULL DEFAULT ?` | ACCESS EXCLUSIVE | 极短（PG 11+） | 旧版需多步 |
| `ALTER COLUMN TYPE` | ACCESS EXCLUSIVE | 重写整表 | 加新列 + 双写 + 删旧 |
| `ADD CONSTRAINT NOT NULL` | ACCESS EXCLUSIVE | 全表扫 | NOT VALID + VALIDATE |
| `ADD FOREIGN KEY` | SHARE ROW EXCLUSIVE | 长 | NOT VALID + VALIDATE |
| `CREATE INDEX` | SHARE | 阻塞写 | CONCURRENTLY |
| `DROP TABLE / DROP COLUMN` | ACCESS EXCLUSIVE | 短 | 安全 |
| `RENAME COLUMN` | ACCESS EXCLUSIVE | 短 | Expand/Contract |

### MySQL

| 操作 | InnoDB Online DDL? | 替代方案 |
|---|---|---|
| `ADD COLUMN`（5.6+） | ✅ INPLACE | 安全 |
| `DROP COLUMN`（5.6+） | ✅ INPLACE | 安全 |
| `ALTER COLUMN TYPE`（兼容） | ✅ INPLACE / 8.0 INSTANT | 多数 OK |
| `ALTER COLUMN TYPE`（不兼容） | ❌ COPY | gh-ost / pt-osc |
| `ADD INDEX`（5.6+） | ✅ INPLACE | 安全 |
| `RENAME INDEX`（5.7+） | ✅ INSTANT | 安全 |
| `OPTIMIZE TABLE` | ❌ COPY（5.6 前） | gh-ost |

## 迁移计划表

| 阶段 | 操作 | SQL | 前置条件 | 验证方式 | 回滚方式 | 负责人 | 预计耗时 |
|------|------|-----|----------|----------|----------|--------|---------|
| 1 兼容变更 | 新增 nullable 字段 | `ALTER TABLE orders ADD ...` | 备份完成 | schema 检查 | 删除字段（无写入时） | DBE | 5 分钟 |
| 2 双写 | 部署新代码 | - | 阶段 1 完成 | 监控错误率 | 回滚部署 | Dev | 10 分钟 |
| 3 回填 | 分批 UPDATE | 见脚本 | 阶段 2 稳定 24h | COUNT 校验 | 不回滚（幂等） | DBE | 2 小时 |
| 4 切换读 | 部署读新列代码 | - | 阶段 3 完成 | 业务监控 | 回滚部署 | Dev | 10 分钟 |
| 5 等观察 | - | - | - | - | - | - | 1 周 |
| 6 清理 | 删旧列 | `ALTER TABLE ... DROP COLUMN` | 阶段 5 无问题 | schema 检查 | 备份恢复 | DBE | 5 分钟 |

## 大表迁移工具

### PostgreSQL

```text
1. CREATE INDEX CONCURRENTLY
   - 不锁表
   - 失败留 INVALID 索引

2. pg_repack
   - 在线重整表（消除膨胀）
   - 触发器 + 副本

3. 内置：ADD COLUMN ... DEFAULT 常量（PG 11+）
   - 不重写表
   - 元数据级
```

### MySQL

```text
1. gh-ost（GitHub 出品）
   - 无触发器
   - 复制历史写入到影子表
   - 主从一致

2. pt-online-schema-change（Percona）
   - 触发器 + 影子表
   - 较老但稳定

3. 内置 ALTER TABLE ... ALGORITHM=INPLACE
   - 5.6+ 大部分 ALTER 已在线
```

## 回填策略

### 分批回填

```sql
-- 错：一次性回填，锁表
UPDATE orders SET source = 'unknown' WHERE source IS NULL;

-- 对：分批 + 限速
DO $$
DECLARE
  batch_size INT := 1000;
  rows_updated INT;
BEGIN
  LOOP
    UPDATE orders SET source = 'unknown'
    WHERE id IN (
      SELECT id FROM orders WHERE source IS NULL LIMIT batch_size
    );
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    EXIT WHEN rows_updated = 0;
    PERFORM pg_sleep(0.1);  -- 限速
  END LOOP;
END $$;
```

### 进度可观测

```sql
-- 单独表跟踪进度
CREATE TABLE migration_progress (
  job_name varchar PRIMARY KEY,
  total_rows bigint,
  processed_rows bigint DEFAULT 0,
  status varchar DEFAULT 'running',
  started_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### 幂等性

```sql
-- 必须可重跑
UPDATE orders SET status = 'pending'
WHERE status IS NULL  -- 幂等条件
  AND id BETWEEN ? AND ?;
```

## 回滚方案设计

### 三层回滚

```text
代码回滚（最快）：
  应用回滚到上一版本
  耗时：5~10 分钟
  适用：代码 Bug，schema 兼容时

Schema 回滚（次之）：
  执行反向 DDL（DROP COLUMN / DROP INDEX）
  耗时：5~30 分钟
  适用：schema 错误

数据回滚（最慢）：
  从备份恢复（point-in-time recovery）
  耗时：1 小时 ~ 数小时
  适用：数据损坏 / 删错数据
```

### 回滚检查表

```text
□ 回滚触发条件清晰（错误率 > X% / P99 > Y）
□ 回滚步骤可执行
□ 回滚执行人和窗口
□ 回滚后验证方式
□ 数据恢复路径（备份 + 复制）
□ 客户沟通模板（如需）
```

## 不可逆操作（必须备份）

```text
DROP TABLE / DROP COLUMN
DELETE / TRUNCATE 大表
DROP INDEX（重建慢）
ALTER COLUMN TYPE（精度丢失）
迁移到不兼容数据库
```

## 灰度策略

```text
Phase 1：金丝雀（5%）
  - 1 个节点 / 1 个租户 / 1% 用户
  - 持续 1 小时～1 天
  - 监控核心指标

Phase 2：扩大（50%）
  - 多节点 / 多租户 / 50% 用户
  - 持续 1～3 天
  - 业务方确认

Phase 3：全量（100%）
  - 全部
  - 持续 1 周观察
  - 进入清理阶段
```

## 配套模板

- `templates/migration-plan-template.md` — 完整迁移计划（背景 + 阶段表 + 验证 + 回滚 + 风险 + 待确认）
- `templates/rollback-checklist-template.md` — 回滚清单（触发条件 / 步骤 / 验证 / 沟通）

## 质量自检

```text
□ 区分空库迁移和生产存量迁移
□ 评估锁表、长事务、磁盘、复制延迟
□ 有备份点和恢复验证
□ 回填分批、幂等、可重试、可暂停
□ 进度可观测
□ 灰度、监控、回滚条件清晰
□ 与后端发布顺序明确
□ 标注不可逆操作
□ 回滚永远可执行
□ 大表用 CONCURRENTLY / Online DDL / gh-ost
□ Expand/Contract 模式（重命名 / 类型变更）
□ 至少 1 周观察期再 Contract
```

## 常见坑

1. **大表 NOT NULL DEFAULT 锁表**——PG 旧版本会重写整表（PG 11+ 已修复）
2. **先删字段再发代码**——旧版本服务崩溃
3. **回填脚本不可重复执行**——失败后无法恢复
4. **没检查复制延迟**——主从延迟到分钟级
5. **没监控磁盘**——回填到一半磁盘满
6. **回滚方案只写"回滚代码"**——没有数据恢复路径
7. **CREATE INDEX 不用 CONCURRENTLY**——PG 锁写
8. **MySQL 跑 gh-ost 不留 buffer**——磁盘满
9. **灰度跳过**——直接全量上线
10. **不可逆操作未备份**——删错列无法恢复
11. **没观察期就 Contract**——刚切完就删旧列，回滚困难
12. **触发器拷贝数据没限速**——主从延迟爆炸
13. **应用代码强依赖新 schema**——schema 失败时应用挂
14. **Migration 脚本不进版本控制**——团队各自跑各自的

## 与其他 skill 的协作

```text
上游：
  schema-design → DDL 来源
  index-access-pattern → 索引变更来源

下游：
  data-operations-safety → 生产操作门禁
  backend-engineer → 应用代码同步发布
  devops-engineer → 部署窗口、CI/CD
  sre-ops → 监控、告警、复制延迟、磁盘
  qa-engineer → 迁移验证用例
```

## 相关参考

- `references/migration-rollout-guide.md` — Expand/Contract 模式深度、gh-ost / pg_repack 实战、回填限速策略、灰度发布、复制延迟监控
