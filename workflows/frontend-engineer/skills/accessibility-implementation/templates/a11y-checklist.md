# 可访问性实现清单（WCAG 2.2 AA）

## 1. 项目信息

```text
项目：
WCAG 目标：AA
测试工具：axe-core / Lighthouse / NVDA / VoiceOver
负责人：
```

---

## 2. 语义化 HTML

```text
□ 用 button 不用 div + onclick
□ 用 a 不用 span 当链接
□ 用 h1~h6 标题层级（每页一个 h1）
□ 用 nav / main / aside / footer
□ 用 ul / ol / li 表示列表
□ 用 form / label / input
□ 用 table / th / td 表示数据
□ 用 dialog 表示模态（或 Radix）
```

---

## 3. ARIA

```text
□ icon-only 按钮：aria-label
□ 输入：aria-required / aria-invalid / aria-describedby
□ 模态：aria-modal / aria-labelledby / aria-describedby
□ 标签页：role="tablist" / aria-selected
□ 菜单：role="menu" / aria-orientation
□ 实时反馈：role="status" / role="alert" / aria-live
□ 折叠：aria-expanded
□ 切换：aria-pressed
□ 装饰图标：aria-hidden="true"
```

---

## 4. 键盘导航

| 控件 | 期望键盘 |
|---|---|
| Button / Link | Enter / Space 激活 |
| Modal | Esc 关闭，Tab 在内部循环 |
| Tabs | 左右键切换 tab |
| Menu | 上下键切换 item |
| Combobox | 上下键 + Enter 选 + Esc 关 |
| Tree | 左右键展开 / 折叠 |

```text
□ Tab 顺序合理
□ 焦点环可见
□ 不拦截 Tab
□ tabindex 不用正数
□ Skip Link 跳到主内容
□ 模态聚焦陷阱
□ 关闭模态焦点还原
```

---

## 5. 颜色与对比

| 检查 | 标准 |
|---|---|
| 文字（普通） | ≥ 4.5:1 |
| 文字（大字 ≥ 18pt 或 14pt 加粗） | ≥ 3:1 |
| UI 控件 / 图标 | ≥ 3:1 |
| 焦点环 | ≥ 3:1 |

```text
□ 不仅靠颜色（图标 + 文字）
□ 暗黑模式对比度
□ 用 WebAIM Contrast Checker 验证
```

---

## 6. 表单

```text
□ 每个 input 有 label（htmlFor / id）
□ 必填用 *（不仅靠颜色）+ aria-required
□ 错误：role="alert" + aria-invalid
□ 错误关联：aria-describedby
□ 错误后聚焦首个错误字段
□ autocomplete 属性
□ inputmode 移动端键盘类型
□ Enter 提交
□ 帮助文字关联
```

---

## 7. 移动端 / 触摸

```text
□ 点击区域 ≥ 24x24（WCAG 2.2 AA）
□ 推荐 ≥ 44x44
□ 间距 ≥ 8px
□ 不依赖 hover
□ 视口缩放允许
□ user-scalable=no 禁用
```

---

## 8. 动画

```text
□ prefers-reduced-motion 媒体查询
□ 减少动画时长 / 禁用
□ 自动播放视频可暂停
□ 闪烁 < 3 次/秒
```

---

## 9. 图片 / 媒体

```text
□ <img alt="描述">（装饰用 alt=""）
□ alt 不写 "图片 / image"
□ 复杂图（图表）有详细描述
□ <video> 有 caption
□ <audio> 有 transcript
□ SVG 有 <title>
```

---

## 10. 测试

### 自动化

```text
□ axe-core CI 集成
□ jest-axe 单元测试
□ Lighthouse Accessibility ≥ 95
```

### 手动

```text
□ 仅键盘走完所有流程
□ Chrome DevTools 检查焦点顺序
□ 缩放 200% 不出现横滚
□ NVDA（Windows）测试
□ VoiceOver（Mac）测试
□ 移动端 TalkBack / VoiceOver
```

---

## 11. 文档

```text
□ a11y 设计规范文档
□ 组件 Storybook 含 a11y addon
□ 已知问题清单
□ 残障用户反馈渠道
```

---

## 12. 自检

```text
□ 语义化 HTML
□ ARIA 完整
□ 键盘 100% 可达
□ 焦点环可见
□ 对比度 AA
□ 不仅靠颜色
□ 表单 label 关联
□ 错误 role="alert"
□ 模态焦点管理
□ 减少动画支持
□ 移动端点击区域
□ 自动化测试通过
□ 手动测试通过
□ 屏幕阅读器测试通过
```
