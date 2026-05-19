# 前端组件库全景 2026

参考：GitHub Stars、npm 下载量、State of JS 2025、各官方文档。

## 1. 选型决策树

```text
Q1：定制需求？
  极高（自定义设计系统）→ shadcn/ui、Radix UI、Headless UI（无样式）
  高（修改主题）→ Mantine、Chakra UI、Naive UI
  中（满足业务即可）→ Ant Design、Element Plus、Vuetify
  低（用默认）→ MUI、Material UI Vue

Q2：业务类型？
  企业后台 → Ant Design / Ant Design Vue / Naive UI / Element Plus
  消费产品 → Mantine / Chakra UI / shadcn/ui
  Material Design → MUI / Vuetify
  国际 SaaS → shadcn/ui + Radix / Headless UI

Q3：技术栈？
  React → shadcn/ui / MUI / Ant Design / Mantine / Chakra UI
  Vue 3 → Element Plus / Naive UI / Ant Design Vue / Vuetify
  Angular → Angular Material / PrimeNG / NG-ZORRO
  Svelte → Skeleton / shadcn-svelte
  Solid → SolidUI / Park UI
```

## 2. React 组件库（30+ 库）

### 一线（必知）

| 库 | Stars | 风格 | 适合 |
|---|---|---|---|
| **shadcn/ui** | 75K+ | 复制粘贴源码 | 自有设计系统、想完全控制 |
| **MUI (Material UI)** | 95K+ | Material Design | 企业、跨平台一致 |
| **Ant Design** | 93K+ | 阿里风格 | 企业后台、中国市场 |
| **Chakra UI** | 38K+ | 简洁现代 | SaaS、中等定制 |
| **Mantine** | 28K+ | 现代功能全 | 全功能、SaaS 后台 |
| **Radix UI** | 17K+ | Headless | 自定义样式、无障碍标杆 |
| **Headless UI** | 27K+ | Headless | 与 Tailwind 配套 |
| **HeroUI（前 NextUI）** | 23K+ | 现代美观 | Next.js 项目 |
| **PrimeReact** | 7K+ | 功能全 | 复杂表单、企业 |
| **React Aria** | 14K+ | Adobe Headless | 无障碍极致 |

### 二线（选用）

```text
- Ariakit               - Headless + 无障碍
- Aceternity UI         - 动效炫酷（落地页）
- Magic UI              - 动效组件
- React Suite           - 复古风格
- Blueprint UI          - Palantir 数据密集
- Geist UI              - Vercel 风格
- React Bootstrap       - Bootstrap 包装
- Evergreen UI          - Segment 出品
- Grommet               - HPE 出品
- Base Web              - Uber 出品
- Fluent UI             - Microsoft Office 风格
- Reach UI              - 已合并到 Radix
- Theme UI              - 主题驱动
- Park UI               - shadcn/ui Vue/Solid 移植
```

### Tailwind 生态

```text
- Tailwind UI           - Tailwind 官方付费组件
- Headless UI           - Tailwind 配套无样式
- daisyUI               - Tailwind 主题组件
- Flowbite React        - 免费 Tailwind 组件
- Preline UI            - 免费 Tailwind 组件
- Float UI              - Vue + Tailwind
- Untitled UI           - 高质量设计系统
- Aceternity UI         - 动效组件
```

### 数据可视化

```text
- Recharts              - 简单易用
- Visx (Airbnb)         - D3 + React
- Apache ECharts        - 强大 / 国内主流
- Chart.js + react-chartjs-2  - 经典
- Nivo                  - 美观 / 响应式
- TanStack Charts       - 新兴
- Tremor                - SaaS 仪表盘风格
```

### 表格 / 列表

```text
- TanStack Table        - Headless 表格之王
- AG Grid               - 企业级（付费）
- React Table（旧版）   - 已合并到 TanStack
- Material React Table  - MUI + TanStack
- Mantine React Table   - Mantine + TanStack
```

### 表单

```text
- React Hook Form       - 主流（高性能）
- Formik                - 经典（维护少）
- TanStack Form         - 新兴（类型安全）
- Final Form            - 函数式
- Zod                   - 校验（配 RHF）
- Yup                   - 校验（旧）
- Valibot               - 轻量校验
```

## 3. Vue 3 组件库

### 一线

| 库 | Stars | 风格 | 适合 |
|---|---|---|---|
| **Element Plus** | 26K+ | Vue 3 后台标杆 | 企业后台、国内主流 |
| **Naive UI** | 18K+ | 现代 TS | 中后台、TypeScript 友好 |
| **Ant Design Vue** | 21K+ | 阿里风格 | 后台、与 React 版一致 |
| **Vuetify 3** | 41K+ | Material Design | Material Design 项目 |
| **Quasar** | 26K+ | 跨端（Web/Mobile/Desktop） | 跨端项目 |
| **PrimeVue** | 12K+ | 功能全 | 复杂表单 |
| **Nuxt UI** | 5K+ | Nuxt 配套 | Nuxt 项目 |
| **shadcn-vue** | 6K+ | 复制粘贴 | 自定义设计系统 |

### 二线

```text
- Arco Design Vue       - 字节出品
- TDesign Vue           - 腾讯出品
- IDUX                  - 蚂蚁出品（Vue）
- Vuestic UI            - 简洁
- Buefy                 - Bulma + Vue
- Bootstrap-Vue         - Bootstrap 包装（Vue 2 主）
- Vant                  - 移动端组件库（有赞）
- NutUI                 - 移动端（京东）
- Inkline               - 现代
```

### 移动端

```text
- Vant                  - 有赞（最主流）
- NutUI                 - 京东
- Vant 4 (Vue 3)        - 持续更新
- Cube UI               - 滴滴
- VUX                   - 老牌
```

## 4. Angular 组件库

| 库 | Stars | 风格 |
|---|---|---|
| **Angular Material** | 24K+ | Material Design 官方 |
| **PrimeNG** | 9K+ | 功能全 |
| **NG-ZORRO** | 9K+ | Ant Design Angular 版 |
| **NGX-Bootstrap** | 5K+ | Bootstrap |
| **Clarity Design** | 6K+ | VMware 出品 |
| **Nebular** | 8K+ | 后台 + 主题 |
| **DevExtreme** | - | 商业（强大）|
| **Kendo UI** | - | 商业 |

## 5. Svelte 组件库

```text
- shadcn-svelte         - shadcn 移植
- Skeleton              - Tailwind + Svelte
- SvelteUI              - Mantine 风格
- Svelte Material UI    - Material
- Carbon Components     - IBM 出品
- Flowbite Svelte       - Flowbite Svelte 版
- Bits UI               - Headless
- Melt UI               - Headless（Headless UI 风格）
```

## 6. 跨框架 / Headless

### Headless（无样式 + 无障碍）

```text
React:
  - Radix UI
  - React Aria（Adobe）
  - Headless UI
  - Ariakit

Vue:
  - Headless UI Vue
  - Radix Vue
  - Ariakit Vue（待出）

Solid / Svelte:
  - Kobalte（Solid）
  - Bits UI（Svelte）
  - Melt UI（Svelte）
```

### Web Components（跨框架）

```text
- Lit                   - Google 维护
- Stencil               - Ionic 出品
- Shoelace              - 通用 web components
- Spectrum              - Adobe 设计系统
- Material Web          - Material Web Components
```

## 7. 设计系统

```text
开源设计系统：
  - Adobe Spectrum       - https://spectrum.adobe.com
  - Atlassian Design     - https://atlassian.design
  - Carbon (IBM)         - https://carbondesignsystem.com
  - Polaris (Shopify)    - https://polaris.shopify.com
  - Lightning (Salesforce) - https://lightningdesignsystem.com
  - Primer (GitHub)      - https://primer.style
  - Wellbeing (Atlassian) - 

中国设计系统：
  - Ant Design           - 阿里
  - Arco Design          - 字节
  - TDesign              - 腾讯
  - Fusion Design        - 阿里
  - IDUX                 - 蚂蚁
  - Smile UI             - 滴滴
```

## 8. 选型对照表

### 企业后台首选

```text
React:
  Ant Design（中国）
  MUI / shadcn/ui（国际）
  
Vue 3:
  Element Plus（中国）
  Naive UI / Ant Design Vue
  
Angular:
  NG-ZORRO（中国）
  Angular Material（国际）
```

### 消费产品（C 端）

```text
React:
  shadcn/ui + Radix + Tailwind
  Mantine
  Chakra UI
  
Vue 3:
  Naive UI
  Vuetify

国际化项目:
  shadcn/ui（自有设计）
  Mantine（功能全）
```

### 移动端

```text
Vue 3: Vant 4 / NutUI
React Native: NativeBase / Tamagui / RN-UI-Lib
跨端 SPA: Ionic / Quasar

桌面端:
  Tauri + 任意框架 + 任意组件库
  Electron + 任意
```

### 仪表盘 / 数据密集

```text
React:
  Tremor（SaaS 仪表盘风格）
  AG Grid + Recharts/ECharts
  Material React Table

Vue:
  Element Plus + ECharts
  Vuetify + Chart.js
```

### 性能极致

```text
任何框架 + 自建（不用大组件库）
或：
  Headless 库（Radix / Headless UI）+ Tailwind
  shadcn/ui（按需复制源码）
```

## 9. 反模式

```text
❌ 一个项目混用多个组件库
   → 风格不一致 + 包大小爆炸

❌ 直接修改第三方组件源码
   → 升级地狱，封装一层即可

❌ 为单一页面引入大组件库
   → 收益不抵成本

❌ 不评估包大小就上
   → bundle 翻倍

❌ 不评估无障碍就上
   → 后期返工大

❌ 追新组件库
   → 维护少 / 文档差
```

## 10. 评估清单

选组件库时检查：

```text
□ 文档质量（中英文 / 示例丰富）
□ TypeScript 支持（一等公民）
□ 无障碍（WCAG 2.2 AA）
□ 包大小（Tree-shake 友好）
□ 主题定制（Token / CSS 变量）
□ 暗黑模式
□ 国际化（i18n）
□ SSR 兼容（如需）
□ 维护活跃（GitHub 30 天提交 / Issue 关闭率）
□ 社区规模（Stars > 5K）
□ 已有大厂使用案例
□ License（MIT 优先）
□ 升级稳定（破坏性变更频率）
□ 移动端支持（如需）
□ 可访问性测试通过
```
