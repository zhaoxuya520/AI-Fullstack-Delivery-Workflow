# 样式系统配置模板

## 1. 项目信息

```text
样式方案：Tailwind / UnoCSS / CSS Modules / vanilla-extract
组件库：shadcn/ui / Element Plus / 等
框架：React / Vue / Angular / Svelte
负责人：
```

---

## 2. 设计 Token 来源

```text
□ Figma 变量（与 UI/UX 同步）
□ Token Studio 导出
□ 自有设计系统
```

---

## 3. 颜色系统

| Token | Light | Dark | 用途 |
|---|---|---|---|
| --color-primary |  |  | 主色 |
| --color-secondary |  |  | 次色 |
| --color-success |  |  | 成功 |
| --color-warning |  |  | 警告 |
| --color-danger |  |  | 危险 |
| --color-foreground |  |  | 文字 |
| --color-background |  |  | 背景 |
| --color-muted |  |  | 弱化 |
| --color-border |  |  | 边框 |

---

## 4. 间距系统

```text
--space-1: 4px
--space-2: 8px
--space-3: 12px
--space-4: 16px
--space-6: 24px
--space-8: 32px
--space-12: 48px
--space-16: 64px
```

---

## 5. 字体

```text
--font-sans: ...
--font-mono: ...

--font-size-xs: 12px
--font-size-sm: 14px
--font-size-base: 16px
--font-size-lg: 18px
--font-size-xl: 20px
--font-size-2xl: 24px
--font-size-3xl: 30px

--leading-tight: 1.25
--leading-normal: 1.5
--leading-loose: 1.75
```

---

## 6. 圆角 + 阴影

```text
--radius-sm: 4px
--radius-md: 6px
--radius-lg: 8px
--radius-xl: 12px
--radius-full: 9999px

--shadow-sm
--shadow-md
--shadow-lg
--shadow-xl
```

---

## 7. 响应式断点

```text
sm: 640px       手机横屏
md: 768px       平板
lg: 1024px      笔记本
xl: 1280px      桌面
2xl: 1536px     大屏
```

---

## 8. 暗黑模式

```text
□ 实现方式：data-theme / class
□ 切换方案：next-themes / 自实现
□ 默认：跟随系统
□ 持久化：localStorage
□ 所有 token 有 light + dark 版本
□ 图片 / 图标暗黑适配
```

---

## 9. Z-index 体系

```text
--z-dropdown: 10
--z-sticky: 20
--z-modal: 50
--z-toast: 60
--z-tooltip: 70

不要用魔术值（如 99999）
```

---

## 10. 动画

```text
--duration-fast: 150ms
--duration-normal: 200ms
--duration-slow: 300ms

--ease-out: cubic-bezier(0.16, 1, 0.3, 1)
--ease-in: cubic-bezier(0.7, 0, 0.84, 0)

只用 transform / opacity 做动画
不用 width / height / top / left
```

---

## 11. 工程化

```text
□ Linter：stylelint
□ Formatter：prettier
□ 命名规范：BEM / Tailwind atomic
□ PurgeCSS / Tree-shake 启用
□ Critical CSS 提取（首屏）
□ Source Map 生产关闭
```

---

## 12. 性能验证

```text
□ CSS 总大小 < 50 KB（gzip）
□ Critical CSS < 14 KB
□ 无 unused CSS
□ 无 !important（除非必要）
□ 字体加载优化（font-display: swap）
□ 图片优化（webp/avif）
```

---

## 13. 自检

```text
□ 一种样式方案
□ Token 完整（颜色/间距/字体/圆角/阴影/动画/z）
□ 暗黑模式
□ 响应式 mobile-first
□ 焦点环
□ 对比度 ≥ 4.5:1
□ 动画用 transform/opacity
□ 包大小达标
□ 不混合方案
□ 不写魔术值
```
