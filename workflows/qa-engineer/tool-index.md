# 测试工程师工具索引

## 1. 测试用例管理

| 工具 | 用途 | 适用 |
|------|------|------|
| TestRail | 用例管理 + 执行追踪 | 中大型团队 |
| Zephyr | Jira 集成 | Jira 已用团队 |
| Xray | Jira 集成 | Jira 已用团队 |
| Markdown / git | 简单 / 透明 | 小团队 / AI 工作流 |

## 2. API 测试

| 工具 | 语言 | 优势 | 劣势 |
|------|------|------|------|
| Postman / Apifox | GUI | 易上手 | 大规模难管理 |
| REST Assured | Java | 强类型、CI 友好 | Java 栈限定 |
| Karate | DSL | 易读、内置 Mock | 学习曲线 |
| pytest + requests | Python | 灵活、生态强 | 需自建结构 |
| Pact | 多语言 | 契约测试 | 流程复杂 |
| Schemathesis | Python | 自动 fuzz | 用例无业务感 |

## 3. UI / E2E 测试

| 工具 | 优势 | 劣势 |
|------|------|------|
| Playwright | 跨浏览器、API + UI、TypeScript 支持 | 较新生态 |
| Cypress | 调试体验好 | 同源限制 |
| Selenium | 老牌、覆盖广 | 慢、API 繁琐 |
| Appium | 移动端 | 配置复杂 |

## 4. 性能测试

| 工具 | 语言 | 优势 |
|------|------|------|
| k6 | JavaScript | 现代、CI 友好 |
| JMeter | Java | 老牌、GUI |
| Locust | Python | 易写、分布式 |
| Gatling | Scala | 高性能、报告漂亮 |
| wrk | C | 极致性能、快速基线 |
| ab | C | 入门快 |

## 5. 安全 / 静态扫描

| 工具 | 用途 |
|------|------|
| OWASP ZAP | DAST（动态扫描） |
| Snyk | 依赖漏洞 |
| SonarQube | 代码质量 + 安全 |
| Semgrep | 自定义规则扫描 |
| Trivy | 容器镜像扫描 |

## 6. 测试数据

| 工具 | 用途 |
|------|------|
| Faker | 假数据生成（多语言） |
| factory_boy | Python 工厂模式 |
| FactoryBot | Ruby 工厂模式 |
| Mockaroo | Web 数据生成 |
| Synthetic Data Vault | 合成数据 |

## 7. Mock / 沙箱

| 工具 | 用途 |
|------|------|
| WireMock | HTTP 服务 Mock |
| Mountebank | 多协议 Mock |
| Mock Service Worker | 前端 Mock |
| OpenAPI Mock（Prism） | OpenAPI 自动 Mock |
| Stripe Sandbox / Twilio Test | 第三方沙箱 |

## 8. 监控 / 报告

| 工具 | 用途 |
|------|------|
| Allure | 测试报告（多语言） |
| ReportPortal | 测试报告平台 |
| Datadog | APM + 日志 |
| Prometheus + Grafana | 指标监控 |

## 9. CI/CD 集成

| 工具 | 用途 |
|------|------|
| GitHub Actions | CI 集成 |
| GitLab CI | CI 集成 |
| Jenkins | CI（老牌） |
| BuildKite | CI（高性能） |

## 10. AI 辅助测试

| 工具 | 用途 |
|------|------|
| GitHub Copilot | 用例代码生成 |
| ChatGPT / Claude | Bug 分析 / 用例生成 |
| Test.AI | AI 自动化用例 |
| Mabl | AI 辅助 E2E |

## 工具选型规则

```text
1. 优先项目已有的工具栈
2. 团队语言 / 技术栈对齐
3. CI 集成友好
4. 报告 / 数据可机器读
5. 社区活跃 / 维护持续
6. 不为单次任务引入新工具
```

## 工具最低能力清单

每个项目至少配齐：

```text
□ 用例管理（哪怕 Markdown）
□ API 测试工具
□ E2E 测试工具（如有 UI）
□ 性能基线工具
□ 数据生成工具
□ Mock 工具
□ 报告工具
□ CI 集成
```
