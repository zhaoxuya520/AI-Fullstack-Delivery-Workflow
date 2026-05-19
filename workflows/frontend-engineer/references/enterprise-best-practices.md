# 大厂前端工程实践参考

> 来源：公开技术博客、会议分享、开源项目。按主题分类，提供可落地的工程范式。

## 1. 字节跳动

### 架构特点
```text
- 统一使用 Modern.js（自研 React 元框架，基于 Rspack）
- Rspack 替代 Webpack（Rust 重写，10x 构建速度）
- Arco Design 组件库（React + Vue 双版本）
- 微前端：Garfish（自研）
- 包管理：Rushstack + pnpm workspace
- 监控：Slardar（自研 RUM）
```

### 可借鉴
```text
✅ Rspack 替代 Webpack（开源可用）
✅ Arco Design 组件库（开源）
✅ Semi Design（另一组件库，也开源）
✅ Monorepo + pnpm workspace 管理
✅ 构建产物 CDN 分发 + 版本管理
```

---

## 2. 阿里巴巴

### 架构特点
```text
- 中后台：Ant Design + Umi.js（React 企业级框架）
- 低代码：LowCodeEngine（开源）
- 微前端：qiankun（开源，国内最广泛）
- 跨端：Rax（类 React，逐步迁到 Taro/ICE）
- 小程序：Rax/ICE → 支付宝小程序
- 状态管理：ICE 内置 / Redux
- 构建：ICE + Webpack 5
```

### 可借鉴
```text
✅ Ant Design 5.x（React 组件库标杆）
✅ Ant Design Vue（Vue 版）
✅ ProComponents（高级业务组件）
✅ qiankun 微前端（生产检验充分）
✅ Formily（复杂表单方案）
✅ BizCharts / AntV（数据可视化）
```

---

## 3. 腾讯

### 架构特点
```text
- 组件库：TDesign（React/Vue/小程序/Flutter 全端）
- 小程序：原生微信小程序 + WePY（早期）
- 中后台：TDesign + Vue 3 + Vite
- 跨端：Hippy（类 RN，自研）
- 监控：TAPD + 自研 RUM
- 微前端：wujie（Web Components 方案）
```

### 可借鉴
```text
✅ TDesign（全端覆盖，腾讯背书）
✅ wujie 微前端（Web Components 隔离）
✅ Vant（移动端 Vue 组件库，有赞/腾讯）
✅ NutUI（京东出品但腾讯也在用的 Taro 组件库）
```

---

## 4. 美团

### 架构特点
```text
- Vue 2/3 为主（国内最大 Vue 用户之一）
- 小程序：mpvue（早期）→ 原生 + uni-app
- SSR：Nuxt 2/3
- 微前端：自研方案
- 性能：自研 APM + Lighthouse CI
- 设计系统：内部 Doodle（未开源）
```

### 可借鉴
```text
✅ Vue + Nuxt SSR 大规模实践
✅ C 端性能优化经验（首屏 < 1s）
✅ 小程序分包优化策略
✅ 前端监控体系设计
```

---

## 5. 国际大厂

### Vercel / Next.js 生态
```text
架构范式：
  - App Router + Server Components（React 19）
  - 增量静态再生成（ISR）
  - Edge Runtime（边缘计算）
  - Turbopack（Rust 构建）
  - shadcn/ui + Tailwind CSS

适合借鉴：
  ✅ Server Components 减少客户端 JS
  ✅ ISR 实现动静结合
  ✅ Edge Functions 降低延迟
  ✅ shadcn/ui 复制粘贴模式
```

### Shopify
```text
- React + Remix（全面押注）
- Polaris 设计系统（开源）
- Hydrogen（电商 Remix 框架）
- 性能：Core Web Vitals 严格监控
```

### Airbnb
```text
- React + TypeScript（大规模）
- Visx（D3 + React 可视化）
- Lottie（动效库）
- 严格 ESLint 规范（eslint-config-airbnb）
- 国际化：自研 i18n 平台
```

### Stripe
```text
- React + TypeScript
- 自研设计系统
- 文档驱动开发（公开 API 文档标杆）
- 极致首屏性能（< 1s）
- A/B 测试驱动 UI 优化
```

---

## 6. 工程规范参考

### 代码规范
```text
业界标准：
  - ESLint + Prettier（必备）
  - eslint-config-airbnb（最严格）
  - @antfu/eslint-config（现代宽松）
  - TypeScript strict 模式

提交规范：
  - Conventional Commits
  - commitlint + husky + lint-staged
  - 格式：feat(scope): description

分支策略：
  - GitHub Flow（简单项目）
  - 主干开发 + Feature Flag（大厂）
```

### 性能标准（大厂共识）
```text
Core Web Vitals：
  LCP  < 2.5s（最大内容绘制）
  FID  < 100ms（首次输入延迟）
  CLS  < 0.1（累计布局偏移）
  INP  < 200ms（交互到下一帧）

首屏：
  首字节 TTFB < 800ms
  首屏可交互 < 3s（3G 网络）
  JS Bundle < 200KB（首屏）

包大小：
  React SPA：< 300KB（gzip 后首屏 JS）
  小程序主包：< 2MB
  APP 安装包：< 30MB
```

### 监控标准
```text
前端监控四层：
  1. 性能监控（Web Vitals / 首屏 / 接口耗时）
  2. 错误监控（JS Error / Promise / Resource）
  3. 业务监控（PV/UV / 转化率 / 功能使用率）
  4. 用户行为（点击 / 页面流 / 留存）

工具选择：
  - Sentry（错误监控，首选）
  - Google Analytics / 神策（业务分析）
  - Lighthouse CI（性能门禁）
  - Web Vitals 库（真实用户数据）
```

---

## 7. 微前端实践

```text
方案对比：
  qiankun（阿里）  — 最成熟，国内用户最多
  wujie（腾讯）    — Web Components 隔离，新方案
  Module Federation — Webpack 5 原生，运行时共享
  Garfish（字节）  — 类 qiankun，字节内部
  single-spa       — 国际标准，底层框架

何时用微前端：
  ✅ 多团队独立开发部署
  ✅ 遗留系统渐进迁移（jQuery → React）
  ✅ 不同技术栈共存（React + Vue）
  
  ❌ 单团队项目（Monorepo 足够）
  ❌ 小项目（过度工程）
  ❌ 性能极致要求（微前端有开销）
```

---

## 8. 设计系统大厂实践

| 公司 | 设计系统 | 开源 | 特点 |
|------|---------|------|------|
| 蚂蚁 | Ant Design | ✅ | React/Vue 最完整 |
| 字节 | Arco Design / Semi | ✅ | 现代风格 |
| 腾讯 | TDesign | ✅ | 全端覆盖 |
| 阿里云 | Fusion Design | ✅ | 可定制性强 |
| Shopify | Polaris | ✅ | 电商标杆 |
| GitHub | Primer | ✅ | 开发工具风格 |
| Adobe | Spectrum | ✅ | 无障碍标杆 |
| IBM | Carbon | ✅ | 企业级 |
| Microsoft | Fluent UI | ✅ | Office 风格 |
| Atlassian | ADS | ✅ | 协作工具 |

建设路径：
```text
1. Token 先行（颜色/字体/间距/圆角/阴影）
2. 原子组件（Button/Input/Select 20个）
3. 业务组件（表单/表格/弹窗/导航）
4. 页面模板（列表页/详情页/表单页/仪表盘）
5. 文档 + Storybook + 在线预览
6. 发布为 npm 包 + Figma 同步
```
