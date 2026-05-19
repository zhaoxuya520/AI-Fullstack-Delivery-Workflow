# 路由设计模板

## 1. 项目信息

```text
路由方案：Next.js / React Router / TanStack Router / Vue Router / Angular / SvelteKit
渲染模式：CSR / SSR / SSG / Hybrid
负责人：
```

---

## 2. 路由表

| Path | 方法 | 组件 | 鉴权 | 角色 | 懒加载 | 备注 |
|---|---|---|---|---|---|---|
| / | GET | Home | ❌ | - | ✅ | 首页 |
| /login | GET | Login | ❌ | - | ✅ |  |
| /dashboard | GET | DashboardLayout | ✅ | * | ✅ |  |
| /dashboard/orders | GET | OrderList | ✅ | user/admin | ✅ |  |
| /dashboard/orders/:id | GET | OrderDetail | ✅ | resource owner | ✅ |  |
| /admin | GET | AdminLayout | ✅ | admin | ✅ |  |

---

## 3. 嵌套布局

```text
RootLayout
  ├── (Public)
  │     ├── Home
  │     ├── Login
  │     └── Register
  └── (Authenticated)
        ├── DashboardLayout
        │     ├── Orders
        │     ├── Products
        │     └── Settings
        └── AdminLayout
              ├── Users
              └── System
```

---

## 4. URL 状态规范

| 页面 | URL 状态 | 类型 |
|---|---|---|
| Order List | `?status=paid&page=2&sort=-createdAt` | 筛选 + 分页 + 排序 |
| Search | `?q=keyboard&category=electronics` | 搜索 + 筛选 |
| User Profile | `?tab=orders` | Tab 状态 |

---

## 5. 守卫层次

### 全局守卫（middleware）

```text
□ 未登录 → /login（带 redirect 参数）
□ 未完成 onboarding → /onboarding
□ Banned 用户 → /banned
□ 维护模式 → /maintenance
```

### 路由级守卫

```text
□ 角色检查（admin / manager）
□ 权限检查（feature flag）
□ 资源归属（A 不能看 B 的订单）
□ 数据预加载
```

### 组件级守卫

```text
□ 字段权限（隐藏按钮）
□ 二次确认（删除）
```

---

## 6. 懒加载策略

```text
□ 所有页面懒加载（默认）
□ 首屏 chunk < 200 KB
□ 路由 prefetch（hover / link 可见时）
□ Server Components 减少 JS（如 Next.js）
```

---

## 7. 错误处理

| 类型 | 页面 | 备注 |
|---|---|---|
| 404 Not Found | not-found.tsx | 全局 |
| 403 Forbidden | error.tsx | 路由级 |
| 500 Error | error.tsx | 兜底 |
| Loading | loading.tsx | 路由切换 |

---

## 8. SEO 配置（如 SSR）

```text
□ <title> 每页面动态
□ <meta description>
□ Open Graph
□ Twitter Card
□ canonical URL
□ robots.txt
□ sitemap.xml
□ 结构化数据（JSON-LD）
```

---

## 9. 性能

```text
□ 路由切换 < 300ms（已加载）
□ 首次进入 < 2.5s LCP
□ Prefetch 关键路径
□ Server Components / loaders 并行加载
□ 滚动恢复
```

---

## 10. 测试

```text
□ 公开路由可访问
□ 受保护路由需登录
□ 角色不足返 403 / 重定向
□ 资源归属检查
□ 404 路径渲染 NotFound
□ URL 状态持久化（刷新保持）
□ 后退前进正常
□ 滚动恢复
```

---

## 11. 自检

```text
□ URL 结构语义化
□ 嵌套布局合理
□ 全部懒加载
□ 三层守卫
□ URL 状态完整
□ 404 / loading / error 页面
□ SEO（如适用）
□ 滚动恢复
□ 测试覆盖
```
