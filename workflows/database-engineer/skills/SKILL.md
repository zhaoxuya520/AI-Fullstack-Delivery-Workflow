# 数据库工程师 Skills 总控

本目录收录数据库工程师工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [schema-design](schema-design/SKILL.md) | 实体建模 / 表结构 / DDL | 关系范式 + DDD 实体 + 业务约束 |
| [index-access-pattern](index-access-pattern/SKILL.md) | 索引设计 / 访问模式 | 查询路径分析 + 读写权衡 |
| [migration-rollout](migration-rollout/SKILL.md) | 数据迁移 / 上线切换 / 回滚 | 兼容迁移 + 双写 + 灰度 + 回填 |
| [query-review](query-review/SKILL.md) | SQL 审查 / 慢查询优化 | 执行计划 + 查询重写 |
| [consistency-multitenancy](consistency-multitenancy/SKILL.md) | 一致性 / 多租户 / 事务 | 事务边界 + 租户隔离 + RLS |
| [data-operations-safety](data-operations-safety/SKILL.md) | 生产数据操作安全 | 备份恢复 + 操作门禁 + 灰度 |

## 统一入口

1. 先读 `routing.md` — 按数据库任务路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到需求 → 先建模
   - schema-design（表结构 + 约束）

2. 索引和查询
   - index-access-pattern（索引方案）
   - query-review（SQL 审查）

3. 一致性和租户
   - consistency-multitenancy（事务 + 隔离）

4. 上线和迁移
   - migration-rollout（迁移 + 回滚）
   - data-operations-safety（操作安全）
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成数据库任务后，回写经验到 `../field-journal/`。
