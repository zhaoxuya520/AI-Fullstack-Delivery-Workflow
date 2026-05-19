# UI/UX 设计 Skills 总控

本目录收录 UI/UX 设计工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [user-flow](user-flow/SKILL.md) | 用户流程设计 | NNGroup / 用户旅程方法 |
| [information-architecture](information-architecture/SKILL.md) | 信息架构 | Rosenfeld IA / 卡片分类 |
| [page-structure](page-structure/SKILL.md) | 页面结构和线框图 | 页面目标导向方法 |
| [component-states](component-states/SKILL.md) | 组件状态设计 | 8 种状态完整覆盖 |
| [atomic-design](atomic-design/SKILL.md) | 组件分层 | Brad Frost Atomic Design |
| [design-tokens](design-tokens/SKILL.md) | 设计令牌系统 | W3C DTCG 2025.10 |
| [responsive-design](responsive-design/SKILL.md) | 响应式设计 | Mobile-First / Bootstrap |
| [accessibility](accessibility/SKILL.md) | 可访问性 | WCAG 2.2 / WAI-ARIA |
| [enterprise-patterns](enterprise-patterns/SKILL.md) | 企业 UI 模式 | 表单/表格/导航/危险操作 |
| [design-system-mapping](design-system-mapping/SKILL.md) | 设计系统对标 | Material/HIG/Ant/shadcn |
| [visual-style](visual-style/SKILL.md) | 视觉风格定义 | 风格库 + 反 AI 化 |
| [usability-evaluation](usability-evaluation/SKILL.md) | 可用性评审 | Nielsen 十大启发式 |
| [design-handoff](design-handoff/SKILL.md) | 设计交接 | Figma DevMode 实践 |
| [hig-principles](hig-principles/SKILL.md) | 平台设计原则 | Apple HIG / Material 4 原则 |

## 统一入口

1. 先读 `routing.md` — 按设计任务路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到设计需求 → 先理解用户和场景
   - user-flow（流程）
   - information-architecture（信息架构）

2. 设计页面 → 结构 + 状态
   - page-structure（页面结构）
   - component-states（组件状态）

3. 系统化设计 → 分层 + 令牌
   - atomic-design（组件分层）
   - design-tokens（设计令牌）

4. 跨设备适配
   - responsive-design（响应式）
   - accessibility（可访问性）

5. 业务模式（企业类）
   - enterprise-patterns（企业 UI 模式）
   - design-system-mapping（系统对标）

6. 视觉定义
   - visual-style（风格 + 反 AI 化）
   - hig-principles（平台原则）

7. 验证和交付
   - usability-evaluation（可用性评审）
   - design-handoff（前端交接）
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成设计任务后，回写经验到 `../field-journal/`。
