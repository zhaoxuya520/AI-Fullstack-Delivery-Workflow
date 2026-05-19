---
name: api-frontend-integration
description: 前后端联调时使用。适用于 Mock → 真实切换、字段对齐、错误处理对接、Token 传递验证。融合 MSW Mock + 类型共享 + 联调清单。
---

# 前后端联调（API-Frontend Integration）

## 适用场景

- Mock 切换到真实 API
- 前后端字段名 / 类型对齐
- 错误码 → 前端提示映射
- Token / Cookie 传递验证
- 分页 / 筛选 / 排序参数对接
- 文件上传联调
- WebSocket / SSE 联调

## 核心原则

```text
1. 类型共享（TypeScript 端到端）
   tRPC / OpenAPI 生成 / 共享 types 包

2. Mock 先行
   前端用 MSW Mock 开发
   后端就绪后切换

3. 错误码映射表
   后端 error.code → 前端 toast / 字段错误

4. 边写边调
   不要等全部写完再联调

5. 联调清单
   每个端点逐条验证
```

## 类型共享方案

### tRPC（最佳，端到端类型安全）

```typescript
// server/router.ts
export const appRouter = router({
  orders: {
    list: publicProcedure
      .input(z.object({ page: z.number(), status: z.string().optional() }))
      .query(async ({ input }) => {
        return await db.order.findMany({ where: { status: input.status } });
      }),
    create: publicProcedure
      .input(createOrderSchema)
      .mutation(async ({ input }) => {
        return await db.order.create({ data: input });
      }),
  },
});

export type AppRouter = typeof appRouter;

// client（自动类型推导）
const { data } = trpc.orders.list.useQuery({ page: 1 });
// data 类型自动推导，无需手写
```

### OpenAPI 生成类型

```bash
# 从 OpenAPI spec 生成 TypeScript 类型
npx openapi-typescript api.yaml -o src/types/api.ts

# 或用 orval 生成 hooks
npx orval --input api.yaml --output src/api/
```

### 共享 types 包（Monorepo）

```text
packages/
├── types/           ← 共享类型
│   └── src/
│       ├── order.ts
│       └── user.ts
├── api/             ← 后端
└── web/             ← 前端
```

## Mock → 真实切换

```typescript
// 1. 开发时用 MSW
// mocks/handlers.ts
export const handlers = [
  http.get('/api/orders', () => HttpResponse.json(mockOrders)),
];

// 2. 后端就绪后关闭 MSW
// 环境变量控制
if (import.meta.env.VITE_ENABLE_MOCKS === 'true') {
  const { worker } = await import('./mocks/browser');
  worker.start();
}

// 3. 切换后逐条验证
```

## 联调清单（每个端点）

```text
□ URL 路径一致
□ HTTP 方法一致
□ 请求字段名一致（snake_case / camelCase）
□ 请求字段类型一致
□ 响应字段名一致
□ 响应字段类型一致
□ 分页参数（page / limit / cursor）
□ 排序参数（sort / order）
□ 筛选参数
□ 错误码 → 前端处理
□ Token 传递（Header / Cookie）
□ CORS 配置
□ Content-Type 正确
□ 文件上传（multipart）
□ 空结果处理
□ 大数据量（分页正确）
```

## 错误码映射

```typescript
// 后端返回
{ "error": { "code": "INSUFFICIENT_STOCK", "message": "库存不足" } }

// 前端映射
const ERROR_MESSAGES: Record<string, string> = {
  VALIDATION_ERROR: '请检查输入',
  INSUFFICIENT_STOCK: '库存不足，请减少数量',
  RESOURCE_NOT_FOUND: '数据不存在',
  FORBIDDEN: '无权限',
  RATE_LIMITED: '操作过于频繁，请稍后重试',
};

function handleApiError(error: ApiError) {
  const message = ERROR_MESSAGES[error.code] ?? '操作失败，请重试';
  toast.error(message);
  
  // 字段级错误
  if (error.code === 'VALIDATION_ERROR' && error.details) {
    error.details.forEach(d => form.setError(d.field, { message: d.message }));
  }
}
```

## 配套模板

- `templates/integration-checklist.md` — 联调清单 + 错误映射 + 类型共享方案

## 质量自检

```text
□ 类型共享（tRPC / OpenAPI / 共享包）
□ Mock 先行（MSW）
□ 每个端点逐条联调
□ 错误码映射完整
□ Token 传递正确
□ CORS 配置正确
□ 分页 / 筛选对接
□ 空结果处理
□ 文件上传（如有）
□ 联调后 Mock 可关闭
```

## 常见坑

1. **字段名不一致**——后端 snake_case 前端 camelCase
2. **类型不一致**——后端 string ID 前端 number
3. **CORS 未配**——浏览器拦截
4. **Token 位置不对**——Cookie vs Header
5. **错误码不映射**——前端显示 "INTERNAL_ERROR"
6. **分页参数不对**——page 从 0 还是 1
7. **时间格式不一致**——ISO 8601 vs timestamp
8. **空数组 vs null**——前端 .map() 崩溃
9. **大数字精度丢失**——JSON number > 2^53
10. **文件上传 Content-Type 错**——不是 JSON

## 与其他 skill 的协作

```text
上游：
  e2e-feature-delivery → 联调是交付的一部分
  database-schema-impl → 字段来源

下游：
  deploy-preview → 联调通过后部署
```
