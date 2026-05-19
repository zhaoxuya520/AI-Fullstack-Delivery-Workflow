---
name: atomic-design
description: 把界面组件按层级组织时使用。适用于设计系统建立、组件库设计、可复用性提升。优先使用 Brad Frost 的 Atomic Design 五层模型（原子→分子→有机体→模板→页面）。
---

# Atomic Design 组件分层

参考来源：[Brad Frost - Atomic Design](https://atomicdesign.bradfrost.com/)

## 适用场景

- 设计系统从零建立
- 组件库设计
- 复杂界面的组件拆分
- 提升设计和代码的复用性

## 核心思想

把界面从小到大分五层，确保组件可复用、可组合：

```text
原子（Atoms）
  ↓ 组合
分子（Molecules）
  ↓ 组合
有机体（Organisms）
  ↓ 布局
模板（Templates）
  ↓ 填数据
页面（Pages）
```

## 五层定义

### 1. 原子（Atoms）

最小不可分割的 UI 单元

```text
- 按钮（Button）
- 输入框（Input）
- 标签（Label）
- 图标（Icon）
- 徽章（Badge）
- 分割线（Divider）
- 颜色 / 字体 / 间距（Tokens）
```

### 2. 分子（Molecules）

原子的简单组合，有独立功能

```text
- 搜索框 = 输入框 + 搜索按钮
- 表单字段 = 标签 + 输入框 + 错误提示
- 卡片头部 = 头像 + 名称 + 时间
- 面包屑 = 链接 + 分隔符
```

### 3. 有机体（Organisms）

分子的组合，构成页面区块

```text
- 导航栏 = Logo + 菜单 + 用户头像
- 数据表格 = 表头 + 行 + 分页 + 操作栏
- 表单 = 多个表单字段 + 提交按钮
- 商品列表 = 多个商品卡片
```

### 4. 模板（Templates）

有机体的布局框架，无真实数据

```text
- 列表页模板 = 顶部筛选 + 表格 + 分页
- 详情页模板 = 侧边栏 + 主内容区 + 操作栏
- 表单页模板 = 标题 + 字段组 + 提交区
```

### 5. 页面（Pages）

模板 + 真实数据 = 最终页面

```text
- 用户列表页 = 列表模板 + 真实用户数据
- 商品详情页 = 详情模板 + 真实商品数据
```

## 组件清单输出格式

```markdown
## 组件清单（Atomic Design）

### Atoms（原子）

| 名称 | 用途 | 变体 |
|------|------|------|
| Button | 触发动作 | primary / secondary / danger / text |
| Input | 文本输入 | default / disabled / error |
| Icon | 图标 | 24+ 图标 |
| Badge | 状态标签 | success / warning / danger / info |

### Molecules（分子）

| 名称 | 组成 | 用途 |
|------|------|------|
| SearchBox | Input + Button(Icon) | 搜索 |
| FormField | Label + Input + ErrorText | 表单字段 |
| CardHeader | Avatar + Title + Subtitle | 卡片头 |

### Organisms（有机体）

| 名称 | 组成 | 用途 |
|------|------|------|
| NavBar | Logo + Menu + UserAvatar | 顶部导航 |
| DataTable | TableHeader + Rows + Pagination | 数据表格 |
| LoginForm | 多个 FormField + Button | 登录表单 |

### Templates（模板）

| 名称 | 布局 | 用途 |
|------|------|------|
| ListPageTemplate | NavBar + Filter + DataTable + Pagination | 列表页 |
| DetailPageTemplate | NavBar + Sidebar + Content + Actions | 详情页 |

### Pages（页面）

| 名称 | 模板 | 数据 |
|------|------|------|
| UserListPage | ListPageTemplate | 用户数据 |
| ProductDetailPage | DetailPageTemplate | 商品数据 |
```

## 工作流程

```text
1. 列出所有页面（来自 page-structure）
2. 拆解每个页面到 Templates
3. 拆解 Templates 到 Organisms
4. 拆解 Organisms 到 Molecules
5. 拆解 Molecules 到 Atoms
6. 识别可复用部分（在多个页面出现的）
7. 输出组件清单
8. 转交前端实现组件库
```

## 使用规则

```text
- 设计时从原子开始，向上组合
- 每个组件单独管理（独立文件）
- 组件清单按层级标注（Atom/Molecule/Organism）
- 前端交接时说明哪些组件可以复用现有库，哪些需要新建
- 不要跨层级直接引用（页面不直接用原子）
```

## 质量自检

```text
□ 是否每个组件都标注了层级
□ 是否识别了可复用组件
□ Atoms 是否真的不可再分
□ Molecules 是否有独立功能
□ Organisms 是否构成完整区块
□ Templates 是否无真实数据
```

## 常见坑

1. **层级混乱**——把 Organism 当成 Molecule
2. **过度拆分**——把每个像素都拆成 Atom
3. **拆分不足**——把整个页面当成一个 Organism
4. **不识别复用**——多个页面用相同 Organism 但分别设计
5. **直接跨层引用**——页面直接调用 Atom，跳过 Template

## 配套模板

- `templates/component-inventory-template.md` — 组件清单模板

## 与其他 skill 的协作

```text
上游：
  page-structure → 提供页面拆分输入

平行：
  design-tokens → Atoms 的颜色/字体/间距
  component-states → 每个组件的状态

下游：
  design-handoff → 组件清单交给前端
```
