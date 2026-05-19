# QA 工作流完整化与 Skills 模块化（2026-05-18）

## 背景

QA 工作流原本只有 80 行 WORKFLOW.md 和空 pitfalls.md，与产品 / 项目 / UI/UX / API 设计四个工作流的成熟度差距明显。本次重构按 skills 模块化架构对齐。

## 完成内容

### 1. WORKFLOW.md 重写（80 → 215 行）

- 适用 / 不适用场景表
- 必需 / 可选输入
- 完整行为链（9 步）
- 12 skills 模块总览
- 复杂度分级（S/M/L/XL）
- 通用质量检查（12 项）
- 14 个跨 skill 高频坑
- 上下游协作矩阵

### 2. 12 个 Skills

| Skill | 来源 | 行数 |
|-------|------|------|
| test-strategy | Mike Cohn 测试金字塔 + Brian Marick 象限 + Beyoncé Rule | ~210 |
| test-case-design | ISTQB 黑盒方法 + 五大方法 | ~220 |
| risk-based-testing | Hans Schaefer + James Bach RBT | ~230 |
| exploratory-testing | James Bach SBTM + Hendrickson Heuristics | ~210 |
| regression-testing | ISTQB + Test Impact Analysis + 三层套件 | ~210 |
| bug-reporting | Cem Kaner + ISTQB 缺陷生命周期 | ~225 |
| acceptance-testing | BDD Given-When-Then + Specification by Example | ~210 |
| api-testing | Pact 契约测试 + Stripe / OpenAPI | ~225 |
| performance-testing | Google SRE Workbook + USE Method | ~225 |
| test-data-management | GDPR + Faker + Stripe Test Mode | ~220 |
| test-report | ISTQB Test Summary Report | ~220 |
| quality-gate | SonarQube + DORA + Microsoft Quality Gates | ~230 |

每个 SKILL.md 包含：
- frontmatter（name + description）
- 适用场景
- 核心原则
- 工作流程
- 质量自检
- 常见坑
- 配套模板
- 与其他 skill 的协作

### 3. 12 个 templates

每个 skill 至少 1 个生产可用模板（非占位）：表格 / 字段 / 示例 / 自检清单。

### 4. 工作流根文件

- `pitfalls.md`：14 个跨 skill 通用坑（含表现 / 风险 / 避免方式）
- `tool-index.md`：10 类工具对比表
- `routing.md`：中文路由 + skills 入口表
- `templates/README.md`：跨 skill 模板索引

### 5. 审查脚本扩展

`scripts/audit-workflows.py` 加入 qa-engineer 到 SKILLED_WORKFLOWS。

## 审查结果

```
A. 全局完整性（17 个工作流）：✅
B. Skills 深度审查 product-manager：✅
B. Skills 深度审查 project-manager：✅
B. Skills 深度审查 ui-ux-designer：✅
B. Skills 深度审查 api-designer：✅
B. Skills 深度审查 qa-engineer：✅
总计：0 错误 / 0 警告
```

## 关键决策

1. **12 个 skill 不再多**：测试领域方法论稳定，12 个能覆盖功能 / 性能 / 数据 / 流程 / 报告 / 门禁
2. **risk-based-testing 独立**：不只是用例方法，是测试时间分配的核心
3. **quality-gate 独立**：作为下游接口，DevOps 集成必经
4. **acceptance-testing 独立**：UAT 与日常测试关注点不同
5. **test-data-management 独立**：合规和性能测试都强依赖

## 下次类似任务可复用

1. **方法论拆分模式**：每个 skill 一个方法论流派（如 test-case-design = ISTQB 五大方法）
2. **模板生产化**：模板里写表格 / 字段 / 示例，不是占位
3. **大厂范式融合**：每个领域引 1-2 个权威来源（Stripe / Google / Microsoft / ISTQB）
4. **8 维度法**：API 测试用 8 维度（成功 / 校验 / 认证 / 权限 / 不存在 / 冲突 / 限流 / 异常）覆盖最稳

## 与其他工作流的衔接确认

| 上游 | 输入 |
|---|---|
| product-manager | 验收标准 |
| api-designer | OpenAPI 契约 |
| ui-ux-designer | 状态 / 字段说明 |
| database-engineer | 数据模型 / 状态 |

| 下游 | 输出 |
|---|---|
| automation-qa | 用例（标自动化优先级） |
| security-engineer | 越权可疑场景 |
| devops-engineer | 质量门禁 / 放行结论 |
| sre-operations | 性能基线 / 监控建议 |
| technical-writer | 已知问题 / 发布说明 |
| project-manager | 缺陷趋势 / 是否能放行 |
