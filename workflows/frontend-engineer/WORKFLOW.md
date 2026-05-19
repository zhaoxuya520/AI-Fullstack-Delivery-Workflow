# 前端工程师工作流（Frontend Engineer Workflow）

## 定位

前端工程师工作流负责把 UI/UX 设计稿、API 契约和业务规则，转化为 **可访问、可维护、高性能、可测试** 的前端实现：组件、状态管理、路由、表单、接口集成、性能优化、可访问性、测试、构建与部署。

它不替代 UI/UX 设计工作流（视觉与交互定义）、API 设计工作流（契约定义）、QA 工作流（测试用例）、DevOps 工作流（部署）。它负责 **把设计变成可运行的代码**。

本工作流采用 **skills 模块化架构**：总控负责路由、技术栈选型和通用规则，具体方法论拆分成独立 skills，按需加载。**支持所有主流前端技术栈**（React / Vue 3 / Angular / Svelte / Solid / Astro / Qwik）。

---

## 适用场景

```text
组件实现（按设计稿）
状态管理（client / server / form / URL）
路由与导航
表单处理与校验
API 集成（REST / GraphQL）
性能优化（包大小 / 渲染 / 网络）
可访问性（WCAG 2.2）
浏览器兼容性
SSR / SSG / ISR
PWA / 离线
组件库选型与封装
单元 / 集成 / E2E 测试
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 设计稿不清 / 设计 token 缺失 | UI/UX 设计工作流 |
| API 契约未定 | API 设计工作流 |
| 后端业务逻辑 | 后端工程师工作流 |
| 单元 / E2E 测试用例设计 | QA 工作流 |
| CI/CD / Docker / 部署 | DevOps 工程师工作流 |
| 监控告警 | SRE/运维工作流 |
| 安全漏洞验证 | 安全工程师工作流 |

---

## 技术栈选型矩阵（2026）

| 业务类型 | 首选 | 备选 | 不推荐 |
|---|---|---|---|
| **企业级 SaaS / 后台** | React + Next.js / Vue 3 + Nuxt | Angular | jQuery |
| **快速 MVP / 创业** | Next.js、Nuxt、SvelteKit | Vite + React | Angular（重）|
| **内容营销站点** | Astro、Next.js（ISR）| Nuxt、SvelteKit | CRA |
| **超高交互（仪表盘）** | React + TanStack Query | Vue 3 + Pinia | - |
| **超轻量页面** | Svelte、Solid、Astro | Hono + JSX | - |
| **移动端 SPA** | React Native / Flutter（跨端）| Ionic / Quasar | - |
| **桌面应用** | Tauri、Electron | NW.js | - |
| **小程序** | Taro、uni-app | mpvue | - |

### 主流框架特点速查

| 框架 | 风格 | 特点 | 适合 |
|---|---|---|---|
| **React 19** | 函数 + Hooks | 生态最大、招聘最多、Server Components | 企业、SaaS、复杂 SPA |
| **Vue 3** | 单文件 + Composition API | 易上手、Pinia / Nuxt 完整 | 国内项目、中小团队 |
| **Angular 18** | 类 + 装饰器 + RxJS | 企业级、强类型、约定多 | 大企业、ERP/CRM |
| **Svelte 5 / SvelteKit** | Compile-time | 包小、性能好、Runes 模式 | 性能敏感、初学者 |
| **Solid.js** | 函数 + signals | 极致性能、类似 React | 高交互应用 |
| **Astro** | 多框架混用 | Islands 架构、零 JS 默认 | 内容站点、博客 |
| **Qwik** | Resumable | 0ms 加载、Lazy 极致 | 启动性能敏感 |

### 元框架（Meta-Framework）

| 框架 | 基于 | 渲染模式 |
|---|---|---|
| **Next.js 15** | React | SSR/SSG/ISR/Server Components |
| **Nuxt 3** | Vue 3 | SSR/SSG/ISR |
| **SvelteKit** | Svelte | SSR/SSG |
| **Remix** | React | SSR + Loaders |
| **TanStack Start** | React | 类型安全 + Server Functions |

---

## 输入

### 必需输入

```text
UI/UX 设计稿（Figma / Sketch）
设计 Token（颜色 / 字体 / 间距）
API 契约（OpenAPI / Mock）
组件清单与状态说明（来自 ui-ux-designer/component-states）
路由结构
权限矩阵（哪些页面 / 操作按角色）
浏览器支持目标
性能目标（LCP / FID / CLS）
```

### 可选输入

```text
现有组件库 / 设计系统
i18n / 多语言
SEO 要求
SSR / CSR 选择
PWA / 离线要求
分析埋点要求
A/B 测试要求
```

### 输入不足时先补问

```text
1. 设计稿在哪？是否完整（含交互状态）？
2. 设计 Token 是否冻结？
3. 组件库已选 or 自建？
4. API 契约 OpenAPI 在哪？
5. 路由结构与权限规则？
6. SSR / CSR 决定？
7. 浏览器支持范围？
8. 性能目标 LCP / FID / CLS？
9. 是否有现有组件库 / 设计系统可复用？
10. i18n / 主题切换 / 暗黑模式？
```

---

## 完整行为链（硬性流程）

```text
1. 读取设计稿 / API 契约 / 组件清单
   ↓
2. 检查 field-journal/_index.md → 是否有同类组件经验可复用
   ↓
3. 确认技术栈和组件库
   ↓
4. 读取 skills/routing.md → 路由到需要的 skills
   ↓
5. 判断实现复杂度（S/M/L/XL）
   ↓
6. 设计组件架构 → 实现 → 单元测试 → E2E → Storybook
   ↓
7. 加载命中 skills → 按 skill 内方法 + 框架范式执行
   ↓
8. 输出代码 + Storybook + 测试 + 性能报告
   ↓
9. 转交 QA / 后端联调 / DevOps
   ↓
10. 按 EVOLUTION.md 沉淀经验 → 回写 field-journal
```

---

## Skills 模块总览

每个 skill 独立可用，按需组合。**每个 skill 都覆盖多框架范式**。详细路由见 `skills/routing.md`。

| Skill | 适用场景 | 覆盖框架 |
|-------|---------|---------|
| [component-architecture](skills/component-architecture/SKILL.md) | 组件设计 / 拆分 / 复用 | React / Vue / Angular / Svelte |
| [state-management](skills/state-management/SKILL.md) | 状态管理 | Redux Toolkit / Zustand / Jotai / Pinia / TanStack Query / Signals |
| [styling-system](skills/styling-system/SKILL.md) | 样式方案 | Tailwind / CSS Modules / styled-components / UnoCSS / vanilla-extract |
| [routing-navigation](skills/routing-navigation/SKILL.md) | 路由 / 导航 / 权限 | Next.js / React Router / Vue Router / Angular Router |
| [forms-validation](skills/forms-validation/SKILL.md) | 表单 / 校验 | React Hook Form + Zod / VeeValidate / Formily |
| [data-fetching](skills/data-fetching/SKILL.md) | API 集成 / 缓存 / 同步 | TanStack Query / SWR / RTK Query / Pinia Colada |
| [performance-optimization](skills/performance-optimization/SKILL.md) | 性能优化 | Web Vitals / Bundle / Image / Code Splitting |
| [accessibility-implementation](skills/accessibility-implementation/SKILL.md) | 可访问性实现 | ARIA / 键盘导航 / 屏幕阅读器 |
| [testing-frontend](skills/testing-frontend/SKILL.md) | 前端测试 | Vitest / Jest / RTL / Playwright / Cypress / MSW |
| [build-deploy](skills/build-deploy/SKILL.md) | 构建 / 部署 / 优化 | Vite / Turbopack / Webpack / Vercel / Cloudflare |
| [miniprogram-development](skills/miniprogram-development/SKILL.md) | 小程序开发 | 微信 / Taro / uni-app 多端 |
| [mobile-hybrid](skills/mobile-hybrid/SKILL.md) | 移动端跨平台 | React Native / Flutter / Expo / Tauri |

---

## 禁止行为

```text
❌ 不在设计稿不全时直接实现（必返工）
❌ 不在 API 契约不清时硬编码 Mock
❌ 不滥用全局状态（能局部就局部）
❌ 不忽略 loading / error / empty 状态
❌ 不忽略可访问性（不是 nice-to-have）
❌ 不为单一需求引入新组件库
❌ 不写没有类型的 TS 代码（any 滥用）
❌ 不绕过设计 Token 硬编码颜色 / 间距
❌ 不忽略性能（首屏 / 包大小 / 图片）
❌ 不忽略浏览器兼容（Safari / 移动端）
❌ 不直接修改第三方组件库源码（封装一层）
❌ 不写没有测试的核心组件
❌ 不混用样式方案
❌ 不日志输出敏感信息
❌ 不跳过 Code Review
```

---

## 任务复杂度分级

```text
S 级（10~30 分钟）：单组件 / 单页面修改 / 简单 Bug
  → component-architecture + testing-frontend

M 级（30~120 分钟）：单功能模块（页面 + 状态 + 表单）
  → + state-management + forms-validation + data-fetching + styling-system

L 级（2~6 小时）：复杂业务 / 新模块 / 性能优化
  → 加 routing-navigation + performance-optimization + accessibility-implementation

XL 级（6 小时+）：核心产品 / 重构 / 架构演进
  → 全部 10 skills + build-deploy 重点
```

---

## 通用质量检查

```text
□ 设计稿 100% 还原（含交互状态）
□ 所有状态实现：loading / empty / error / 无权限
□ 响应式（移动端 / 平板 / 桌面）
□ 键盘可操作（Tab / Enter / Esc）
□ ARIA 角色与属性正确
□ 屏幕阅读器友好（已用 NVDA / VoiceOver 测）
□ 颜色对比度（WCAG AA 4.5:1）
□ 表单校验完整（前端 + 后端）
□ 错误友好（含 trace_id 给客服）
□ 性能目标达成（LCP < 2.5s / FID < 100ms / CLS < 0.1）
□ 包大小（首屏 JS < 200KB）
□ 图片优化（webp/avif / 懒加载 / responsive）
□ 单元测试覆盖核心逻辑
□ Storybook 覆盖组件
□ E2E 测试关键流程
□ 浏览器兼容（Chrome / Safari / Firefox / Edge）
□ i18n 字符串外置
□ 设计 Token 用变量
□ Code Review 通过
```

---

## 常见坑（跨 skill 通用）

```text
1. 状态管理过度（Context / Redux 滥用）
2. 缺 loading / error 状态 → UI 闪烁
3. 表单不防重复提交 → 重复请求
4. useEffect 滥用 / 依赖错 → 死循环
5. 大列表不虚拟化 → 卡顿
6. 图片不优化 → LCP 差
7. CSS 全局污染 → 难维护
8. 写死颜色不用 token → 主题切换难
9. 不写类型 / any 滥用 → 重构地狱
10. 不测可访问性 → 残障用户被排除
11. 包过大不分割 → 首屏慢
12. 不缓存 API 响应 → 重复请求
13. 直接改第三方组件源码 → 升级地狱
14. SSR / CSR 混用导致 hydration 错误
15. 跳过 i18n 准备 → 国际化时大改
16. 不监控真实用户性能（RUM）
```

---

## 与其他工作流的协作

### 上游

| 上游工作流 | 前端需要的输入 |
|---|---|
| UI/UX 设计工作流 | Figma 设计稿、Token、组件状态、流程 |
| API 设计工作流 | OpenAPI 契约、Mock、错误码 |
| 后端工程师工作流 | API 实现、错误码示例、联调环境 |
| 产品经理工作流 | PRD、用户故事、验收标准 |
| 项目经理工作流 | 任务拆解、依赖、里程碑 |

### 下游

| 下游工作流 | 前端交付内容 |
|---|---|
| QA 工作流 | 联调通过的 UI、可测试性钩子（data-testid）|
| 自动化测试工作流 | E2E 测试代码 |
| DevOps 工作流 | 构建产物、Dockerfile、配置 |
| SRE 工作流 | RUM 数据、Sentry 集成、性能监控 |
| 技术文档工作流 | Storybook、组件 API 文档 |
| 安全工程师工作流 | 第三方依赖清单、CSP 配置 |

---

## 多任务与中断处理

```text
1. 多页面并行：每个独立分支 + Storybook 隔离测试
2. 中途中断：保存进度（已完成组件 + 待联调 + 阻塞）
3. API 契约变更：评估影响 → Mock 更新 → 重新联调
4. 设计变更：评估影响 → 走变更流程
```

---

## 自进化要求

任务完成后按 `EVOLUTION.md` 检查：

```text
是否形成新组件 / 模板？→ 加入对应 skill 的 templates/
是否发现新反模式？→ 更新 pitfalls.md 和对应 skill
是否需要新增工具？→ 更新 tool-index.md
是否需要补充性能 / a11y / 测试经验？→ 更新对应 skill
是否引入新框架？→ 更新技术栈选型矩阵
是否需要写入 field-journal？
是否需要新增 skill？→ 按 CONTRIBUTING.md
```

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow frontend-engineer
```

支持自动安装：Node.js、pnpm、TypeScript、ESLint、Prettier、Vite、Playwright

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |
| 框架/组件库版本不兼容 | 检查 tool-index.json 确认推荐版本 |

---

## 相关参考

- `references/frontend-frameworks-2026.md` — 8 大主流前端框架完整对比 + 性能基准 + 选型决策树
- `references/frontend-component-libraries.md` — React / Vue / Angular 组件库全景图（50+ 库）
- `references/frontend-tech-stack-guide.md` — 状态 / 样式 / 测试 / 构建全景
- `tool-index.json` — 机器可读工具索引（框架/组件库/构建/测试/小程序/移动端）
