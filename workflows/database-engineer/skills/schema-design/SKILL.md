---
name: schema-design
description: 设计数据库实体、表结构、字段类型和约束时使用。适用于新业务建模、API 契约落库、已有表结构重构和 ER 设计。融合 DDD 实体识别 + 关系范式 + 业务约束 + 演进策略。
---

# Schema 设计（Schema Design）

参考来源：Eric Evans《Domain-Driven Design》、E.F. Codd 范式理论、PostgreSQL 文档、MySQL 设计指南、Stripe / GitHub 数据建模实践。

## 适用场景

- 从 PRD、API 契约或业务规则提取实体
- 设计表、字段、字段类型、默认值、空值规则
- 设计主键、外键、唯一约束、检查约束
- 判断规范化、反规范化和冗余字段取舍
- 已有表结构重构 / 拆表 / 合表
- 输出 DDL 或 migration 草案

## 核心原则

```text
1. 先表达业务事实，再考虑页面展示
   Schema 是业务的"记忆"，不是 UI 的镜像

2. 实体边界清楚，关系基数明确
   一对一 / 一对多 / 多对多 / 多态 都要显式

3. 约束落在数据库层
   业务必须唯一的事实，必须有 UNIQUE 兜底
   不允许 NULL 的字段，必须 NOT NULL
   必须正数的金额，必须 CHECK > 0

4. 字段语义和 API/后端一致
   命名、类型、枚举值、空值规则同步

5. 可迁移、可回滚、可验证
   先想好怎么改 / 怎么撤回 / 怎么验证一致性

6. 三个时间字段必备
   created_at / updated_at / 业务时间（如 paid_at）

7. 软删除谨慎用
   deleted_at 看起来无害，但破坏唯一约束
```

## 标准流程

```text
1. 读取 PRD / API 契约 / 现有 schema
   ↓
2. 识别实体（DDD 视角）
   - 聚合根（Aggregate Root）
   - 实体（Entity）
   - 值对象（Value Object）
   - 关系（Association）
   ↓
3. 画 ER 图（Mermaid 或工具）
   ↓
4. 设计表和字段
   - 命名规范
   - 类型选择
   - 必填 / 默认值
   ↓
5. 设计主键、外键、唯一约束、检查约束
   ↓
6. 标注空值、默认值、枚举、时间字段、审计字段
   ↓
7. 评估规范化与必要冗余
   ↓
8. 输出 schema 说明 + DDL 草案 + 待确认问题
```

## 命名规范

```text
表名：
  ✅ orders         （复数）
  ✅ order_items    （子资源 + 复数）
  ❌ Order          （首字母大写）
  ❌ tbl_order      （冗余前缀）

字段名：
  ✅ user_id        （snake_case）
  ✅ created_at     （时间用 _at）
  ✅ is_active      （布尔用 is_）
  ✅ amount_cents   （金额单位明确）
  ❌ userId         （camelCase 混用）
  ❌ time           （含义不清）
  ❌ amount         （单位不明）

主键：
  ✅ id             （bigint / uuid，统一）
  ❌ order_id       （表内自指用 id 即可）

外键：
  ✅ user_id        （引用 users.id）
  ✅ created_by     （引用人，业务语义）
```

## 字段类型选择

### 数值

| 业务字段 | 推荐类型 | 理由 |
|---|---|---|
| 主键 / ID | `bigint` 或 `uuid` | int 上限 21 亿，不够用 |
| 金额 | `bigint`（最小单位 / 分） 或 `numeric(19,4)` | 永远不用 float / double |
| 计数 | `integer` | 一般够用 |
| 评分 / 比率 | `numeric(5,2)` | 精度可控 |

### 字符串

| 业务字段 | 推荐类型 | 理由 |
|---|---|---|
| 短标识符（≤32 字符）| `varchar(64)` | 留缓冲 |
| 邮箱 | `varchar(255)` | RFC 5321 上限 |
| URL | `varchar(2048)` 或 `text` | 视实际 |
| 长文本 | `text` | 无长度限制（PG）|
| 富文本 / HTML | `text` | 同上 |
| 标签数组 | `text[]`（PG）/ JSON（MySQL）| 避免单独 join 表（小数据时）|

### 时间

| 字段 | 推荐类型 | 备注 |
|---|---|---|
| created_at / updated_at | `timestamp with time zone` | 永远 UTC，前端转本地 |
| 日期（生日 / 截止日）| `date` | 不带时间 |
| 时长（秒） | `integer` | 不用 interval（跨库不兼容）|

### 枚举

```sql
-- 推荐：用 varchar + CHECK 约束（演进灵活）
status varchar(32) NOT NULL CHECK (status IN ('draft','submitted','paid','cancelled'))

-- 不推荐：PostgreSQL ENUM 类型
-- 优点：类型安全
-- 缺点：增删值困难、跨库不兼容
```

### JSON

```sql
-- 适合：低频查询的扩展字段、配置、metadata
metadata jsonb DEFAULT '{}' NOT NULL

-- 不适合：核心查询字段、需要排序聚合的字段
-- 反例：把 status 塞 metadata，每次查询都要 metadata->>'status'
```

## 主键策略

```text
方案 A：自增整数（bigint）
  优点：简单、有序、占空间小
  缺点：暴露规模、可枚举（防爬）
  适合：内部系统

方案 B：UUID v4
  优点：不可枚举、分布式友好、无热点
  缺点：占 16 字节、无序导致 B-tree 写放大
  适合：分布式系统

方案 C：UUID v7 / ULID（推荐）
  优点：时间有序 + 不可枚举 + 分布式友好
  缺点：较新（2024 年标准化）
  适合：新项目

方案 D：业务前缀 + 随机 ID
  Stripe 风格：`cus_abc123`、`ord_xyz789`
  优点：可读、可识别类型
  缺点：自定义实现
  适合：对外 API
```

## 关系建模

### 一对多（最常见）

```sql
-- 订单属于用户
CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  user_id bigint NOT NULL REFERENCES users(id),
  ...
);

-- 索引子表的外键（必加）
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### 多对多

```sql
-- 用户和角色的多对多关系
CREATE TABLE user_roles (
  user_id bigint NOT NULL REFERENCES users(id),
  role_id bigint NOT NULL REFERENCES roles(id),
  granted_at timestamptz DEFAULT now(),
  granted_by bigint REFERENCES users(id),
  PRIMARY KEY (user_id, role_id)
);
```

### 多态（慎用）

```text
反模式（多态外键）：
  comments(target_type, target_id)  -- 没有 FK 约束，难维护

替代：每种类型独立外键
  comments(post_id, user_id, ...)
  post_comments / user_comments 单独表
```

## 字段设计清单

| 项目 | 检查点 | 反例 |
|------|--------|------|
| 命名 | 业务语义 + 与 API 一致 | `data` / `info` / `time` |
| 类型 | 匹配数据库能力和未来增长 | int 存订单号、float 存金额 |
| 空值 | NULL 是否有业务含义 | 默认 NULL（语义不清） |
| 默认值 | 影响历史数据和迁移 | 加默认值导致全表锁 |
| 枚举 | 扩展策略 | PG ENUM 难加值 |
| 时间 | 创建、更新、删除、归档 | 缺 updated_at、不加时区 |
| 审计 | 操作人、来源、租户、追踪 ID | 出问题查不到原因 |
| 长度 | 字符串字段必有上限 | text 不限长 → DoS 风险 |
| 唯一性 | 业务唯一 → 数据库 UNIQUE | 仅代码层判重 |

## 多租户设计

```sql
-- 每张租户数据表必有 tenant_id
CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  tenant_id bigint NOT NULL REFERENCES tenants(id),
  user_id bigint NOT NULL REFERENCES users(id),
  ...
  -- 唯一性：复合（含 tenant_id）
  CONSTRAINT uq_order_number UNIQUE (tenant_id, order_number)
);

-- 行级安全（PostgreSQL RLS，可选兜底）
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON orders
  USING (tenant_id = current_setting('app.tenant_id')::bigint);
```

详见 `consistency-multitenancy/SKILL.md`。

## 软删除策略

```text
方案 A：deleted_at（软删除时间戳）
  优点：可恢复、可审计
  缺点：破坏唯一约束（同 email 的活跃用户和已删除用户）
  解决：UNIQUE (email) WHERE deleted_at IS NULL  （部分索引）

方案 B：归档表
  优点：核心表干净、性能好
  缺点：跨表查询历史复杂

方案 C：硬删除 + 审计日志表
  优点：核心表清爽
  缺点：不可"恢复"

推荐：核心业务用方案 A + 部分索引，审计敏感用方案 C
```

## 审计字段（建议每张表都有）

```sql
created_at timestamptz NOT NULL DEFAULT now(),
updated_at timestamptz NOT NULL DEFAULT now(),
created_by bigint REFERENCES users(id),
updated_by bigint REFERENCES users(id),
version integer NOT NULL DEFAULT 1  -- 乐观锁
```

## 规范化 vs 反规范化

```text
默认规范化（3NF）：
  - 不重复存储
  - 修改一处不漏
  - 节省空间

反规范化（合理冗余）：
  - 冗余字段：order.user_email（避免 join 拿邮箱）
  - 冗余汇总：user.order_count（避免每次 count）
  - 物化视图：报表场景

权衡：
  读多写少 → 可以反规范化
  写多读少 → 严格规范化
  报表 → 用物化视图 / 数据仓库分离
```

## 配套模板

- `templates/schema-design-template.md` — 完整 schema 设计文档（背景 + ER + 表 + 约束 + 索引 + 迁移 + 风险）
- `templates/ddl-template.sql.md` — DDL 标准模板

## 质量自检

```text
□ 每张表是否有明确业务实体或关系含义
□ 每个字段是否有类型、空值、默认值、说明
□ 必须唯一的业务事实是否有 UNIQUE 约束
□ 关系是否有 FK 约束或明确的应用层约束说明
□ 枚举、状态、软删、审计字段是否明确
□ 三个时间字段（created_at/updated_at/业务时间）是否齐全
□ 多租户字段（tenant_id）+ 复合唯一约束
□ DDL 与目标数据库类型匹配
□ JSON 字段不承载核心查询
□ 主键策略明确（int/uuid/ULID/业务前缀）
□ 字符串字段都有长度上限
□ 字段命名风格统一（snake_case / camelCase 二选一）
□ 是否列出待确认问题和迁移影响
```

## 常见坑

1. **只按页面字段建表**——忽略业务生命周期，重构成本高
2. **唯一性只在代码里**——并发 / 重试 / 导入产生脏数据
3. **JSON 承载核心查询**——`metadata->>'status'` 全表扫描
4. **默认值导致全表锁**——MySQL/PG 加 NOT NULL DEFAULT 时锁表
5. **API/ORM/DB 字段名不一致**——联调反复返工
6. **金额用 float**——精度丢失，财务对不上
7. **时间不带时区**——跨地区用户时间错乱
8. **PG ENUM 类型**——加值难、跨库迁移痛
9. **缺 updated_at**——排查问题没线索
10. **软删除破坏唯一约束**——同 email 不能再注册
11. **char(255) 反射性使用**——存 1 个字符也占 255
12. **超大 text 不限长**——攻击面 / DoS
13. **缺审计字段**——出事查不到操作人
14. **多态外键**——没 FK 约束、难维护

## 与其他 skill 的协作

```text
上游：
  api-designer → 提供 API 契约 / 资源模型
  product-manager → 提供业务实体 / 生命周期
  ui-ux-designer → 提供页面字段需求

下游：
  index-access-pattern → 根据访问模式补索引
  migration-rollout → 把 DDL 转成可上线迁移
  consistency-multitenancy → 补事务、租户、生命周期约束
  query-review → 验证 SQL 与 schema 配合
  backend-engineer → 实现 ORM 模型
```

## 相关参考

- `references/schema-design-guide.md` — DDD 实体识别、范式理论、PostgreSQL/MySQL 类型对比、大厂建模范式（Stripe / GitHub / Discord）、演进策略
