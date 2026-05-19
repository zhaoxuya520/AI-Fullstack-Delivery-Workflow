# 数据获取检查清单

## 1. 项目信息

```text
库：TanStack Query / SWR / Apollo / RTK Query
API 风格：REST / GraphQL
Mock：MSW / 自建
负责人：
```

---

## 2. API 客户端配置

```text
□ 统一 baseURL（环境变量）
□ 超时（10s）
□ 请求拦截：Token / Trace ID
□ 响应拦截：错误转换 / 401 刷新
□ TypeScript 类型（OpenAPI 生成）
□ 错误类（ApiError / 业务码）
```

---

## 3. queryKey 设计

| 业务实体 | queryKey 模式 | 用途 |
|---|---|---|
| 列表 | `['orders', { filter, page, sort }]` | 列表 + 筛选 |
| 详情 | `['orders', orderId]` | 单个详情 |
| 关联 | `['orders', orderId, 'items']` | 子资源 |
| 嵌套 | `['users', userId, 'orders']` | 用户的订单 |
| 全局 | `['currentUser']` | 当前用户 |

---

## 4. 缓存策略

| 数据类型 | staleTime | gcTime | refetchOnWindowFocus |
|---|---|---|---|
| 用户偏好 | 30 min | 1 hour | false |
| 列表（实时性强）| 30 sec | 5 min | true |
| 详情 | 5 min | 30 min | true |
| 配置 | 1 hour | 1 day | false |
| 静态数据 | Infinity | Infinity | false |

---

## 5. 状态处理

每个查询页面：

```text
□ isLoading → 骨架屏 / 占位
□ isError → ErrorState + 重试按钮
□ isSuccess + 空 → EmptyState
□ isSuccess + 有数据 → Content
□ isFetching（后台刷新）→ 角标 / 不阻塞
```

---

## 6. Mutation 清单

| Mutation | invalidate 列表 | 乐观更新 | 错误处理 |
|---|---|---|---|
| createOrder | ['orders'] | ❌ | toast 错误 |
| updateOrder | ['orders'], ['orders', id] | ✅ | 回滚 + toast |
| deleteOrder | ['orders'] | ✅ | 回滚 + toast |
| toggleFavorite | - | ✅ | 回滚（无感）|

---

## 7. Prefetch 策略

```text
□ Link hover 预加载
□ 路由 loader 预加载
□ 页面初始化预加载首屏
□ 预加载控制频率（防滥用）
```

---

## 8. 错误处理

| 错误类型 | 处理 |
|---|---|
| 网络错误 | 自动重试 3 次 |
| 401 | 刷新 Token / 重新登录 |
| 403 | 提示无权限 |
| 404 | 显示 NotFound |
| 409 | 显示冲突 + 操作建议 |
| 422 | 字段级错误提示 |
| 429 | 限流提示 + 退避 |
| 5xx | 自动重试 + 兜底提示 |

---

## 9. 重试策略

```typescript
retry: (failureCount, error) => {
  // 不可重试错误：4xx
  if (error.status && error.status < 500) return false;
  // 5xx 重试 3 次
  return failureCount < 3;
},
retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
```

---

## 10. Mock 配置

```text
□ MSW handlers（每个端点）
□ 成功响应
□ 失败响应（每种错误码）
□ 慢响应模拟
□ 无网络模拟
```

---

## 11. 测试

```text
□ 成功路径
□ 失败路径（每种错误）
□ 慢网络（loading 状态）
□ 空数据（empty 状态）
□ 重试逻辑
□ 乐观更新 + 回滚
□ 缓存命中
□ Invalidate 流程
```

---

## 12. 性能

```text
□ 用 keepPreviousData 防闪
□ 用 select 只取需要字段
□ 大数据用虚拟列表
□ Prefetch 关键路径
□ DevTools 监控（开发）
```

---

## 13. 自检

```text
□ 用专门库（不手撕）
□ API 客户端封装
□ queryKey 规范
□ 缓存策略明确
□ 4 状态全处理
□ 错误统一处理
□ Mutation 后 invalidate
□ 关键操作乐观更新
□ Prefetch 关键路径
□ Mock 覆盖
□ 测试覆盖
□ 不缓存敏感数据
```
