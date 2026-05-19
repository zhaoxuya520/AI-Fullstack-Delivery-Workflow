# API 设计公开资料索引

## 标准和规范

| 来源 | 用途 |
|---|---|
| OpenAPI Specification — https://spec.openapis.org/oas/latest.html | OpenAPI 契约结构、paths、components、security |
| Swagger Documentation — https://swagger.io/docs/ | Swagger 工具链和 OpenAPI 使用说明 |
| HTTP Semantics RFC 9110 — https://www.rfc-editor.org/rfc/rfc9110 | HTTP 方法、状态码、语义 |
| JSON Schema — https://json-schema.org/ | JSON 数据结构和校验规则 |
| OAuth 2.0 RFC 6749 — https://www.rfc-editor.org/rfc/rfc6749 | OAuth2 授权框架 |
| Bearer Token RFC 6750 — https://www.rfc-editor.org/rfc/rfc6750 | Bearer Token 使用规则 |
| Problem Details RFC 9457 — https://www.rfc-editor.org/rfc/rfc9457 | HTTP API 错误响应结构参考 |

## API 指南和真实产品参考

| 来源 | 用途 |
|---|---|
| Microsoft REST API Guidelines — https://github.com/microsoft/api-guidelines | REST 风格、版本、分页、错误等规则 |
| Google API Improvement Proposals — https://google.aip.dev/ | 资源导向 API、命名、分页、长任务 |
| Zalando RESTful API Guidelines — https://opensource.zalando.com/restful-api-guidelines/ | REST 设计规范、错误、兼容性 |
| GitHub REST API Docs — https://docs.github.com/rest | 分页、认证、错误和版本化参考 |
| Stripe API Docs — https://docs.stripe.com/api | 幂等、错误模型、示例和开发者体验参考 |

## 使用原则

```text
优先参考标准语义，不盲目照搬某家公司风格。
公开标准用于判断 HTTP、OpenAPI、错误、认证等基础边界。
真实产品文档用于学习开发者体验和示例组织方式。
项目已有规范优先于外部风格。
```
