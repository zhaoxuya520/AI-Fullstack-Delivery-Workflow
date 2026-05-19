# 数据库工程师工作流路由

## 触发关键词

```text
数据库, 数据建模, ER图, ERD, schema, 表结构, DDL, migration, 迁移, 回滚,
索引, SQL优化, 慢查询, 执行计划, 主键, 外键, 唯一约束, 事务,
一致性, 多租户, 分库分表, 分区, 备份恢复, 数据修复, PostgreSQL,
MySQL, SQLite, Redis
```

## 机器可读路由

```yaml
workflow: database-engineer
name: 数据库工程师工作流
entry: WORKFLOW.md
skills_routing: skills/routing.md
keywords:
  - 数据库
  - 数据建模
  - ER图
  - 表结构
  - DDL
  - 索引
  - SQL优化
  - 迁移
  - 回滚
  - 多租户
  - 备份恢复
required_files:
  - WORKFLOW.md
  - routing.md
  - tool-index.md
  - pitfalls.md
  - skills/routing.md
  - field-journal/_index.md
outputs:
  - 数据库设计说明
  - ER/实体关系说明
  - DDL 或 migration 草案
  - 索引方案
  - 迁移和回滚计划
  - 数据风险说明
  - 验证清单
```

## 进入条件

```text
□ 目标是数据库结构、数据访问、迁移、查询性能或数据操作安全
□ 已知业务实体或至少有 PRD / API 契约 / 现有表结构作为输入
□ 能识别数据库类型或需要先补问数据库类型
□ 输出物需要被后端、QA、DevOps/SRE 或安全工作流接手
```

## 补问规则

如果信息不足，按风险优先级补问：

1. 数据库类型、版本和 ORM / migration 工具是什么？
2. 这是新建结构还是已有生产数据变更？
3. 高频查询、写入路径、数据量级和增长预估是什么？
4. 是否有多租户、权限、审计、软删、归档、脱敏要求？
5. 是否允许停机？迁移窗口、备份、回滚要求是什么？

## 按任务类型路由

| 用户说 | 进入工作流 | 继续加载 |
|--------|------------|----------|
| “设计表结构 / ER 图 / schema” | database-engineer | `skills/schema-design/SKILL.md` |
| “这个查询怎么建索引” | database-engineer | `skills/index-access-pattern/SKILL.md` |
| “这条 SQL 很慢 / 帮我审 SQL” | database-engineer | `skills/query-review/SKILL.md` |
| “怎么做迁移 / 回滚 / 回填” | database-engineer | `skills/migration-rollout/SKILL.md` |
| “事务边界 / 一致性 / 多租户怎么做” | database-engineer | `skills/consistency-multitenancy/SKILL.md` |
| “生产改表前检查什么 / 数据修复安全吗” | database-engineer | `skills/data-operations-safety/SKILL.md` |

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 业务规则、实体生命周期不清 | `product-manager` |
| API 字段、分页、幂等、错误语义未定 | `api-designer` |
| 需要实现业务代码或 ORM 查询 | `backend-engineer` / `fullstack-engineer` |
| 需要发布、扩容、监控、备份任务编排 | `devops-engineer` / `sre-ops` |
| 涉及敏感数据、权限、审计、漏洞验证 | `security-engineer` |
| 需要用户文档或运维说明 | `technical-writer` |

## 未命中处理

如果任务不属于数据库设计、数据访问、迁移或数据操作安全，不要硬塞进本工作流；返回根 `routing.md` 选择更合适的工作流。