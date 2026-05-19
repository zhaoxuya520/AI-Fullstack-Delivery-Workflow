---
name: data-operations-safety
description: 生产数据操作、备份恢复、批量修复、数据导出和高风险变更前使用。适用于上线门禁、恢复验证、脱敏边界和操作风险评估。融合 SRE 双人复核 + 灰度执行 + 三层备份 + GDPR 脱敏。
---

# 数据操作安全（Data Operations Safety）

参考来源：Google《Site Reliability Engineering》Postmortem 文化、AWS Well-Architected Framework、PostgreSQL Backup 文档、MySQL Operational Best Practices、GDPR / CCPA 合规规范。

## 适用场景

- 生产 DDL、索引、回填、批量 UPDATE / DELETE 前检查
- 数据修复脚本、导入导出、脱敏处理
- 备份、恢复、恢复演练和验证
- 高风险变更影响面评估
- 输出上线前数据库门禁清单
- 紧急数据修复（生产事故）

## 核心原则

```text
1. 能恢复，才允许变更
   未验证恢复的备份 = 没有备份

2. 双人复核（4-eyes principle）
   生产 DELETE / UPDATE / DROP 必须 2 人确认

3. 灰度先于全量
   1 行 → 100 行 → 10000 行 → 全部

4. 影响面预估必须做
   COUNT 受影响行数 / 锁表时长 / 磁盘增量

5. 每次操作有审计
   谁、何时、对什么、为什么、结果如何

6. 不可逆操作必须备份
   DROP TABLE / DROP COLUMN / DELETE 大批

7. 脱敏永不可逆
   测试 / 开发环境的生产数据必须脱敏

8. 操作脚本进版本控制
   不在 production console 即兴写
```

## 操作前检查清单（必填）

```text
□ 1. 授权
  □ 操作目的
  □ 操作人 + 审批人
  □ 目标环境（dev / staging / prod）
  □ 业务方知悉

□ 2. 影响面
  □ 受影响表 / 行数
  □ 锁表预估时间
  □ 磁盘增量预估
  □ 复制延迟影响
  □ 受影响业务（哪些 API / 用户）

□ 3. 备份
  □ 最近备份时间（< 24h）
  □ 备份是否已验证恢复
  □ 备份恢复 RTO（多久能恢复）
  □ 必要时新建备份点

□ 4. 脚本质量
  □ 脚本幂等
  □ 脚本可暂停
  □ 脚本可恢复
  □ 分批 + 限速
  □ 进度可观测

□ 5. 监控
  □ 数据库 CPU / IO / 锁等待
  □ 主从复制延迟
  □ 磁盘空间
  □ 业务指标（错误率 / P99）

□ 6. 回滚
  □ 回滚条件清晰（错误率 > X / 延迟 > Y）
  □ 回滚步骤可执行
  □ 数据恢复路径

□ 7. 灰度
  □ 1 行测试（dry-run）
  □ 100 行
  □ 10000 行
  □ 全部
```

## 高风险操作清单

| 操作 | 必备检查 | 灰度策略 |
|------|----------|---------|
| DDL 变更 | 锁表风险、兼容性、回滚路径 | dev → staging → prod |
| 大表回填 | 分批、限速、幂等、进度记录 | 1k → 10k → 100k → 全部 |
| 批量 UPDATE | WHERE 复核、影响行数、备份 | 1 行 → 100 → 10000 → 全 |
| 批量 DELETE | 同 UPDATE + 强制备份 | 同上 |
| 索引变更 | 建索引耗时、磁盘、写入影响 | CONCURRENTLY 单表 |
| 数据导出 | 授权、脱敏、保存位置、销毁策略 | 小样 → 全量 |
| 恢复操作 | 备份有效性、恢复点、数据一致性 | 隔离环境先验证 |
| TRUNCATE | 备份 + 三人确认 | 无（不可逆）|

## 灰度执行模板

```sql
-- 阶段 1：DRY RUN（看影响行数）
BEGIN;
SELECT COUNT(*) FROM orders
WHERE status = 'unknown' AND created_at < '2025-01-01';
ROLLBACK;
-- 看到：影响 1234567 行

-- 阶段 2：1 行测试
BEGIN;
UPDATE orders SET status = 'archived'
WHERE id = (SELECT id FROM orders WHERE status = 'unknown' LIMIT 1);
-- 验证结果
SELECT * FROM orders WHERE status = 'archived' LIMIT 5;
COMMIT;

-- 阶段 3：100 行
BEGIN;
UPDATE orders SET status = 'archived'
WHERE id IN (
  SELECT id FROM orders
  WHERE status = 'unknown' AND created_at < '2025-01-01'
  LIMIT 100
);
COMMIT;

-- 阶段 4：分批全量（限速）
DO $$
DECLARE
  rows_updated INT;
  total INT := 0;
BEGIN
  LOOP
    UPDATE orders SET status = 'archived'
    WHERE id IN (
      SELECT id FROM orders
      WHERE status = 'unknown' AND created_at < '2025-01-01'
      LIMIT 1000
    );
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    total := total + rows_updated;
    
    -- 进度
    RAISE NOTICE 'Updated total: %', total;
    
    EXIT WHEN rows_updated = 0;
    PERFORM pg_sleep(0.1);  -- 限速
  END LOOP;
END $$;
```

## 备份策略

### 三层备份

```text
1. 物理备份（每天）
   - PostgreSQL: pg_basebackup / pgBackRest
   - MySQL: xtrabackup / mysqlbackup
   - 用途：完整恢复、克隆环境

2. 逻辑备份（每周或按需）
   - PostgreSQL: pg_dump
   - MySQL: mysqldump
   - 用途：单表恢复、跨版本迁移

3. 持续归档（实时）
   - PostgreSQL: WAL 归档（PITR 基础）
   - MySQL: binlog
   - 用途：Point-In-Time Recovery
```

### 备份验证（关键）

```bash
#!/bin/bash
# 每月备份恢复演练

# 1. 在隔离环境恢复最近备份
restore_backup_to_test_env

# 2. 验证数据完整性
psql -h test_env -c "SELECT COUNT(*) FROM critical_tables"

# 3. 验证关键查询
psql -h test_env -c "SELECT COUNT(*) FROM orders WHERE created_at > now() - INTERVAL '1 day'"

# 4. 计算 RTO（恢复时间）
# 5. 计算 RPO（数据损失窗口）

# 6. 记录结果
echo "Backup test: PASS, RTO=15min, RPO=5min" >> /var/log/backup-test.log
```

### Point-In-Time Recovery（PITR）

```bash
# PostgreSQL PITR：恢复到任意时间点
pg_basebackup -D /backup/base/

# WAL 持续归档（postgresql.conf）
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'

# 恢复到 2026-05-18 14:30:00
restore_command = 'cp /backup/wal/%f %p'
recovery_target_time = '2026-05-18 14:30:00'
```

## 数据导出和脱敏

### 脱敏规则

```sql
-- 不可逆脱敏脚本（生产 → 测试）

-- 邮箱（保留域名）
UPDATE users SET email = MD5(email) || '@test.example.com';

-- 手机号（替换中间 4 位）
UPDATE users SET phone = SUBSTRING(phone, 1, 3) || '****' || SUBSTRING(phone, 8);

-- 姓名（保留姓 + 假名）
UPDATE users SET name = SUBSTRING(name, 1, 1) || '****';

-- 身份证（替换中间）
UPDATE users SET id_card = SUBSTRING(id_card, 1, 6) || '********' || SUBSTRING(id_card, 15);

-- 地址（仅保留城市级）
UPDATE users SET address = REGEXP_REPLACE(address, '(.*?[市县区]).*', '\1');

-- 银行卡（仅保留前 6 + 后 4）
UPDATE users SET card_number = SUBSTRING(card_number, 1, 6) || '******' || SUBSTRING(card_number, -4);

-- 完全删除
UPDATE users SET 
  password = NULL,
  api_token = NULL,
  refresh_token = NULL,
  notes = NULL;  -- 用户备注可能含 PII

-- 跳过最近的活跃用户（避免泄露）
DELETE FROM users WHERE last_login_at > now() - INTERVAL '30 days';
```

### 导出审计

```sql
-- 记录所有导出
CREATE TABLE export_audit (
  id bigserial PRIMARY KEY,
  exported_by varchar(64) NOT NULL,
  exported_at timestamptz DEFAULT now(),
  table_name varchar(64) NOT NULL,
  row_count bigint,
  destination varchar(255) NOT NULL,
  reason text,
  approved_by varchar(64) NOT NULL,
  retention_days integer DEFAULT 30
);
```

## 数据修复（生产事故）

### 修复流程（必须）

```text
1. 评估影响
   - 影响行数 / 用户数
   - 业务影响
   - 是否需要客户沟通

2. 备份当前状态
   - 即使数据已损坏，备份是修复依据
   - CREATE TABLE backup_before_fix AS SELECT * FROM ...

3. 在 staging 验证修复脚本
   - 完整 dry-run

4. 双人复核
   - 第二人 review SQL
   - 第二人执行（如可能）

5. 生产执行（灰度）
   - 1 行 → 100 行 → 全量

6. 验证
   - 修复后状态符合预期
   - 业务指标恢复

7. 通知
   - 业务方
   - 受影响用户（如适用）

8. 复盘
   - 写 postmortem
   - 沉淀到 field-journal
   - 评估流程改进
```

### 修复脚本示例

```sql
-- 场景：bug 导致 500 个订单状态错误

-- 阶段 1：备份
CREATE TABLE _backup_orders_2026_05_18 AS
SELECT * FROM orders
WHERE id IN (...)  -- 受影响 ID 列表
;

-- 阶段 2：dry run
SELECT id, status, expected_status
FROM (
  SELECT id, status,
    CASE WHEN ... THEN 'paid' ELSE 'cancelled' END AS expected_status
  FROM orders
  WHERE id IN (...)
) sub
WHERE status != expected_status;
-- 验证 500 行符合预期

-- 阶段 3：1 行修复
UPDATE orders SET status = 'paid'
WHERE id = (SELECT id FROM ... LIMIT 1);
-- 业务验证：1 个用户的订单状态正常

-- 阶段 4：批量
BEGIN;
UPDATE orders SET status = ... WHERE id IN (...);
-- COMMIT 前再 SELECT 验证
SELECT COUNT(*), status FROM orders WHERE id IN (...) GROUP BY status;
COMMIT;

-- 阶段 5：清理
-- 30 天后删除备份表
DROP TABLE _backup_orders_2026_05_18;
```

## 操作命令模板

### 改 SQL 前必跑

```sql
-- PostgreSQL：dry-run 看影响
EXPLAIN (ANALYZE FALSE)
UPDATE orders SET status = 'archived'
WHERE created_at < '2025-01-01';

-- 看 actual rows 估算

-- 实际跑：包在事务里看结果
BEGIN;
UPDATE orders SET status = 'archived'
WHERE created_at < '2025-01-01' LIMIT 100;
SELECT COUNT(*) FROM orders WHERE status = 'archived';
ROLLBACK;  -- 或 COMMIT
```

### MySQL 安全模式

```sql
-- 防止 UPDATE/DELETE 不带 WHERE
SET sql_safe_updates = 1;

-- 现在以下会报错：
DELETE FROM orders;  -- ERROR 1175

-- 必须明确条件
DELETE FROM orders WHERE id = 123;  -- OK
```

## 配套模板

- `templates/db-change-safety-checklist-template.md` — 操作前完整检查 + 影响评估 + 备份确认 + 灰度方案 + 回滚 + 审计

## 质量自检

```text
□ 明确环境、授权范围和负责人
□ 双人复核（生产 DELETE / DROP）
□ 备份和恢复验证
□ 估算影响行数、锁、磁盘、耗时
□ 脚本幂等、分批、可重试、可停止
□ 设置监控和回滚条件
□ 灰度执行（1 → 100 → 10k → 全部）
□ 避免泄露敏感数据
□ 记录执行结果和复盘项
□ 操作脚本进版本控制
□ 不在 production console 即兴写 SQL
□ 修复脚本在 staging 验证过
```

## 常见坑

1. **没 WHERE 复核就 UPDATE/DELETE**——一秒清空全表
2. **备份存在但从未验证恢复**——真要恢复时备份损坏
3. **回填脚本不可暂停**——失败后无法续跑
4. **导出生产数据未脱敏**——PII 泄露
5. **导出生产数据无销毁策略**——测试环境永久保留 PII
6. **DDL 风险只交给应用发布流程**——DBA 没权审 SQL
7. **修复脚本不留备份**——修错无法回退
8. **TRUNCATE 不三人确认**——不可逆
9. **DROP TABLE 当作普通操作**——级联删除引发灾难
10. **大表加索引不监控**——磁盘满 / 主从断
11. **生产 console 即兴写 SQL**——无版本控制、无审计
12. **修复脚本没 dry run**——直接全量错
13. **跨租户操作无审计**——后期追溯困难
14. **脱敏脚本不彻底**——昵称 / 备注 / metadata 仍含 PII

## 与其他 skill 的协作

```text
上游：
  migration-rollout → 提供迁移计划
  consistency-multitenancy → 提供租户和权限边界
  schema-design → 提供 DDL

下游：
  devops-engineer → 执行窗口、监控、CI/CD
  sre-ops → 监控、告警、恢复
  security-engineer → 敏感数据和权限审查
  field-journal → 记录真实操作经验
  qa-engineer → 数据修复后的回归
```

## 相关参考

- `references/data-operations-safety-guide.md` — SRE Postmortem、生产事故案例库、备份恢复演练、脱敏脚本完整库、双人复核流程
