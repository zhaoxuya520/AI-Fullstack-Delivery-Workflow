# 数据操作安全深度指引

参考：Google《Site Reliability Engineering》、Netflix Chaos Engineering、Etsy Just Culture、AWS Operational Excellence Pillar、PostgreSQL Backup 文档、MySQL Operational Best Practices。

## 1. SRE 操作哲学

### 错误预算（Error Budget）

```text
SLO：99.99% 可用 → 每月允许 4 分钟不可用

每次高风险操作消耗错误预算：
  - 灰度小心 → 消耗少
  - 直接全量 → 消耗多

预算用完 → 冻结发布，专注稳定性
```

### Postmortem 文化（不追责，求改进）

```text
Postmortem 必含：
  1. 事故时间线（精确到分钟）
  2. 影响范围（用户 / 业务）
  3. 根因分析（5 Whys）
  4. 修复措施
  5. 改进项（防止再次发生）
  6. 教训沉淀（field-journal）

Just Culture：
  - 责任在系统，不在个人
  - "为什么这么容易出错？"
  - 不是"谁犯了错"
```

### 双人复核（4-eyes Principle）

```text
适用：
  - 生产 DELETE / UPDATE 大批
  - 生产 DROP / TRUNCATE
  - 数据导出（含 PII）
  - 资金相关操作

流程：
  1. 操作人写脚本
  2. Reviewer 审 SQL（看 WHERE 条件、影响范围）
  3. 操作人执行（或 Reviewer 执行）
  4. 双方签字确认

文化：
  - 不是不信任，是双重保险
  - Senior 也要被 review
```

## 2. 真实事故案例

### GitLab 删库事件（2017-01-31）

```text
背景：复制延迟，工程师手动同步
事故：在主库执行 rm -rf （以为是从库）
影响：
  - 6 小时不可用
  - 6 小时数据丢失
  - 5 小时手动恢复

根因：
  - 备份机制 5 个全部失效
  - LVM 快照功能损坏
  - 复制状态混乱
  - 终端切错

教训：
  - 永远不在生产 rm -rf
  - 备份必须验证（不只是"看起来在跑"）
  - 多个备份机制不等于多重备份
  - 终端 prompt 区分（绿色 dev / 红色 prod）
```

### Knight Capital 4.5 亿美元事件（2012-08-01）

```text
背景：交易系统升级
事故：8 台服务器中 7 台升级，1 台未升级
影响：45 分钟内交易了 70 亿股，亏损 4.4 亿美元

根因：
  - 部署没有完整自动化
  - 旧代码遗留功能在新代码下行为不同
  - 没有 kill switch

教训：
  - 部署必须全自动 + 验证
  - 部分升级是禁忌
  - 必须有紧急停止开关
  - 灰度 + 监控 + 自动回滚
```

### Stripe 事件（2019-07-10）

```text
背景：MongoDB → PostgreSQL 迁移
事故：写入错误的字段类型导致部分订单失败
影响：少量订单创建失败 30 分钟

应对：
  - 自动监控发现异常
  - 立即回滚
  - 公开 postmortem

教训：
  - 类型验证在迁移中至关重要
  - 自动化监控 + 自动化回滚
  - 公开透明赢得信任
```

## 3. 生产 SQL 审查清单

### 改写检查

```sql
-- ❌ 危险
DELETE FROM users WHERE 1=1;
UPDATE users SET email = NULL;
TRUNCATE TABLE orders;
DROP TABLE old_orders;

-- ✅ 安全（明确条件 + 限制）
DELETE FROM users WHERE id = ? AND deleted_at IS NULL LIMIT 1;
UPDATE users SET email = ? WHERE id = ? AND email = ?;  -- 旧 email 校验
```

### Review 关注点

```text
□ WHERE 条件是否唯一定位
□ 是否有 LIMIT 兜底
□ 是否影响多张表（外键级联）
□ 是否在事务内
□ 索引能否被用上（看 EXPLAIN）
□ 锁等级（FOR UPDATE / NO LOCK）
□ 是否在主库还是从库
□ 时区 / 字符集是否正确
□ 是否带 timeout
```

## 4. 备份恢复演练（季度必做）

### 演练脚本

```bash
#!/bin/bash
# 备份恢复演练 - 季度执行

set -e

BACKUP_FILE=$(ls -t /backups/*.sql.gz | head -1)
TEST_DB="restore_test_$(date +%Y%m%d)"
TIMER_START=$(date +%s)

echo "===== 演练开始 ====="
echo "备份文件: $BACKUP_FILE"
echo "测试数据库: $TEST_DB"

# 1. 创建隔离测试库
createdb $TEST_DB

# 2. 恢复
gunzip -c $BACKUP_FILE | psql $TEST_DB

# 3. 验证关键表行数
echo "===== 数据完整性验证 ====="
psql $TEST_DB -c "SELECT 'users' AS table, COUNT(*) FROM users;"
psql $TEST_DB -c "SELECT 'orders' AS table, COUNT(*) FROM orders;"
psql $TEST_DB -c "SELECT 'payments' AS table, COUNT(*) FROM payments;"

# 4. 验证关键查询
psql $TEST_DB -c "SELECT COUNT(*) FROM orders WHERE created_at > now() - INTERVAL '7 days';"

# 5. 验证关联完整
psql $TEST_DB -c "
  SELECT COUNT(*) FROM orders o
  LEFT JOIN users u ON o.user_id = u.id
  WHERE u.id IS NULL;
"
# 期望：0 孤儿订单

# 6. 计算 RTO
TIMER_END=$(date +%s)
RTO_SECONDS=$((TIMER_END - TIMER_START))
echo "RTO: $RTO_SECONDS 秒"

# 7. 清理
dropdb $TEST_DB

# 8. 写报告
cat <<EOF >> /var/log/backup-drill.log
$(date): RTO=$RTO_SECONDS, status=PASS
EOF

echo "===== 演练完成 ====="
```

### 演练频率

```text
S0 系统（核心交易）：每月演练
S1 系统（重要业务）：每季度演练
S2 系统（次要）：每年演练

每次演练必产出：
  - RTO（恢复时间）
  - RPO（数据丢失窗口）
  - 改进项
```

## 5. 数据导出脱敏完整脚本库

### 用户表脱敏

```sql
-- 创建脱敏版本（不破坏原表）
CREATE TABLE users_anonymized AS SELECT * FROM users;

-- 邮箱：保留域名提示业务来源
UPDATE users_anonymized SET 
  email = 'user_' || id || '@anonymized.test';

-- 手机：测试号段 138 + 8 位 ID
UPDATE users_anonymized SET 
  phone = '138' || LPAD(id::text, 8, '0');

-- 姓名：用 Faker 风格
UPDATE users_anonymized SET 
  first_name = (ARRAY['Alice','Bob','Charlie','Diana','Eve'])[1 + (id % 5)],
  last_name = (ARRAY['Smith','Jones','Brown','Johnson','Williams'])[1 + (id % 5)];

-- 地址：仅保留国家 + 城市
UPDATE users_anonymized SET 
  address = SPLIT_PART(address, ',', 1) || ', ANONYMIZED';

-- 出生日期：仅保留年份
UPDATE users_anonymized SET 
  birth_date = MAKE_DATE(EXTRACT(YEAR FROM birth_date)::int, 1, 1);

-- 完全删除
UPDATE users_anonymized SET 
  password_hash = 'REDACTED',
  api_token = NULL,
  refresh_token = NULL,
  bio = NULL,                 -- 用户简介可能含 PII
  notes = NULL;               -- 客服备注必删

-- 删除最近活跃用户（避免泄露）
DELETE FROM users_anonymized 
WHERE last_login_at > now() - INTERVAL '30 days';

-- 关联表也要处理
UPDATE messages SET 
  body = 'ANONYMIZED'
WHERE user_id IN (SELECT id FROM users_anonymized);
```

### 金融数据脱敏

```sql
-- 银行卡：保留前 6（BIN）+ 后 4
UPDATE bank_accounts SET 
  card_number = SUBSTRING(card_number, 1, 6) || '******' || SUBSTRING(card_number, -4);

-- 金额：加噪 ±10%（保留分布）
UPDATE transactions SET 
  amount = amount * (0.9 + RANDOM() * 0.2);

-- 但保留总和不变（高级）
WITH adjusted AS (
  SELECT id, amount * (0.9 + RANDOM() * 0.2) AS new_amount
  FROM transactions
),
sum_orig AS (SELECT SUM(amount) AS total FROM transactions),
sum_new AS (SELECT SUM(new_amount) AS total FROM adjusted)
UPDATE transactions t SET 
  amount = (a.new_amount * (SELECT total FROM sum_orig) / (SELECT total FROM sum_new))
FROM adjusted a WHERE t.id = a.id;
```

### 验证脱敏完整性

```sql
-- 必跑：检查是否还有真 PII
SELECT email FROM users_anonymized WHERE email NOT LIKE '%@anonymized.test' LIMIT 1;
SELECT phone FROM users_anonymized WHERE phone NOT LIKE '138%' LIMIT 1;
SELECT * FROM users_anonymized WHERE notes IS NOT NULL LIMIT 1;
SELECT * FROM users_anonymized WHERE bio IS NOT NULL LIMIT 1;

-- 检查 metadata JSON 是否含 PII
SELECT id, metadata FROM users_anonymized 
WHERE metadata::text ~ '\d{11}' OR metadata::text ~ '@\w+\.\w+'
LIMIT 5;
```

## 6. 紧急事故响应（Runbook）

### 数据库不可用

```text
1. 第一分钟（识别）
   - 监控告警确认
   - 排除网络 / 客户端问题
   - 检查数据库进程是否存活

2. 5 分钟（评估）
   - 主库 / 从库状态
   - 是否能 failover
   - 业务影响评估

3. 10 分钟（决策）
   - failover 到从库（如配置）
   - 或：启动备用实例 + 恢复备份
   - 通知 oncall + 业务方

4. 30 分钟（恢复）
   - 数据库可用
   - 验证关键查询
   - 监控错误率回落

5. 1 小时（稳定）
   - 完整 sanity check
   - 业务指标确认

6. 24 小时（复盘）
   - Postmortem
   - 改进项
   - field-journal
```

### 数据被误删

```text
1. 立即（不要慌）
   - 停止所有写入（kill 应用 / read-only 模式）
   - 防止数据被覆盖

2. 评估
   - 几行 / 哪张表 / 何时
   - 是否还在 binlog / WAL

3. 选恢复方式
   - 简单：从最近备份恢复（损失 < 24h）
   - 高级：PITR 恢复到删除前一秒

4. 在隔离环境恢复
   - 不直接覆盖生产
   - 验证数据正确

5. 应用恢复
   - 选项 A：替换整张表
   - 选项 B：导出丢失数据，INSERT 回主库

6. 验证 + 解锁应用
```

## 7. 操作审计日志

### 必记的操作

```sql
CREATE TABLE db_operation_audit (
  id bigserial PRIMARY KEY,
  operator varchar(64) NOT NULL,
  approver varchar(64),
  operation_type varchar(32) NOT NULL,  -- DDL / DML / GRANT / REVOKE
  target_schema varchar(64),
  target_table varchar(64),
  sql_statement text NOT NULL,
  affected_rows bigint,
  reason text NOT NULL,
  ticket_id varchar(64),
  executed_at timestamptz DEFAULT now(),
  duration_ms integer,
  status varchar(32) DEFAULT 'success',  -- success / failed / rolled_back
  error_message text
);

CREATE INDEX idx_audit_operator_time ON db_operation_audit(operator, executed_at DESC);
CREATE INDEX idx_audit_table ON db_operation_audit(target_table, executed_at DESC);
```

## 8. 终端安全配置

### 区分环境的终端 prompt

```bash
# ~/.psqlrc

\set PROMPT1 '%[%033[1;31m%]%n@%/%[%033[0m%]> '

\set qstats 'SELECT * FROM pg_stat_database WHERE datname = current_database();'
\set lock_status 'SELECT * FROM pg_locks WHERE NOT granted;'

-- 危险命令前确认
\set AUTOCOMMIT off  -- 默认手动 commit
```

```bash
# ~/.bashrc 或 .zshrc
# 生产环境红色提示
if [[ "$DB_ENV" == "production" ]]; then
  PS1='\[\e[1;41m\]PROD\[\e[0m\] \u@\h:\w$ '
fi
```

### 危险命令 alias

```bash
# 防止 rm -rf 直接执行
alias rm='rm -i'  # 交互式确认

# 防止 dropdb
alias dropdb='echo "Use full path with confirmation"'
```

## 9. 数据保留与合规

### GDPR 数据主体权利

```text
1. 知情权：用户可问"你存了我什么"
   → 实现：导出用户全部数据 API

2. 访问权：用户可下载自己的数据
   → 实现：JSON 导出

3. 更正权：用户可修改错误信息
   → 实现：用户编辑界面

4. 删除权（被遗忘权）：用户可要求删除
   → 实现：30 天延迟 + 硬删除

5. 限制处理权：用户可暂停处理
   → 实现：is_processing_paused 字段

6. 数据可携带权：用户可导出数据到其他服务
   → 实现：标准格式（JSON / CSV）导出

7. 反对权：用户可拒绝营销
   → 实现：unsubscribe / opt-out 字段
```

### 删除请求实现

```sql
CREATE TABLE deletion_requests (
  id bigserial PRIMARY KEY,
  user_id bigint NOT NULL REFERENCES users(id),
  requested_at timestamptz DEFAULT now(),
  scheduled_at timestamptz NOT NULL DEFAULT (now() + INTERVAL '30 days'),
  cancelled_at timestamptz,
  completed_at timestamptz,
  status varchar(32) DEFAULT 'pending'  -- pending / cancelled / completed
);

-- 30 天后批处理硬删
CREATE OR REPLACE FUNCTION execute_pending_deletions() RETURNS void AS $$
BEGIN
  -- 软删除用户
  UPDATE users SET deleted_at = now()
  WHERE id IN (
    SELECT user_id FROM deletion_requests
    WHERE status = 'pending' AND scheduled_at <= now()
  );
  
  -- 删除关联 PII
  DELETE FROM user_addresses WHERE user_id IN (...);
  DELETE FROM user_payment_methods WHERE user_id IN (...);
  
  -- 标记完成
  UPDATE deletion_requests SET status = 'completed', completed_at = now()
  WHERE status = 'pending' AND scheduled_at <= now();
END;
$$ LANGUAGE plpgsql;
```

## 10. 自检清单（资深视角）

```text
□ 操作前完整检查清单已填
□ 双人复核（生产 DELETE / DROP）
□ 备份验证（最近 < 30 天）
□ 灰度 1 → 100 → 10k → 全部
□ 脚本幂等可暂停可恢复
□ 进度可观测（migration_progress 表）
□ 监控完整（CPU / IO / 锁 / 复制 / 磁盘）
□ 回滚方案三层（代码 / Schema / 数据）
□ 不可逆操作有备份
□ 终端 prompt 区分环境
□ 操作审计日志完整
□ 数据导出脱敏验证
□ GDPR 删除请求实现
□ 季度恢复演练
□ Runbook 文档化
□ Postmortem 文化
□ 错误预算管理
```
