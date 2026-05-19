---
name: consistency-multitenancy
description: 设计事务边界、一致性策略、多租户隔离和数据生命周期时使用。适用于高并发写入、幂等、多租户 SaaS、软删归档和审计字段设计。融合 ACID + Saga + 乐观锁 + RLS + Tenant Per Schema。
---

# 一致性与多租户（Consistency & Multi-tenancy）

参考来源：Pat Helland《Life beyond Distributed Transactions》、Martin Kleppmann《Designing Data-Intensive Applications》、AWS SaaS 多租户白皮书、Stripe / Slack / Notion 多租户实践。

## 适用场景

- 判断事务边界和一致性要求
- 设计幂等写入、并发冲突处理、乐观锁
- 设计多租户字段、租户隔离、复合唯一约束
- 设计软删、归档、审计字段和数据生命周期
- 评估跨表、跨服务、跨数据库的一致性方案
- 行级安全（RLS）配置
- Tenant Per Schema vs Shared Schema 选型

## 核心原则

```text
1. 把隔离边界和一致性要求显式写入 schema 与约束
   "tenant_id 字段" ≠ "多租户隔离"
   还需要：查询过滤 + 唯一约束 + 权限边界 + 测试

2. 事务不应无限扩大
   边界应等于业务不变量边界

3. 幂等和唯一性优先由数据库约束兜底
   不靠应用代码判重

4. 不在事务里做外部调用
   HTTP / 邮件 / 第三方 API 都不能放事务

5. 强一致 vs 最终一致：业务驱动
   涉及钱：强一致
   不影响财务：最终一致 + 补偿

6. 多租户三层防御：应用层 + 数据库层 + 测试层
   单层防御必定漏

7. 软删除是甜蜜陷阱
   破坏唯一约束、查询要带 WHERE deleted_at IS NULL
```

## 事务（ACID）速查

```text
A - Atomicity（原子性）：要么全成，要么全败
C - Consistency（一致性）：事务前后业务规则一致
I - Isolation（隔离性）：并发事务互不干扰
D - Durability（持久性）：提交后数据不丢
```

### 隔离级别（PostgreSQL / MySQL）

| 级别 | 脏读 | 不可重复读 | 幻读 | 写偏斜 |
|---|---|---|---|---|
| Read Uncommitted | ✓ | ✓ | ✓ | ✓ |
| Read Committed（默认）| ✗ | ✓ | ✓ | ✓ |
| Repeatable Read（PG/MySQL 默认变体）| ✗ | ✗ | ✗ | ✓ |
| Serializable | ✗ | ✗ | ✗ | ✗ |

```sql
-- PostgreSQL
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- MySQL
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

```text
建议：
  - 默认 Read Committed 已能满足大多数业务
  - 关键金融场景用 Serializable + 重试
  - 慎用 Read Uncommitted（一般不需要）
```

## 事务边界设计

### 错：事务过大

```python
# 反模式：事务包含外部调用
@transaction.atomic
def create_order(user_id, items):
    order = Order.objects.create(...)
    OrderItem.objects.bulk_create(...)
    
    # 外部 HTTP 调用 → 事务持续 30 秒
    payment_result = call_payment_gateway(order)
    
    if payment_result.success:
        order.status = 'paid'
        order.save()
```

### 对：事务最小化 + Saga

```python
# 阶段 1：本地事务（仅 DB 操作）
@transaction.atomic
def create_order(user_id, items):
    order = Order.objects.create(status='pending', ...)
    OrderItem.objects.bulk_create(...)
    return order

# 阶段 2：异步外部调用
def process_payment(order_id):
    order = Order.objects.get(id=order_id)
    result = call_payment_gateway(order)
    
    # 阶段 3：本地事务更新状态
    if result.success:
        order.update(status='paid')
    else:
        order.update(status='failed')
        # 补偿动作（释放库存、退款）
        compensate(order)
```

## 幂等性设计

### Idempotency-Key 模式（写接口必备）

```sql
-- 幂等性表
CREATE TABLE idempotency_keys (
  key varchar(128) PRIMARY KEY,
  request_hash varchar(64) NOT NULL,
  response_body jsonb,
  status varchar(32) NOT NULL,  -- 'processing' / 'completed' / 'failed'
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz NOT NULL DEFAULT (now() + INTERVAL '24 hours')
);

CREATE INDEX idx_idempotency_expires ON idempotency_keys(expires_at);
```

### 业务唯一约束（最强幂等）

```sql
-- 同一订单不能支付两次
CREATE TABLE payments (
  id bigserial PRIMARY KEY,
  order_id bigint NOT NULL,
  amount_cents bigint NOT NULL,
  status varchar(32) NOT NULL,
  created_at timestamptz DEFAULT now(),
  
  -- 业务唯一：每个订单只能有一条成功的支付
  CONSTRAINT uq_order_payment UNIQUE (order_id, status)
    DEFERRABLE INITIALLY DEFERRED
);
```

### 乐观锁（version 字段）

```sql
-- 表设计
CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  status varchar(32) NOT NULL,
  version integer NOT NULL DEFAULT 1,
  ...
);

-- 更新时校验版本
UPDATE orders
SET status = 'paid', version = version + 1
WHERE id = ? AND version = ?;

-- 影响 0 行 → 版本冲突 → 应用层重试或返回 409
```

### 悲观锁（SELECT FOR UPDATE）

```sql
-- 高冲突场景：直接锁行
BEGIN;
SELECT * FROM accounts WHERE id = ? FOR UPDATE;
UPDATE accounts SET balance = balance - 100 WHERE id = ?;
COMMIT;
```

```text
何时用：
  乐观锁：冲突率低（< 5%），重试代价小
  悲观锁：冲突率高，必须串行
```

## 多租户隔离三层防御

### 第一层：应用层

```python
# 中间件：每个查询都带 tenant_id
class TenantMiddleware:
    def process_request(self, request):
        request.tenant_id = get_tenant_from_token(request)

# ORM 自动过滤
class TenantAwareManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(tenant_id=current_tenant_id())
```

### 第二层：数据库层（RLS / 视图）

```sql
-- PostgreSQL Row Level Security（强烈推荐）
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON orders
  USING (tenant_id = current_setting('app.current_tenant_id')::bigint);

-- 应用每次连接时设置
SET LOCAL app.current_tenant_id = '123';
SELECT * FROM orders;  -- 自动过滤
```

### 第三层：测试层

```python
# 跨租户越权测试用例
def test_cross_tenant_isolation():
    user_a = create_user(tenant=1)
    user_b = create_user(tenant=2)
    
    order_a = create_order(user=user_a)  # tenant 1 的订单
    
    # 用 user_b 的身份尝试访问 user_a 的订单
    response = client.get(f'/orders/{order_a.id}', as_user=user_b)
    assert response.status_code == 404  # 或 403
```

## 多租户数据模型

### Shared Schema（共享 Schema，最常用）

```sql
-- 所有租户共享表，靠 tenant_id 区分
CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  tenant_id bigint NOT NULL REFERENCES tenants(id),
  ...
);

-- 复合唯一（必须含 tenant_id）
CREATE UNIQUE INDEX uq_orders_number
  ON orders(tenant_id, order_number);
```

优势：
- 简单
- 资源利用高（单库支持千个租户）
- 升级一次性

劣势：
- 单租户故障可能影响全部
- 大租户 vs 小租户性能干扰
- 跨租户查询风险

适合：SaaS 中小租户、共用功能

### Schema Per Tenant（每租户独立 Schema）

```sql
-- 每个租户一个 schema
CREATE SCHEMA tenant_acme;
CREATE TABLE tenant_acme.orders (...);

CREATE SCHEMA tenant_globex;
CREATE TABLE tenant_globex.orders (...);
```

优势：
- 隔离更强
- 备份恢复粒度细
- 大租户性能可控

劣势：
- 升级复杂（每个 schema 都要 migrate）
- 资源消耗大
- 应用层切换 schema 复杂

适合：百级租户、企业版

### Database Per Tenant

```text
每个租户独立数据库实例

优势：
  - 完全隔离
  - 性能 / 备份 / 安全独立

劣势：
  - 资源消耗大
  - 运维复杂

适合：大型企业客户、合规要求强（PII / 医疗）
```

## 唯一性约束设计

### 多租户场景

```sql
-- 错：用户邮箱全局唯一
CREATE UNIQUE INDEX uq_users_email ON users(email);
-- 不同租户不能有同名邮箱

-- 对：租户内唯一
CREATE UNIQUE INDEX uq_users_email_tenant
  ON users(tenant_id, email);
```

### 软删除场景

```sql
-- 错：软删后无法重新注册
CREATE UNIQUE INDEX uq_users_email
  ON users(tenant_id, email);
-- 同 email 的删除用户阻止新注册

-- 对：部分索引
CREATE UNIQUE INDEX uq_users_email_active
  ON users(tenant_id, email)
  WHERE deleted_at IS NULL;
```

## 软删除 vs 硬删除决策

```text
软删除（deleted_at）：
  ✅ 用户可恢复
  ✅ 关联数据完整
  ✅ 审计需要
  ❌ 唯一约束复杂
  ❌ 查询都要带 WHERE
  ❌ 数据膨胀

硬删除：
  ✅ 简单
  ✅ 性能好
  ❌ 不可恢复
  ❌ 关联数据连锁删除

归档（删除前移到归档表）：
  ✅ 主表干净
  ✅ 历史数据可查
  ❌ 跨表查询复杂

推荐：
  - 用户数据：软删除（GDPR 30 天后硬删）
  - 业务数据：软删除 + 6 个月归档
  - 临时数据（缓存 / 会话）：硬删除
  - 审计日志：永不删除
```

## 数据生命周期

```sql
-- 推荐字段
CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  -- ... 业务字段 ...
  
  -- 生命周期字段
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,                            -- 软删
  archived_at timestamptz,                           -- 归档
  retention_until timestamptz,                       -- 保留期限
  
  -- 审计字段
  created_by bigint REFERENCES users(id),
  updated_by bigint REFERENCES users(id),
  deleted_by bigint REFERENCES users(id),
  
  -- 乐观锁
  version integer NOT NULL DEFAULT 1
);
```

## 标准流程

```text
1. 识别业务不变量和并发写入场景
   - 哪些状态不能同时存在
   - 哪些操作不能重复执行
   - 哪些字段必须唯一
   ↓
2. 判断强一致、最终一致或补偿机制
   - 涉及钱 → 强一致
   - 通知 / 报表 → 最终一致
   - 跨服务 → Saga
   ↓
3. 设计事务边界、锁策略、唯一约束、版本字段
   - 事务最小化
   - 数据库约束兜底
   - 乐观锁优先
   ↓
4. 设计租户字段、复合约束、默认过滤规则
   - 三层防御
   - 复合唯一含 tenant_id
   - RLS 兜底
   ↓
5. 设计删除、归档、审计和恢复策略
   - 软删 + 部分索引
   - 归档表
   - 审计日志
   ↓
6. 输出一致性和隔离检查清单
```

## 多租户检查表

| 项目 | 检查点 |
|------|--------|
| 租户键 | 每张租户数据表是否有明确 tenant_id 字段 |
| 查询 | 是否默认带 tenant_id 过滤（中间件 / RLS） |
| 唯一性 | 唯一约束是否包含租户维度 |
| 后台操作 | 跨租户操作是否有审计和授权 |
| 测试 | 是否有跨租户越权回归用例 |
| 备份 | 单租户备份恢复是否可行 |
| 监控 | 单租户性能 / 错误是否可观测 |
| 删除 | 租户注销时数据如何处理（GDPR） |

## 配套模板

- `templates/consistency-checklist-template.md` — 一致性 + 多租户 + 软删除 + 审计 + RLS 配置完整清单

## 质量自检

```text
□ 列出业务不变量
□ 说明事务边界和失败补偿
□ 幂等键、唯一约束、版本字段明确
□ 多租户三层防御（应用 + 数据库 + 测试）
□ 唯一约束包含 tenant_id
□ 软删除有部分唯一索引
□ 删除、归档、审计、恢复策略明确
□ 事务不包含外部调用
□ 隔离级别选择有依据
□ 跨服务一致性方案（Saga / 事件）
□ RLS 配置（PG）兜底
□ 与安全工作流协作评审
```

## 常见坑

1. **有 tenant_id 但唯一约束没带 tenant_id**——同 email 跨租户冲突
2. **后台管理接口绕过租户过滤**——越权读取
3. **长事务包外部调用**——锁持有 30 秒，影响并发
4. **幂等只靠前端防重复点击**——后端裸奔
5. **软删后唯一约束和恢复逻辑冲突**——无法重新注册
6. **乐观锁 version 不增**——更新成功但无法检测并发
7. **隔离级别用 Read Uncommitted**——读到未提交数据
8. **跨表强一致用分布式事务**——2PC 性能差，应该 Saga
9. **多租户共享表无 RLS 兜底**——应用层一漏全漏
10. **审计日志在主表**——主表膨胀，审计被污染
11. **删除级联到所有关联表**——删一个用户影响 50 张表
12. **保留期限不明**——GDPR 违规
13. **跨租户备份恢复无方案**——单租户问题影响所有
14. **测试不覆盖跨租户越权**——上线后才发现

## 与其他 skill 的协作

```text
上游：
  schema-design → 提供表结构基础
  api-designer → 提供权限边界

下游：
  index-access-pattern → 设计租户维度索引
  data-operations-safety → 评估跨租户操作和数据修复风险
  security-engineer → 评审敏感数据和权限边界
  backend-engineer → 实现租户中间件
  qa-engineer → 跨租户越权回归用例
```

## 相关参考

- `references/consistency-multitenancy-guide.md` — ACID 深度、Saga 模式、SaaS 多租户三种架构对比、RLS 实战、PostgreSQL 隔离级别真相、Slack / Notion 真实案例
