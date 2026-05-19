# 补充 GitHub 热门 UI 项目参考

## Date

2026-05-18

## Workflow

ui-ux-designer

## Task Background

用户要求继续在 GitHub 上找设计风格和热门 UI 项目参考，用于完善 UI/UX 工作流，避免只参考趋势文章或同质化模板。

## Inputs

通过 GitHub CLI 检索和查看了以下方向：

```text
Tailwind / React UI components
shadcn/ui blocks
animated UI components
dashboard templates
AI interface components
anime / manga UI
game website UI
```

代表项目包括：

```text
daisyUI
HeroUI
Flowbite
Headless UI
gluestack-ui
21st
Creative Tim UI
UI Layouts
UITripled
Magic UI
Animate UI
Lightswind UI
React Awesome Button
TailAdmin
Mosaic Lite
Material Kit React
Materio MUI Next.js Admin
Tremor
Prompt Kit
Hermes UI
Anime Website
Moopa
MangaReader
Houdoku
Yomikiru
Game Website
Gamer
```

## Problem

前一轮已经建立视觉风格库和反 AI 化规则，但仍需要更多真实开源项目作为落地参考，尤其是组件系统、动效边界、后台模板、AI 工作台、动漫/漫画阅读和游戏沉浸式页面。

## Solution

新增参考资料：

- `references/github-ui-projects-reference.md`

同步更新：

- `references/README.md`
- `tool-index.md`
- `WORKFLOW.md`
- `pitfalls.md`
- `field-journal/_index.md`

新增常见坑：

```text
只看概念图，不看真实开源项目
```

## Reusable Lesson

GitHub 项目的价值不是照抄 UI，而是帮助判断设计是否能组件化、是否有状态覆盖、是否有动效边界、是否符合技术栈和是否适合当前产品品类。Blocks 和模板能提高起步速度，但也最容易造成同质化，必须明确借鉴与不借鉴的部分。

## Follow-up Improvements

- 前端工程师工作流应读取 `github-ui-projects-reference.md`，将可借鉴项目转成技术选型、组件实现和主题 token。
- UI/UX 工作流在强风格设计前，应优先区分：基础组件库、动效库、blocks、后台模板、内容产品和游戏/动漫品类项目。
- QA 工作流可增加视觉实现验收：动效性能、键盘可用、状态覆盖、移动端表现。

## Tags

#ui-ux-designer #github #open-source-ui #shadcn #tailwind #animation #anime-ui #game-ui #dashboard #anti-homogeneous #self-evolution
