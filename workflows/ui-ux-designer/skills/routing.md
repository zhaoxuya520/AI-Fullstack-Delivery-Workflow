# UI/UX 设计 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "用户怎么走" / "流程图" | [user-flow](user-flow/SKILL.md) |
| "页面怎么组织" / "导航结构" | [information-architecture](information-architecture/SKILL.md) |
| "画线框图" / "页面结构" | [page-structure](page-structure/SKILL.md) |
| "组件有哪些状态" / "loading/error/empty" | [component-states](component-states/SKILL.md) |
| "拆组件" / "可复用组件" | [atomic-design](atomic-design/SKILL.md) |
| "颜色/字体/间距规范" / "design tokens" | [design-tokens](design-tokens/SKILL.md) |
| "移动端怎么办" / "响应式" | [responsive-design](responsive-design/SKILL.md) |
| "无障碍" / "可访问性" / "WCAG" | [accessibility](accessibility/SKILL.md) |
| "表单/表格/后台" / "企业级界面" | [enterprise-patterns](enterprise-patterns/SKILL.md) |
| "参考 Material/Ant/shadcn" | [design-system-mapping](design-system-mapping/SKILL.md) |
| "什么风格" / "避免 AI 味" | [visual-style](visual-style/SKILL.md) |
| "可用性评审" / "易用性检查" | [usability-evaluation](usability-evaluation/SKILL.md) |
| "交接给前端" / "设计文档" | [design-handoff](design-handoff/SKILL.md) |
| "iOS/Android/桌面端原则" | [hig-principles](hig-principles/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单页面快速设计（S 级） | page-structure + component-states |
| 功能模块设计（M 级） | user-flow + page-structure + component-states + accessibility |
| 多页面联动设计（L 级） | user-flow + information-architecture + page-structure + atomic-design + component-states + responsive-design + accessibility + design-handoff |
| 完整产品设计（XL 级） | 全部 14 个 skills |
| 企业后台设计 | enterprise-patterns + design-system-mapping + page-structure + component-states |
| 移动 App 设计 | hig-principles + responsive-design + page-structure + component-states |
| 设计系统建立 | atomic-design + design-tokens + design-system-mapping + visual-style |
| 设计评审 | usability-evaluation + accessibility |
| 给前端交接 | design-handoff + component-states + responsive-design |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 10~30min | page-structure + component-states |
| M | 30~90min | user-flow + page-structure + component-states + accessibility |
| L | 1~3h | + information-architecture + atomic-design + responsive-design + design-handoff |
| XL | 3h+ | 全部 14 个 skills |

## 路径交叉

```text
新页面设计：
  user-flow → information-architecture → page-structure
  → component-states → accessibility → design-handoff

设计系统建立：
  atomic-design → design-tokens → design-system-mapping
  → visual-style → component-states

企业后台设计：
  enterprise-patterns → page-structure → component-states
  → responsive-design → accessibility → design-handoff

移动端设计：
  hig-principles → responsive-design → page-structure
  → component-states → accessibility

可用性优化：
  usability-evaluation → 识别问题
  → 加载具体改进 skill（如 page-structure / component-states）
```

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增。
