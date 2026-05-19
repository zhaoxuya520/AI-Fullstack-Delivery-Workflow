# 自动化测试 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "单元测试" / "Jest" / "pytest" / "JUnit" | [unit-testing](unit-testing/SKILL.md) |
| "集成测试" / "Testcontainers" / "Supertest" | [integration-testing](integration-testing/SKILL.md) |
| "E2E" / "Playwright" / "Cypress" / "端到端" | [e2e-testing](e2e-testing/SKILL.md) |
| "契约测试" / "Pact" / "API 测试" / "Dredd" | [api-contract-testing](api-contract-testing/SKILL.md) |
| "性能测试" / "k6" / "Locust" / "压测" | [ci-test-integration](ci-test-integration/SKILL.md) |
| "CI 测试" / "流水线" / "并行" | [ci-test-integration](ci-test-integration/SKILL.md) |
| "覆盖率" / "Codecov" / "质量门禁" | [coverage-reporting](coverage-reporting/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单模块测试（S 级） | unit-testing |
| 模块 + CI（M 级） | + integration-testing + ci-test-integration |
| 全栈测试套件（L 级） | 全部 6 skills |

## 路由未命中

按 `CONTRIBUTING.md` 流程新增。
