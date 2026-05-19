---
name: data-fetching
description: 实现 API 调用 / 缓存 / 加载 / 错误处理 / 乐观更新时使用。覆盖 TanStack Query / SWR / RTK Query / Apollo Client / urql / Pinia Colada / Pinia Query。融合 stale-while-revalidate + 乐观更新 + Mutation + 无限加载。
---

# 数据获取（Data Fetching）

参考来源：TanStack Query 官方、SWR 官方、Stripe / Vercel 数据获取实践、stale-while-revalidate RFC 5861。

## 适用场景

- REST / GraphQL API 集成
- 缓存策略设计
- Loading / Error / Empty 状态管理
- 乐观更新（Optimistic Updates）
- 无限滚动 / 分页
- 实时数据同步
- 离线优先

## 核心原则

```text
1. 服务端状态用专门库
   不要 useEffect + useState 手撕

2. SWR 模式（Stale-While-Revalidate）
   先用缓存（即使过期）→ 后台重新请求

3. queryKey 设计是核心
   层次化：['users', { filter, page }]

4. staleTime + gcTime 双层
   staleTime：多久"新鲜"
   gcTime：多久从缓存清除

5. 乐观更新提升体验
   立即 UI 更新 → 失败回滚

6. 错误边界 + 重试
   网络错误自动重试
   业务错误不重试

7. Prefetch 预加载
   悬停 / 路由切换前

8. 不要每页重写 fetch
   封装 API 客户端
```

## TanStack Query（推荐 React）

### 基础查询

```typescript
import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';

// 单个查询
function OrderDetail({ id }: { id: number }) {
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['orders', id],
    queryFn: () => api.getOrder(id),
    staleTime: 5 * 60 * 1000,         // 5 分钟内不重请求
    gcTime: 30 * 60 * 1000,            // 30 分钟后清缓存
    enabled: id > 0,                   // 条件查询
    retry: (failureCount, error) => {
      if (error.status === 404) return false;  // 不存在不重试
      return failureCount < 3;
    },
  });
  
  if (isLoading) return <Skeleton />;
  if (error) return <ErrorState onRetry={refetch} />;
  if (!data) return <Empty />;
  return <Detail order={data} />;
}
```

### 列表 + 分页

```typescript
function OrderList() {
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState({ status: 'all' });
  
  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['orders', { page, filter }],   // 参数变化自动新查询
    queryFn: () => api.getOrders({ page, ...filter }),
    placeholderData: keepPreviousData,         // 切换页时保留旧数据（防闪烁）
  });
  
  return (
    <>
      {isFetching && <RefreshIndicator />}
      <List items={data?.items ?? []} />
      <Pagination page={page} onChange={setPage} total={data?.total ?? 0} />
    </>
  );
}
```

### 无限滚动

```typescript
import { useInfiniteQuery } from '@tanstack/react-query';

function InfiniteOrderList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useInfiniteQuery({
    queryKey: ['orders', 'infinite'],
    queryFn: ({ pageParam = 0 }) => api.getOrders({ cursor: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    initialPageParam: 0,
  });
  
  const allOrders = data?.pages.flatMap(p => p.items) ?? [];
  
  return (
    <>
      {allOrders.map(order => <OrderCard key={order.id} order={order} />)}
      {hasNextPage && (
        <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
          {isFetchingNextPage ? '加载中...' : '加载更多'}
        </button>
      )}
    </>
  );
}

// 配合 Intersection Observer 自动加载
function useIntersectionFetchNext(ref, fetchNextPage, hasNextPage) {
  useEffect(() => {
    if (!ref.current || !hasNextPage) return;
    const observer = new IntersectionObserver(
      ([entry]) => entry.isIntersecting && fetchNextPage(),
      { threshold: 0.1 }
    );
    observer.observe(ref.current);
    return () => observer.disconnect();
  }, [ref, fetchNextPage, hasNextPage]);
}
```

### Mutation（变更）

```typescript
function CreateOrderForm() {
  const qc = useQueryClient();
  
  const mutation = useMutation({
    mutationFn: api.createOrder,
    onSuccess: (newOrder) => {
      // 失效列表查询（自动重新请求）
      qc.invalidateQueries({ queryKey: ['orders'] });
      // 或：直接更新缓存
      qc.setQueryData(['orders', newOrder.id], newOrder);
      toast.success('订单创建成功');
    },
    onError: (error) => {
      if (error.code === 'INSUFFICIENT_STOCK') {
        toast.error('库存不足');
      } else {
        toast.error('创建失败');
      }
    },
  });
  
  return (
    <form onSubmit={handleSubmit((data) => mutation.mutate(data))}>
      ...
      <button disabled={mutation.isPending}>
        {mutation.isPending ? '创建中...' : '创建'}
      </button>
    </form>
  );
}
```

### 乐观更新

```typescript
const mutation = useMutation({
  mutationFn: api.updateOrder,
  onMutate: async (newOrder) => {
    // 1. 取消进行中的请求（防覆盖）
    await qc.cancelQueries({ queryKey: ['orders', newOrder.id] });
    
    // 2. 保存当前数据用于回滚
    const previous = qc.getQueryData(['orders', newOrder.id]);
    
    // 3. 立即更新 UI
    qc.setQueryData(['orders', newOrder.id], newOrder);
    
    return { previous };
  },
  onError: (err, newOrder, context) => {
    // 失败回滚
    qc.setQueryData(['orders', newOrder.id], context?.previous);
    toast.error('更新失败');
  },
  onSettled: (data, error, variables) => {
    // 不管成败，最终同步
    qc.invalidateQueries({ queryKey: ['orders', variables.id] });
  },
});
```

### Prefetch 预加载

```typescript
// 悬停预加载
function OrderCard({ order }: { order: Order }) {
  const qc = useQueryClient();
  
  const prefetch = () => {
    qc.prefetchQuery({
      queryKey: ['orders', order.id],
      queryFn: () => api.getOrder(order.id),
      staleTime: 60 * 1000,
    });
  };
  
  return (
    <Link to={`/orders/${order.id}`} onMouseEnter={prefetch} onFocus={prefetch}>
      {order.title}
    </Link>
  );
}

// 路由切换前预加载（React Router loaders）
const router = createBrowserRouter([
  {
    path: '/orders/:id',
    loader: ({ params }) => qc.prefetchQuery({
      queryKey: ['orders', params.id],
      queryFn: () => api.getOrder(params.id),
    }),
  },
]);
```

### 全局配置

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000,                    // 默认 1 分钟新鲜
      gcTime: 5 * 60 * 1000,                    // 5 分钟清缓存
      refetchOnWindowFocus: false,              // 关注口取消（看业务）
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
    },
    mutations: {
      retry: 0,
    },
  },
});

<QueryClientProvider client={queryClient}>
  <App />
  {process.env.NODE_ENV === 'development' && <ReactQueryDevtools />}
</QueryClientProvider>
```

## SWR（轻量替代）

```typescript
import useSWR, { mutate } from 'swr';

function useOrder(id: number) {
  const { data, error, isLoading } = useSWR(
    id > 0 ? `/api/orders/${id}` : null,
    fetcher,
    {
      revalidateOnFocus: true,
      dedupingInterval: 60000,
      errorRetryCount: 3,
    }
  );
  
  return { order: data, isLoading, error };
}

// Mutation
async function updateOrder(id: number, data: Partial<Order>) {
  await api.updateOrder(id, data);
  mutate(`/api/orders/${id}`);  // 刷新缓存
}
```

## Vue 3 + TanStack Query

```vue
<script setup lang="ts">
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query';
import { ref } from 'vue';

const filter = ref({ status: 'all' });

const { data: orders, isLoading, error } = useQuery({
  queryKey: ['orders', filter],
  queryFn: () => api.getOrders(filter.value),
});

const qc = useQueryClient();
const createMutation = useMutation({
  mutationFn: api.createOrder,
  onSuccess: () => qc.invalidateQueries({ queryKey: ['orders'] }),
});
</script>

<template>
  <Skeleton v-if="isLoading" />
  <ErrorState v-else-if="error" />
  <OrderList v-else :orders="orders" />
</template>
```

## Vue 3 + Pinia Colada（新兴）

```typescript
// 类似 TanStack Query 但与 Pinia 集成
import { useQuery, useMutation } from '@pinia/colada';

const { data, status, error } = useQuery({
  key: ['orders', filter],
  query: () => api.getOrders(filter.value),
});
```

## RTK Query（已用 Redux）

```typescript
// api/orderApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const orderApi = createApi({
  reducerPath: 'orderApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/v1',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) headers.set('Authorization', `Bearer ${token}`);
      return headers;
    },
  }),
  tagTypes: ['Order'],
  endpoints: (build) => ({
    getOrder: build.query<Order, number>({
      query: (id) => `/orders/${id}`,
      providesTags: (result, error, id) => [{ type: 'Order', id }],
    }),
    createOrder: build.mutation<Order, CreateOrderInput>({
      query: (body) => ({ url: '/orders', method: 'POST', body }),
      invalidatesTags: [{ type: 'Order', id: 'LIST' }],
    }),
  }),
});

export const { useGetOrderQuery, useCreateOrderMutation } = orderApi;
```

## Apollo Client（GraphQL）

```typescript
import { useQuery, useMutation, gql } from '@apollo/client';

const GET_ORDER = gql`
  query GetOrder($id: ID!) {
    order(id: $id) {
      id
      status
      total
      items { id name quantity }
    }
  }
`;

const { data, loading, error } = useQuery(GET_ORDER, {
  variables: { id },
  fetchPolicy: 'cache-first',
  pollInterval: 30000,  // 30s 轮询
});
```

## API 客户端封装

```typescript
// api/client.ts
import axios, { AxiosError } from 'axios';

const client = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
});

// 请求拦截器：注入 Token
client.interceptors.request.use((config) => {
  const token = getToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  
  config.headers['X-Request-Id'] = crypto.randomUUID();
  return config;
});

// 响应拦截器：错误统一处理
client.interceptors.response.use(
  (res) => res.data,
  (error: AxiosError<{ error?: { code: string; message: string } }>) => {
    if (error.response?.status === 401) {
      // Token 过期，刷新或跳登录
      return refreshToken().then(() => client(error.config!));
    }
    
    // 包装为业务错误
    const apiError = new ApiError(
      error.response?.data?.error?.code ?? 'NETWORK_ERROR',
      error.response?.data?.error?.message ?? error.message,
      error.response?.status,
    );
    return Promise.reject(apiError);
  }
);

// API 函数
export const api = {
  getOrder: (id: number) => client.get<Order>(`/orders/${id}`),
  createOrder: (data: CreateOrderInput) => client.post<Order>('/orders', data),
  updateOrder: (id: number, data: Partial<Order>) => client.patch<Order>(`/orders/${id}`, data),
  deleteOrder: (id: number) => client.delete(`/orders/${id}`),
};
```

## Mock Service Worker（MSW）

```typescript
// mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/v1/orders', ({ request }) => {
    const url = new URL(request.url);
    const status = url.searchParams.get('status');
    
    return HttpResponse.json({
      items: mockOrders.filter(o => !status || o.status === status),
      total: mockOrders.length,
    });
  }),
  
  http.post('/api/v1/orders', async ({ request }) => {
    const body = await request.json() as CreateOrderInput;
    const newOrder = { id: Date.now(), ...body, status: 'DRAFT' };
    return HttpResponse.json(newOrder, { status: 201 });
  }),
];

// 启用（dev / test）
import { worker } from './mocks/browser';
if (import.meta.env.DEV) {
  worker.start();
}
```

## queryKey 设计规范

```text
原则：层次化 + 唯一识别 + 可失效

✅ 推荐：
  ['orders']                          # 所有订单
  ['orders', { filter, page }]        # 筛选 + 分页
  ['orders', orderId]                 # 单个详情
  ['orders', orderId, 'items']        # 关联数据
  ['users', userId, 'orders']         # 嵌套

❌ 反例：
  `orders-${userId}-${page}`          # 字符串拼接
  ['orders' + userId]                  # 不易匹配 invalidate
  
失效策略：
  qc.invalidateQueries({ queryKey: ['orders'] })          # 失效所有 orders 开头
  qc.invalidateQueries({ queryKey: ['orders', orderId] })  # 仅失效该订单
```

## Loading 状态最佳实践

```text
4 种状态都要处理：
  isLoading        - 首次加载（无任何数据）
  isFetching       - 任何时候在请求（含后台刷新）
  isError          - 出错
  isSuccess        - 成功

UI 渲染：
  if (isLoading) → 骨架屏
  if (isError) → 错误页 + 重试按钮
  if (data && data.length === 0) → 空状态
  if (data) → 内容（同时 isFetching 时角标提示）
```

## 工作流程

```text
1. 选择数据获取库
   - REST → TanStack Query / SWR
   - GraphQL → Apollo / urql
   - Redux 已用 → RTK Query

2. 封装 API 客户端
   - 统一拦截 / Token / 错误
   - 类型定义（OpenAPI 生成最佳）

3. queryKey 设计
   - 与业务实体对应

4. 状态处理
   - Loading / Error / Empty / Success

5. 缓存策略
   - staleTime / gcTime
   - invalidate 时机

6. 乐观更新（关键操作）

7. Prefetch（路由 + hover）

8. Mock（MSW 开发环境）

9. 测试
   - 模拟成功 / 失败 / 慢网络
```

## 配套模板

- `templates/data-fetching-checklist.md` — API 客户端 + 缓存策略 + Loading/Error 处理 + Mock + 测试

## 质量自检

```text
□ 用专门库（TanStack Query / SWR）
□ API 客户端封装（拦截 / Token）
□ queryKey 层次化
□ staleTime / gcTime 配置
□ Loading / Error / Empty / Success 全状态
□ 错误统一处理 + 用户友好
□ 重试策略（404 / 403 不重试）
□ 乐观更新（关键操作）
□ Prefetch（路由 / hover）
□ keepPreviousData 切页防闪
□ Mock 覆盖（MSW 开发 + 测试）
□ 不在 useEffect 手撕 fetch
□ 不缓存敏感数据
```

## 常见坑

1. **手撕 useEffect + fetch**——重复请求 / 竞态 / 无缓存
2. **queryKey 字符串拼接**——失效困难
3. **不区分 isLoading / isFetching**——切页全屏 loading
4. **不处理 error 边界**——白屏
5. **不处理 empty**——返回空数组就空白
6. **不 keepPreviousData**——切页闪烁
7. **乐观更新不回滚**——失败 UI 不一致
8. **大量数据放 Redux**——应该 TanStack Query
9. **Mutation 后不 invalidate**——列表不更新
10. **轮询忘了取消**——离开页面还在请求
11. **不设超时**——慢网络挂死
12. **错误信息技术化**——用户看不懂
13. **缓存敏感数据到 localStorage**——XSS 风险
14. **GraphQL 过度抓取**——性能差

## 与其他 skill 的协作

```text
上游：
  api-designer 工作流 → OpenAPI 契约
  state-management → 服务端状态归这里

下游：
  forms-validation → mutation 提交
  routing-navigation → loader 数据
  performance-optimization → 缓存策略
  testing-frontend → MSW Mock
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 数据获取库
