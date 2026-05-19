# 扩展视觉风格库并加入反 AI 化设计检查

## Date

2026-05-18

## Workflow

ui-ux-designer

## Task Background

用户确认 UI/UX 工作流负责前端页面风格设计，并要求继续爬取更多设计风格资料，同时尽量避免设计出现 AI 化风格。

## Inputs

- 2026 UI / Web Design Trends
- Figma 设计趋势和 UI 原则资料
- Canva 2026 视觉趋势资料
- NN/g 视觉设计原则资料
- Laws of UX / UI 原则资料
- Mobbin 等真实产品界面参考平台资料
- 前一轮大厂设计系统资料：Material、Apple HIG、Fluent、Atlassian、Polaris、Carbon、Ant Design、MUI、Radix、shadcn、Tailwind UI 等

## Problem

原 UI/UX 工作流已经能参考大厂设计系统和热门组件生态，但对“视觉风格”本身的分类、适用场景、禁用边界、前端实现约束和反 AI 化检查还不够明确。若只写“液态玻璃、高级、科技感”，前端仍无法稳定实现，最终容易产出同质化的 AI 模板界面。

## Solution

新增参考资料：

- `references/visual-style-patterns-guide.md`
- `references/anti-ai-visual-design-guide.md`

新增模板：

- `templates/visual-style-template.md`
- `templates/anti-ai-style-checklist-template.md`

同步更新：

- `WORKFLOW.md`
- `tool-index.md`
- `pitfalls.md`
- `templates/README.md`
- `references/README.md`

## Style Patterns Added

新增视觉风格模式包括：

```text
液态玻璃 / Glassmorphism
极简 SaaS / Minimal SaaS
企业专业 / Enterprise Professional
编辑排版 / Editorial
Bento Grid / 模块化卡片
新粗野 / Neo-brutalism
触感拟物 / Tactile Skeuomorphism
暗黑科技 / Dark Tech
数据密集 / Data-dense Dashboard
开发者工具 / Developer Tool
复古 / Retro / Y2K
温暖人文 / Human Warmth
高级奢华 / Premium Luxury
政务可信 / Civic Trust
```

## Anti-AI Rules Added

反 AI 化检查重点：

```text
避免无意义蓝紫渐变
避免漂浮发光球
避免假 3D 装饰
避免通用机器人/火箭/闪电插画
避免所有模块都是同款圆角玻璃卡片
避免空泛大标题和模板化营销文案
避免没有业务含义的假图表
避免只写“高级/现代/科技感”而不定义约束
```

## Verification

- 新增参考资料和模板已落盘。
- `tool-index.md` 已注册新增模板和参考资料。
- `WORKFLOW.md` 已加入视觉风格定义和反 AI 化检查步骤。
- `pitfalls.md` 已新增视觉风格形容词化、AI 化视觉痕迹明显两个常见坑。

## Reusable Lesson

视觉风格必须从形容词变成约束：颜色、排版、组件形态、状态、动效、禁用效果和前端实现风险。避免 AI 味的关键不是拒绝趋势，而是让每个视觉选择都服务真实用户任务和真实业务数据。

## Follow-up Improvements

- 前端工程师工作流应读取 `visual-style-template.md`，把风格定义转成 CSS Token、组件变体和动效规则。
- QA 工作流应把 `anti-ai-style-checklist-template.md` 转成设计验收清单。
- 产品经理工作流可在 PRD 中加入品牌气质、目标用户审美和禁用视觉风格输入。

## Tags

#ui-ux-designer #visual-style #glassmorphism #minimal-saas #dark-tech #bento #anti-ai-design #design-system #self-evolution
