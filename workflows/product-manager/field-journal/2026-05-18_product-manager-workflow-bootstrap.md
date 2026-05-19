# 产品经理工作流初始化

## Date

2026-05-18

## Workflow

product-manager

## Task Background

为全栈交付工作流创建第一个完整岗位工作流，要求结构对齐逆向/渗透工作流：主流程、路由、工具索引、常见坑、模板、参考资料、脚本、经验回写和自进化协议齐全。

## Inputs

- 全栈交付工作流总架构
- 岗位工作流标准目录结构
- 产品经理常见交付物：PRD、MVP、用户故事、验收标准、评审清单、变更影响分析

## Problem

产品经理工作流如果只写 PRD 模板，无法支撑下游设计、API、数据库、开发、测试和安全工作流协作；必须把需求澄清、范围切分、验收、交接和变更影响分析一起标准化。

## Solution

- 用 `WORKFLOW.md` 定义产品经理从模糊想法到下游交付包的完整步骤。
- 用 `routing.md` 定义需求、PRD、MVP、用户故事、优先级、版本规划等触发条件。
- 用 `tool-index.md` 汇总模板、方法论、检查清单和脚本。
- 用 `pitfalls.md` 固化常见需求风险。
- 在 `templates/`、`references/`、`scripts/` 中沉淀可复用交付件。
- 用 `check-prd.ps1` 做 PRD 必要章节检查。

## Verification

- 产品经理工作流目录包含标准结构要求的核心文件和子目录。
- 使用 `check-prd.ps1` 检查 `templates/prd-template.md`，结果通过。

## Reusable Lesson

创建岗位工作流时，不应只写岗位说明；至少要同时完成路由、工具索引、常见坑、模板、参考资料、脚本和自进化要求，这样后续岗位才能按同一标准扩展。

## Follow-up Improvements

- 后续编写项目经理、UI/UX、前端、后端等工作流时，复用本次产品经理工作流的建设顺序。
- 如果某个岗位有可自动检查的核心交付物，应优先沉淀到 `scripts/`。

## Tags

#product-manager #workflow-bootstrap #prd #self-evolution
