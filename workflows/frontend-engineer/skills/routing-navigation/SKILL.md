---
name: routing-navigation
description: 设计和实现路由 / 导航 / 权限守卫 / 嵌套路由 / 动态路由时使用。覆盖 Next.js / React Router / TanStack Router / Vue Router / Angular Router / SvelteKit。融合文件路由 + 嵌套布局 + 守卫 + 懒加载 + 数据加载。
---

# 路由与导航（Routing & Navigation）

参考来源：Next.js / Remix / TanStack Router / Vue Router / Angular Router 官方文档、Web Standards History API、Stripe / Linear 路由实践。

## 适用场景

- 路由结构设计
- 嵌套布局
- 动态路由 / 通配
- 路由守卫（鉴权 / 角色）
- 懒加载（code splitting）
- 数据预加载（loaders）
- 导航过渡 / 滚动恢复

## 核心原则

```text
1. URL 是状态
   可分享 / 可书签 / 可后退
   筛选 / 分页 / 排序都该进 URL

2. 路由 = 页面
   不要把弹窗 / 抽屉做成路由（除非确实需要分享）

3. 嵌套布局共享
   Layout 不重复渲染
   只更新内层

4. 懒加载是默认
   每个路由 = 一个 chunk
   首屏只加载需要的

5. 数据预加载
   路由切换前并行加载（Loaders）

6. 守卫分层
   全局（鉴权）+ 路由（角色）+ 组件（细粒度）

7. 404 / 错误页面统一
   每层 layout 都有 fallback
```

## 路由系统对比

| 方案 | 类型 | 文件路由 | Loaders | 守卫 | SSR |
|---|---|---|---|---|---|
| **Next.js App Router** | 文件 | ✅ | ✅ | middleware | ✅ |
| **Next.js Pages Router** | 文件 | ✅ | getServerSideProps | middleware | ✅ |
| **React Router 7** | 配置 | 可选 | ✅ loaders | element | ✅ |
| **TanStack Router** | 类型安全 | ✅ | ✅ | beforeLoad | ✅ |
| **Vue Router 4** | 配置 | 否（用 Nuxt）| 钩子 | beforeEach | - |
| **Nuxt Router** | 文件 | ✅ | useFetch | middleware | ✅ |
| **Angular Router** | 配置 | ❌ | resolvers | guards | ✅ |
| **SvelteKit** | 文件 | ✅ | load | hooks | ✅ |

## Next.js App Router（推荐 React 项目）

```text
app/
├── layout.tsx                   ← 根布局（HTML / providers）
├── page.tsx                     ← /
├── (auth)/                      ← 路由组（不影响 URL）
│   ├── login/page.tsx          ← /login
│   └── register/page.tsx       ← /register
├── (dashboard)/
│   ├── layout.tsx              ← /dashboard 共享布局
│   ├── orders/
│   │   ├── page.tsx            ← /orders
│   │   ├── [id]/page.tsx       ← /orders/[id]
│   │   └── [id]/edit/page.tsx  ← /orders/[id]/edit
│   └── users/
│       └── page.tsx
├── api/                         ← API 路由
│   └── orders/route.ts
├── loading.tsx                  ← 加载 fallback
├── error.tsx                    ← 错误 fallback
└── not-found.tsx               ← 404
```

```typescript
// app/(dashboard)/orders/page.tsx
export default async function OrdersPage({ searchParams }: { searchParams: { page?: string } }) {
  // Server Component：直接 await 数据
  const orders = await fetchOrders({ page: searchParams.page ?? '1' });
  
  return (
    <>
      <h1>Orders</h1>
      <OrderList orders={orders} />
    </>
  );
}

// 动态路由
// app/(dashboard)/orders/[id]/page.tsx
export default async function OrderDetailPage({ params }: { params: { id: string } }) {
  const order = await fetchOrder(params.id);
  if (!order) notFound();
  return <OrderDetail order={order} />;
}

// middleware.ts 全局守卫
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token');
  
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = { matcher: ['/dashboard/:path*'] };
```

## React Router 7

```typescript
import { createBrowserRouter, RouterProvider, redirect } from 'react-router';

const router = createBrowserRouter([
  {
    path: '/',
    Component: RootLayout,
    errorElement: <ErrorBoundary />,
    children: [
      { index: true, Component: Home },
      { path: 'login', Component: Login },
      {
        path: 'dashboard',
        Component: DashboardLayout,
        loader: requireAuth,        // 守卫
        children: [
          {
            path: 'orders',
            Component: OrderList,
            loader: async ({ request }) => {
              const url = new URL(request.url);
              const page = url.searchParams.get('page') ?? '1';
              return await fetchOrders({ page });
            },
          },
          {
            path: 'orders/:id',
            Component: OrderDetail,
            loader: async ({ params }) => {
              const order = await fetchOrder(params.id);
              if (!order) throw new Response('Not Found', { status: 404 });
              return order;
            },
          },
        ],
      },
    ],
  },
]);

// 守卫
async function requireAuth({ request }: LoaderFunctionArgs) {
  const user = await getCurrentUser();
  if (!user) {
    const params = new URLSearchParams({ redirect: new URL(request.url).pathname });
    throw redirect(`/login?${params}`);
  }
  return user;
}

// 用 loader 数据
function OrderList() {
  const orders = useLoaderData() as Order[];
  return <List items={orders} />;
}

// 主入口
<RouterProvider router={router} />
```

## TanStack Router（类型安全）

```typescript
// routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router';

export const Route = createRootRoute({
  component: () => (
    <>
      <Header />
      <Outlet />
    </>
  ),
});

// routes/orders/$id.tsx
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/orders/$id')({
  beforeLoad: async ({ params }) => {
    const user = await requireAuth();
    return { user };
  },
  loader: async ({ params }) => {
    return await fetchOrder(params.id);
  },
  component: OrderDetail,
});

function OrderDetail() {
  const { id } = Route.useParams();        // 类型安全
  const order = Route.useLoaderData();      // 类型安全
  return <div>{order.title}</div>;
}
```

## Vue Router 4

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  { path: '/', component: () => import('@/pages/Home.vue') },
  { path: '/login', component: () => import('@/pages/Login.vue') },
  {
    path: '/dashboard',
    component: () => import('@/layouts/Dashboard.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: 'orders', component: () => import('@/pages/orders/List.vue') },
      { path: 'orders/:id', component: () => import('@/pages/orders/Detail.vue') },
    ],
  },
  { path: '/:pathMatch(.*)*', component: () => import('@/pages/NotFound.vue') },
];

const router = createRouter({ history: createWebHistory(), routes });

// 全局守卫
router.beforeEach(async (to) => {
  const userStore = useUserStore();
  if (to.meta.requiresAuth && !userStore.user) {
    return { path: '/login', query: { redirect: to.fullPath } };
  }
});

export default router;
```

```vue
<!-- 使用 -->
<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();

const id = computed(() => route.params.id as string);

async function navigateToEdit() {
  await router.push(`/orders/${id.value}/edit`);
}
</script>

<template>
  <RouterLink to="/orders/123">Order 123</RouterLink>
  <RouterView />
</template>
```

## SvelteKit

```text
src/routes/
├── +layout.svelte             ← 根布局
├── +page.svelte               ← /
├── login/+page.svelte         ← /login
├── dashboard/
│   ├── +layout.svelte         ← /dashboard 布局
│   ├── +layout.server.ts      ← 服务端守卫
│   └── orders/
│       ├── +page.svelte
│       ├── +page.ts           ← Universal load
│       └── [id]/+page.svelte
├── +error.svelte              ← 错误页
└── hooks.server.ts            ← 全局守卫
```

```typescript
// routes/dashboard/+layout.server.ts
import { redirect } from '@sveltejs/kit';

export async function load({ cookies }) {
  const token = cookies.get('token');
  if (!token) throw redirect(303, '/login');
  return { user: await getUser(token) };
}

// routes/orders/[id]/+page.ts
import { error } from '@sveltejs/kit';

export async function load({ params, fetch }) {
  const res = await fetch(`/api/orders/${params.id}`);
  if (!res.ok) throw error(404, 'Order not found');
  return { order: await res.json() };
}
```

## Angular Router

```typescript
// app.routes.ts
import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: '', loadComponent: () => import('./home/home.component').then(m => m.HomeComponent) },
  { path: 'login', loadComponent: () => import('./auth/login.component').then(m => m.LoginComponent) },
  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadComponent: () => import('./layouts/dashboard.component').then(m => m.DashboardComponent),
    children: [
      { path: 'orders', loadComponent: () => import('./orders/list.component').then(m => m.OrderListComponent) },
      {
        path: 'orders/:id',
        loadComponent: () => import('./orders/detail.component').then(m => m.OrderDetailComponent),
        resolve: { order: orderResolver },
      },
    ],
  },
  { path: '**', loadComponent: () => import('./not-found.component').then(m => m.NotFoundComponent) },
];

// guards/auth.guard.ts
import { inject } from '@angular/core';
import { Router } from '@angular/router';

export const authGuard = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  
  if (!auth.isLoggedIn()) {
    router.navigate(['/login']);
    return false;
  }
  return true;
};
```

## URL 状态（搜索 / 筛选 / 分页）

```typescript
// React + nuqs（推荐）
import { useQueryState, useQueryStates, parseAsInteger, parseAsString } from 'nuqs';

function ProductList() {
  const [search, setSearch] = useQueryState('q', parseAsString.withDefault(''));
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1));
  const [filters, setFilters] = useQueryStates({
    category: parseAsString,
    sort: parseAsString.withDefault('newest'),
  });
  
  // URL 自动 sync
  // ?q=keyboard&page=2&category=electronics&sort=price-asc
}
```

```vue
<!-- Vue 3 -->
<script setup>
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();

const search = computed({
  get: () => route.query.q as string ?? '',
  set: (val) => router.push({ query: { ...route.query, q: val || undefined } }),
});
</script>
```

## 守卫层次

```text
1. 全局守卫（middleware）
   - 鉴权检查
   - i18n 重定向
   - A/B 测试分流

2. 路由级守卫（guard / loader）
   - 角色权限
   - 数据预加载
   - 重定向

3. 组件级守卫
   - 字段权限
   - 二次确认（弹框）
```

## 懒加载（Code Splitting）

```typescript
// React
const OrderList = lazy(() => import('./pages/OrderList'));

<Suspense fallback={<Skeleton />}>
  <OrderList />
</Suspense>

// Vue
{ component: () => import('./pages/OrderList.vue') }

// Angular
loadComponent: () => import('./order-list/order-list.component').then(m => m.OrderListComponent)

// 自动：Next.js / Nuxt / SvelteKit 默认每页面一 chunk
```

## 滚动恢复

```text
浏览器后退应回到原位置：

Next.js / Nuxt / SvelteKit：默认支持
React Router 7：<ScrollRestoration /> 组件
Vue Router：scrollBehavior 配置
```

## 工作流程

```text
1. 设计 URL 结构（与 PM 同步）
   - RESTful：/users / /users/:id / /users/:id/edit
   - 不在 URL 暴露内部信息

2. 列路由清单
   - 公开 vs 需登录 vs 角色限定

3. 设计布局
   - 嵌套 layout（共享 sidebar / header）

4. 实现路由
   - 文件路由（如可）
   - 懒加载所有页面

5. 守卫
   - 全局：登录
   - 路由级：角色
   - 组件级：字段权限

6. 数据预加载（loaders）
   - 并行加载

7. 错误 / 404 / loading 页面

8. URL 状态（筛选 / 分页）

9. 滚动恢复 / 过渡

10. 测试
```

## 配套模板

- `templates/routing-template.md` — 路由表 + 守卫 + 懒加载 + URL 状态 + 错误处理

## 质量自检

```text
□ URL 结构清晰
□ 嵌套布局共享
□ 所有页面懒加载
□ 鉴权全局守卫
□ 角色路由级守卫
□ 数据预加载（loaders）
□ 404 / 错误 / loading 页面
□ URL 状态用 search params
□ 滚动恢复
□ 不暴露内部 ID（如可）
□ 路由测试覆盖
```

## 常见坑

1. **弹窗做成路由**——后退一打开
2. **筛选参数不进 URL**——刷新丢失、不能分享
3. **守卫只在前端**——直接调 API 仍可访问
4. **不懒加载**——首屏 JS 1MB
5. **嵌套 layout 重复请求**——loader 没正确分层
6. **404 不统一**——每页面自己写
7. **路由切换没 loading**——白屏
8. **滚动不恢复**——后退到顶部
9. **URL 暴露 internal ID**——爬取 / 越权
10. **路由参数不解码**——中文乱码
11. **不用 prefetch**——hover 已能预加载
12. **Hash 路由 vs History**——SEO 失败
13. **守卫返回 false 不跳转**——白屏

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer 工作流 user-flow → 路由结构
  api-designer auth-permission → 角色矩阵

下游：
  state-management → URL 状态
  data-fetching → loader / prefetch
  performance-optimization → 懒加载
  accessibility-implementation → 焦点管理
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 路由库
