# 自动化测试工具索引

## 单元测试

| 工具 | 语言 | 特点 |
|---|---|---|
| Vitest | TS/JS | 快、Vite 生态 |
| Jest | TS/JS | 老牌、生态大 |
| pytest | Python | 灵活、插件多 |
| JUnit 5 | Java | 标准 |
| Go testing | Go | 内置 |
| xUnit | C# | .NET 标准 |

## 集成测试

| 工具 | 用途 |
|---|---|
| Testcontainers | 真实依赖容器化 |
| WireMock | HTTP Mock |
| MockServer | HTTP Mock |

## E2E

| 工具 | 特点 |
|---|---|
| Playwright | 跨浏览器、推荐 |
| Cypress | 调试好 |
| Selenium | 老牌 |

## 契约测试

| 工具 | 用途 |
|---|---|
| Pact | 消费者驱动 |
| Spring Cloud Contract | Java |
| Dredd | OpenAPI 验证 |

## Mock

| 工具 | 用途 |
|---|---|
| MSW | 前端 API Mock |
| Mockito | Java Mock |
| unittest.mock | Python Mock |
| testify/mock | Go Mock |

## 覆盖率

| 工具 | 语言 |
|---|---|
| Istanbul / c8 | JS/TS |
| JaCoCo | Java |
| coverage.py | Python |
| go test -cover | Go |
| Codecov | 多语言报告 |

## CI

| 工具 | 用途 |
|---|---|
| GitHub Actions | CI |
| GitLab CI | CI |
| Jenkins | CI |

## 高风险操作

- 生产环境不跑 E2E（用 staging）
- 不在 CI 中用真实第三方 API
