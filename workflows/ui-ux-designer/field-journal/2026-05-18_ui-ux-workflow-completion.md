# UI/UX 设计工作流配套文件完善

## Date

2026-05-18

## Workflow

ui-ux-designer

## Task Background

按全栈交付工作流顺序，完成产品经理和项目经理后，进入 UI/UX 设计工作流建设。原有 UI/UX 工作流只有简略主文档，配套文件存在英文骨架和编码残留，需要补齐为可执行、可检查、可交接、可自进化的工作流。

## Inputs

- 岗位工作流标准结构
- 产品经理工作流输出：PRD、用户故事、验收标准、用户旅程
- 项目经理工作流输出：阶段计划、门禁、交接点
- UI/UX 核心职责：用户流程、信息架构、页面结构、组件、状态、响应式、可访问性、前端交接

## Problem

原 UI/UX 工作流不足以支撑前端、API、QA 和安全下游协作，主要缺少：

- 明确的路由和触发条件
- 页面设计说明模板
- 组件和状态设计模板
- 响应式和可访问性检查
- 前端交接模板
- 可验证脚本
- 经验回写记录

## Solution

- 重写 `WORKFLOW.md`，定义完整行为链、禁止行为、核心方法、输出和质量检查。
- 重写 `routing.md`，补充 UI/UX、交互、状态、响应式、可访问性等触发关键词。
- 重写 `tool-index.md`，建立模板、方法、图表、脚本和参考资料索引。
- 重写 `pitfalls.md`，沉淀 10 类常见设计坑。
- 新增设计 Brief、用户流程、信息架构、线框图、页面说明、组件清单、交互状态、响应式可访问性、设计交接和可用性评审模板。
- 新增 UX 方法、交互状态、可访问性、设计交接和公开资料参考。
- 新增 `check-design-spec.ps1` 检查页面设计说明核心章节。

## Verification

- 使用 `check-design-spec.ps1` 检查 `templates/page-spec-template.md`，结果通过。
- 使用文件 glob 确认 UI/UX 工作流标准结构和新增模板、参考资料、脚本已落盘。

## Reusable Lesson

UI/UX 工作流不能只交付静态页面结构，必须同时交付用户路径、组件边界、状态矩阵、响应式规则、可访问性要求和前端交接说明，否则前端、QA、API 和安全工作流都会被迫猜测设计意图。

## Follow-up Improvements

- 后续前端工程师工作流应直接消费 `design-handoff-template.md` 的字段。
- API 设计工作流应读取 UI/UX 页面字段和操作清单，反向校验接口契约是否支撑页面。
- QA 工作流应读取状态矩阵生成测试用例。

## Tags

#ui-ux-designer #workflow-completion #design-handoff #interaction-state #accessibility #self-evolution
