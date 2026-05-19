# 一致性与多租户深度指引

参考：Martin Kleppmann《Designing Data-Intensive Applications》、Pat Helland 论文、AWS SaaS Tenant Isolation Strategies、Stripe / Slack / Notion 公开技术文章。

## 1. ACID 与 BASE

### ACID（关系型）

```text
强一致性
适合：金融、计费、库存、状态流转

代价：可用性 / 性能
```

### BASE（NoSQL / 分布式）

```text
Basically Available（基本可用）
Soft state（软状态）
Eventually consistent（最终一致）

适合：通知、推荐、报表、缓存

代价：业务复杂度上移
```

### CAP 定理

```text
分布式系统三选二：
  C - Consistency（一致性）
  A - Availability（可用性）
  P - Partition Tolerance（分区容忍）

实际：
  - 网络分区（P）必然存在
  - 选 CP（强一致，可能不可用）
  - 选 AP（可用，最终一致）
```

## 2. 事务隔离级别真相

### PostgreSQL

```text
PG 实际只有三个级别：
  Read Committed（默认）
  Repeatable Read（PG 把 Snapshot Isolation 实现成这个）
  Serializable（PG 用 SSI - Serializable Snapshot Isolation）

PG Repeatable Read：
  - 实际是 Snapshot Isolation
  - 防脏读、不可重复读、幻读
  - 但仍允许写偏斜
  - 性能好

PG Serializable：
  - SSI 算法
  - 防所有异常
  - 高冲突时会触发 serialization_failure，需要重试
```

### MySQL InnoDB

```text
MySQL Repeatable Read（默认）：
  - Next-Key Locking 防幻读（与 SQL 标准不同）
  - 也允许写偏斜
  - 性能折中

MySQL Serializable：
  - 强制锁所有读
  - 性能差，少用
```

### 异常类型详解

```text
脏读（Dirty Read）：
  T1 写未提交，T2 读到 → T1 回滚，T2 读到无效数据

不可重复读（Non-repeatable Read）：
  T1 第一次读 X=5
  T2 改 X=10 提交
  T1 第二次读 X=10（不一致）

幻读（Phantom Read）：
  T1 第一次范围读得 5 行
  T2 插入新行
  T1 第二次范围读得 6 行

写偏斜（Write Skew）：
  T1 读 X，根据 X 决定写 Y
  T2 读 Y，根据 Y 决定写 X
  并发执行 → 都基于过期数据写入

  例：医院值班，T1 看到有 2 人值班，决定下班；
      T2 看到有 2 人值班，也决定下班；
      → 0 人值班
```

## 3. Saga 模式深度

### Choreography（编舞）

```text
事件驱动，无中心协调

Order Service → emits OrderCreated
Payment Service → consumes OrderCreated → emits PaymentSuccess
Inventory Service → consumes PaymentSuccess → emits InventoryReserved
Shipping Service → consumes InventoryReserved → ...

失败时：
  - 反向事件链（OrderCancelled / PaymentRefunded）

优势：去中心化
劣势：链路追踪难、排错复杂
```

### Orchestration（编排）

```text
中心协调器（Saga Orchestrator）

Saga Coordinator：
  Step 1: Call Payment Service
    Success → Step 2
    Failure → Compensate (cancel order)
  Step 2: Call Inventory Service
    Success → Step 3
    Failure → Compensate (refund payment, cancel order)
  Step 3: ...

优势：清晰、易追踪
劣势：协调器是单点
```

### 实现要点

```text
1. 每个步骤必须幂等
2. 每个步骤必须有补偿
3. 状态持久化（防止协调器重启丢失）
4. 监控每个步骤的延迟和失败率
```

## 4. SaaS 多租户三种架构

### 模式 A：Pool（共享，最经济）

```text
共享数据库 + 共享 Schema + tenant_id 字段

成本：低
隔离：靠应用 + RLS
适合：B2B SaaS、中小客户、千级租户

代表：Slack（早期）、Notion
```

### 模式 B：Bridge（共享库，独立 Schema）

```text
共享数据库 + 每租户独立 Schema

成本：中
隔离：Schema 边界
适合：百级租户、中型客户

代表：Salesforce 早期
```

### 模式 C：Silo（完全独立）

```text
每租户独立数据库 + 应用实例

成本：高
隔离：物理隔离
适合：合规、医疗、金融、企业版

代表：医疗系统、政府客户
```

### 混合架构（实战）

```text
分层混合：
  - 大客户（Enterprise）→ Silo
  - 中客户（Business）→ Bridge
  - 小客户（Startup）→ Pool

按租户大小自动迁移
```

## 5. PostgreSQL Row Level Security（RLS）实战

### 基础配置

```sql
-- 启用 RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 创建策略：当前 tenant 才能看到
CREATE POLICY tenant_isolation ON orders
  USING (tenant_id = current_setting('app.current_tenant_id')::bigint);

-- 写入策略
CREATE POLICY tenant_write_isolation ON orders
  FOR INSERT WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::bigint);

-- 应用每次连接设置
SET LOCAL app.current_tenant_id = '123';

-- 查询自动过滤
SELECT * FROM orders;  -- 只返回 tenant=123 的数据
```

### 高级：管理员绕过

```sql
-- 创建管理员角色
CREATE ROLE admin_user;

-- 策略：admin 看所有
CREATE POLICY admin_bypass ON orders
  FOR ALL
  TO admin_user
  USING (true);
```

### 性能注意

```text
RLS 在每个查询中加 WHERE
  → 索引必须包含 tenant_id
  → 否则全表扫每行检查

测试：EXPLAIN 看是否用上索引
```

## 6. 唯一约束设计模式

### 模式 1：复合唯一（最常用）

```sql
-- 用户邮箱在租户内唯一
CREATE UNIQUE INDEX uq_users_email
  ON users(tenant_id, email);
```

### 模式 2：部分索引（软删除友好）

```sql
-- 软删除后可重注册
CREATE UNIQUE INDEX uq_users_email_active
  ON users(tenant_id, email)
  WHERE deleted_at IS NULL;
```

### 模式 3：DEFERRABLE（延迟检查）

```sql
-- 复杂业务规则：交换两个用户的角色
CREATE TABLE user_roles (
  user_id bigint,
  role_id bigint,
  PRIMARY KEY (user_id, role_id)
    DEFERRABLE INITIALLY DEFERRED
);

BEGIN;
SET CONSTRAINTS ALL DEFERRED;
-- 临时违反约束
UPDATE user_roles SET role_id = 2 WHERE user_id = 1;
UPDATE user_roles SET role_id = 1 WHERE user_id = 2;
COMMIT;  -- 此时检查约束
```

### 模式 4：Exclusion 约束（PG 特有）

```sql
-- 房间预订时段不重叠
CREATE TABLE room_bookings (
  room_id bigint,
  during tstzrange,
  EXCLUDE USING gist (room_id WITH =, during WITH &&)
);
```

## 7. 实际案例库

### Slack 多租户演进

```text
2014：Pool（单库共享）
  - 上百个租户共用一个 PG
  - 性能问题：大客户拖慢

2016：Sharding by workspace_id
  - 按 workspace_id 哈希分库
  - 每个 shard 含多个租户

2020：Hybrid + 大客户独立 shard
  - 自动迁移大客户到独立 shard
  - 中小客户继续共享
```

### Notion 数据模型

```text
所有数据是 "Block"（统一抽象）：
  - Page = Block
  - Paragraph = Block
  - Image = Block
  - Database = Block

多租户：
  - workspace_id 字段
  - 共享表 + 应用层过滤

挑战：
  - Block 数十亿
  - 跨租户查询（搜索）
  - 已分片到多个 Cassandra 集群
```

### Stripe 一致性策略

```text
强一致：
  - 支付（钱直接相关）
  - 用 PG + 分布式锁

最终一致：
  - 报表 / 分析
  - 用 Kafka + Materialized View

幂等：
  - Idempotency-Key（24 小时窗口）
  - 业务唯一约束（同一 charge 不能重复）

事务：
  - 单库事务为主
  - 跨服务用 Saga + 事件溯源
```

## 8. 数据生命周期管理

### GDPR 合规

```sql
-- 用户注销请求
CREATE TABLE deletion_requests (
  id bigserial PRIMARY KEY,
  user_id bigint NOT NULL,
  requested_at timestamptz DEFAULT now(),
  scheduled_at timestamptz NOT NULL DEFAULT (now() + INTERVAL '30 days'),
  completed_at timestamptz,
  status varchar(32) DEFAULT 'pending'
);

-- 30 天后异步执行硬删除
-- 期间用户可撤回
```

### 保留期管理

```sql
-- 不同数据不同保留期
CREATE TABLE retention_policies (
  table_name varchar PRIMARY KEY,
  retention_days integer NOT NULL,
  archive_after_days integer
);

INSERT INTO retention_policies VALUES
  ('audit_logs', 2555, 90),       -- 7 年合规、90 天后归档
  ('user_sessions', 30, 7),        -- 30 天保留
  ('orders', 3650, 365),           -- 10 年保留、1 年后归档
  ('temp_uploads', 7, NULL);       -- 7 天硬删除
```

### 归档表设计

```sql
-- 主表
CREATE TABLE orders (...);

-- 归档表（结构相同 + archive 元数据）
CREATE TABLE orders_archive (
  LIKE orders INCLUDING ALL,
  archived_at timestamptz DEFAULT now(),
  archived_by varchar(64)
);

-- 定时归档
WITH archived AS (
  DELETE FROM orders
  WHERE created_at < NOW() - INTERVAL '1 year'
  RETURNING *
)
INSERT INTO orders_archive
SELECT * FROM archived;
```

## 9. 审计日志设计

```sql
-- 全局审计表
CREATE TABLE audit_logs (
  id bigserial PRIMARY KEY,
  tenant_id bigint NOT NULL,
  user_id bigint REFERENCES users(id),
  action varchar(64) NOT NULL,         -- 'order.created' / 'user.deleted'
  resource_type varchar(64) NOT NULL,
  resource_id bigint NOT NULL,
  changes jsonb,                        -- 变更前后
  ip_address inet,
  user_agent text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_audit_tenant_resource
  ON audit_logs(tenant_id, resource_type, resource_id, created_at DESC);
```

### 触发器自动审计

```sql
CREATE OR REPLACE FUNCTION audit_trigger() RETURNS trigger AS $$
BEGIN
  INSERT INTO audit_logs (tenant_id, user_id, action, resource_type, resource_id, changes)
  VALUES (
    NEW.tenant_id,
    current_setting('app.user_id')::bigint,
    TG_OP,
    TG_TABLE_NAME,
    NEW.id,
    jsonb_build_object('old', row_to_json(OLD), 'new', row_to_json(NEW))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_orders AFTER INSERT OR UPDATE OR DELETE ON orders
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

## 10. 自检清单（资深视角）

```text
□ 业务不变量明确
□ 隔离级别选择有依据
□ 事务边界 = 业务不变量边界
□ 事务不包含外部调用
□ 幂等三层防御（Idempotency-Key + 业务唯一 + 版本字段）
□ 多租户三层防御（应用 + RLS + 测试）
□ 唯一约束含 tenant_id
□ 软删除 + 部分唯一索引
□ Saga 模式（跨服务一致性）
□ 每个步骤幂等 + 补偿
□ GDPR 数据生命周期
□ 保留期 + 归档策略
□ 审计日志（关键操作）
□ 跨租户越权测试覆盖
□ 大租户性能隔离方案
```
