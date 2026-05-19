# 社区优秀资源整合索引

> 从 GitHub 上高星开源项目中提取的可复用知识，按工作流分类。
> 最后更新：2026-05-19

---

## 1. AI 编码规则集合（Cursor Rules / Claude Rules）

### [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) ⭐ 39.6K

最大的 Cursor AI 规则集合，覆盖 130+ 技术栈组合。

**可直接复用的规则（按我们的工作流分类）：**

| 我们的工作流 | 推荐规则 | 用途 |
|-------------|---------|------|
| frontend-engineer | `nextjs15-react19-vercelai-tailwind` | Next.js 15 + React 19 最新范式 |
| frontend-engineer | `vue-3-nuxt-3-typescript` | Vue 3 + Nuxt 3 TypeScript |
| frontend-engineer | `react-zustand` | Zustand 状态管理最佳实践 |
| frontend-engineer | `vue-pinia` | Pinia 状态管理 |
| frontend-engineer | `svelte-5-vs-svelte-4` | Svelte 5 迁移 |
| frontend-engineer | `tanstack-query-v5` | TanStack Query 数据获取 |
| frontend-engineer | `react-router-v7` | React Router v7 路由 |
| backend-engineer | `java-springboot-jpa` | Spring Boot + JPA |
| backend-engineer | `typescript-nestjs-best-practices` | NestJS 最佳实践 |
| backend-engineer | `python-312-fastapi-best-practices` | FastAPI 最佳实践 |
| backend-engineer | `python-django-best-practices` | Django 最佳实践 |
| backend-engineer | `go-backend-scalability` | Go 后端可扩展性 |
| backend-engineer | `fastapi-production-architecture` | FastAPI 生产架构 |
| mobile-hybrid | `flutter-app-expert` | Flutter 开发专家 |
| mobile-hybrid | `react-native-expo` | React Native Expo |
| mobile-hybrid | `android-jetpack-compose` | Android Jetpack Compose |
| mobile-hybrid | `swiftui-guidelines` | SwiftUI 开发 |
| automation-qa | `playwright-e2e-testing` | Playwright E2E |
| automation-qa | `vitest-unit-testing` | Vitest 单元测试 |
| automation-qa | `cypress-e2e-testing` | Cypress E2E |
| automation-qa | `jest-unit-testing` | Jest 单元测试 |
| devops-engineer | `vercel-deployment` | Vercel 部署 |
| devops-engineer | `kubernetes-mkdocs-documentation` | K8s 文档 |
| security-engineer | `security-devsecops-ssdls-appsec` | DevSecOps 安全开发 |
| technical-writer | `readme-best-practices` | README 最佳实践 |
| qa-engineer | `qa-bug-report` | QA Bug 报告 |

**使用方式：** 访问上述链接获取完整 `.mdc` 文件，提取核心规则融入对应工作流的 `references/` 目录。

---

### [steipete/agent-rules](https://github.com/steipete/agent-rules)

与 Claude Code / Cursor 配合的 Agent 规则和知识库。

**可复用价值：**
- Agent 任务分解模式
- 代码审查规则
- 错误处理模式
- 测试策略规则

---

### [instructa/ai-prompts](https://github.com/instructa/ai-prompts)

面向 Cursor / Cline / Windsurf / GitHub Copilot 的通用 AI 提示词集合。

**可复用价值：**
- 多 AI 编辑器兼容的提示词格式
- 通用编码规范提示
- 代码生成质量控制

---

### [shinpr/claude-code-workflows](https://github.com/shinpr/claude-code-workflows)

Claude Code 的生产级开发工作流。

**可复用价值：**
- 多 Agent 协作模式
- 任务分解与执行策略
- 代码质量门禁设计

---

### [lifedever/claude-rules](https://github.com/lifedever/claude-rules)

自动检测技术栈并生成项目规则。

**可复用价值：**
- 技术栈自动检测逻辑
- 项目规则自动生成模式
- 多框架规则模板

---

## 2. 前端工程化资源

### [awesome-react](https://github.com/enaqx/awesome-react) ⭐ 67K+

React 生态全景。

**已整合到：** `frontend-engineer/references/frontend-frameworks-2026.md`

### [awesome-vue](https://github.com/vuejs/awesome-vue) ⭐ 72K+

Vue.js 生态全景。

**已整合到：** `frontend-engineer/references/frontend-component-libraries.md`

### [awesome-tailwindcss](https://github.com/aniftyco/awesome-tailwindcss) ⭐ 14K+

Tailwind CSS 生态。

**可补充到：** `frontend-engineer/skills/styling-system/references/`

---

## 3. 后端架构资源

### [system-design-primer](https://github.com/donnemartin/system-design-primer) ⭐ 290K+

系统设计面试知识库，包含大量架构模式。

**可复用到：**
- `backend-engineer/skills/microservice-design/references/`（分布式系统模式）
- `database-engineer/references/`（数据库扩展模式）

### [java-design-patterns](https://github.com/iluwatar/java-design-patterns) ⭐ 90K+

Java 设计模式实现。

**可复用到：** `backend-engineer/skills/domain-modeling/references/`

### [realworld](https://github.com/gothinkster/realworld) ⭐ 80K+

同一个 APP 用不同技术栈实现（Medium.com 克隆）。

**可复用到：** 各工作流的框架对比参考

---

## 4. DevOps / SRE 资源

### [90DaysOfDevOps](https://github.com/MichaelCade/90DaysOfDevOps) ⭐ 27K+

DevOps 学习路径。

**可复用到：** `devops-engineer/references/`

### [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way) ⭐ 41K+

K8s 从零搭建。

**已整合精华到：** `devops-engineer/references/docker-kubernetes-guide.md`

---

## 5. 安全资源

### [OWASP/CheatSheetSeries](https://github.com/OWASP/CheatSheetSeries) ⭐ 28K+

OWASP 安全速查表。

**已整合精华到：** `security-engineer/references/owasp-security-guide.md`

### [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) ⭐ 64K+

渗透测试 Payload 集合。

**已整合到：** `reverse-pentest/` 工作流

---

## 6. 测试资源

### [goldbergyoni/javascript-testing-best-practices](https://github.com/goldbergyoni/javascript-testing-best-practices) ⭐ 24K+

JavaScript & Node.js 测试最佳实践（50+ 条）。

**已整合精华到：** `automation-qa/references/testing-strategy-guide.md`

---

## 7. 如何使用这些资源

```text
1. 识别当前任务属于哪个工作流
2. 查看对应工作流的 references/ 目录
3. 如果 references 不够 → 来本文件找对应社区资源
4. 访问开源项目提取需要的内容
5. 整合后写入对应 references/（标注来源和日期）
6. 更新 field-journal 记录新知识来源
```

---

## 8. 贡献新资源

发现优质开源项目时：
1. 确认 License 允许引用（MIT / CC0 / Apache 2.0）
2. 提取与我们工作流相关的核心知识
3. 写入对应工作流的 `references/` 目录
4. 在本文件中添加索引条目
5. 标注来源 URL 和访问日期
