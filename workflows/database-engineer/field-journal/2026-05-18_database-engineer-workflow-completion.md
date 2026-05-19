# 2026-05-18 数据库工程师工作流模块化补全

## 背景

数据库工程师工作流原本只有旧版根目录骨架，`routing.md` 存在代码块损坏，`tool-index.md` 混入 here-string 和其他文件内容，`pitfalls.md` 与 `field-journal/_index.md` 为空，模板和参考资料没有按项目经理工作流的结构下沉。

## 问题

- 根目录承担过多内容，缺少 `skills/routing.md` 和子 skill 方法模块。
- 路由文件不可稳定解析，工具索引存在污染内容。
- 数据库交付缺少对迁移、回滚、索引、租户隔离和生产操作安全的显式门禁。

## 方案

- 将根 `WORKFLOW.md` 调整为总控文档，明确硬行为链、复杂度分级、协作边界和自进化规则。
- 新增 6 个数据库子 skill：`schema-design`、`index-access-pattern`、`migration-rollout`、`query-review`、`consistency-multitenancy`、`data-operations-safety`。
- 将模板和参考资料下沉到各 skill，根 `templates/README.md` 和 `references/README.md` 改为索引说明。
- 新增 ASCII-safe PowerShell 检查脚本，检查数据库交付文档核心章节。

## 验证

- 使用 `check-database-deliverable.ps1` 验证 schema 设计模板核心章节。
- 检查本地 Markdown 链接和污染残留。
- 复跑既有章节检查，确认 product-manager、project-manager、ui-ux-designer、api-designer 链路未被破坏。

## 可复用结论

后续所有岗位工作流应优先参考 `project-manager` 的结构：根目录只做总控和跨模块入口，具体方法、模板、参考资料下沉到内部 `skills/`，并通过 `skills/routing.md` 组合调用。

## 后续更新点

- 如果真实项目中出现新的数据库迁移模式，应补充到 `migration-rollout`。
- 如果出现新的生产数据操作事故或风险，应补充到 `data-operations-safety` 和 `pitfalls.md`。
- 如果某类 SQL 优化反复出现，应补充到 `query-review` 和 `index-access-pattern`。
