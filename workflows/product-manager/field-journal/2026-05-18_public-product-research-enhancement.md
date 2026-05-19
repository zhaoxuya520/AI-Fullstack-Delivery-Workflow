# 公开产品资料增强产品经理工作流

## Date

2026-05-18

## Workflow

product-manager

## Task Background

用户要求从网上检索大量公开资料，完善产品经理工作流。资料范围覆盖 PRD、用户故事、验收标准、用户需求、产品发现、优先级、路线图、Backlog 和产品指标。

## Inputs

- Atlassian PRD、用户故事、验收标准公开资料
- GOV.UK Service Manual 用户需求和敏捷交付资料
- NN/g 用户旅程和 UX 交付物资料
- SVPG 产品发现和四类风险资料
- Scrum Guide Product Goal / Product Backlog 资料
- Agile Alliance INVEST 和用户故事资料
- Cucumber Gherkin / Given-When-Then 资料
- Google HEART 指标资料
- ProductPlan、Mind the Product、Roman Pichler 的优先级和路线图资料

## Problem

原产品经理工作流已能输出 PRD、MVP、用户故事和验收标准，但对产品发现、假设验证、指标、路线图、Backlog、公开资料引用和高不确定需求处理不足。

## Solution

新增和更新：

- `references/public-source-index.md`
- `references/product-discovery-guide.md`
- `references/product-metrics-guide.md`
- `references/prioritization-roadmap-guide.md`
- `templates/discovery-brief-template.md`
- `templates/opportunity-solution-tree-template.md`
- `templates/product-metrics-template.md`
- `templates/roadmap-template.md`
- `templates/persona-journey-template.md`
- `templates/prd-template.md`
- `templates/requirement-review-template.md`
- `WORKFLOW.md`
- `routing.md`
- `tool-index.md`
- `pitfalls.md`
- `references/product-methods.md`
- `references/prd-quality-checklist.md`
- `templates/README.md`
- `references/README.md`

## Verification

- 使用 `check-prd.ps1` 验证更新后的 `templates/prd-template.md`，检查通过。
- `Glob` 确认新增模板和参考资料已落盘。

## Reusable Lesson

公开资料增强工作流时，应先建立 `public-source-index.md` 记录来源，再把方法拆到 `references/`，把可执行格式拆到 `templates/`，最后同步更新 `WORKFLOW.md`、`routing.md`、`tool-index.md`、`pitfalls.md` 和质量检查清单。

## Follow-up Improvements

- 后续写其他岗位工作流时，也可以先建立公开资料索引，再沉淀岗位方法论、模板和检查清单。
- 如果某类文档能自动检查，应补充对应脚本，而不是只依赖人工评审。

## Tags

#product-manager #public-research #product-discovery #prd #metrics #roadmap #self-evolution
