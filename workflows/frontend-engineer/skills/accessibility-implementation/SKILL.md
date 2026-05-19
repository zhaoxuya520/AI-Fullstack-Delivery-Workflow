---
name: accessibility-implementation
description: 实现可访问性（无障碍）时使用。覆盖 WCAG 2.2 AA / ARIA / 键盘导航 / 屏幕阅读器 / 颜色对比 / 焦点管理。融合 React Aria / Radix UI / Headless UI 实践 + axe-core 自动化测试。
---

# 可访问性实现（Accessibility Implementation）

参考来源：W3C WCAG 2.2 (2024)、WAI-ARIA Authoring Practices、MDN Accessibility、Adobe React Aria、Radix UI a11y、deque axe-core。

## 适用场景

- 所有面向用户的界面
- 表单 / 模态 / 菜单 / 表格 / 标签
- 键盘可操作
- 屏幕阅读器友好
- 视觉障碍（对比度 / 字体）
- 运动障碍（点击区域 / 减少动画）
- 认知障碍（清晰文案 / 错误恢复）

## 核心原则

```text
1. 不是 nice-to-have
   - 法律要求（ADA、欧盟无障碍法案）
   - 占用户 15%+
   - SEO 受益

2. 默认无障碍（不是事后补救）
   - 用语义化 HTML
   - 用 Headless 库（自带 a11y）

3. 键盘可操作 = 屏幕阅读器友好的第一步
   - Tab 导航
   - Enter / Space 激活
   - Esc 取消
   - 方向键（菜单 / 标签）

4. 不仅靠颜色传达信息
   - 错误：红色 + ✗ 图标 + 文字
   - 不止颜色

5. 焦点环必须可见
   - 不要 outline: none

6. 测试三层
   - 自动（axe-core）
   - 手动（键盘 + 缩放）
   - 真实工具（NVDA / VoiceOver）
```

## WCAG 2.2 关键标准（AA 级）

| 标准 | 要求 |
|---|---|
| 1.3.1 Info and Relationships | 信息和结构能被程序理解（语义化 HTML / ARIA）|
| 1.4.3 Contrast (Minimum) | 文字对比度 ≥ 4.5:1（大字 ≥ 3:1）|
| 1.4.10 Reflow | 320px 宽度可用（不需要横滚）|
| 1.4.11 Non-text Contrast | UI 控件对比度 ≥ 3:1 |
| 2.1.1 Keyboard | 全功能键盘可达 |
| 2.4.3 Focus Order | 焦点顺序合理 |
| 2.4.7 Focus Visible | 焦点可见 |
| 2.5.5 Target Size (AAA → 2.2 加入 AA) | 点击区域 ≥ 24x24px |
| 3.3.1 Error Identification | 错误明确识别 |
| 3.3.2 Labels or Instructions | 输入有 label |
| 4.1.2 Name, Role, Value | 控件有 name / role / value |

## 语义化 HTML（最重要）

```html
<!-- ❌ 反例 -->
<div onclick="...">点我</div>
<div class="title">标题</div>
<div class="list">
  <div>项目 1</div>
  <div>项目 2</div>
</div>

<!-- ✅ 正确 -->
<button type="button" onclick="...">点我</button>
<h2>标题</h2>
<ul>
  <li>项目 1</li>
  <li>项目 2</li>
</ul>

<!-- 表单 -->
<form>
  <label for="email">邮箱</label>
  <input id="email" type="email" required aria-describedby="email-help" />
  <p id="email-help">我们不会泄露您的邮箱</p>
  
  <button type="submit">提交</button>
</form>

<!-- 导航 -->
<nav aria-label="主导航">
  <ul>
    <li><a href="/">首页</a></li>
    <li><a href="/about">关于</a></li>
  </ul>
</nav>

<!-- 主要内容 -->
<main>
  <article>
    <h1>文章标题</h1>
    ...
  </article>
</main>

<!-- 章节 -->
<section aria-labelledby="features-heading">
  <h2 id="features-heading">特性</h2>
  ...
</section>
```

## ARIA 速查

### 角色（Role）

```text
landmark 角色（页面结构）：
  banner / navigation / main / contentinfo / complementary / search / form / region

widget 角色：
  button / link / checkbox / radio / textbox / combobox / listbox / option
  tab / tabpanel / tablist / menu / menuitem
  dialog / alertdialog / tooltip / status / alert
  tree / treeitem / grid / row / cell

非交互（仅当 HTML 不够用时用）：
  heading / list / listitem / table
```

### 属性（Property / State）

```text
描述：
  aria-label="按钮标签"
  aria-labelledby="id"
  aria-describedby="id"
  aria-details="id"

状态：
  aria-disabled="true"
  aria-checked="true | false | mixed"
  aria-selected="true"
  aria-expanded="true | false"
  aria-pressed="true | false"
  aria-hidden="true"        # 屏幕阅读器忽略
  aria-invalid="true"
  aria-required="true"
  aria-busy="true"

关系：
  aria-controls="id"
  aria-owns="id"
  aria-haspopup="true | menu | listbox | dialog"
  
实时区域：
  aria-live="polite | assertive | off"
  role="status"             # = aria-live=polite
  role="alert"              # = aria-live=assertive
```

## React 完整示例

### 按钮

```typescript
<button
  type="button"
  onClick={handleClick}
  disabled={isLoading}
  aria-busy={isLoading}
  aria-label={iconOnly ? '关闭' : undefined}  // icon-only 必须
>
  {isLoading ? <Spinner aria-hidden="true" /> : null}
  {!iconOnly && <span>提交</span>}
</button>
```

### 输入框

```typescript
<div className="form-field">
  <label htmlFor="email" className="label">
    邮箱 <span aria-hidden="true">*</span>
    <span className="sr-only">必填</span>
  </label>
  <input
    id="email"
    type="email"
    required
    aria-required="true"
    aria-invalid={!!error}
    aria-describedby={error ? 'email-error' : 'email-help'}
    autoComplete="email"
  />
  {!error && (
    <p id="email-help" className="help">
      我们不会泄露您的邮箱
    </p>
  )}
  {error && (
    <p id="email-error" role="alert" className="error">
      {error}
    </p>
  )}
</div>
```

### 模态对话框（用 Radix）

```typescript
import * as Dialog from '@radix-ui/react-dialog';

<Dialog.Root>
  <Dialog.Trigger asChild>
    <button>打开</button>
  </Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Overlay className="overlay" />
    <Dialog.Content
      className="dialog"
      aria-labelledby="dialog-title"
      aria-describedby="dialog-desc"
    >
      <Dialog.Title id="dialog-title">确认删除</Dialog.Title>
      <Dialog.Description id="dialog-desc">
        此操作不可撤销
      </Dialog.Description>
      <button>确认</button>
      <Dialog.Close asChild>
        <button aria-label="关闭">×</button>
      </Dialog.Close>
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

Radix 自动处理：
- 焦点陷阱（Tab 不出 dialog）
- Esc 关闭
- 打开时聚焦首个可聚焦元素
- 关闭时焦点回到触发器
- aria-modal / role=dialog
- 屏幕阅读器读 title + description

### 自定义按钮（如非要）

```typescript
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  }}
  aria-disabled={disabled}
  className={cn('custom-btn', disabled && 'disabled')}
>
  点击我
</div>

// 但首选 <button>，自定义除非有强理由
```

### 实时反馈

```typescript
// Toast 通知
<div role="status" aria-live="polite">
  操作成功
</div>

// 紧急错误
<div role="alert" aria-live="assertive">
  网络错误，请重试
</div>

// Loading
<div role="status" aria-live="polite" aria-busy="true">
  加载中...
</div>
```

## 键盘导航

### 标准键盘交互

```text
Tab：下一个可聚焦
Shift+Tab：上一个
Enter：激活按钮 / 链接
Space：激活按钮 / 切换 checkbox
Esc：关闭模态 / 取消
方向键：菜单 / 标签 / 单选组

不要：
  ❌ 拦截 Tab 改变行为
  ❌ tabindex > 0（破坏顺序）
  ❌ outline: none 不替代焦点环
```

### 焦点管理

```typescript
// 模态打开聚焦首个输入
useEffect(() => {
  if (isOpen) {
    inputRef.current?.focus();
  }
}, [isOpen]);

// 模态关闭还原焦点（Radix 自动）
const triggerRef = useRef<HTMLButtonElement>(null);
const closeAndRestore = () => {
  setOpen(false);
  triggerRef.current?.focus();
};

// 路由切换聚焦 main
useEffect(() => {
  document.getElementById('main')?.focus();
}, [pathname]);

// 表单提交失败聚焦首个错误
const onError = (errors) => {
  const firstError = Object.keys(errors)[0];
  document.getElementById(firstError)?.focus();
};
```

### Skip Link

```html
<!-- 让键盘用户跳过导航 -->
<a href="#main" className="skip-link">跳到主内容</a>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
}
.skip-link:focus {
  top: 0;
}
</style>
```

## 颜色与对比

```text
WCAG AA：
  - 普通文字 ≥ 4.5:1
  - 大文字（18pt / 14pt 加粗）≥ 3:1
  - UI 控件 ≥ 3:1
  - 图标边框 ≥ 3:1

WCAG AAA（更高）：
  - 普通文字 ≥ 7:1
  - 大文字 ≥ 4.5:1

工具：
  - WebAIM Contrast Checker
  - Chrome DevTools - Lighthouse Accessibility
  - Stark（Figma 插件）
```

```text
不仅靠颜色：
  ❌ 错误：红色边框
  ✅ 错误：红色边框 + ✗ 图标 + "邮箱格式不正确"

  ❌ 链接：仅蓝色
  ✅ 链接：蓝色 + 下划线
```

## 暗黑模式

```text
需要：
  □ 切换控件
  □ 持久化（localStorage）
  □ 跟随系统（默认）
  □ 所有图片 / 图标暗黑适配
  □ 对比度暗黑下也达标
```

## 移动端 / 触摸

```text
□ 点击区域 ≥ 44x44px（WCAG 2.2 至少 24x24）
□ 间距足够（≥ 8px）
□ 不依赖 hover（用 :focus / 持续显示）
□ 横屏 / 缩放可用
□ 视口设置正确
```

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

## 减少动画

```css
/* 用户偏好 */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

## 测试方法

### 自动化（必跑）

```typescript
// 1. axe-core 集成（开发时）
import { AxeBuilder } from '@axe-core/playwright';

test('a11y check', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});

// 2. jest-axe / vitest-axe（单元测试）
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

test('Button is accessible', async () => {
  const { container } = render(<Button>Click</Button>);
  expect(await axe(container)).toHaveNoViolations();
});

// 3. Lighthouse CI Accessibility
```

### 手动（必做）

```text
1. 仅键盘操作（拔鼠标）
   □ 能 Tab 到所有交互
   □ 焦点环可见
   □ Enter / Space 激活
   □ Esc 取消模态

2. 缩放 200%
   □ 不出现横滚
   □ 内容不重叠

3. 屏幕阅读器
   □ NVDA（Windows）
   □ VoiceOver（Mac，Cmd+F5）
   □ TalkBack（Android）
   □ VoiceOver iOS
```

### 用户测试

```text
□ 邀请障碍用户测试
□ 录屏 + 反馈
```

## Headless 库（推荐）

| 库 | 框架 | 特点 |
|---|---|---|
| **Radix UI** | React | 业界 a11y 标杆 |
| **React Aria** | React | Adobe 出品，最严格 |
| **Headless UI** | React/Vue | Tailwind 配套 |
| **Ariakit** | React | 全面 |
| **Reka UI（前 Radix Vue）** | Vue | Radix Vue 移植 |
| **Melt UI** | Svelte | Headless |
| **Bits UI** | Svelte | 简化 |
| **Kobalte** | Solid | a11y 优秀 |

## 工作流程

```text
1. 设计阶段
   - 与 UI/UX 同步：对比度 / 焦点 / 错误传达

2. 实现阶段
   - 用语义化 HTML
   - 用 Headless 库
   - 焦点管理

3. 自动化测试
   - jest-axe / @axe-core/playwright
   - CI 阻塞

4. 手动测试
   - 键盘导航
   - 屏幕阅读器
   - 缩放 200%

5. 用户测试（可选）

6. 监控
   - 定期 Lighthouse
```

## 配套模板

- `templates/a11y-checklist.md` — WCAG 2.2 + ARIA + 键盘 + 测试 + 移动端

## 质量自检

```text
□ 语义化 HTML（button/nav/main/h1...）
□ 表单 label 关联
□ ARIA 角色 / 属性正确
□ 键盘可操作（Tab/Enter/Esc/方向键）
□ 焦点环可见（focus-visible）
□ 焦点管理（模态聚焦 / 还原）
□ Skip Link
□ 不仅靠颜色（图标 + 文字）
□ 对比度 AA（4.5:1 普通 / 3:1 大）
□ 点击区域 ≥ 24x24
□ aria-live 状态变化
□ 减少动画偏好支持
□ 暗黑模式对比度
□ 缩放 200% 无横滚
□ 自动化测试（axe-core）
□ 手动测试（键盘 + 屏幕阅读器）
```

## 常见坑

1. **outline: none**——焦点不可见
2. **div onclick**——键盘不可达
3. **图标按钮无 aria-label**——读屏器读"按钮"
4. **错误只用红色**——色盲看不到
5. **对比度不达 4.5**——视障读不清
6. **模态打开不聚焦**——键盘用户找不到
7. **模态关闭焦点丢失**——回到第一个 Tab
8. **tabindex 滥用 > 0**——顺序乱
9. **placeholder 当 label**——填了就看不见
10. **不测屏幕阅读器**——无法验证
11. **动画无控制**——前庭疾病不适
12. **图片无 alt**——读屏器跳过
13. **alt 重复 img / image**——浪费
14. **链接文字"点这里"**——脱离上下文无意义
15. **表格无 caption / scope**——读屏器混乱

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer 工作流 accessibility skill → 设计阶段保证

下游：
  component-architecture → 组件 a11y 内置
  styling-system → 焦点 / 对比度 / 动画
  forms-validation → 字段错误关联
  testing-frontend → axe-core 测试
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — Headless 库
- ui-ux-designer 工作流 accessibility skill
