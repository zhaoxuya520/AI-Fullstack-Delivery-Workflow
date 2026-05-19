# UI/UX 设计工作流

## 定位

UI/UX 设计工作流负责把产品需求、用户目标和业务流程，转化为 **可理解、可交互、可实现、可验收** 的界面设计说明。

它不负责最终代码实现，也不替代产品经理决定业务范围；它负责定义用户路径、信息架构、页面结构、交互规则、视觉层级、组件状态、响应式要求、可访问性要求和前端交接说明。

本工作流采用 **skills 模块化架构**：总控负责路由和通用规则，具体方法论拆分成独立 skills，按需加载。

---

## 适用场景

```text
用户流程设计 / 信息架构
页面结构 / 线框图 / 原型设计
交互规则 / 组件拆分
状态设计（loading/error/empty/success/权限）
表单 / 数据表格 / 导航 / 企业后台 / SaaS 控制台
设计系统对标 / Design Tokens
视觉风格 / 反 AI 化检查
响应式 / 移动端适配
可访问性（WCAG）
设计交接 / 可用性评审
```

典型用户请求：

```text
帮我设计这个功能的页面结构。
把这个 PRD 转成 UI/UX 设计说明。
这个流程用户怎么走最合理？
帮我列页面、组件和状态。
帮我写给前端的设计交接文档。
这个页面有哪些空状态和错误状态？
```

---

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 需求目标、MVP、业务规则不清 | 产品经理工作流 |
| 排期、依赖、里程碑 | 项目经理工作流 |
| API 契约、字段、错误码 | API 设计工作流 |
| 数据实体、表结构 | 数据库工程师工作流 |
| 前端代码实现 | 前端工程师工作流 |
| 后端业务逻辑 | 后端工程师工作流 |
| 测试用例和测试报告 | QA 工作流 |
| 权限、敏感数据、攻击面 | 安全工程师工作流 |

---

## 输入

### 必需输入

```text
PRD 或功能范围
目标用户 / 用户目标
核心流程
目标终端（桌面 / 移动 / 平板 / 后台）
```

### 可选输入

```text
品牌风格 / 设计规范
目标视觉风格 / 禁用视觉风格
真实产品参考 / 反 AI 化要求
竞品参考 / 已有页面或系统截图
API 字段草案 / 组件库限制
设备和浏览器范围 / 可访问性要求
```

### 输入不足时先补问

```text
1. 这个页面服务哪个用户角色？
2. 用户进入页面时最想完成什么？
3. 这是桌面端、移动端还是响应式页面？
4. 是否已有品牌色、组件库或设计规范？
5. 是否有必须展示的数据字段和权限限制？
```

---

## 完整行为链（硬性流程）

```text
1. 读取 PRD / 功能范围 / 用户目标
   ↓
2. 检查 field-journal/_index.md → 是否有同类设计经验可复用
   ↓
3. 读取 skills/routing.md → 路由到需要的 skills
   ↓
4. 判断设计复杂度（S/M/L/XL）→ 选择产出粒度
   ↓
5. 加载命中的 skills（一个或多个）→ 按 skill 内方法执行
   ↓
6. 输出设计产物
   ↓
7. 转交前端 / API / QA / 安全工作流
   ↓
8. 按 EVOLUTION.md 检查是否需要沉淀经验 → 回写 field-journal
```

---

## Skills 模块总览

每个 skill 独立可用，按需组合。详细路由见 `skills/routing.md`。

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [user-flow](skills/user-flow/SKILL.md) | 用户流程设计 | 用户旅程 + 决策点 + 异常路径 |
| [information-architecture](skills/information-architecture/SKILL.md) | 信息架构 | 卡片分类 + 树状结构 + 导航模式 |
| [page-structure](skills/page-structure/SKILL.md) | 页面结构和线框图 | 页面目标 + 内容层级 + 主次操作 |
| [component-states](skills/component-states/SKILL.md) | 组件状态设计 | 8 种状态完整覆盖 |
| [atomic-design](skills/atomic-design/SKILL.md) | 组件分层 | Brad Frost 五层模型 |
| [design-tokens](skills/design-tokens/SKILL.md) | 设计令牌系统 | W3C DTCG 标准 + JSON 输出 |
| [responsive-design](skills/responsive-design/SKILL.md) | 响应式设计 | 断点策略 + 移动优先 |
| [accessibility](skills/accessibility/SKILL.md) | 可访问性 | WCAG 2.2 + 键盘 + 焦点 |
| [enterprise-patterns](skills/enterprise-patterns/SKILL.md) | 企业 UI 模式 | 表单 / 表格 / 导航 / 危险操作 |
| [design-system-mapping](skills/design-system-mapping/SKILL.md) | 设计系统对标 | Material/HIG/Ant/shadcn |
| [visual-style](skills/visual-style/SKILL.md) | 视觉风格定义 | 风格库 + 反 AI 化检查 |
| [usability-evaluation](skills/usability-evaluation/SKILL.md) | 可用性评审 | Nielsen 十大启发式 |
| [design-handoff](skills/design-handoff/SKILL.md) | 设计交接 | Figma DevMode + 交接清单 |
| [hig-principles](skills/hig-principles/SKILL.md) | 平台设计原则 | Apple HIG / Material 4 原则 |

---

## 禁止行为

```text
❌ 不要在目标用户和核心任务不清时直接画页面
❌ 不要只输出静态页面，不定义交互状态
❌ 不要忽略空状态、错误状态、加载状态和权限状态
❌ 不要让页面字段和 API / 数据模型脱节
❌ 不要把所有信息堆在一个页面，没有层级
❌ 不要只考虑成功路径，忽略失败路径和边界状态
❌ 不要输出前端无法实现或无法验收的模糊说明
❌ 不要跳过移动端 / 响应式 / 目标设备检查
❌ 不要忽略可访问性：键盘、对比度、焦点、文本替代
❌ 不要在任务完成后跳过经验沉淀
```

---

## 任务复杂度分级

```text
S 级（10~30 分钟）：单页面/单组件 → 加载 page-structure + component-states

M 级（30~90 分钟）：功能模块 → 加载 user-flow + page-structure + component-states + accessibility

L 级（1~3 小时）：多页面联动 → 加载 user-flow + information-architecture + page-structure + atomic-design + component-states + responsive-design + accessibility + design-handoff

XL 级（3 小时+）：产品级设计 → 加载所有 14 个 skills
```

---

## 通用质量检查

```text
□ 用户角色是否明确？
□ 页面目标是否明确？
□ 主路径是否足够短？
□ 信息层级是否清楚？
□ 主操作和次操作是否区分？
□ 视觉风格是否匹配产品场景？
□ 是否避免 AI 模板化效果？
□ 每个核心组件是否有状态说明？
□ 空/错/加载/权限状态是否定义？
□ 移动端或目标终端是否考虑？
□ 可访问性要求是否检查？
□ 页面所需字段是否能交给 API 设计？
□ 设计说明是否能交给前端直接拆任务？
□ QA 是否能根据状态说明设计测试？
```

---

## 常见坑（跨 skill 通用）

```text
1. 只画静态页面，不定义交互状态。
2. 忽略空状态、错误状态、加载状态。
3. 页面字段和 API / 数据库模型不匹配。
4. 组件边界不清，前端无法拆分。
5. 信息层级混乱，主操作不突出。
6. 只考虑桌面端，忽略移动端或响应式。
7. 表单错误提示不清，用户不知道如何修正。
8. 忽略权限状态，导致越权入口或错误体验。
9. 忽略可访问性，键盘、焦点、对比度不可用。
10. 没有设计交接文档，前端只能猜。
11. 视觉风格泛化（漂浮发光球 / 假 3D / 通用 AI 插画）。
12. Design Tokens 和实际设计脱节。
```

具体 skill 内的常见坑见各 skill 的 SKILL.md。

---

## 与其他工作流的协作

### 上游

```text
产品经理工作流：PRD、用户故事、验收标准、用户旅程
项目经理工作流：阶段计划、交付节点、设计门禁
```

### 下游

| 下游工作流 | UI/UX 交付内容 |
|---|---|
| API 设计工作流 | 页面数据字段、操作、错误场景 |
| 前端工程师工作流 | 页面结构、组件、状态、交互规则、响应式要求 |
| QA 工作流 | 用户路径、状态、异常场景、可用性验收点 |
| 安全工程师工作流 | 权限状态、敏感信息展示、危险操作确认 |
| 技术文档工作流 | 页面说明、用户操作流程素材 |

---

## 多任务与中断处理

```text
1. 多页面并行：每个页面独立维护，标注共享组件
2. 中途中断：保存当前进度（已完成页面 + 待确认问题）
3. 需求变更：评估影响 → 更新设计说明 → 通知前端
```

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow ui-ux-designer
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

任务完成后按 `EVOLUTION.md` 检查：

```text
是否形成新的页面模板？→ 加入对应 skill 的 templates/
是否发现新的交互坑？→ 更新对应 skill
是否需要新增状态设计规则？→ 更新 component-states
是否需要更新前端交接模板？→ 更新 design-handoff
是否需要更新可访问性检查项？→ 更新 accessibility
是否需要写入 field-journal？
是否需要新增 skill？→ 按 CONTRIBUTING.md 流程
```
