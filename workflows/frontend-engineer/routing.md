# 前端工程师工作流路由

## 触发关键词

```yaml
workflow: frontend-engineer
name: 前端工程师工作流
keywords: [前端, 页面, 组件, React, Vue, Angular, Svelte, Next.js, Nuxt, 状态管理, 表单, 路由, CSS, Tailwind, 性能, 可访问性, E2E, Storybook]
entry: WORKFLOW.md
skills_routing: skills/routing.md
outputs: [页面代码, 组件, 测试, Storybook, 性能报告, 构建产物]
```

## Skills 入口

进入 WORKFLOW.md 后按 `skills/routing.md` 路由到具体 skill。

| 用户意图 | Skill |
|---------|-------|
| 组件设计 / 拆分 / 复用 | component-architecture |
| 状态管理 / Redux / Zustand / Pinia | state-management |
| 样式 / CSS / Tailwind / 主题 | styling-system |
| 路由 / 导航 / 权限守卫 | routing-navigation |
| 表单 / 校验 / 提交 | forms-validation |
| API 调用 / 缓存 / TanStack Query | data-fetching |
| 性能 / 首屏 / 包大小 / Web Vitals | performance-optimization |
| 无障碍 / ARIA / 键盘 / 屏幕阅读器 | accessibility-implementation |
| 单元测试 / E2E / Storybook / MSW | testing-frontend |
| 构建 / 部署 / Vite / CI | build-deploy |

## 进入前检查

```text
□ 设计稿已完成（Figma）
□ 设计 Token 已冻结
□ API 契约已定义（OpenAPI / Mock）
□ 组件清单和状态说明已有
□ 技术栈已锁定
□ 浏览器支持目标明确
□ 性能目标明确（LCP / INP / CLS）
```

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 设计稿不清 / Token 缺失 | ui-ux-designer |
| API 契约未定 | api-designer |
| 后端业务逻辑 | backend-engineer |
| 测试用例设计 | qa-engineer |
| CI/CD / Docker | devops-engineer |
| 监控告警 | sre-operations |
| 安全漏洞 | security-engineer |

## 路由未命中

返回根 `../../routing.md` 选择其他工作流。
