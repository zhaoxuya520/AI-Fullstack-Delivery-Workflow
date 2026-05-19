# OpenAPI 风格指南

## 1. 基本结构

```text
openapi
info
servers
paths
components.schemas
components.responses
components.parameters
components.securitySchemes
security
tags
```

## 2. Operation 规则

```text
operationId 必须唯一且稳定。
tags 按业务模块组织。
summary 写调用方能理解的用途。
description 补充业务边界和副作用。
每个 operation 必须有成功响应和主要失败响应。
```

## 3. Schema 规则

```text
复用 components.schemas。
字段类型、format、required、nullable、enum 必须明确。
示例值必须真实但不含敏感数据。
响应字段不要直接绑定数据库字段名。
```

## 4. 参数规则

```text
Path 参数必须 required。
Query 参数必须说明默认值和允许值。
Header 参数用于认证、幂等、追踪、版本等横切信息。
分页、筛选、排序参数应复用 components.parameters。
```

## 5. 错误响应

```text
错误结构统一。
常见错误响应可放在 components.responses。
每个端点至少列出认证、权限、参数、资源不存在和服务异常相关错误。
```

## 6. 安全规则

```text
securitySchemes 必须说明认证方式。
operation 级 security 可覆盖全局规则。
敏感字段必须在 Schema 说明中标注脱敏或不可返回。
```
