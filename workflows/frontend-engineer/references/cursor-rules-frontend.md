# 前端 AI 编码规则集（Cursor/Claude/Copilot 通用）

> 来源：awesome-cursorrules + 社区最佳实践。适配到我们的工作流格式。
> 用途：AI 执行前端任务时自动加载，作为编码行为约束。

---

## React + TypeScript 通用规则

```text
代码风格：
- 使用函数组件 + Hooks（不用 class 组件）
- 组件用 PascalCase，hooks 用 camelCase（use 前缀）
- Props 类型用 interface 定义（不用 type，除非需要 union）
- 导出组件用 named export（不用 default export）
- 文件名与组件名一致

TypeScript：
- 启用 strict 模式
- 不用 any（用 unknown + 类型守卫）
- 优先用 satisfies 而不是 as
- API 响应用 Zod schema 校验（不要信任后端返回）
- 枚举用 const object + as const（不用 enum）

状态管理：
- 服务端状态用 TanStack Query（不放 Redux/Zustand）
- 全局客户端状态用 Zustand（简单）或 Jotai（原子）
- 表单状态用 React Hook Form + Zod
- URL 状态用 nuqs（类型安全 searchParams）

性能：
- 使用 React.lazy + Suspense 做代码分割
- 图片用 next/image 或 <img loading="lazy">
- 列表 > 50 条用虚拟化（@tanstack/react-virtual）
- 不要在 render 中创建新对象/函数（除非确认无影响）
- useMemo/useCallback 只在有性能问题时用（不要预优化）

错误处理：
- 用 Error Boundary 包裹页面级组件
- API 调用总是处理 loading/error/empty 三种状态
- 用 toast 展示操作反馈（不用 alert）
- 表单提交防重复（loading 状态 + disabled）
```

---

## Vue 3 + TypeScript 通用规则

```text
代码风格：
- 使用 <script setup lang="ts">（不用 Options API）
- 组件用 PascalCase（文件名也是）
- 使用 Composition API + Composables
- Props 用 defineProps<T>()（不用运行时声明）
- Emits 用 defineEmits<T>()

TypeScript：
- 启用 vue-tsc 严格检查
- Props 和 Emits 有完整类型
- Composable 返回值有明确类型
- ref/reactive 有泛型（ref<User | null>(null)）

状态管理：
- 用 Pinia（不用 Vuex）
- Store 用 setup 语法（不用 options）
- 服务端数据用 @tanstack/vue-query 或 Pinia Colada
- 不要把所有东西放 store（局部状态就局部）

组件设计：
- 单文件组件（SFC）标准结构：<script> → <template> → <style>
- scoped styles 或 CSS Modules
- slot 比 props 传递 VNode 更好
- provide/inject 用于深层依赖注入（不要 prop drilling 超过 3 层）
```

---

## Next.js 15 专属规则

```text
App Router：
- 默认用 Server Components（除非需要交互）
- 'use client' 只加在需要浏览器 API / hooks 的组件
- 数据获取在 Server Component 中直接 await（不用 useEffect）
- 用 loading.tsx / error.tsx / not-found.tsx 做界面状态
- Metadata 用 generateMetadata 函数（不硬编码 <title>）

路由：
- 动态路由用 [slug] / [...slug] / [[...slug]]
- 路由组用 (group) 组织布局
- 平行路由用 @slot 做复杂布局
- 拦截路由用 (..) 做 Modal

数据：
- Server Actions 替代简单 API Route
- 用 revalidatePath / revalidateTag 做缓存失效
- 大型列表用 Server Components + streaming

性能：
- 用 next/image（自动优化 + WebP/AVIF）
- 用 next/font（零布局偏移字体加载）
- 动态导入（next/dynamic）延迟加载重组件
- Partial Prerendering（PPR）混合静态+动态
```

---

## Nuxt 3 专属规则

```text
约定：
- 页面在 pages/（自动路由）
- 组件在 components/（自动导入）
- Composables 在 composables/（自动导入）
- Server API 在 server/api/（Nitro）
- 中间件在 middleware/

数据：
- useFetch / useAsyncData 做数据获取（不用 axios + onMounted）
- 用 $fetch 做非 SSR 请求
- 用 useState 做跨组件共享状态

SEO：
- useHead / useSeoMeta 管理 meta
- 动态页面用 definePageMeta
- 用 NuxtLink 做预取
```

---

## Tailwind CSS 规则

```text
原则：
- utility-first（不写自定义 CSS 除非真有必要）
- 用 @apply 仅在需要复用的基础组件中
- 响应式用 sm: md: lg: xl: 前缀
- 暗黑模式用 dark: 前缀
- 动态类名不要字符串拼接（用 clsx/cn）

组织：
- 顺序：布局 → 盒模型 → 排版 → 视觉 → 交互
- 组件长类名提取到变量或 cn() 函数
- 自定义主题在 tailwind.config（不直接写 px 值）

v4 新特性：
- CSS-first 配置（用 @theme 替代 tailwind.config）
- 原生嵌套
- 容器查询（@container）
```

---

## 通用 Git 提交规则

```text
格式：<type>(<scope>): <subject>

type:
  feat     新功能
  fix      Bug 修复
  docs     文档变更
  style    代码格式（不影响逻辑）
  refactor 重构
  perf     性能优化
  test     测试
  build    构建/依赖
  ci       CI/CD
  chore    杂务

scope: 模块名（可选）
subject: 50字以内，不加句号，现在时态

示例：
  feat(auth): add WeChat OAuth login
  fix(order): prevent duplicate payment submission
  docs(readme): update deployment instructions
```
