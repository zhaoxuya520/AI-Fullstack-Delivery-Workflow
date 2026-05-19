# 前端工程师 Skills 总控

本目录收录前端工程师工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [component-architecture](component-architecture/SKILL.md) | 组件设计 / 拆分 / 复用 | Atomic Design + Container/Presentation + Compound Components |
| [state-management](state-management/SKILL.md) | 状态管理 | Redux / Zustand / Jotai / Pinia / TanStack Query |
| [styling-system](styling-system/SKILL.md) | 样式方案 | Tailwind / CSS-in-JS / CSS Modules / vanilla-extract / UnoCSS |
| [routing-navigation](routing-navigation/SKILL.md) | 路由 / 导航 / 权限 | Next.js / React Router / Vue Router / Angular Router |
| [forms-validation](forms-validation/SKILL.md) | 表单 / 校验 | React Hook Form + Zod / VeeValidate / Formily |
| [data-fetching](data-fetching/SKILL.md) | API 集成 / 缓存 | TanStack Query / SWR / Apollo / RTK Query |
| [performance-optimization](performance-optimization/SKILL.md) | 性能优化 | Web Vitals / Code Splitting / Image / Bundle |
| [accessibility-implementation](accessibility-implementation/SKILL.md) | 可访问性 | WCAG 2.2 / ARIA / 键盘 / 屏幕阅读器 |
| [testing-frontend](testing-frontend/SKILL.md) | 前端测试 | Vitest / RTL / Playwright / Cypress / Storybook / MSW |
| [build-deploy](build-deploy/SKILL.md) | 构建 / 部署 | Vite / Turbopack / Vercel / Cloudflare / Docker |
| [miniprogram-development](miniprogram-development/SKILL.md) | 小程序开发 | 微信 + Taro + uni-app 多端 |
| [mobile-hybrid](mobile-hybrid/SKILL.md) | 移动端跨平台 | React Native + Flutter + Expo + Tauri |

## 统一入口

1. 先读 `routing.md` — 按前端任务路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

```text
1. 拿到设计稿 → 组件架构
   - component-architecture（拆分 + 复用）
   - styling-system（样式方案）

2. 状态和数据
   - state-management（客户端状态）
   - data-fetching（服务端状态）
   - forms-validation（表单状态）

3. 路由和导航
   - routing-navigation（页面 + 权限）

4. 性能和可访问性
   - performance-optimization
   - accessibility-implementation

5. 测试
   - testing-frontend

6. 上线
   - build-deploy
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成前端任务后，回写经验到 `../field-journal/`。
