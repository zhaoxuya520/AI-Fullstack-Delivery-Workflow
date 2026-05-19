# 自动化测试工作流路由

## 触发关键词

```yaml
workflow: automation-qa
name: 自动化测试工作流
keywords: [单元测试, 集成测试, E2E, Playwright, Cypress, Jest, Pytest, 覆盖率, CI测试, 契约测试, Pact]
entry: WORKFLOW.md
skills_routing: skills/routing.md
outputs: [自动化测试代码, 测试运行结果, 覆盖率报告, CI配置]
```

## Skills 入口

| 用户意图 | Skill |
|---------|-------|
| 单元测试 / Jest / Vitest / pytest | unit-testing |
| 集成测试 / Testcontainers | integration-testing |
| E2E / Playwright / Cypress | e2e-testing |
| 契约测试 / Pact | api-contract-testing |
| CI 集成 / 流水线 | ci-test-integration |
| 覆盖率 / Codecov | coverage-reporting |

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 测试用例设计（不是实现） | qa-engineer |
| 业务代码修复 | backend-engineer / frontend-engineer |
| CI/CD 流水线深度 | devops-engineer |

## 路由未命中

返回根 `../../routing.md`。
