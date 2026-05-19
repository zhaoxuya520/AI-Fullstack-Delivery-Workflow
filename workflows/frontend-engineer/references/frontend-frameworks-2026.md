# 前端框架全景 2026

参考：State of JS 2025、Stack Overflow Developer Survey、State of Frontend、Bundlephobia、各官方文档、GitHub Stars / npm 下载量。

> 持续更新。AI 工作流每次新建前端项目前都应快速过一遍。

## 1. 选型决策树

```text
Q1：项目类型？
  内容站 / 博客 / 营销 → Astro / Next.js（ISR）
  仪表盘 / 后台 → React + Next.js / Vue 3 + Nuxt
  实时高交互 → React + Vite / Vue 3
  移动端 SPA → React Native / Flutter（跨端）
  桌面 → Tauri + 任意框架
  小程序 → Taro / uni-app

Q2：团队语言能力？
  TS 强 → React、Solid、Angular
  TS 一般 → Vue 3
  喜欢约定 → Angular、Nuxt
  喜欢灵活 → React、Vue

Q3：性能要求？
  极致首屏 → Astro、Qwik
  超低包体 → Svelte、Solid
  通用 → 任意

Q4：SSR / CSR / SSG？
  SEO 重要 → SSR / SSG / ISR
  纯应用 → CSR
  混合 → Server Components（Next.js / SvelteKit）
```

## 2. 框架完整档案

### React 19

```text
官网: react.dev
最新: 19 (2024-12)
GitHub Stars: 230K+
适合: 企业级 SaaS、复杂交互、招聘市场最大

核心特性:
  - Hooks（useState/useEffect/useMemo...）
  - Server Components
  - useTransition / useDeferredValue
  - Suspense 流式渲染
  - Actions（表单 + 异步）
  - 编译器（实验）

性能:
  - 中等（用 Vite + 优化可达 95+ Lighthouse）
  - 包大小 React + ReactDOM ~ 45KB

招聘市场:
  - 全球占有率 >40%
  - 国内大厂主流

何时选:
  ✅ 复杂业务、多团队、长期项目
  ✅ 需要海量第三方库
  ❌ 内容站点（用 Astro）
```

### Vue 3.5+

```text
官网: vuejs.org
最新: 3.5 (2025), 3.6 在路上（性能大改）
GitHub Stars: 215K+
适合: 国内项目、中小团队、易上手

核心特性:
  - Composition API + <script setup>
  - SFC（单文件组件）
  - Reactivity 系统（自动追踪）
  - Pinia（官方状态库）
  - Suspense / Teleport

性能:
  - 优秀（响应式自动优化）
  - 包大小 Vue ~ 34KB

招聘市场:
  - 国内主流（阿里、百度、字节、美团多用）
  - 国际偏少（与 React 比）

何时选:
  ✅ 中小团队、国内项目
  ✅ 喜欢约定 + 灵活兼顾
  ❌ 美国市场（招聘窄）
```

### Angular 18+

```text
官网: angular.dev
最新: 19 (2024-11)
GitHub Stars: 96K+
适合: 大企业、ERP / CRM、长期项目

核心特性:
  - Standalone Components（取代 NgModule）
  - Signals（细粒度响应）
  - SSR + Hydration
  - RxJS 深度集成
  - 强类型 + 装饰器
  - Material Design 官方

性能:
  - 中等（包大小较大 ~ 100KB）
  - 编译时优化好

招聘市场:
  - 企业级稳定、银行 / 政府常见

何时选:
  ✅ 大型 ERP / CRM
  ✅ 团队 50+ 人，需要约定
  ❌ 创业 MVP（重）
```

### Svelte 5 + SvelteKit

```text
官网: svelte.dev
最新: 5 (2024-10) — Runes 模式
GitHub Stars: 80K+
适合: 性能敏感、初学者

核心特性:
  - Compile-time（不需要运行时）
  - Runes（$state / $derived / $effect）
  - 零虚拟 DOM
  - 包小（hello world ~ 1.5KB）

性能:
  - 顶级（Lighthouse 接近 100）
  - State of JS 满意度第一

招聘市场:
  - 较小但增长快

何时选:
  ✅ 性能极致、包小
  ✅ 1~3 人小团队
  ❌ 大型企业（生态不如 React）
```

### Solid.js

```text
官网: solidjs.com
GitHub Stars: 32K+
适合: 高交互应用、React 用户想要更快

核心特性:
  - Signals（细粒度响应，不重渲染）
  - JSX（与 React 类似）
  - 极致性能（接近原生）
  - SolidStart（元框架）

性能:
  - 顶级（与 Svelte 并肩）
  - 包小 ~ 7KB

何时选:
  ✅ 性能极致 + 喜欢 JSX
  ❌ 生态不如 React（招聘少）
```

### Astro

```text
官网: astro.build
GitHub Stars: 47K+
适合: 内容站点、博客、营销页

核心特性:
  - Islands 架构（默认 0 JS）
  - 多框架混用（React + Vue + Svelte 同站）
  - 内置 MDX、内容集合
  - SSR / SSG / Hybrid

性能:
  - 顶级（默认无 JS）

何时选:
  ✅ 内容驱动、SEO 关键
  ❌ 高交互应用（不擅长）
```

### Qwik

```text
官网: qwik.dev
GitHub Stars: 22K+
适合: 启动性能敏感

核心特性:
  - Resumable（不 hydrate，从服务端 resume）
  - 0ms 加载
  - Lazy loading 极致

何时选:
  ✅ 启动性能极致（电商首屏）
  ❌ 学习成本高
```

## 3. 性能基准（Web Vitals）

```text
LCP (Largest Contentful Paint) — 越低越好（目标 < 2.5s）：
  Astro              0.8s ★★★★★
  Qwik               0.9s ★★★★★
  SvelteKit          1.2s ★★★★★
  Next.js            1.5s ★★★★
  Nuxt               1.5s ★★★★
  React + Vite       1.8s ★★★★
  Angular            2.5s ★★★

包大小（hello world，越小越好）：
  Svelte             1.5 KB ★★★★★
  Solid              7 KB ★★★★★
  Vue                34 KB ★★★★
  React              45 KB ★★★★
  Angular            100 KB ★★★

注：实际项目业务代码占大头，框架本身差距不大
```

## 4. 元框架对比

| 框架 | 基础 | SSR | SSG | ISR | RSC | Streaming |
|---|---|---|---|---|---|---|
| **Next.js 15** | React | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Nuxt 3.13** | Vue 3 | ✅ | ✅ | ✅ | 🔄 | ✅ |
| **SvelteKit** | Svelte | ✅ | ✅ | ✅ | - | ✅ |
| **Remix** | React | ✅ | - | - | - | ✅ |
| **TanStack Start** | React | ✅ | - | - | ✅ | ✅ |
| **SolidStart** | Solid | ✅ | ✅ | - | - | ✅ |
| **Analog** | Angular | ✅ | ✅ | - | - | ✅ |
| **Astro** | 多 | ✅ | ✅ | ✅ | - | - |

## 5. 大厂技术栈案例

```text
Meta:
  Facebook / Instagram - React + Relay (GraphQL)
  WhatsApp Web - React

Google:
  YouTube - 自研框架
  Gmail - Polymer / 自研
  Google Maps - 自研

Netflix:
  网页 - React
  TV App - React Native

Vercel:
  全部 - Next.js（自家产品）

GitHub:
  网页 - React + Rails

Shopify:
  Hydrogen - Remix（Storefront）
  Admin - React

Twitter/X:
  Web - React
  Mobile - React Native

Discord:
  Web - React + Redux

LinkedIn:
  Web - Ember.js（迁移中）+ React
  
TikTok:
  Web - React

Adobe:
  React + 自研工具

阿里巴巴:
  各产品 - React / Vue 混用
  Ant Design / Fusion - React

字节跳动:
  抖音 / TikTok Web - React
  飞书 - React

腾讯:
  PC 端 - React 多
  小程序 - 自研 + Taro

百度:
  Vue 3 + React 混用
```

## 6. 渲染模式选择

```text
CSR（Client-Side Rendering）：
  ✅ 适合：纯应用（管理后台）
  ❌ 不适合：SEO

SSR（Server-Side Rendering）：
  ✅ 适合：动态内容 + SEO
  ❌ 不适合：高并发（每次都渲染）

SSG（Static Site Generation）：
  ✅ 适合：内容不常变（博客、文档）
  ❌ 不适合：用户个性化

ISR（Incremental Static Regeneration）：
  ✅ 适合：内容定期更新（新闻、电商列表）

Server Components（React 19）：
  ✅ 适合：减少客户端 JS
  ❌ 不适合：高交互组件
```

## 7. 选型反模式

```text
❌ "因为大厂用所以选 React"
   → 业务体量不同，需求不同

❌ "Vue 中文文档好就 Vue"
   → 全球团队 / 国际化项目用 React

❌ "包小所以 Svelte"
   → 业务代码占大头，框架本身差距小

❌ "Angular 太重"
   → 大企业项目反而合适

❌ "Astro 内容站，所以应用也用 Astro"
   → 高交互不适合
```

## 8. 持续学习资源

```text
官方文档（首选）：
  - react.dev
  - vuejs.org
  - angular.dev
  - svelte.dev

调研报告：
  - State of JS（每年）
  - State of Frontend
  - Stack Overflow Survey

GitHub Trending：
  - https://github.com/trending/javascript

技术博客：
  - Dan Abramov（React 核心）
  - Evan You（Vue 作者）
  - Rich Harris（Svelte 作者）
  - Ryan Carniato（Solid 作者）

性能基准：
  - JS Framework Benchmark
  - Lighthouse / Web Vitals
```
