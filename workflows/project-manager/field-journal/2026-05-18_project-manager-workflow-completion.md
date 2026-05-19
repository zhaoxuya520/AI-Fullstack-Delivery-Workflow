# 项目经理工作流配套文件完善

## Date

2026-05-18

## Workflow

project-manager

## Task Background

项目经理工作流的 `WORKFLOW.md` 已经比较完整，但配套文件仍是骨架或存在编码残留，需要补齐到可执行、可检查、可自进化的工作流结构。

## Inputs

- 已有 `WORKFLOW.md`
- 岗位工作流标准结构
- 项目经理核心职责：WBS、依赖、关键路径、里程碑、风险、门禁、变更、交接、进度、复盘

## Problem

原有 `routing.md`、`tool-index.md` 存在英文骨架和脚本残留；`pitfalls.md` 为空；`templates/`、`references/`、`scripts/` 和 `field-journal/` 缺少可用内容。

## Solution

- 重写 `routing.md`，补充中文触发关键词、输入输出、任务类型和转出规则。
- 重写 `tool-index.md`，建立模板、方法、图表、脚本和参考资料索引。
- 重写 `pitfalls.md`，沉淀 12 类项目管理常见坑。
- 新增项目计划、WBS、里程碑、DAG、风险、门禁、交接、进度、变更、复盘模板。
- 新增项目方法、编排、门禁、风险变更和公开资料参考。
- 新增 `check-project-plan.ps1`，检查项目计划模板核心章节。

## Verification

- 使用 `check-project-plan.ps1` 检查 `templates/project-plan-template.md`，结果通过。
- 使用文件 glob 确认 project-manager 标准结构和新增模板、参考资料、脚本已落盘。

## Reusable Lesson

当某个工作流的主文档先写完时，不能认为工作流已经完成；必须同步补齐路由、工具索引、坑位、模板、参考资料、脚本和经验库，否则无法稳定复用。

## Follow-up Improvements

- 后续工作流应按“主文档 + 路由 + 工具索引 + 常见坑 + 模板 + 参考 + 脚本 + 经验库”的顺序一次性完成。
- 如果工作流有核心交付物，应提供检查脚本验证模板完整性。

## Tags

#project-manager #workflow-completion #wbs #milestone #risk #delivery-gate #self-evolution
