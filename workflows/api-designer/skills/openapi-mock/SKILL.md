---
name: openapi-mock
description: 输出 OpenAPI 契约和 Mock 服务时使用。适用于 API 设计的最后一步、给前端/后端/QA 的交付。优先使用 OpenAPI 3.1 + Mock 数据覆盖所有路径 + 详细的下游交接清单。
---

# OpenAPI 契约和 Mock

参考来源：[OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)、[Stoplight Studio](https://stoplight.io/)

## 适用场景

- API 设计的最后一步
- 输出机器可读的契约
- Mock 服务搭建
- 给前端/后端/QA/安全/文档的交接

## 核心原则

```text
1. OpenAPI 是真理来源（Source of Truth）
   不是文档的附属，是契约本身
   代码、Mock、文档都从 OpenAPI 生成

2. Schema 完整
   每个字段都有类型、约束、示例
   不能 type: object 就完事

3. 示例覆盖所有路径
   成功 / 失败 / 边界 / 权限不足 / 限流

4. Markdown 说明 ≠ 替代品
   Markdown 给人看，OpenAPI 给机器读
```

## OpenAPI 3.1 完整结构

```yaml
openapi: 3.1.0
info:
  title: Example API
  version: 1.0.0
  description: |
    完整的 API 描述
    支持 Markdown
  contact:
    email: api@example.com
  license:
    name: MIT

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api-staging.example.com/v1
    description: Staging

# 标签分组
tags:
  - name: users
    description: 用户管理
  - name: orders
    description: 订单管理

# 全局安全
security:
  - bearerAuth: []

components:
  # 鉴权
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
  
  # Schema 定义
  schemas:
    User:
      type: object
      required: [id, email, name]
      properties:
        id:
          type: string
          example: usr_abc123
          pattern: '^usr_[a-z0-9]+$'
        email:
          type: string
          format: email
          example: user@example.com
        name:
          type: string
          minLength: 1
          maxLength: 50
          example: 张三
        created_at:
          type: string
          format: date-time
          example: 2026-01-15T10:30:00Z
    
    Error:
      type: object
      required: [code, message]
      properties:
        code:
          type: string
          example: invalid_email
        message:
          type: string
          example: 邮箱格式不正确
        trace_id:
          type: string
          example: req_abc123
  
  # 通用参数
  parameters:
    PageParam:
      name: page
      in: query
      schema:
        type: integer
        default: 1
        minimum: 1
    PageSizeParam:
      name: page_size
      in: query
      schema:
        type: integer
        default: 20
        minimum: 1
        maximum: 100
  
  # 通用响应
  responses:
    BadRequest:
      description: 请求参数错误
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          examples:
            invalid_email:
              value:
                code: invalid_email
                message: 邮箱格式不正确
                trace_id: req_abc123
    Unauthorized:
      description: 未认证
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

paths:
  /users:
    get:
      tags: [users]
      summary: List users
      description: 查询用户列表，支持分页和筛选
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/PageSizeParam'
        - name: status
          in: query
          schema:
            type: string
            enum: [active, inactive, banned]
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
              examples:
                success:
                  value:
                    data:
                      - id: usr_001
                        email: user1@example.com
                        name: 张三
                        created_at: 2026-01-15T10:30:00Z
                    pagination:
                      page: 1
                      page_size: 20
                      total: 156
        '401':
          $ref: '#/components/responses/Unauthorized'
    
    post:
      tags: [users]
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, name]
              properties:
                email:
                  type: string
                  format: email
                name:
                  type: string
            examples:
              normal:
                value:
                  email: new@example.com
                  name: 新用户
      responses:
        '201':
          description: 创建成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          description: 邮箱已存在
          content:
            application/json:
              examples:
                duplicate:
                  value:
                    code: email_taken
                    message: 邮箱已被使用
```

## Schema 设计要点

```text
✅ 必须有：
  - type（不要省略）
  - 必填字段标 required
  - 字符串：minLength / maxLength / pattern / format
  - 数字：minimum / maximum
  - 数组：items / minItems / maxItems
  - 枚举：enum
  - 时间：format: date-time
  - example（每个字段）

❌ 避免：
  - type: object 没有 properties
  - 没有 example
  - 一个 schema 对应多种含义
```

## 示例覆盖

```yaml
responses:
  '200':
    description: 成功
    content:
      application/json:
        examples:
          normal:           # 标准成功
            value: {...}
          empty:            # 空结果
            value: { data: [], pagination: { total: 0 } }
  '400':
    examples:
      invalid_email:        # 字段错误
        value: { code: invalid_email, ... }
      missing_field:        # 缺字段
        value: { code: missing_field, ... }
  '401':
    examples:
      token_expired:        # token 过期
        value: { code: token_expired, ... }
      token_invalid:        # token 无效
        value: { code: token_invalid, ... }
  '403':
    examples:
      permission_denied:
        value: { code: permission_denied, ... }
  '429':
    examples:
      rate_limit:
        value: { code: rate_limit_exceeded, ... }
        headers:
          Retry-After: 60
```

## Mock 服务

### 工具选择

```text
轻量级：
  - Stoplight Prism（基于 OpenAPI 自动生成）
  - Mockoon
  - JSON Server

完整服务：
  - Apifox（中文友好）
  - Postman Mock Servers
  - WireMock

OpenAPI 直接生成：
  npx @stoplight/prism-cli mock openapi.yaml
```

### Mock 数据要求

```text
必须覆盖：
  ✅ 主路径（成功响应）
  ✅ 空结果
  ✅ 校验失败
  ✅ 权限不足
  ✅ 资源不存在
  ✅ 冲突（如重复创建）
  ✅ 限流

数据真实：
  ✅ 用真实业务字段（不要 Lorem Ipsum）
  ✅ 用真实格式（手机号 138... / 邮箱 @example.com）
  ✅ 时间用 ISO 8601
  ✅ ID 符合定义的格式（usr_abc123）

数据规模：
  ✅ 列表至少 20 条（验证分页）
  ✅ 包含边界数据（最大长度字符串、特殊字符）
```

## 下游交接协议

参考来源：[OpenAPI Specification](https://www.openapis.org/)、[Stripe API Design Guide](https://stripe.com/blog/api-versioning)、[GitHub REST API Guidelines](https://docs.github.com/en/rest)

### 交接三要素

```text
1. 产物（Artifact）
   - OpenAPI / Swagger 文档（机器可读）
   - Markdown 说明（人类阅读）
   - Mock 服务地址或 Mock 数据文件

2. 上下文（Context）
   - 为什么这样设计（决策背景）
   - 哪些是稳定契约，哪些可能变化
   - 已知的性能/安全/兼容约束

3. 验收标准（Acceptance）
   - 下游能否独立用 Mock 完成开发
   - 错误处理是否覆盖所有失败路径
   - 不合格时的退回机制
```

### 各下游工作流的交接清单

```text
→ 后端工程师：
  □ OpenAPI 完整契约
  □ 资源模型和状态流转
  □ 每个端点的权限规则
  □ 幂等键和并发冲突处理规则
  □ 异步任务和 Webhook 协议
  □ 错误码和触发条件
  验收：后端能据此实现接口且通过契约测试

→ 前端工程师：
  □ OpenAPI 文档
  □ Mock 服务地址（可独立联调）
  □ 请求响应示例（成功/失败/空）
  □ 错误处理建议
  □ 分页/筛选/排序使用方式
  验收：前端能在不依赖后端的情况下完成主路径开发

→ QA 工程师：
  □ 端点清单 + 权限矩阵
  □ 成功/失败/边界/权限/并发/重试测试点
  □ Mock 数据覆盖所有路径
  □ 错误码完整列表
  验收：QA 能据此设计接口测试用例

→ 安全工程师：
  □ 认证鉴权方式
  □ 敏感字段清单和脱敏规则
  □ Webhook 签名规则
  □ 限流和滥用防护策略
  □ 租户隔离边界
  验收：安全工程师能据此评审权限和数据保护

→ 技术文档工作流：
  □ 对外 API 文档（含示例和错误码）
  □ 迁移说明（如果是版本升级）
  □ 常见问题解答
  验收：开发者能据此独立接入 API
```

### 交接质量自检

```text
- OpenAPI 和 Markdown 说明是否一致？
- Mock 数据是否能覆盖所有错误路径？
- 如果我是前端，能不能在不问后端的情况下开发完整页面？
- 如果我是 QA，能不能直接根据契约设计测试用例？
- 错误码是否每条都有触发条件和处理建议？
- 敏感字段是否都标注了脱敏规则？
```

## 工作流程

```text
1. 整合所有 skill 的输出
2. 写入 OpenAPI YAML
3. 定义 components（schemas / parameters / responses）
4. 为每个端点写完整的 path 定义
5. 添加详细 example（覆盖所有路径）
6. 配置 Mock 服务（Prism / Apifox）
7. 自检 OpenAPI 和 Markdown 一致性
8. 输出交接包给所有下游
```

## 质量自检

```text
□ OpenAPI 通过 lint 检查（Spectral）
□ 每个 schema 都有 example
□ 每个端点都有成功 + 失败示例
□ 错误响应覆盖所有错误码
□ Mock 服务运行正常
□ 前端能用 Mock 独立开发
□ Markdown 说明和 OpenAPI 字段一致
□ 交接清单完整
```

## 常见坑

1. **OpenAPI 写得简陋**——type: object 没有 properties
2. **没有 example**——前端不知道字段长什么样
3. **示例只有成功路径**——前端不知道错误格式
4. **Mock 用假数据**——Lorem Ipsum / hello world
5. **OpenAPI 和 Markdown 不一致**——QA 不知道信哪个
6. **Mock 服务返回 200**——所有错误响应都没 mock
7. **没有交接说明**——前端拿到 OpenAPI 不知道怎么用
8. **没考虑版本演进**——OpenAPI 不带 version

## 配套模板

- `templates/api-design-brief-template.md` — OpenAPI 骨架模板
- `templates/openapi-handoff-template.md` — 交接包模板
- `templates/mock-contract-template.md` — Mock 数据模板

## 与其他 skill 的协作

```text
上游（汇总）：
  resource-modeling → schemas
  endpoint-design → paths
  request-response → schemas / examples
  error-handling → error responses
  auth-permission → securitySchemes
  pagination-filtering → query parameters
  versioning → info.version
  idempotency-retry → headers
  webhook-async → 异步端点 / Webhook schema

下游（交付）：
  转交所有下游工作流
  作为 API 真理来源（Source of Truth）
```
