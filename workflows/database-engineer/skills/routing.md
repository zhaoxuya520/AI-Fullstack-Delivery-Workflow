# 数据库工程师 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "设计表结构" / "画 ER 图" / "schema 怎么建" | [schema-design](schema-design/SKILL.md) |
| "字段类型怎么选" / "主键外键怎么设计" | [schema-design](schema-design/SKILL.md) |
| "这个查询怎么建索引" / "索引怎么设计" | [index-access-pattern](index-access-pattern/SKILL.md) |
| "读多写少怎么优化" / "复合索引顺序" | [index-access-pattern](index-access-pattern/SKILL.md) |
| "这条 SQL 很慢" / "帮我审 SQL" | [query-review](query-review/SKILL.md) |
| "怎么做迁移" / "如何回填" / "怎么回滚" | [migration-rollout](migration-rollout/SKILL.md) |
| "事务边界" / "一致性怎么保证" | [consistency-multitenancy](consistency-multitenancy/SKILL.md) |
| "多租户怎么隔离" / "租户字段怎么设计" | [consistency-multitenancy](consistency-multitenancy/SKILL.md) |
| "生产改表前检查" / "批量修数据安全吗" | [data-operations-safety](data-operations-safety/SKILL.md) |
| "备份恢复" / "数据导出脱敏" | [data-operations-safety](data-operations-safety/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 新业务模型落地 | schema-design + consistency-multitenancy |
| API 契约落库 | schema-design + index-access-pattern |
| 上线前数据库变更 | migration-rollout + data-operations-safety |
| 性能问题排查 | query-review + index-access-pattern |
| 大表字段新增或回填 | migration-rollout + data-operations-safety |
| 多租户/权限隔离设计 | consistency-multitenancy + schema-design |
| 生产数据修复 | data-operations-safety + migration-rollout |
| 数据库设计总评审 | 全部核心 skills 按需加载 |

## 按复杂度

| 复杂度 | 典型场景 | 典型组合 |
|--------|----------|---------|
| S | 单表新增、简单字段调整、单条 SQL 审查 | 单个 skill |
| M | 多表关系、索引方案、常规迁移 | 2~3 个 skills |
| L | 存量大表、多租户、在线迁移、性能瓶颈 | 3~5 个 skills |
| XL | 分区分片、跨库迁移、核心交易链路 | 全部相关 skills + DevOps/SRE/安全协作 |

## 路径交叉

```text
建模路径：
  schema-design
  → consistency-multitenancy
  → index-access-pattern

上线迁移路径：
  migration-rollout
  → data-operations-safety
  → backend / devops / sre 交接

性能优化路径：
  query-review
  → index-access-pattern
  → migration-rollout（如需新增索引或结构变更）

生产数据操作路径：
  data-operations-safety
  → migration-rollout
  → field-journal 复盘
```

## 路由未命中处理

如果问题无法归入上述 skills，不要强行处理；先判断是否应转给 `api-designer`、`backend-engineer`、`devops-engineer`、`sre-ops` 或 `security-engineer`，必要时按 `CONTRIBUTING.md` 增补新的数据库 skill。
