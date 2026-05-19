# 状态管理检查清单

## 1. 项目信息

```text
框架：React / Vue 3 / Angular / Svelte
状态管理库：[选定]
服务端状态：TanStack Query / SWR / Apollo
负责人：
```

---

## 2. 状态分类清单

| 状态 | 类型 | 实现 | 持久化 |
|---|---|---|---|
| 用户信息 | 服务端 → 持久化 | TanStack Query + localStorage | ✅ |
| 主题 | 客户端偏好 | Zustand + localStorage | ✅ |
| 表单 | 表单 | React Hook Form | ❌ |
| 列表筛选 | URL | useSearchParams | URL |
| 用户列表 | 服务端 | TanStack Query | ❌ |
| 通知 | 客户端临时 | Zustand（in-memory）| ❌ |

---

## 3. 库选型

```text
服务端状态：TanStack Query
理由：[]

客户端状态：Zustand
理由：[]

表单：React Hook Form + Zod
理由：[]

派生状态：useMemo / computed
```

---

## 4. Store 设计（如用）

```text
按 feature 分 slice：
  src/stores/
    userStore.ts          - 用户信息
    cartStore.ts          - 购物车
    uiStore.ts            - UI 偏好（主题 / 折叠）
    notificationStore.ts  - 通知

不要：
  ❌ 全局唯一 store
  ❌ 服务端数据放进 store
```

---

## 5. TanStack Query 配置

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,        // 1 分钟
      gcTime: 1000 * 60 * 5,        // 5 分钟
      retry: 3,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 0,
    },
  },
});
```

### Query Key 规范

```text
全局唯一前缀 + 实体 + 参数：

['users']                            // 所有用户
['users', { filter, status }]        // 筛选
['users', userId]                    // 详情
['users', userId, 'orders']          // 关联
```

---

## 6. 持久化策略

| 数据 | 存储 | 备注 |
|---|---|---|
| 主题偏好 | localStorage | OK |
| 语言 | localStorage | OK |
| 表单草稿 | localStorage / IndexedDB | 大用 IDB |
| 购物车 | localStorage | 同步用户后合并 |
| 用户 Token | HttpOnly Cookie | ✅ |
| 用户 Token | localStorage | ❌ XSS |
| 用户偏好 | API + localStorage 缓存 | OK |

---

## 7. Selector 优化

```typescript
// ❌ 返回新对象，每次重渲染
const user = useStore((s) => ({ name: s.user.name, age: s.user.age }));

// ✅ 拆细
const name = useStore((s) => s.user.name);
const age = useStore((s) => s.user.age);

// ✅ 或用 shallow 比较
const user = useStore(useShallow((s) => ({ name: s.user.name, age: s.user.age })));
```

---

## 8. 测试

```text
□ Store 单元测试
□ Hook 单元测试（renderHook）
□ Query 集成测试（mock API）
□ 持久化测试
```

---

## 9. 自检

```text
□ 状态分类清晰
□ 服务端用 TanStack Query
□ 不滥用全局
□ 派生状态用 computed
□ Selector 优化
□ 不可变更新
□ 持久化谨慎
□ Token 不放 localStorage
□ 测试覆盖
```
