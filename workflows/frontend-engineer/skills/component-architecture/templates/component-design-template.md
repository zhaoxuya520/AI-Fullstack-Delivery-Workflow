# 组件设计文档模板

## 1. 组件信息

```text
组件名：
路径：
原子层级：Atom / Molecule / Organism / Template / Page
分类：UI / 布局 / 反馈 / 数据 / 表单
框架：React / Vue / Angular / Svelte
负责人：
```

---

## 2. 用途和场景

```text
用途：
何时使用：
何时不用：
```

---

## 3. API 设计

### Props

| Prop | 类型 | 默认 | 必填 | 说明 |
|---|---|---|---|---|
| variant | 'primary' \| 'secondary' \| 'danger' | 'primary' | ❌ | 视觉变体 |
| size | 'sm' \| 'md' \| 'lg' | 'md' | ❌ | 尺寸 |
| isLoading | boolean | false | ❌ | 加载状态 |
| disabled | boolean | false | ❌ | 禁用 |
| children | ReactNode | - | ✅ | 内容 |

### 事件

| 事件 | 参数 | 说明 |
|---|---|---|
| onClick | (e: MouseEvent) => void | 点击 |

### Slot / Children

```text
默认插槽：内容
具名插槽（Vue）：icon / suffix
```

---

## 4. 状态

```text
内部状态：
  - hover, active（CSS 处理）
  - 不应有业务状态

外部状态：
  - 通过 props 接收
```

---

## 5. 受控 vs 非受控

```text
受控：value + onChange
非受控：defaultValue
```

---

## 6. 子组件 / Compound

```text
<MyComponent>
  <MyComponent.Header />
  <MyComponent.Body />
  <MyComponent.Footer />
</MyComponent>
```

---

## 7. 设计 Token 引用

```text
颜色：--color-primary, --color-danger
间距：--space-2, --space-4
字体：--font-base, --font-bold
圆角：--radius-md
阴影：--shadow-sm
```

---

## 8. 可访问性

```text
□ role 属性正确
□ ARIA 属性（aria-label, aria-pressed, aria-disabled）
□ 键盘可操作（Tab / Enter / Space）
□ 焦点可见（focus ring）
□ 屏幕阅读器友好
□ 颜色对比度 ≥ 4.5:1
□ 不仅靠颜色传达信息
```

---

## 9. 状态变体（Storybook）

```text
□ Default
□ Hover
□ Active / Pressed
□ Focused
□ Disabled
□ Loading
□ Error（如有）
□ Empty（如有数据组件）
```

---

## 10. 测试

```text
□ 单元测试（行为）
□ 视觉回归（Storybook + Chromatic）
□ a11y 测试（jest-axe）
□ E2E（关键路径）
```

### 测试用例

```text
□ 默认渲染
□ 各 variant 渲染
□ 各 size 渲染
□ 点击事件触发
□ disabled 时不触发
□ isLoading 时显示 spinner
□ 键盘导航（Tab + Enter）
□ 屏幕阅读器（aria-label）
```

---

## 11. 用法示例

```typescript
// 基础
<Button>点击</Button>

// 变体
<Button variant="danger">删除</Button>

// Loading
<Button isLoading>提交中</Button>

// 受控（如表单）
<Button onClick={handleSubmit}>提交</Button>
```

---

## 12. 性能

```text
□ 不必要的 re-render（用 memo 判断）
□ 大列表用虚拟化（TanStack Virtual）
□ 懒加载（React.lazy / dynamic import）
□ 包大小（< 5KB gzip 单组件）
```

---

## 13. 自检

```text
□ 单一职责
□ API 完整
□ 类型完备（TypeScript）
□ a11y 通过
□ Storybook 覆盖
□ 测试覆盖
□ 不依赖业务（纯 UI 组件）
□ 文档齐全
□ 设计稿 100% 还原
```
