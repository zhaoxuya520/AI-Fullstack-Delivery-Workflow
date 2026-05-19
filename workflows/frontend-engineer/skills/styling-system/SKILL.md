---
name: styling-system
description: 选择和实现样式方案时使用。覆盖 Tailwind / CSS Modules / CSS-in-JS（styled-components / Emotion）/ vanilla-extract / UnoCSS / Sass。融合设计 Token + 主题 + 暗黑模式 + 响应式。
---

# 样式系统（Styling System）

参考来源：Tailwind CSS 官方、shadcn/ui 实践、Stripe / Linear 设计系统、CSS Variables 规范、Brad Frost 设计 Token。

## 适用场景

- 新项目样式方案选型
- 设计 Token 体系建立
- 主题切换（亮 / 暗）
- 响应式实现
- 组件样式封装
- CSS 性能优化

## 核心原则

```text
1. 设计 Token 优先
   颜色 / 间距 / 字体 / 圆角全用变量

2. 一种样式方案
   不要 Tailwind + CSS-in-JS 混用

3. 局部作用域
   避免全局污染（CSS Modules / Tailwind / CSS-in-JS）

4. 响应式 mobile-first
   小屏先写，大屏覆盖

5. 暗黑模式从一开始考虑
   用 CSS 变量切换

6. 不写魔术值
   不要 padding: 17px，要 padding: var(--space-4)

7. 性能感知
   - CSS-in-JS 运行时开销
   - Tailwind + PurgeCSS 包小
   - vanilla-extract 编译时

8. 动画用变换不用 layout 属性
   transform / opacity > top / left / width
```

## 样式方案对比

| 方案 | 类型 | 包大小 | 类型安全 | 主题切换 | 适合 |
|---|---|---|---|---|---|
| **Tailwind CSS** | 原子化 | 小（PurgeCSS）| ❌ | CSS 变量 | 主流首选 |
| **UnoCSS** | 原子化 | 极小 | ❌ | CSS 变量 | Vue/Nuxt |
| **CSS Modules** | 局部 | 中 | 部分 | CSS 变量 | 简单可靠 |
| **styled-components** | CSS-in-JS | 大（运行时）| TS | props 动态 | 老牌 |
| **Emotion** | CSS-in-JS | 中 | TS | props 动态 | 灵活 |
| **vanilla-extract** | 编译时 CSS-in-JS | 小 | 强 TS | 主题 | 类型安全 |
| **Linaria** | 编译时 | 小 | TS | 静态 | 性能 |
| **Sass / Less** | 预处理 | 中 | ❌ | 变量 | 老项目 |

### 推荐组合

```text
React 新项目（推荐）：
  Tailwind CSS + shadcn/ui + Radix UI
  暗黑模式 + 主题切换全靠 CSS 变量

Vue 3 新项目（推荐）：
  UnoCSS / Tailwind + Element Plus / Naive UI

设计系统强（自有库）：
  vanilla-extract + 自有 Token + Headless UI

老项目兼容：
  CSS Modules + Sass

避免：
  ❌ Tailwind + styled-components 混用
  ❌ inline style 大量
  ❌ 全局 CSS 不限作用域
```

## 设计 Token 体系

```css
/* tokens.css */
:root {
  /* Colors - Semantic */
  --color-primary: hsl(220, 90%, 56%);
  --color-primary-foreground: hsl(0, 0%, 100%);
  --color-secondary: hsl(220, 14%, 96%);
  --color-success: hsl(142, 76%, 36%);
  --color-warning: hsl(38, 92%, 50%);
  --color-danger: hsl(0, 84%, 60%);
  --color-muted: hsl(220, 14%, 96%);
  --color-foreground: hsl(220, 9%, 9%);
  --color-background: hsl(0, 0%, 100%);
  --color-border: hsl(220, 13%, 91%);
  
  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  --space-12: 48px;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --font-size-xs: 12px;
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 18px;
  --font-size-xl: 20px;
  --font-size-2xl: 24px;
  
  /* Border */
  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --radius-xl: 12px;
  --radius-full: 9999px;
  
  /* Shadow */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
  
  /* Animation */
  --duration-fast: 150ms;
  --duration-normal: 200ms;
  --duration-slow: 300ms;
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  
  /* Layout */
  --container-max: 1280px;
  --header-height: 64px;
  --sidebar-width: 240px;
  --z-modal: 50;
  --z-toast: 60;
  --z-tooltip: 70;
}

/* Dark mode */
[data-theme='dark'] {
  --color-foreground: hsl(220, 9%, 95%);
  --color-background: hsl(220, 9%, 9%);
  --color-muted: hsl(220, 9%, 15%);
  --color-border: hsl(220, 9%, 20%);
}
```

## Tailwind CSS 实战

```javascript
// tailwind.config.js
import { fontFamily } from 'tailwindcss/defaultTheme';

/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ['class'],  // 用 class 切换
  content: ['./src/**/*.{ts,tsx,vue}'],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: { '2xl': '1400px' },
    },
    extend: {
      colors: {
        // 用 CSS 变量（与 Token 对接）
        primary: {
          DEFAULT: 'hsl(var(--color-primary))',
          foreground: 'hsl(var(--color-primary-foreground))',
        },
        background: 'hsl(var(--color-background))',
        foreground: 'hsl(var(--color-foreground))',
        muted: 'hsl(var(--color-muted))',
        border: 'hsl(var(--color-border))',
      },
      fontFamily: {
        sans: ['Inter', ...fontFamily.sans],
      },
      borderRadius: {
        lg: 'var(--radius-lg)',
        md: 'var(--radius-md)',
        sm: 'var(--radius-sm)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('tailwindcss-animate'),
  ],
};
```

```typescript
// 组件中
<button className="
  inline-flex items-center justify-center
  px-4 py-2 rounded-md
  bg-primary text-primary-foreground
  hover:bg-primary/90
  focus-visible:ring-2 focus-visible:ring-ring
  disabled:opacity-50 disabled:cursor-not-allowed
  transition-colors
">
  Click me
</button>
```

## class-variance-authority（cva）模式

```typescript
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:ring-2',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        sm: 'h-8 px-3 text-xs',
        default: 'h-9 px-4 text-sm',
        lg: 'h-10 px-8 text-base',
        icon: 'h-9 w-9',
      },
    },
    defaultVariants: { variant: 'default', size: 'default' },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ className, variant, size, ...props }: ButtonProps) {
  return <button className={cn(buttonVariants({ variant, size }), className)} {...props} />;
}
```

## CSS Modules（简单可靠）

```typescript
// Button.module.css
.button {
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  background: var(--color-primary);
  color: var(--color-primary-foreground);
  transition: background var(--duration-normal) var(--ease-out);
}

.button:hover { background: hsl(220, 90%, 50%); }
.button.destructive { background: var(--color-danger); }
.button.lg { padding: var(--space-3) var(--space-6); }

// Button.tsx
import styles from './Button.module.css';
import { clsx } from 'clsx';

export function Button({ variant = 'default', size = 'md', className, children }) {
  return (
    <button className={clsx(styles.button, styles[variant], styles[size], className)}>
      {children}
    </button>
  );
}
```

## vanilla-extract（类型安全 + 编译时）

```typescript
// button.css.ts
import { style, styleVariants } from '@vanilla-extract/css';
import { vars } from './theme.css';

const base = style({
  padding: `${vars.space[2]} ${vars.space[4]}`,
  borderRadius: vars.radius.md,
  transition: `background ${vars.duration.normal} ${vars.ease.out}`,
});

export const button = styleVariants({
  default: [base, { background: vars.color.primary }],
  destructive: [base, { background: vars.color.danger }],
  outline: [base, { border: `1px solid ${vars.color.border}` }],
});
```

## 暗黑模式实现

### 方案 A：CSS 变量 + class 切换（推荐）

```css
:root { --color-bg: white; --color-fg: black; }
[data-theme='dark'] { --color-bg: #0a0a0a; --color-fg: #f5f5f5; }

.app { background: var(--color-bg); color: var(--color-fg); }
```

```typescript
// 主题切换 hook
function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  
  useEffect(() => {
    const saved = localStorage.getItem('theme') as 'light' | 'dark';
    const system = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const initial = saved ?? system;
    setTheme(initial);
    document.documentElement.dataset.theme = initial;
  }, []);
  
  const toggle = () => {
    const next = theme === 'light' ? 'dark' : 'light';
    setTheme(next);
    document.documentElement.dataset.theme = next;
    localStorage.setItem('theme', next);
  };
  
  return { theme, toggle };
}
```

### 方案 B：next-themes（Next.js）

```typescript
import { ThemeProvider } from 'next-themes';

<ThemeProvider attribute="class" defaultTheme="system" enableSystem>
  <App />
</ThemeProvider>

// 用法
const { theme, setTheme } = useTheme();
```

## 响应式策略

```text
Mobile-First：
  默认样式 → 手机
  sm: ≥ 640px
  md: ≥ 768px
  lg: ≥ 1024px
  xl: ≥ 1280px
  2xl: ≥ 1536px

Tailwind 范式：
  <div class="text-sm md:text-base lg:text-lg">
  
CSS：
  .title { font-size: 14px; }
  @media (min-width: 768px) { .title { font-size: 16px; } }
  @media (min-width: 1024px) { .title { font-size: 18px; } }
```

## 工作流程

```text
1. 选样式方案（基于团队 + 项目）
   ↓
2. 建立设计 Token（与 UI/UX 同步）
   - 颜色 / 间距 / 字体 / 圆角 / 阴影
   ↓
3. 配置框架（Tailwind / Postcss）
   ↓
4. 暗黑模式从一开始
   ↓
5. 实现组件样式
   - 用 Token 不写魔术值
   ↓
6. 响应式（mobile-first）
   ↓
7. 性能验证
   - PurgeCSS / Tree-shake
   - 包大小
```

## 配套模板

- `templates/styling-system-template.md` — 设计 Token + Tailwind 配置 + 暗黑模式 + 响应式

## 质量自检

```text
□ 一种样式方案
□ 设计 Token 完整（与 UI/UX 同步）
□ 不写魔术值（颜色 / 间距 / 圆角）
□ 暗黑模式支持
□ 响应式 mobile-first
□ 焦点环可见（focus-visible）
□ 颜色对比度 ≥ 4.5:1
□ 动画 transform / opacity（不用 layout）
□ 减少 reflow
□ Tailwind / UnoCSS PurgeCSS 启用
□ 包大小（CSS < 50KB）
□ 不全局污染
□ 不混合方案
```

## 常见坑

1. **混合方案**——Tailwind + styled-components 同存
2. **写死颜色**——`color: #4287f5` 而非 token
3. **不暗黑**——后期重构成本大
4. **CSS-in-JS 运行时开销**——影响渲染性能
5. **不 PurgeCSS**——Tailwind 包 3MB
6. **inline style 滥用**——不可复用
7. **!important 滥用**——级联崩
8. **z-index 魔术值**——`z-index: 99999`
9. **动画用 width / top**——大量 reflow
10. **focus 不可见**——a11y 失败
11. **响应式 desktop-first**——移动端样式难
12. **CSS 变量不用 hsl**——无法 alpha 调整
13. **图标用 png**——应该用 SVG
14. **大字体未做 fallback**——FOUT / FOIT

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer 工作流 design-tokens skill → Token 来源
  ui-ux-designer atomic-design → 组件层级

下游：
  component-architecture → 组件接受 className
  accessibility-implementation → 焦点 / 对比度
  performance-optimization → 包大小
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 样式方案对比
- ui-ux-designer 工作流 design-tokens skill
