# 数据库工程师工作流工具索引

## 使用原则

1. 优先复用当前项目已有数据库、ORM、migration 和运维工具。
2. 不为一次性文档生成引入新依赖。
3. 涉及生产数据库、备份、迁移、批量修复、权限变更时，先确认影响面和回滚路径。
4. 工具缺失时先检查本文件和根 `../../tool-index.md`，再决定是否安装或替换。
5. 输出命令示例时使用占位符，不写死密钥、Token、密码、私有地址或生产连接串。

## 建模与设计工具

| 工具 | 用途 | 说明 |
|------|------|------|
| Mermaid ER | 文档内表达实体关系 | 适合轻量 ER 图和评审材料 |
| Markdown 表格 | 表结构、字段、约束、索引清单 | 默认交付格式 |
| dbdiagram.io / draw.io | 复杂 ER 图 | 上传前确认不含敏感数据 |
| DBeaver / DataGrip | 浏览 schema、执行计划、数据检查 | 生产只读优先 |

## 数据库与迁移工具

| 工具 | 用途 | 说明 |
|------|------|------|
| PostgreSQL | 关系型数据库 | 关注约束、索引、事务、分区 |
| MySQL | 关系型数据库 | 关注 Online DDL、字符集、锁表风险 |
| SQLite | 轻量嵌入式数据库 | 关注迁移限制和并发边界 |
| Redis | 缓存/临时状态/队列辅助 | 不替代持久化业务事实 |
| Flyway / Liquibase | 数据库迁移 | 适合版本化 migration |
| Prisma / TypeORM / Sequelize / SQLAlchemy | ORM / schema 管理 | DDL 需和真实数据库能力对齐 |

## 查询和性能工具

| 工具 | 用途 | 说明 |
|------|------|------|
| EXPLAIN / EXPLAIN ANALYZE | 查询执行路径分析 | 生产环境谨慎使用 ANALYZE |
| 慢查询日志 | 识别真实瓶颈 | 优先看真实负载而非猜测 |
| pg_stat_statements | PostgreSQL 查询统计 | 适合高频慢查询排查 |
| MySQL Performance Schema | MySQL 性能分析 | 结合慢日志和执行计划 |

## 模板入口

具体模板已下沉到各 skill：

- `skills/schema-design/templates/`
- `skills/index-access-pattern/templates/`
- `skills/migration-rollout/templates/`
- `skills/query-review/templates/`
- `skills/consistency-multitenancy/templates/`
- `skills/data-operations-safety/templates/`

## 参考资料入口

- `references/database-methods.md` — 综合数据库设计方法
- `references/public-source-index.md` — 公开资料来源索引
- `skills/*/references/` — 各 skill 专项方法

## 脚本入口

| 脚本 | 用途 |
|------|------|
| `scripts/check-database-deliverable.ps1` | 检查数据库交付文档核心章节是否齐全 |

## 高风险工具使用边界

生产环境中以下动作必须先确认授权、备份和回滚：

- DDL 变更
- 大表回填
- 批量 UPDATE / DELETE
- 索引创建或删除
- 数据导出、脱敏、恢复
- 权限、租户隔离、审计策略变更
