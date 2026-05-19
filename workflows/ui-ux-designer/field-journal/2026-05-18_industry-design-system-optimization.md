# 参考大厂和热门项目优化 UI/UX 工作流

## Date

2026-05-18

## Workflow

ui-ux-designer

## Task Background

用户要求继续优化 UI/UX 工作流，重点参考网络上大厂、火爆项目和热门项目的公开资料。优化目标是让 UI/UX 工作流不仅能产出基础页面说明，还能吸收成熟设计系统和开源 UI 生态中的高频模式。

## Inputs

- Material Design
- Apple Human Interface Guidelines
- Microsoft Fluent UI
- Atlassian Design System
- Shopify Polaris
- IBM Carbon Design System
- GitHub Primer
- GitLab Pajamas
- USWDS / GOV.UK
- Ant Design
- MUI
- Radix UI
- shadcn/ui
- Tailwind UI
- Tabler / AdminLTE 等管理后台项目

## Problem

原 UI/UX 工作流已经具备基础用户流程、页面说明、组件、状态、响应式和可访问性能力，但对企业后台、SaaS 控制台、数据表格、复杂表单、空状态、导航模式、设计系统对标和热门开源组件生态的模式沉淀不足。

## Solution

新增参考资料：

- `references/industry-design-system-index.md`
- `references/enterprise-ui-patterns-guide.md`
- `references/open-source-ui-patterns-guide.md`
- `references/form-table-empty-state-guide.md`

新增模板：

- `templates/design-system-benchmark-template.md`
- `templates/ui-pattern-library-template.md`
- `templates/form-pattern-template.md`
- `templates/data-table-pattern-template.md`
- `templates/empty-state-pattern-template.md`
- `templates/navigation-pattern-template.md`

同步更新：

- `WORKFLOW.md`
- `tool-index.md`
- `pitfalls.md`
- `templates/README.md`
- `references/README.md`

## Verification

- 使用 `check-design-spec.ps1` 检查 `templates/page-spec-template.md`，结果通过。
- 使用文件 glob 确认新增参考资料和模板已落盘。

## Reusable Lesson

参考大厂和热门项目时，不应照抄视觉风格，而应提炼：页面类型、组件行为、状态矩阵、表单校验、表格能力、空状态引导、导航层级、可访问性和前端交接规则。成熟设计系统的价值在模式和约束，不在皮肤。

## Follow-up Improvements

- 后续前端工作流应根据 `open-source-ui-patterns-guide.md` 对接 Ant Design、MUI、Radix、shadcn、Tailwind 等技术实现模式。
- API 设计工作流应特别读取 `data-table-pattern-template.md` 和 `form-pattern-template.md`，支撑分页、筛选、排序、校验和错误码。
- QA 工作流应把表单、表格、空状态和导航模板转成测试用例。

## Tags

#ui-ux-designer #design-system #enterprise-ui #ant-design #mui #radix #shadcn #accessibility #self-evolution
