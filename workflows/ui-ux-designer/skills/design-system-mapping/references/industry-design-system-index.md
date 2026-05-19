# 大厂与热门项目设计系统索引

本索引用于记录 UI/UX 工作流参考的大厂设计系统、政府设计系统和热门开源 UI 项目。使用原则：提炼模式和检查项，不复制大段原文或专有视觉资产。

## 大厂设计系统

| 来源 | 适合参考 | 可沉淀模式 |
|---|---|---|
| [Material Design](https://m1.material.io/patterns/empty-states.html) | Android / Web 通用体验、组件状态 | 空状态、反馈、布局、组件状态 |
| [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) | iOS / macOS / 平台体验 | 导航、反馈、输入、平台一致性 |
| [Microsoft Fluent UI](https://learn.microsoft.com/en-us/fluent-ui/web-components/) | 企业级 Web / Windows 体验 | Design tokens、状态、无障碍、高对比度 |
| [Atlassian Design System](https://atlassian.design/) | 协作工具、复杂表单、消息反馈 | 表单、错误消息、空状态、内容设计 |
| [Shopify Polaris](https://shopify.dev/docs/api/polaris/using-polaris-web-components) | 商家后台、SaaS 管理台 | 表单、标签、可访问性、空状态引导 |
| [IBM Carbon Design System](https://carbondesignsystem.com/) | 企业后台、数据密集型产品 | 数据表格、表单、空状态、可访问性 |
| [GitHub Primer](https://primer.github.io/design/) | 开发者工具、协作平台 | 表单、按钮状态、导航、可访问性注释 |
| [GitLab Pajamas](https://design.gitlab.com/) | DevOps 平台、复杂后台 | 空状态、表单、内容结构、可访问性 |

## 政府和公共设计系统

| 来源 | 适合参考 | 可沉淀模式 |
|---|---|---|
| [U.S. Web Design System](https://designsystem.digital.gov/) | 公共服务、表单、验证、可访问性 | 表单结构、校验、错误提示、公共服务可访问性 |
| [GOV.UK Service Manual](https://www.gov.uk/service-manual) | 服务设计、用户需求、可访问性 | 以用户任务为中心、服务流程、内容设计 |

## 热门开源 / 前端生态

| 来源 | 适合参考 | 可沉淀模式 |
|---|---|---|
| [Ant Design](https://ant.design/components/overview/) | 企业后台、表单、表格、反馈 | 管理后台信息密度、表格、表单、空状态 |
| [MUI](https://mui.com/material-ui/guides/responsive-ui/) | React + Material 风格产品 | 响应式 Grid、Data Grid、组件 API |
| [Radix UI](https://www.radix-ui.com/primitives/docs/overview/accessibility) | 无样式可访问组件基础 | Focus 管理、键盘交互、ARIA 模式 |
| [shadcn/ui](https://www.shadcn.io/ui) | Tailwind + Radix 的现代组件模式 | 可复制组件、组合式设计、开发友好交接 |
| [Tailwind UI](https://tailwindcss.com/plus/ui-blocks/application-ui) | 应用 UI 模式库 | 表单、表格、导航、空状态、布局块 |
| [Tabler](https://tabler.io/) | 开源管理后台 | Dashboard、表单、表格、空页面 |
| [AdminLTE](https://adminlte.io/) | 传统后台模板 | 数据表格、表单、侧边栏、管理台布局 |

## 提炼到本工作流的规则

```text
1. 空状态必须告诉用户当前状态、原因和下一步。
2. 表单必须有标签、帮助文本、校验、错误恢复和提交反馈。
3. 数据表格必须处理加载、空数据、错误、分页、排序、筛选、批量操作和移动端退化。
4. 导航必须体现当前位置、可返回路径和任务优先级。
5. 组件必须定义状态：默认、hover、focus、disabled、loading、error、selected。
6. 可访问性不是后置项，必须在设计说明中写入键盘、焦点、语义、对比度和错误文本。
7. 大厂设计系统的价值在模式和约束，不在照抄视觉风格。
```
