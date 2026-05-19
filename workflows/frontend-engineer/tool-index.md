# 前端工程师工具索引

## 使用原则

1. 优先复用当前项目已有工具链。
2. 不为单次需求引入新组件库。
3. 评估包大小（bundlephobia.com）再引入。
4. 工具缺失时先检查本文件和根 `../../tool-index.md`。
5. 不在 bundle 中放密钥。

## 核心工具

详见 `references/frontend-frameworks-2026.md`、`references/frontend-component-libraries.md`、`references/frontend-tech-stack-guide.md`。

### 框架

| 框架 | 适合 |
|---|---|
| React 19 + Next.js 15 | 企业 SaaS、复杂交互 |
| Vue 3 + Nuxt 3 | 国内项目、中小团队 |
| Angular 18+ | 大企业 ERP/CRM |
| Svelte 5 + SvelteKit | 性能敏感 |
| Solid.js | 极致性能 |
| Astro | 内容站点 |

### 组件库

| 框架 | 推荐 |
|---|---|
| React | shadcn/ui / MUI / Ant Design / Mantine |
| Vue 3 | Element Plus / Naive UI / Ant Design Vue |
| Angular | Angular Material / NG-ZORRO |
| Svelte | shadcn-svelte / Skeleton |

### 状态管理

| 框架 | 推荐 |
|---|---|
| React | Zustand / TanStack Query / Jotai |
| Vue 3 | Pinia / TanStack Query |
| Angular | Signals / NgRx |

### 样式

| 方案 | 适合 |
|---|---|
| Tailwind CSS | 主流首选 |
| UnoCSS | Vue/Nuxt |
| CSS Modules | 简单可靠 |
| vanilla-extract | 类型安全 |

### 表单

| 框架 | 推荐 |
|---|---|
| React | React Hook Form + Zod |
| Vue 3 | VeeValidate + Zod |
| Angular | Reactive Forms |

### 测试

| 类型 | 工具 |
|---|---|
| 单元 | Vitest / Jest |
| 组件 | React Testing Library / Vue Test Utils |
| E2E | Playwright / Cypress |
| Mock | MSW |
| 视觉 | Storybook + Chromatic |
| a11y | axe-core / jest-axe |

### 构建

| 工具 | 适合 |
|---|---|
| Vite | 应用主流 |
| Turbopack | Next.js |
| Rspack | Webpack 替代 |
| Rollup / tsup | 库打包 |

### 性能

| 工具 | 用途 |
|---|---|
| Lighthouse CI | CI 集成 |
| web-vitals | RUM |
| Bundle Analyzer | 包分析 |
| Sentry Performance | 真实用户 |

### 部署

| 平台 | 适合 |
|---|---|
| Vercel | Next.js 首选 |
| Cloudflare Pages | 边缘 |
| Netlify | 通用 |
| Docker + Nginx | 自建 |

### 开发体验

| 工具 | 用途 |
|---|---|
| ESLint + Prettier / Biome | Lint + Format |
| TypeScript | 类型检查 |
| Husky + lint-staged | Git Hooks |
| pnpm | 包管理 |
| Turborepo / Nx | Monorepo |

## 模板入口

各 skill 的模板在 `skills/<skill-name>/templates/`。

## 参考资料入口

- `references/frontend-frameworks-2026.md` — 8 大框架对比
- `references/frontend-component-libraries.md` — 60+ 组件库
- `references/frontend-tech-stack-guide.md` — 12 类组件全景

## 高风险工具边界

以下操作需要评估：
- 组件库大版本升级（Breaking Changes）
- 框架迁移（React → Vue / CRA → Vite）
- 依赖安全漏洞修复
- CSP 配置变更
