---
name: design-system-mapping
description: 对标参考成熟设计系统时使用。适用于复杂后台、SaaS、开发者工具的设计。优先参考 Material/HIG/Carbon/Ant Design/shadcn/Radix 等成熟系统，按本项目约束适配。
---

# 行业设计系统对标

## 适用场景

- 设计复杂后台 / SaaS / 开发者工具
- 表格表单密集页面
- 需要快速建立规范的项目
- 借鉴成熟系统的最佳实践

## 不适用场景

- C 端营销类（自由度高，过度参考会同质化）
- 品牌强烈的产品（应有独特视觉语言）

## 主流设计系统对比

| 系统 | 维护方 | 特点 | 适合场景 |
|------|--------|------|---------|
| **Material Design** | Google | 全平台体验、卡片化、阴影层级 | Android / Web / 跨平台 |
| **Apple HIG** | Apple | iOS/macOS 平台规范、Liquid Glass | iOS / macOS / iPad 应用 |
| **Fluent Design** | Microsoft | Windows 风格、动效丰富 | Windows / Office 类 |
| **Carbon** | IBM | 企业级、数据密集、可访问性强 | 企业 SaaS / 数据平台 |
| **Atlassian Design** | Atlassian | 协作类产品 | 协作工具 / 项目管理 |
| **Polaris** | Shopify | 电商 / 商家后台 | 商家工具 / 电商后台 |
| **Pajamas** | GitLab | 开发者工具 | 开发者平台 |
| **Ant Design** | 蚂蚁 | 中后台、表格表单完善 | 中文中后台 |
| **MUI** | Material UI | Material + React 实现 | React 项目 |
| **shadcn/ui** | shadcn | 复制粘贴式、Radix 底层 | 现代 Web 应用 |
| **Radix** | Modulz | 无样式组件、键盘 / ARIA | 自定义视觉 + 强可访问性 |
| **Tailwind UI** | Tailwind | Tailwind 预制组件 | Tailwind 项目 |
| **Tabler / AdminLTE** | 开源 | 后台管理模板 | 后台模板 |

## 选择指南

```text
项目类型 → 推荐对标

中文中后台 → Ant Design（首选）+ shadcn（视觉升级）
英文 SaaS → shadcn / Radix + 自定义视觉
企业级数据平台 → Carbon（可访问性 + 数据密集）
开发者工具 → Pajamas / GitHub 风格
电商/商家 → Polaris（电商场景成熟）
移动 App → 平台原生（HIG / Material）
跨平台一致 → Material Design 3
```

## 对标方法

```text
1. 不要全盘照搬
   - 借鉴模式和方法论
   - 不抄具体视觉风格

2. 关注成熟模式
   - 表单：标签位置、错误提示、必填标记
   - 表格：排序、筛选、分页交互
   - 导航：层级结构、当前位置高亮
   - 反馈：Toast / Alert / Banner 用法

3. 关注可访问性
   - 大厂系统的 ARIA 实现
   - 键盘交互模式
   - 焦点管理

4. 关注组件 API 设计
   - 命名约定
   - 属性结构
   - 变体（variant）系统
```

## 常见模式对照

### 按钮变体

```text
Material：FAB / Filled / Tonal / Outlined / Text
Apple：Filled / Bordered / Plain
Ant：Primary / Default / Dashed / Text / Link
shadcn：Default / Destructive / Outline / Secondary / Ghost / Link
```

### 表单字段标签

```text
顶部标签：Material / Ant Design / 大部分
左侧标签：Carbon / 数据密集场景
浮动标签：Material 早期 / 已不推荐
```

### 表格选中

```text
左侧复选框：所有主流系统
点击行选中：Notion / 现代工具
Shift 多选：Carbon / Ant
```

### 反馈

```text
Toast：Material（Snackbar）/ Ant（Message）/ shadcn（Sonner）
Modal：所有系统
Drawer：Ant / Carbon / 大屏侧边操作
Banner：GitLab / Polaris
```

## 输出格式

```markdown
## 设计系统对标：[页面/功能]

### 主参考系统
[选用的系统] + 理由

### 借鉴的模式
1. [模式 1] 来自 [系统] - 适配方式：[本项目如何调整]
2. [模式 2] 来自 [系统] - 适配方式：...

### 不采纳的部分
- [原系统的某个设计] - 不适合的原因：...

### 视觉调整
- 颜色：使用本项目品牌色，不用原系统颜色
- 字体：[本项目字体]
- 圆角：[本项目圆角规范]

### 组件 API 命名
- 按钮变体：primary / secondary / danger / ghost（参考 shadcn）
- 表格列：title / dataIndex / render（参考 Ant）

### 可访问性策略
- 键盘交互：参考 Radix
- ARIA 属性：参考 Carbon
```

## 工作流程

```text
1. 识别项目类型和场景
2. 选择主参考系统（1~2 个）
3. 列出值得借鉴的模式
4. 列出不采纳的部分（避免照抄）
5. 结合本项目品牌做视觉调整
6. 输出对标说明
```

## 质量自检

```text
□ 主参考系统是否合适
□ 是否只借鉴模式不抄视觉
□ 是否考虑了多个系统的优点
□ 是否结合本项目品牌做调整
□ 可访问性策略是否参考了强系统（Carbon/Radix）
```

## 常见坑

1. **全盘照抄**——视觉、布局、组件全部复制 → 失去品牌
2. **只看一家**——错过其他系统的好做法
3. **不考虑场景**——SaaS 用 Material 风格 → 不专业
4. **忽略可访问性**——参考的系统可访问性弱
5. **追新弃老**——只看 shadcn 不看 Ant 的成熟
6. **不调整**——直接套模板 → 同质化

## 配套模板

- `templates/design-system-benchmark-template.md` — 系统对比表 + 模式对照表

## 与其他 skill 的协作

```text
上游：
  visual-style → 决定整体视觉风格

平行：
  enterprise-patterns → 借鉴具体模式
  atomic-design → 组件分层参考
  accessibility → 可访问性参考

下游：
  design-handoff → 标注组件来源（"参考 shadcn"）
```
