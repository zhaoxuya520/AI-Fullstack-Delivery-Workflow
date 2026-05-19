---
name: design-handoff
description: 把设计交接给前端时使用。适用于设计完成后的交付、设计审查通过后的执行准备。优先使用 Figma DevMode 实践 + 交接清单 + 待确认问题。
---

# 设计交接

参考来源：[Figma Developer Handoff Guide](https://www.figma.com/best-practices/guide-to-developer-handoff/)、[figr.design Developer Handoff Playbook](https://figr.design/blog/developer-handoff-playbook-tools-templates-and-best-practices-for-cross-functional-teams)

## 适用场景

- 设计稿完成后给前端
- 设计变更后的同步
- 跨团队协作的设计交接

## 核心原则

```text
"Design handoff is where most product work breaks down."

设计交接是项目失败的高发区。

避免：
  - 设计师扔过去就不管
  - 前端一边问一边做
  - 关键决策没传达
  - 状态/响应式/可访问性缺失
```

## 交接三要素

```text
1. 产物（Artifact）
   - Figma 文件 / 设计说明文档 / Design Tokens
   - 可直接使用的格式

2. 上下文（Context）
   - 设计意图（为什么这样做）
   - 决策背景（哪些是硬要求，哪些可灵活）
   - 已知约束

3. 验收标准（Acceptance）
   - 前端如何判断实现符合设计意图
   - 哪些状态必须实现
   - 不合格时的退回机制
```

## 完整交接清单

### 页面层面

```text
□ 页面清单（每个页面的目标和入口）
□ 用户流程（页面间跳转逻辑）
□ 路由说明（URL 设计）
□ 进入条件（权限 / 登录状态）
```

### 组件层面

```text
□ 组件清单（按 Atomic Design 分层）
□ 每个组件的状态（来自 component-states）
  - 默认/悬停/聚焦/禁用/加载/错误/空/权限
□ 组件变体（primary/secondary/danger...）
□ 复用关系（哪些组件多页面共用）
```

### 视觉层面

```text
□ Design Tokens（JSON 文件或 Figma Variables）
  - 颜色 / 字体 / 间距 / 圆角 / 阴影
□ 视觉风格说明（来自 visual-style）
□ 图标资源（SVG 优先）
□ 图片资源（含 retina @2x/@3x）
```

### 交互层面

```text
□ 交互规则（点击/悬停/拖拽行为）
□ 动画说明（时长 / 缓动函数）
□ 反馈机制（Toast / 对话框 / 内联提示）
□ 键盘交互（快捷键 / Tab 顺序）
```

### 响应式层面

```text
□ 断点说明（来自 responsive-design）
□ 每个断点的布局变化
□ 内容降级策略
□ 触控目标尺寸（移动端）
```

### 可访问性层面

```text
□ ARIA 属性要求（aria-label/role 等）
□ 键盘导航顺序
□ 焦点状态
□ 对比度报告
□ 屏幕阅读器要求
```

### 数据层面

```text
□ 字段需求（每个组件需要的数据）
□ 数据格式（日期/数字/货币）
□ 空值处理（缺失字段如何展示）
□ 数据来源（API / 本地状态）
```

## 交接说明文档模板

```markdown
# 设计交接：[功能/页面名]

## 基本信息

- 设计版本：v1.2
- 交接日期：YYYY-MM-DD
- 设计文件：[Figma 链接]
- Design Tokens：[JSON 文件链接]
- 联系人：UI/UX 设计工作流

## 1. 页面清单

| 页面 | 路由 | 目标 | 入口 | 权限 |
|------|------|------|------|------|
| 用户列表 | /users | 管理用户 | 顶部导航 | admin |
| 用户详情 | /users/:id | 查看/编辑 | 列表点击 | admin |

## 2. 用户流程

[Mermaid 流程图]

## 3. 组件清单

### Atoms
- Button（primary/secondary/danger/text）
- Input（default/disabled/error）
- Badge（success/warning/danger）

### Molecules
- SearchBox（搜索框）
- FormField（表单字段）

### Organisms
- DataTable（数据表格）
- LoginForm（登录表单）

### 复用
- DataTable 在 [用户列表/订单列表/商品列表] 复用

## 4. 状态清单

[每个组件的完整状态表]

## 5. 设计 Tokens

[JSON 文件或链接]

## 6. 响应式

[断点 + 布局变化]

## 7. 可访问性

[ARIA / 键盘 / 对比度要求]

## 8. 交互动画

| 元素 | 触发 | 动画 | 时长 |
|------|------|------|------|
| 模态框 | 打开 | 淡入 + 缩放 | 200ms |
| Toast | 显示 | 从右滑入 | 300ms |

## 9. 待确认问题

- [ ] Q1: 表格行内编辑保存后是否显示成功提示？
- [ ] Q2: 移动端是否支持表格行操作？

## 10. 验收标准

- [ ] 所有页面状态完整实现（默认/加载/错误/空）
- [ ] 响应式在 320px / 768px / 1440px 验证
- [ ] 可访问性通过 axe DevTools
- [ ] Tokens 与设计一致
```

## Figma DevMode 实践

```text
启用 DevMode：
  - 给前端提供"开发者模式"视图
  - 可复制 CSS / 距离 / 颜色
  - 可标注组件 status（Ready for Dev / In Progress）

最佳实践：
  - 每个页面打"Ready for Dev"标签
  - 关键交互写注释（不是 sticky note）
  - 使用 Variables 而不是硬编码颜色
  - 使用 Auto Layout（接近真实布局）
  - 组件命名清晰（Button/Primary 而非 Rectangle 36）
```

## 工作流程

```text
1. 设计完成 + 通过可用性评审
2. 按交接清单逐项准备产物
3. 写交接说明文档
4. 列出待确认问题
5. 与前端工作流走一遍交接（解释决策）
6. 前端按验收标准检查
7. 不合格 → 退回修复
8. 合格 → 前端开始实现
```

## 质量自检

```text
□ 页面清单完整
□ 组件清单按 Atomic 分层
□ 每个组件有完整状态
□ Design Tokens 已输出
□ 响应式规则明确
□ 可访问性要求列出
□ 待确认问题已标注
□ 验收标准可执行
```

## 常见坑

1. **只丢 Figma 文件**——没有上下文，前端要猜
2. **状态缺失**——只画了默认状态
3. **响应式没说明**——前端自己想象
4. **可访问性没要求**——上线后被审计才知道
5. **待确认问题没列**——前端做了一半发现问题
6. **没有验收标准**——做完不知道对不对
7. **Tokens 在 Figma 里有，文档没**——前端用不上

## 配套模板

- `templates/design-handoff-template.md` — 交接说明文档 + 交接清单检查表

## 与其他 skill 的协作

```text
上游：
  所有设计 skills 完成后

下游：
  转交前端工程师 → 实现页面
  转交 API 设计 → 字段需求
  转交 QA → 测试输入
```
