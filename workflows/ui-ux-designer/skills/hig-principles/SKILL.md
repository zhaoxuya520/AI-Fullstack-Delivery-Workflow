---
name: hig-principles
description: 设计移动 App 或多平台产品时使用。适用于 iOS/Android/桌面应用的平台原则适配。优先使用 Apple HIG 四原则 + Material Design 3 原则 + 平台规范。
---

# 平台设计原则（HIG）

参考来源：[Apple Human Interface Guidelines](https://developer.apple.com/design/)、[Material Design 3](https://m3.material.io/)

## 适用场景

- 移动 App 设计（iOS / Android）
- 桌面应用（macOS / Windows）
- 跨平台一致性
- 平台原生体验

## 不适用场景

- 纯 Web 应用（用 visual-style + responsive-design）
- 内部工具（不需要平台原生感）

## Apple HIG 四原则

参考来源：[Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)

### 1. 清晰（Clarity）

```text
"文字可读、图标可识别、装饰不干扰功能"

具体：
  - 字号足够大（最小 11pt iOS / 14sp Android）
  - 图标含义明确，不需要猜
  - 负空间引导注意力
  - 颜色和字体引导层级
```

### 2. 顺从（Deference）

```text
"UI 服务于内容，不抢夺注意力"

具体：
  - 内容优先，界面退后
  - 透明 / 模糊背景（让内容透出）
  - 极简的 chrome（导航栏、工具栏）
  - 不用过度装饰
```

### 3. 深度（Depth）

```text
"用层级、动效、阴影传达空间关系"

具体：
  - 模态层级（push / present）
  - 视差 / 视差滚动
  - 阴影表达悬浮
  - 过渡动画表达关系
```

### 4. 一致性（Consistency）

```text
"遵循平台惯例（导航模式、手势、图标含义）"

具体：
  - 用平台原生组件（不要自造）
  - 遵循平台手势（左滑返回 / 下拉刷新）
  - 系统图标含义统一
  - 不要让 Android 看起来像 iOS
```

## Material Design 3 原则

参考来源：[Material Design 3](https://m3.material.io/)

```text
1. Adaptive（自适应）
   - 大小屏适配
   - 浅色/暗黑模式
   - 用户偏好（动效减少 / 大字号）

2. Expressive（表达性）
   - 通过颜色 / 字体 / 形状传达品牌
   - Dynamic Color（基于壁纸生成主题）
   - 个性化主题

3. Useful（有用）
   - 解决真实问题
   - 不是为了好看而存在

4. Accessible（无障碍）
   - 默认可访问
   - 键盘 / 触控 / 语音支持

5. Responsive（响应）
   - 用户操作有即时反馈
   - 状态变化平滑过渡
```

## 平台对比

```text
| 维度 | iOS | Android | macOS | Windows |
|------|-----|---------|-------|---------|
| 默认字体 | SF Pro | Roboto | SF Pro | Segoe UI |
| 触控目标 | 44×44pt | 48×48dp | - | - |
| 圆角 | 中等（Liquid Glass 大） | 中等 | 小 | 小 |
| 导航 | Tab Bar / Nav Bar | Bottom Nav / Drawer | Toolbar / Sidebar | Ribbon |
| 返回手势 | 左滑边缘 | 系统返回键 / 边缘 | 标题栏 < | 标题栏 ← |
| 主题 | 浅/深 / Liquid Glass | 浅/深 / Dynamic Color | 浅/深 | 浅/深 |
```

## iOS 26 Liquid Glass

```text
2025 年起 Apple 推出 Liquid Glass 设计语言：

特点：
  - 半透明 + 模糊背景
  - 流畅响应触控
  - 跨平台一致（iOS/iPadOS/macOS/watchOS/tvOS）
  - 强调深度和层次

设计要素：
  - 玻璃质感的卡片和导航
  - 内容透过界面元素若隐若现
  - 触控时实时反馈（流体形变）
  - 大圆角（16~24pt）
```

## 移动端常见模式

### iOS 模式

```text
导航：
  - Tab Bar（底部，最多 5 项）
  - Navigation Bar（顶部，含返回）
  - 模态（present from bottom）
  - 大标题（Large Title）

手势：
  - 左滑返回（屏幕边缘）
  - 下拉刷新
  - 长按预览（3D Touch / Haptic Touch）

交互：
  - Action Sheet（底部弹起选项）
  - Alert（中央对话框）
  - Toast（不推荐，用 Banner）
```

### Android 模式

```text
导航：
  - Bottom Navigation（最多 5 项）
  - Top App Bar（菜单按钮 / 操作）
  - Navigation Drawer（侧边抽屉）
  - FAB（Floating Action Button）

手势：
  - 边缘左滑返回（系统手势）
  - 下拉刷新
  - 长按多选

交互：
  - Bottom Sheet（底部上拉）
  - Snackbar（底部提示，含撤销）
  - Material Dialog
```

## 输出格式

```markdown
## 平台设计：[App 名称]

### 目标平台
- iOS（iOS 26+）
- Android（Android 13+）

### 应用的原则

iOS：
  ✅ 清晰：用 SF Pro，字号 ≥ 17pt
  ✅ 顺从：列表项用透明背景
  ✅ 深度：模态采用 sheet 样式
  ✅ 一致性：用原生 Tab Bar，不自造

Android：
  ✅ Adaptive：支持暗黑 + Dynamic Color
  ✅ Expressive：品牌色作为种子色
  ✅ 用 Material 3 组件
  ✅ Bottom Navigation（4 项）

### 平台差异处理

| 元素 | iOS | Android |
|------|-----|---------|
| 顶部导航 | Navigation Bar 大标题 | Top App Bar |
| 底部导航 | Tab Bar | Bottom Navigation |
| 列表项操作 | 左滑显示 | 长按显示菜单 |
| 删除确认 | Action Sheet | Material Dialog |
| 提示 | Banner（顶部） | Snackbar（底部） |

### 共享设计语言
- 品牌色：[#XXXXXX]
- 主要字体：[西文/中文]
- 圆角：12pt（iOS）/ 12dp（Android）
```

## 工作流程

```text
1. 确定目标平台
2. 选择主导原则（HIG / Material）
3. 列出平台特定模式
4. 共享设计语言（品牌色 / 字体）
5. 列出平台差异处理
6. 输出平台设计说明
7. 转交移动端开发
```

## 质量自检

```text
□ 是否选对了平台原则
□ 是否用了平台原生组件
□ 是否遵循平台手势
□ 触控目标是否符合规范（44pt iOS / 48dp Android）
□ 是否处理了平台差异
□ 是否考虑暗黑模式
□ 是否考虑系统级偏好（大字号 / 减少动画）
```

## 常见坑

1. **iOS 当 Android 设计**——失去原生感
2. **强行统一**——iOS 强加 FAB 或 Android 强加 Tab Bar
3. **不用原生组件**——自造组件用户不熟悉
4. **忽略手势**——iOS 没做左滑返回
5. **触控目标太小**——< 44pt 用户难点
6. **不支持暗黑**——iOS 用户大量使用暗黑
7. **不响应系统偏好**——大字号设置后布局崩溃

## 配套模板

- `templates/ios-design-template.md` — iOS 设计模板
- `templates/android-design-template.md` — Android 设计模板
- `templates/cross-platform-template.md` — 跨平台模板

## 与其他 skill 的协作

```text
上游：
  product-manager 的需求和目标平台

平行：
  visual-style → 视觉风格
  responsive-design → 不同屏幕尺寸
  accessibility → 系统级偏好

下游：
  design-handoff → 平台特定要求交接
  转交移动端前端工程师
```
