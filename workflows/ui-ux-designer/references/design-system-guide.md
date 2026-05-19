# 设计系统与交互设计实战指南

> 面向 APP / 小程序 / 网页产品的设计体系建设。

## 1. 设计系统分层

```text
┌─────────────────────────────────────────────────────────┐
│ Design System Architecture                               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Foundation Layer（基础层）                               │
│  ├── Color Tokens（颜色）                                │
│  ├── Typography（字体）                                  │
│  ├── Spacing（间距 4px 网格）                            │
│  ├── Elevation（阴影层级）                               │
│  ├── Border Radius                                       │
│  └── Motion（动效时长/缓动）                             │
│                                                          │
│  Component Layer（组件层）                                │
│  ├── Atoms: Button / Input / Icon / Badge                │
│  ├── Molecules: FormField / SearchBar / Card             │
│  └── Organisms: Header / Sidebar / DataTable             │
│                                                          │
│  Pattern Layer（模式层）                                  │
│  ├── Navigation Patterns                                 │
│  ├── Form Patterns                                       │
│  ├── Data Display Patterns                               │
│  └── Feedback Patterns                                   │
│                                                          │
│  Page Template Layer（页面模板层）                        │
│  ├── Dashboard Layout                                    │
│  ├── List-Detail Layout                                  │
│  ├── Form Wizard Layout                                  │
│  └── Auth Layout                                         │
└─────────────────────────────────────────────────────────┘
```

## 2. Design Token 规范

```json
{
  "color": {
    "primary": { "50": "#EFF6FF", "500": "#3B82F6", "900": "#1E3A5F" },
    "neutral": { "50": "#F9FAFB", "500": "#6B7280", "900": "#111827" },
    "success": { "500": "#10B981" },
    "warning": { "500": "#F59E0B" },
    "error": { "500": "#EF4444" }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px",
    "2xl": "48px"
  },
  "typography": {
    "heading-1": { "size": "32px", "weight": 700, "lineHeight": 1.25 },
    "heading-2": { "size": "24px", "weight": 600, "lineHeight": 1.3 },
    "body": { "size": "14px", "weight": 400, "lineHeight": 1.5 },
    "caption": { "size": "12px", "weight": 400, "lineHeight": 1.4 }
  },
  "radius": {
    "sm": "4px",
    "md": "8px",
    "lg": "12px",
    "full": "9999px"
  },
  "shadow": {
    "sm": "0 1px 2px rgba(0,0,0,0.05)",
    "md": "0 4px 6px rgba(0,0,0,0.1)",
    "lg": "0 10px 15px rgba(0,0,0,0.1)"
  }
}
```

## 3. 交互设计规范

### 状态设计（每个组件必须覆盖）

```text
7 种状态：
  1. Default（默认）
  2. Hover（悬停）
  3. Active/Pressed（按下）
  4. Focus（聚焦 - 键盘导航）
  5. Disabled（禁用）
  6. Loading（加载中）
  7. Error（错误）

页面级状态：
  1. 正常数据（有内容）
  2. 空状态（无数据 + 引导操作）
  3. 加载中（Skeleton / Spinner）
  4. 错误状态（失败 + 重试）
  5. 无权限（403 + 联系管理员）
  6. 网络异常（离线提示 + 缓存）
```

### 表单设计模式

```text
原则：
  - 标签在输入框上方（移动端友好）
  - 实时校验（离开焦点时）
  - 错误提示紧跟字段下方（红色）
  - 必填标星号
  - 提交按钮在表单最后
  - 长表单分步骤（Wizard）
  - 防重复提交（按钮 loading）
  - 自动保存草稿（长表单）

字段排序：
  1. 最常用/最容易填的在前
  2. 逻辑分组（个人信息/地址/支付）
  3. 可选字段折叠或放后面
```

### 反馈设计

```text
操作反馈时机：
  即时（<100ms）: 按钮状态变化/输入响应
  短暂（1~3s）: Toast 提示（成功/警告）
  持续: Loading 状态/进度条
  永久: 页面跳转/状态变更

Toast 使用规范：
  ✅ 成功操作确认（保存成功/删除成功）
  ✅ 非阻塞警告
  ❌ 不用于错误（错误用内联提示或 Modal）
  ❌ 不用于需要用户操作的信息

Modal 使用规范：
  ✅ 确认危险操作（删除/退出/覆盖）
  ✅ 需要用户做决定
  ❌ 不用于纯信息展示（用 Toast）
  ❌ 不嵌套 Modal
```

## 4. 响应式断点

```text
标准断点（Mobile First）：
  mobile:    < 640px   (默认)
  tablet:    640~1024px  (sm/md)
  desktop:   1024~1440px (lg)
  wide:      > 1440px    (xl/2xl)

布局策略：
  mobile: 单列，底部导航，全宽卡片
  tablet: 双列，侧边栏可收起
  desktop: 多列，固定侧边栏，弹性内容区
```

## 5. 无障碍设计清单

```text
视觉：
  □ 文本对比度 ≥ 4.5:1（正文）/ ≥ 3:1（大字）
  □ 不单独用颜色传递信息（配合图标/文字）
  □ 焦点指示器可见（Focus ring）
  □ 支持 200% 缩放不破坏布局

交互：
  □ 所有功能可用键盘操作
  □ Tab 顺序逻辑合理
  □ 可点击区域 ≥ 44×44px（移动端）
  □ 表单有关联 label
  □ 错误提示与字段关联（aria-describedby）

内容：
  □ 图片有 alt 文本
  □ 链接文本有意义（不用"点击这里"）
  □ 页面有合理标题层级（h1→h2→h3）
  □ 语言标注（lang 属性）
```

## 6. 设计交付清单

```text
交付给开发的内容：
  □ Figma 链接（开启 Dev Mode）
  □ Design Token 文件（JSON / CSS Variables）
  □ 组件状态完整（7种 + 响应式）
  □ 交互说明（动效/转场/手势）
  □ 空状态/错误状态/Loading 设计
  □ 移动端适配说明
  □ 切图标注（如非 Token 覆盖的间距）
  □ 图标 SVG 导出
  □ 字体文件（如有自定义字体）
```
