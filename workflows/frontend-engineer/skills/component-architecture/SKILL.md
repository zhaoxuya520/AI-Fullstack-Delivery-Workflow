---
name: component-architecture
description: 设计组件结构、拆分粒度和复用策略时使用。覆盖 React / Vue / Angular / Svelte。融合 Atomic Design + Container/Presentation + Compound Components + Headless 模式。
---

# 组件架构（Component Architecture）

参考来源：Brad Frost《Atomic Design》、Dan Abramov《Presentational and Container Components》、Kent C. Dodds《Compound Components》、Adam Wathan《Inversion of Control》。

## 适用场景

- 设计组件树和拆分粒度
- 复用率提升 / 设计系统建设
- 组件 API 设计
- 组件状态封装策略
- React / Vue / Angular / Svelte 框架范式

## 核心原则

```text
1. 单一职责
   一个组件做一件事

2. 显式 props，避免 prop drilling
   多于 3 层往下传 → 用 Context / 状态管理

3. Composition over Configuration
   `<Card><Card.Header /></Card>` 优于
   `<Card title="..." footer="..." actions={[...]} />`

4. 数据从上往下，事件从下往上
   单向数据流

5. 设计 API 比内部实现重要
   API 是契约，能改实现不能改 API

6. 受控 vs 非受控明确
   表单组件提供两种模式

7. 可访问性是默认
   不是事后补救（详见 a11y skill）

8. 状态最小化
   能从 props 派生就不存 state
```

## Atomic Design 五层

```text
┌─────────────────────────────────────┐
│ Pages（页面）                        │
│ 例：UserProfilePage / OrderListPage   │
└────────────────┬────────────────────┘
┌────────────────┴────────────────────┐
│ Templates（模板）                     │
│ 例：DashboardLayout / AuthLayout      │
└────────────────┬────────────────────┘
┌────────────────┴────────────────────┐
│ Organisms（生物体）                   │
│ 例：Header / Sidebar / OrderList     │
└────────────────┬────────────────────┘
┌────────────────┴────────────────────┐
│ Molecules（分子）                     │
│ 例：FormField / SearchBar / UserCard │
└────────────────┬────────────────────┘
┌────────────────┴────────────────────┐
│ Atoms（原子）                         │
│ 例：Button / Input / Icon / Label    │
└─────────────────────────────────────┘
```

## Container / Presentation 模式

```text
Container（容器）：
  - 管理状态 / 调用 API / 业务逻辑
  - 不写 UI 细节
  - 命名：UserListContainer

Presentation（展示）：
  - 纯 UI / 无状态（或仅 UI 状态）
  - 接收 props，emit 事件
  - 易测试 / 易复用 / Storybook 友好
  - 命名：UserList
```

```typescript
// Presentation：纯 UI
interface UserListProps {
  users: User[];
  isLoading: boolean;
  onUserClick: (id: number) => void;
}

export function UserList({ users, isLoading, onUserClick }: UserListProps) {
  if (isLoading) return <Skeleton count={5} />;
  if (users.length === 0) return <EmptyState />;
  
  return (
    <ul>
      {users.map(user => (
        <li key={user.id} onClick={() => onUserClick(user.id)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}

// Container：业务逻辑
export function UserListContainer() {
  const { data, isLoading } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
  const navigate = useNavigate();
  
  return (
    <UserList
      users={data ?? []}
      isLoading={isLoading}
      onUserClick={(id) => navigate(`/users/${id}`)}
    />
  );
}
```

## Compound Components 模式

```typescript
// 用法（用户写）
<Tabs defaultValue="orders">
  <Tabs.List>
    <Tabs.Trigger value="orders">订单</Tabs.Trigger>
    <Tabs.Trigger value="products">商品</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Panel value="orders"><OrderList /></Tabs.Panel>
  <Tabs.Panel value="products"><ProductList /></Tabs.Panel>
</Tabs>

// 实现：用 Context 共享状态
const TabsContext = createContext<TabsContextValue | null>(null);

export function Tabs({ children, defaultValue }: TabsProps) {
  const [value, setValue] = useState(defaultValue);
  return (
    <TabsContext.Provider value={{ value, setValue }}>
      <div data-tabs>{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }) {
  return <div role="tablist">{children}</div>;
};

Tabs.Trigger = function TabsTrigger({ value, children }) {
  const ctx = useContext(TabsContext);
  return (
    <button
      role="tab"
      aria-selected={ctx.value === value}
      onClick={() => ctx.setValue(value)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function TabsPanel({ value, children }) {
  const ctx = useContext(TabsContext);
  return ctx.value === value ? <div role="tabpanel">{children}</div> : null;
}
```

## Headless 模式

```text
不提供样式，只提供逻辑和无障碍：
  - Radix UI（React）
  - Headless UI（React/Vue）
  - React Aria
  - Melt UI（Svelte）
  - Bits UI（Svelte）
  - Kobalte（Solid）

优势：
  - 100% 自定义样式
  - 无障碍由库保证
  - 不与设计系统冲突

劣势：
  - 需要自己写样式
  - 学习曲线
```

```typescript
// 用 Radix Dialog
import * as Dialog from '@radix-ui/react-dialog';

export function ConfirmDialog({ children, onConfirm }) {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>{children}</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="overlay" />
        <Dialog.Content className="content">
          <Dialog.Title>确认</Dialog.Title>
          <Dialog.Description>...</Dialog.Description>
          <button onClick={onConfirm}>确认</button>
          <Dialog.Close>取消</Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

## React 组件范式

```typescript
// 1. 函数组件（推荐）
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', isLoading, children, className, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(buttonVariants({ variant, size }), className)}
        disabled={isLoading || props.disabled}
        {...props}
      >
        {isLoading && <Spinner />}
        {children}
      </button>
    );
  }
);
Button.displayName = 'Button';

// 2. 自定义 Hook 抽逻辑
function useUserList() {
  const [filter, setFilter] = useState('');
  const { data, isLoading } = useQuery({
    queryKey: ['users', filter],
    queryFn: () => fetchUsers({ filter }),
  });
  return { users: data ?? [], isLoading, filter, setFilter };
}

// 3. memo 避免不必要重渲染（仅当真有性能问题）
export const ExpensiveItem = memo(function ExpensiveItem({ item }) {
  return <div>...</div>;
});
```

## Vue 3 组件范式

```vue
<!-- Button.vue -->
<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  disabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
});

const emit = defineEmits<{
  click: [event: MouseEvent];
}>();
</script>

<template>
  <button
    :class="['btn', `btn-${variant}`, `btn-${size}`]"
    :disabled="isLoading || disabled"
    @click="emit('click', $event)"
  >
    <Spinner v-if="isLoading" />
    <slot />
  </button>
</template>
```

```vue
<!-- 组合式函数（Composables，Vue 的 Hook）-->
<script setup lang="ts">
import { useUserList } from '@/composables/useUserList';

const { users, isLoading, filter } = useUserList();
</script>

<!-- composables/useUserList.ts -->
<script lang="ts">
import { ref, computed } from 'vue';
import { useQuery } from '@tanstack/vue-query';

export function useUserList() {
  const filter = ref('');
  const { data, isLoading } = useQuery({
    queryKey: ['users', filter],
    queryFn: () => fetchUsers({ filter: filter.value }),
  });
  
  return {
    users: computed(() => data.value ?? []),
    isLoading,
    filter,
  };
}
</script>
```

## Angular 组件范式

```typescript
// button.component.ts
@Component({
  selector: 'app-button',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button
      [class]="'btn btn-' + variant() + ' btn-' + size()"
      [disabled]="isLoading() || disabled()"
      (click)="onClick.emit($event)"
    >
      <app-spinner *ngIf="isLoading()" />
      <ng-content />
    </button>
  `,
})
export class ButtonComponent {
  variant = input<'primary' | 'secondary'>('primary');
  size = input<'sm' | 'md' | 'lg'>('md');
  isLoading = input(false);
  disabled = input(false);
  onClick = output<MouseEvent>();
}
```

## Svelte 5 组件范式

```svelte
<!-- Button.svelte -->
<script lang="ts">
  interface Props {
    variant?: 'primary' | 'secondary' | 'danger';
    size?: 'sm' | 'md' | 'lg';
    isLoading?: boolean;
    onclick?: (e: MouseEvent) => void;
    children: any;
  }
  
  let {
    variant = 'primary',
    size = 'md',
    isLoading = false,
    onclick,
    children,
  }: Props = $props();
</script>

<button class="btn btn-{variant} btn-{size}" disabled={isLoading} {onclick}>
  {#if isLoading}<Spinner />{/if}
  {@render children()}
</button>
```

## 组件目录结构

```text
推荐：feature-based + 共享组件分离

src/
├── components/              ← 跨业务的通用组件
│   ├── ui/                  ← 原子组件（Button, Input, Card）
│   ├── layout/              ← 布局组件
│   └── feedback/            ← Toast, Modal, Skeleton
├── features/                ← 业务模块（领域驱动）
│   ├── orders/
│   │   ├── components/      ← 仅订单用到的组件
│   │   ├── hooks/           ← useOrder, useOrderList
│   │   ├── api/             ← API 调用
│   │   ├── types.ts
│   │   └── OrderListPage.tsx
│   └── products/
│       └── ...
├── pages/                   ← 路由页面（薄）
├── lib/                     ← 工具函数
└── App.tsx
```

## 组件 API 设计

```text
1. Props 命名
   - 布尔：is/has/can 前缀
   - 事件：on 前缀（onClick / onSubmit）
   - 字符串枚举：明确选项（variant: 'primary' | 'secondary'）

2. 默认值
   - 提供合理默认
   - 不要全部 required

3. 受控 vs 非受控
   提供两种模式：
   <Input value={x} onChange={fn} />     // 受控
   <Input defaultValue="x" />            // 非受控

4. forwardRef
   原子组件应该转发 ref

5. ...rest props
   原子组件应允许传递 HTML 属性
   <Button {...props} />
```

## 状态封装原则

```text
状态从上往下放：
  局部 state（一个组件用） → useState 在该组件
  父子共享 → 提到父组件
  跨组件 → Context / 状态管理库
  服务端数据 → TanStack Query / SWR

不要：
  - useState 然后只 setState 一次（用 props）
  - useEffect 同步 props 到 state（直接用 props）
  - 把 server state 放 Redux（用 React Query）
```

## 工作流程

```text
1. 看设计稿 → 拆分 Atomic Design 五层
   ↓
2. 列原子组件清单（Button / Input / Icon ...）
   ↓
3. 看是否复用现有组件库（不要重造轮子）
   ↓
4. 组件 API 设计（先 README 再写代码）
   ↓
5. 实现 + Storybook story
   ↓
6. 单元测试 + 集成测试 + 视觉测试
   ↓
7. 检查 a11y（键盘 + 屏幕阅读器）
   ↓
8. 性能（memo 必要时 / 懒加载）
   ↓
9. 文档（API + 用法示例）
```

## 配套模板

- `templates/component-design-template.md` — 组件设计文档（API + 状态 + 复用 + 测试 + a11y）

## 质量自检

```text
□ 单一职责（一个组件做一件事）
□ Props 类型完整（TypeScript）
□ 默认值合理
□ 受控 / 非受控明确
□ forwardRef（原子组件）
□ ...rest 透传
□ a11y 完整（角色 / 键盘 / 屏幕阅读器）
□ 状态最小化
□ 命名清晰
□ Storybook story 覆盖主要状态
□ 测试覆盖
□ 不深嵌套（< 3 层 prop drilling）
□ 不滥用 memo / useCallback
□ Loading / Empty / Error 状态完整
```

## 常见坑

1. **prop drilling 5+ 层**——用 Context / 状态库
2. **God Component**——一个组件 1000 行
3. **状态在错误层级**——子组件用却放在最顶层
4. **useState 初始化是同步函数**——重复执行
5. **useEffect 同步 props 到 state**——直接用 props
6. **server state 放 Redux**——用 TanStack Query
7. **没有 Storybook**——视觉回归无门
8. **直接修改组件库源码**——升级地狱
9. **滥用 forwardRef / memo**——过度优化
10. **不区分受控 / 非受控**——使用混乱
11. **Container 写 UI 细节**——破坏分层
12. **Atomic Design 教条化**——硬塞五层不实际
13. **a11y 后置**——重构成本巨大
14. **组件不文档化**——团队各自重造

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer 工作流 → 设计稿 / 状态 / 流程
  api-designer → API 契约（影响数据组件）

下游：
  state-management → 全局状态
  styling-system → 样式
  forms-validation → 表单组件
  data-fetching → 数据组件
  testing-frontend → 测试覆盖
  accessibility-implementation → a11y 实现
```

## 相关参考

- 项目根 `references/frontend-component-libraries.md` — 组件库选型
- 项目根 `references/frontend-frameworks-2026.md` — 框架对比
- ui-ux-designer 工作流 atomic-design / component-states skill
