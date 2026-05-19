# 前端技术栈组件全景图 2026

## 1. 状态管理

### React 生态

| 库 | 类型 | 大小 | 适合 | 推荐 |
|---|---|---|---|---|
| **useState / Context** | 内置 | 0 | 简单状态 | 小型 |
| **Redux Toolkit (RTK)** | 集中式 | 13KB | 复杂、企业、可追溯 | ⭐⭐⭐⭐ |
| **Zustand** | 简洁集中式 | 1KB | 中小型、易上手 | ⭐⭐⭐⭐⭐ |
| **Jotai** | 原子化 | 4KB | 细粒度、Recoil 替代 | ⭐⭐⭐⭐ |
| **Valtio** | Proxy | 3KB | 易用、Vue 风格 | ⭐⭐⭐ |
| **MobX** | 响应式 | 16KB | 类风格 | ⭐⭐⭐ |
| **XState** | 状态机 | 17KB | 复杂状态机 | ⭐⭐⭐⭐ |
| **Recoil** | 原子化 | 21KB | 已停止维护，用 Jotai | ⛔ |

### 服务端状态（必备）

| 库 | 适合 |
|---|---|
| **TanStack Query (React Query)** | 标杆，必学 |
| **SWR** | Vercel 出品，简洁 |
| **RTK Query** | 已用 Redux 时 |
| **Apollo Client** | GraphQL |
| **urql** | GraphQL 轻量 |
| **TanStack Router + Loaders** | 与路由整合 |

### 表单状态

| 库 | 适合 |
|---|---|
| **React Hook Form** | 主流，性能好 |
| **TanStack Form** | 类型安全 |
| **Formik** | 经典（维护少）|
| **Final Form** | 函数式 |

### Vue 3 生态

| 库 | 类型 | 适合 |
|---|---|---|
| **Pinia** | 官方推荐 | 主流 |
| **Vuex 4** | 旧（已不推荐）| 维护期 |
| **VueUse** | 工具组合式 | 必装 |
| **Pinia Colada** | 服务端状态 | 新兴 |

### Angular

```text
- NgRx                  - Redux 风格
- Akita                 - 简洁
- NGXS                  - 装饰器
- Signals（19+ 内置）  - 推荐
```

## 2. 样式方案

| 方案 | 类型 | 优缺点 |
|---|---|---|
| **Tailwind CSS** | 原子化 | 主流、生态最大、需培训 |
| **CSS Modules** | 局部 | 简单、安全 |
| **CSS-in-JS** | 运行时 | styled-components / Emotion |
| **vanilla-extract** | 编译时 | 类型安全、零运行时 |
| **UnoCSS** | 原子化 | Tailwind 兼容 + 更快 |
| **Linaria** | 编译时 CSS-in-JS | 性能好 |
| **Sass / Less** | 预处理 | 老牌 |
| **PostCSS** | 后处理 | 配套 |
| **Stitches** | CSS-in-JS（已停） | - |

### 推荐组合

```text
React 新项目：
  Tailwind CSS + shadcn/ui + Headless UI
  
Vue 新项目：
  UnoCSS + Element Plus 主题定制
  
设计系统强：
  CSS Modules + 自有 token + Headless UI
  
性能极致：
  vanilla-extract + 无 JS 样式
```

## 3. 路由

| 库 | 框架 | 特点 |
|---|---|---|
| **React Router 7** | React | 主流 |
| **TanStack Router** | React | 类型安全 |
| **Next.js Router** | Next.js | 文件路由 |
| **Vue Router 4** | Vue 3 | 主流 |
| **Nuxt Router** | Nuxt | 文件路由 |
| **Angular Router** | Angular | 内置 |
| **SvelteKit Router** | SvelteKit | 文件路由 |

## 4. 构建工具

| 工具 | 类型 | 速度 |
|---|---|---|
| **Vite** | 现代主流 | 快 |
| **Turbopack** | Vercel 新一代 | 极快（实验）|
| **esbuild** | Go 编写 | 极快 |
| **Webpack 5** | 老牌 | 慢但成熟 |
| **Rspack** | Rust 重写 webpack | 快 |
| **Rollup** | 库打包 | 快 |
| **Bun** | 多用途 | 快 |
| **Parcel 2** | 零配置 | 快 |

### 推荐

```text
新项目：
  应用 → Vite
  库 → Rollup / tsup
  Next.js → Turbopack（默认）

老项目升级：
  Webpack → Rspack（最少改动）
  CRA → Vite
```

## 5. 测试

### 单元 / 集成

| 库 | 适合 |
|---|---|
| **Vitest** | Vite 生态、Jest API 兼容 |
| **Jest** | 老牌、生态广 |
| **React Testing Library** | React 主流 |
| **Vue Test Utils** | Vue 官方 |
| **Angular Testing** | 内置 |
| **Mock Service Worker (MSW)** | API Mock 标杆 |

### E2E

| 库 | 适合 |
|---|---|
| **Playwright** | 主流（推荐）|
| **Cypress** | 老牌 |
| **Selenium** | 兼容性测试 |
| **WebDriverIO** | 适合 mobile |

### 视觉 / 组件

| 库 | 用途 |
|---|---|
| **Storybook** | 组件展示 + 测试 |
| **Chromatic** | 视觉回归（Storybook 出品）|
| **Percy** | 视觉回归 |
| **Playwright Component Testing** | 真实浏览器组件测试 |

## 6. UI 工具库

```text
日期：
  - date-fns（推荐）
  - dayjs（轻量）
  - luxon（i18n 强）
  - moment（已废弃）

图标：
  - Lucide Icons（推荐）
  - Heroicons（Tailwind 配套）
  - Phosphor Icons
  - React Icons（聚合）
  - Iconify（聚合，Vue/Svelte 友好）

动效：
  - Framer Motion（React 主流）
  - GSAP（强大）
  - Motion One（轻量）
  - Auto-Animate（简单）
  - Anime.js
  - View Transitions API（原生）

拖拽：
  - dnd-kit（React 主流）
  - SortableJS（通用）
  - react-dnd（老）

虚拟列表：
  - TanStack Virtual（推荐）
  - react-window
  - virtua（轻量）

富文本：
  - TipTap（推荐，基于 ProseMirror）
  - Lexical（Meta 出品）
  - Slate
  - Quill
  - Editor.js

代码编辑器：
  - Monaco Editor（VSCode 内核）
  - CodeMirror 6
  - Shiki（高亮）

国际化（i18n）：
  - react-i18next / i18next（主流）
  - Lingui
  - FormatJS
  - vue-i18n（Vue）

主题切换：
  - next-themes（Next.js）
  - useDarkMode（通用）

通知 / Toast：
  - Sonner（推荐）
  - react-hot-toast
  - react-toastify

模态：
  - Radix Dialog
  - Headless UI Dialog
```

## 7. 开发体验工具

```text
Linter / Formatter：
  - ESLint + Prettier（主流）
  - Biome（一体化、Rust 重写）
  - oxc（更快）

Type Check：
  - TypeScript（必装）
  - tsc 或 swc（编译）

Git Hooks：
  - Husky + lint-staged
  - simple-git-hooks（轻量）

Monorepo：
  - pnpm + workspaces
  - Turborepo（推荐）
  - Nx
  - Lerna（已不推荐）

包管理：
  - pnpm（推荐）
  - yarn（berry）
  - npm（默认）
  - Bun

CSS 工具：
  - Stylelint
  - PurgeCSS（已被 Tailwind 内置）
```

## 8. 性能优化工具

```text
分析：
  - Bundle Analyzer（webpack-bundle-analyzer）
  - Vite Bundle Visualizer
  - Source Map Explorer
  - Lighthouse / Lighthouse CI
  - Web Vitals
  - PageSpeed Insights

优化：
  - Sharp（图片处理）
  - Squoosh（图片压缩）
  - Plaiceholder（图片占位）
  - cssnano（CSS 压缩）
  - swc / esbuild（JS 压缩）

监控：
  - Web Vitals lib
  - Sentry Performance
  - Datadog RUM
  - New Relic Browser
  - Cloudflare Analytics
```

## 9. PWA / 离线

```text
PWA：
  - Workbox（Google 工具集）
  - Vite PWA Plugin
  - next-pwa
  - vite-plugin-pwa

离线存储：
  - IndexedDB（原生）
  - Dexie.js（IndexedDB 包装）
  - localForage
  - SQLite（WebAssembly，wa-sqlite）
  - PGlite（PostgreSQL WASM）

本地优先：
  - Replicache
  - PowerSync
  - ElectricSQL
  - RxDB
```

## 10. 数据可视化

```text
图表：
  - Apache ECharts（功能最全）
  - Chart.js（简单）
  - Recharts（React 简单）
  - Visx（D3 + React）
  - Nivo（美观）
  - Tremor（仪表盘）
  - Plotly（科学）
  - D3.js（底层）

3D：
  - Three.js
  - React Three Fiber
  - Babylon.js
  - Pixi.js（2D）

地图：
  - Mapbox GL JS
  - Leaflet
  - Google Maps API
  - 高德 / 百度地图（中国）
```

## 11. 实时通信

```text
WebSocket：
  - Socket.IO（主流）
  - native WebSocket
  - Phoenix Channels（Elixir 后端）
  - Ably / Pusher（SaaS）

SSE：
  - EventSource API（原生）
  - eventsource-parser

WebRTC：
  - simple-peer
  - PeerJS

实时同步：
  - Yjs（CRDT）
  - Automerge（CRDT）
  - PartyKit
```

## 12. 选型决策原则

```text
1. 优先项目已有的栈
   - 不为单次需求引入新技术

2. TypeScript 一等公民
   - 没有 TS 支持的库慎用

3. Tree-shake 友好
   - 看 Bundle 影响

4. 维护活跃
   - GitHub 30 天内有提交
   - Issue 关闭率 > 60%

5. 社区规模
   - npm 周下载 > 10K
   - Stars > 5K

6. License（MIT / Apache 优先）

7. 评估包大小
   - bundlephobia.com

8. 浏览器兼容
   - 看 caniuse + 项目目标

9. 无障碍（必查）
   - WCAG 2.2 AA
```
