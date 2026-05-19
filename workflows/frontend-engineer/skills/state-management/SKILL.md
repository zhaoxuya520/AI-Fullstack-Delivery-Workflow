---
name: state-management
description: 选择和实现状态管理方案时使用。覆盖 React (Redux Toolkit / Zustand / Jotai / Valtio / TanStack Query) / Vue (Pinia) / Angular (NgRx / Signals) / Svelte (Stores / Runes)。融合客户端状态 + 服务端状态分离。
---

# 状态管理（State Management）

参考来源：Dan Abramov《You Might Not Need Redux》、TanStack Query 官方文档、Zustand 文档、Pinia 文档、Kent C. Dodds《Application State Management》。

## 适用场景

- 客户端状态管理（UI / 表单 / 应用配置）
- 服务端状态管理（API 数据 / 缓存）
- 跨组件状态共享
- 持久化状态（localStorage / IndexedDB）
- 复杂工作流（状态机）

## 核心原则

```text
1. 状态分类（最重要）
   - 服务端状态（来自 API）→ TanStack Query / SWR
   - 客户端状态（UI 控制）→ Redux / Zustand / Pinia
   - 表单状态 → React Hook Form / VeeValidate
   - URL 状态 → 路由参数 / search params
   - 派生状态（从其他派生）→ 不存，computed

2. 状态最小化
   能从 props / URL 派生就不存

3. 状态在最近共同祖先
   不一上来就全局

4. 服务端数据不放 Redux
   用 TanStack Query 自动处理缓存 / 失效 / 重试

5. 不滥用 Context
   Context value 变化 = 所有消费者重渲染

6. 不可变更新
   用 Immer / structural sharing
```

## 状态分类决策

```text
要管理的状态：
├── 来自服务端 API？
│   YES → TanStack Query / SWR（必选）
│   NO ↓
├── 来自表单？
│   YES → React Hook Form / VeeValidate
│   NO ↓
├── 来自 URL（搜索 / 筛选）？
│   YES → 路由参数 / useSearchParams
│   NO ↓
├── 跨组件共享？
│   YES ↓
│        ├── 简单 → Context / useReducer
│        ├── 中复杂 → Zustand / Pinia
│        └── 复杂 / 团队大 → Redux Toolkit / NgRx
│   NO → useState 在组件内
```

## React + Zustand（推荐中小型）

```typescript
// store/userStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface UserState {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const useUserStore = create<UserState>()(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
      logout: () => set({ user: null }),
    }),
    { name: 'user-storage' }
  )
);

// 用法
const user = useUserStore((s) => s.user);
const setUser = useUserStore((s) => s.setUser);

// 选择器避免不必要重渲染
const userName = useUserStore((s) => s.user?.name);
```

## React + Redux Toolkit（企业 / 复杂）

```typescript
// features/users/userSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchUsers = createAsyncThunk('users/fetch', async () => {
  return await api.fetchUsers();
});

const userSlice = createSlice({
  name: 'users',
  initialState: { list: [] as User[], loading: false, error: null as string | null },
  reducers: {
    addUser: (state, action) => {
      state.list.push(action.payload);  // Immer 内置
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUsers.pending, (s) => { s.loading = true; })
      .addCase(fetchUsers.fulfilled, (s, a) => {
        s.loading = false;
        s.list = a.payload;
      })
      .addCase(fetchUsers.rejected, (s, a) => {
        s.loading = false;
        s.error = a.error.message ?? null;
      });
  },
});

// 用法
const dispatch = useAppDispatch();
const users = useAppSelector((s) => s.users.list);
useEffect(() => { dispatch(fetchUsers()); }, []);
```

## React + Jotai（细粒度）

```typescript
import { atom, useAtom } from 'jotai';
import { atomWithStorage } from 'jotai/utils';

const userAtom = atomWithStorage<User | null>('user', null);

// 派生 atom（自动更新）
const userNameAtom = atom((get) => get(userAtom)?.name ?? 'Guest');

// 用法
const [user, setUser] = useAtom(userAtom);
const [userName] = useAtom(userNameAtom);
```

## React + TanStack Query（服务端状态必选）

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// 查询
function UserList() {
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['users', filter],
    queryFn: () => api.fetchUsers(filter),
    staleTime: 5 * 60 * 1000,    // 5 分钟内不重新请求
    gcTime: 30 * 60 * 1000,      // 30 分钟后清缓存
    retry: 3,                     // 失败重试 3 次
  });
  
  if (isLoading) return <Skeleton />;
  if (error) return <Error onRetry={refetch} />;
  return <List items={data} />;
}

// 变更
function CreateUserButton() {
  const qc = useQueryClient();
  const mutation = useMutation({
    mutationFn: api.createUser,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['users'] });  // 自动刷新
      toast.success('Created');
    },
  });
  
  return <button onClick={() => mutation.mutate(data)}>Create</button>;
}
```

## Vue 3 + Pinia

```typescript
// stores/user.ts
import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null);
  const isLoggedIn = computed(() => !!user.value);
  
  async function login(credentials: LoginInput) {
    user.value = await api.login(credentials);
  }
  
  function logout() {
    user.value = null;
  }
  
  return { user, isLoggedIn, login, logout };
});

// 用法
const userStore = useUserStore();
userStore.login(...);
console.log(userStore.user);
```

## Vue 3 + TanStack Query

```vue
<script setup lang="ts">
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query';

const filter = ref('');
const { data, isLoading } = useQuery({
  queryKey: ['users', filter],
  queryFn: () => api.fetchUsers(filter.value),
});

const qc = useQueryClient();
const mutation = useMutation({
  mutationFn: api.createUser,
  onSuccess: () => qc.invalidateQueries({ queryKey: ['users'] }),
});
</script>
```

## Angular Signals（19+）

```typescript
@Component({
  template: `
    <input [(ngModel)]="filter" />
    @for (user of filteredUsers(); track user.id) {
      <div>{{ user.name }}</div>
    }
  `,
})
export class UserListComponent {
  users = signal<User[]>([]);
  filter = signal('');
  
  filteredUsers = computed(() =>
    this.users().filter(u => u.name.includes(this.filter()))
  );
  
  ngOnInit() {
    this.userService.fetch().subscribe(data => this.users.set(data));
  }
}
```

## Svelte 5 Runes

```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);
  
  $effect(() => {
    console.log('count changed:', count);
  });
</script>

<button onclick={() => count++}>{count}</button>
<p>Doubled: {doubled}</p>
```

## Context 反模式

```text
❌ 把所有数据放一个 Context：
  - 任意字段变化 → 全部组件重渲染

✅ 拆 Context：
  - 一个 Context 一个相关状态组
  - 或：用 Zustand / Jotai（自动选择性订阅）
```

## 持久化策略

```text
localStorage：
  - 用户偏好（主题 / 语言）
  - 表单草稿
  - 不放敏感信息

sessionStorage：
  - 临时会话状态

IndexedDB：
  - 大量数据 / 离线
  - 用 Dexie.js 包装

URL（query / hash）：
  - 可分享状态（搜索 / 筛选 / 排序）

cookies：
  - HttpOnly：Token（后端管理）
  - JavaScript 不应放敏感信息
```

## 工作流程

```text
1. 列状态清单
   - 服务端 vs 客户端 vs 表单 vs URL

2. 服务端状态 → TanStack Query
   - 配置 staleTime / gcTime
   - 设计 queryKey

3. 客户端状态 → 选库
   - 简单 → useState / Context
   - 中等 → Zustand / Pinia
   - 复杂 → Redux Toolkit

4. 表单状态 → React Hook Form / VeeValidate

5. URL 状态 → router

6. 派生状态 → computed / useMemo / derived

7. 持久化 → 必要时 localStorage

8. 测试
```

## 配套模板

- `templates/state-management-checklist.md` — 状态分类 + 库选型 + 持久化 + 测试

## 质量自检

```text
□ 状态分类清晰（4 类）
□ 服务端状态用 TanStack Query / SWR
□ 客户端状态最小化
□ 不滥用 Context（拆细 / 用 Zustand）
□ 派生状态用 computed
□ Selector 优化避免重渲染
□ 不可变更新（Immer / structural sharing）
□ 持久化谨慎（不放敏感）
□ 测试 store / hook
```

## 常见坑

1. **服务端数据放 Redux**——用 TanStack Query
2. **一个大 Context**——任意变化全部重渲染
3. **同步 props 到 state**——直接用 props
4. **useState 初始化重计算**——用懒初始化
5. **派生数据存 state**——直接 computed
6. **mutation 改原对象**——React 不更新
7. **Selector 不优化**——返回新对象每次
8. **localStorage 存 Token**——XSS 风险
9. **不清理 effect 订阅**——内存泄漏
10. **过度全局化**——所有状态全局

## 配套模板

- `templates/state-management-checklist.md`

## 与其他 skill 的协作

```text
上游：
  api-designer → API 契约 → queryKey 设计

下游：
  data-fetching → TanStack Query 深度
  forms-validation → 表单状态
  component-architecture → state 在哪层
  performance-optimization → 优化重渲染
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 状态管理库
