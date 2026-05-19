# Schema 设计深度指引

参考：Eric Evans《Domain-Driven Design》、E.F. Codd 范式理论、Martin Fowler《Refactoring Databases》、PostgreSQL 17 文档、MySQL 8.0 设计手册、Stripe / GitHub / Discord / Slack 公开数据建模文章。

## 1. DDD 实体识别（建模起点）

### 战略层

```text
1. 限界上下文（Bounded Context）
   - 一个业务领域 = 一个上下文
   - 不同上下文之间用 ID 引用，不直接关联
   - 例：订单上下文 / 库存上下文 / 用户上下文

2. 通用语言（Ubiquitous Language）
   - 业务方说的"客户"和代码里的 customer 一致
   - 表名 / 字段名 / API 字段统一术语
```

### 战术层

```text
聚合根（Aggregate Root）：
  - 业务事务的边界
  - 外部只能通过聚合根访问内部
  - 例：订单 = 聚合根，订单项 = 内部实体

实体（Entity）：
  - 有唯一身份（ID）
  - 可变状态
  - 例：User、Order、Product

值对象（Value Object）：
  - 无身份，靠属性比较
  - 不可变
  - 例：Address、Money、DateRange

关系（Association）：
  - 一对一 / 一对多 / 多对多 / 多态
  - 双向 vs 单向
```

### 落库映射

| DDD 概念 | 数据库实现 |
|---|---|
| 聚合根 | 主表 + 主键 |
| 实体 | 子表 + 外键到聚合根 |
| 值对象 | 嵌入字段 或 JSON |
| 关系 | 外键 / 关联表 |

## 2. 范式理论（避免冗余 + 数据一致性）

```text
1NF（第一范式）：每个字段原子
  ❌ users.tags = "admin,vip,beta"
  ✅ user_tags 关联表

2NF（第二范式）：消除部分依赖
  ❌ order_items(order_id, product_id, product_name, ...)
     product_name 依赖 product_id 不依赖订单
  ✅ products(id, name) + order_items(order_id, product_id)

3NF（第三范式）：消除传递依赖
  ❌ orders(id, user_id, user_email, ...)
  ✅ orders(id, user_id) + users(id, email)

BCNF（BC 范式）：每个决定因素都是超键
  实际项目：3NF 足够

5NF / DKNF：理论意义大于实际
```

### 何时反规范化

```text
读多写少 + 性能瓶颈 → 反规范化
  例：商品列表频繁需要分类名 → 冗余 category_name

报表场景 → 物化视图
  CREATE MATERIALIZED VIEW user_order_summary AS ...

缓存层 → 不修改 DB schema，用 Redis

单表不超 1 亿行 → 通常不需要反规范化
```

## 3. PostgreSQL vs MySQL 类型对比

| 类型 | PostgreSQL | MySQL | 推荐 |
|---|---|---|---|
| 主键自增 | `bigserial` / `bigint GENERATED ...` | `bigint AUTO_INCREMENT` | bigint |
| UUID | `uuid` | `binary(16)` | uuid（PG 原生）|
| 时间戳 | `timestamp with time zone` | `datetime` / `timestamp` | PG: timestamptz / MySQL: datetime |
| JSON | `jsonb`（推荐） / `json` | `json` | jsonb（PG 索引友好） |
| 数组 | `int[]` / `text[]` 原生 | 不支持，用 JSON 模拟 | PG: 数组 / MySQL: JSON |
| 枚举 | `ENUM` 类型 / CHECK | `ENUM` 类型 / CHECK | CHECK（演进灵活） |
| 几何 / 范围 | 原生支持 | 有限 | 看需求 |
| 全文搜索 | `tsvector` 原生 | `FULLTEXT` 索引 | 看需求 |

## 4. 大厂建模范式速查

### Stripe（金融 SaaS）

```text
特点：
  1. 业务前缀 ID：cus_xxx, pi_xxx, ch_xxx
  2. 不可变事件流：events 表记录每次状态变更
  3. metadata 字段：扩展点，避免改 schema
  4. 金额：integer，单位分（cents）
  5. timezone：UTC，对外 ISO 8601
```

### GitHub（社交 SaaS）

```text
特点：
  1. 数字主键 + slug 双主键（id + login）
  2. 软删除：deleted_at + 部分索引
  3. 多态：用单独表（issue_comments / commit_comments）
  4. 高频字段冗余：user.public_repos_count 避免 count
```

### Discord（实时通信）

```text
特点：
  1. Snowflake ID（时间有序 + 不可枚举）
  2. 消息表分片（按 channel_id 哈希）
  3. 极少 join（NoSQL 思维）
  4. 反规范化激进（读优先）
```

### Slack（企业协作）

```text
特点：
  1. workspace_id 作为多租户键
  2. 复合唯一：(workspace_id, name)
  3. RLS（Row Level Security）兜底
  4. 软删除 + 物理归档双轨
```

## 5. 字段命名规范（生产案例）

```text
ID 字段：
  - 主键：id
  - 外键：<table>_id（user_id, order_id）
  - 业务编号：<entity>_number（order_number）

时间字段（_at 后缀）：
  - 创建：created_at
  - 修改：updated_at
  - 删除（软）：deleted_at
  - 业务时间：paid_at, shipped_at, refunded_at

布尔字段（is_/has_/can_ 前缀）：
  - is_active, is_deleted, is_published
  - has_subscription, has_avatar
  - can_edit, can_delete

计数字段（_count 后缀）：
  - view_count, like_count, comment_count

金额字段（明确单位）：
  - amount_cents（分）
  - price_usd_cents（美分）
  - 不用 amount（单位不明）

枚举字段（无后缀）：
  - status, state, role, type
  - 值用大写：'PAID' / 'SHIPPED'

JSON 字段：
  - metadata（用户自定义）
  - settings（系统配置）
  - data（避免，不明确）
```

## 6. 演进策略（Refactoring Databases）

### 添加列

```text
1. 添加列（NULL 或 DEFAULT）
2. 应用代码读写双兼容
3. 回填历史数据（分批）
4. 改 NOT NULL（如需）
5. 完成
```

### 重命名列

```text
危险：直接 RENAME 会破坏老代码

正确流程：
1. 加新列
2. 应用同时写新旧两列
3. 回填新列
4. 应用读新列
5. 应用停写旧列
6. 删旧列
```

### 拆表

```text
1. 创建新表
2. 应用同时写两表（双写）
3. 回填新表
4. 应用读新表
5. 应用停写旧表
6. 一段时间后删旧表
```

### 合表

```text
反向同上：
1. 应用同时写两表（迁移到一张）
2. 回填合并
3. 应用读合并表
4. 应用停写另一张
5. 删多余表
```

## 7. Schema 演进原则（兼容性）

```text
向前兼容（旧应用 + 新 schema）：
  ✅ 加列（NULL 或 DEFAULT）
  ✅ 加表
  ✅ 加索引
  ✅ 扩大字段长度（varchar(50) → varchar(100)）

不兼容（必须协调发布）：
  ❌ 删列（先停止使用，再删）
  ❌ 改列类型（int → varchar）
  ❌ 改约束（NULL → NOT NULL）
  ❌ 缩小长度（varchar(255) → varchar(50)）
  ❌ 改枚举语义
```

## 8. 数据建模反模式

### EAV（实体-属性-值）

```text
反模式：
  attributes(entity_id, attribute_name, attribute_value)

问题：
  - 无类型校验
  - 查询 N 倍 join
  - 索引困难

替代：
  - 固定结构 → 用列
  - 灵活扩展 → 用 JSON
```

### 多态外键

```text
反模式：
  comments(target_type, target_id)

问题：
  - 无 FK 约束
  - 数据完整性差

替代：
  - 每种类型独立表（post_comments / video_comments）
  - 或独立关联表（comment_targets）
```

### 状态字段爆炸

```text
反模式：
  is_paid, is_shipped, is_delivered, is_cancelled, is_refunded

问题：
  - 状态组合 2^N
  - 容易出现不可能状态（is_paid=true & is_cancelled=true）

替代：
  status enum + status_history 表
```

### 大表无分区

```text
反模式：
  orders 表存 5 年所有订单 → 50 亿行

问题：
  - 索引膨胀
  - 维护慢
  - 备份慢

替代：
  - 按时间分区（PG 声明式分区 / MySQL PARTITION BY）
  - 历史数据归档
```

## 9. ER 图工具

| 工具 | 适合 |
|---|---|
| Mermaid ER | 文档内嵌、轻量评审 |
| dbdiagram.io | 在线协作、导出 SQL |
| draw.io | 复杂 ER + 流程图 |
| DBeaver | 反向工程现有库 |
| dbml | 代码化 ER（git 友好） |

## 10. 自检清单（资深视角）

```text
□ 实体边界来自业务，不是 UI
□ 三种身份：聚合根 / 实体 / 值对象 区分清楚
□ 关系基数标注（1:1 / 1:N / M:N）
□ 主键策略合理（id / uuid / ULID / 业务前缀）
□ 唯一性 100% 落到 UNIQUE 约束
□ 外键 FK 是否兜底（性能影响时可只加索引）
□ 字段类型最小化（不滥用 text / bigint）
□ 枚举用 CHECK + varchar（演进友好）
□ JSON 只承载非查询字段
□ 时间统一 timestamptz（PG）/ datetime UTC（MySQL）
□ 软删除：deleted_at + 部分唯一索引
□ 审计字段齐全（created_at/by, updated_at/by, version）
□ 多租户 tenant_id + 复合 UNIQUE
□ 命名风格全项目一致
□ 大表考虑分区
□ 演进有兼容性策略
□ DDL 与 ORM 模型字段语义一致
```
