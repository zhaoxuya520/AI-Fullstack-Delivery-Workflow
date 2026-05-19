---
name: endpoint-design
description: 设计具体 API 端点时使用。适用于资源建模后的下一步、列端点清单、HTTP 方法和状态码选择。优先使用 RFC 7231 HTTP 语义 + GitHub REST 命名规范。
---

# 端点设计

参考来源：[RFC 7231 HTTP/1.1 Semantics](https://www.rfc-editor.org/rfc/rfc7231)、[GitHub REST API Guidelines](https://docs.github.com/en/rest)

## 适用场景

- 资源建模后的端点列表
- 单个端点的 method + path 设计
- HTTP 状态码选择
- 端点命名规范

## 核心原则

```text
1. 用 HTTP 方法表达动作
   GET / POST / PUT / PATCH / DELETE 各有语义

2. 用 HTTP 状态码表达结果
   不要用 200 包装所有错误

3. URL 路径用名词
   动作通过 method 表达

4. 一致性优先
   全 API 用同一套命名规范
```

## HTTP 方法语义

| 方法 | 用途 | 幂等 | 安全 |
|------|------|------|------|
| GET | 查询资源 | ✅ | ✅ |
| POST | 创建资源 / 触发动作 | ❌ | ❌ |
| PUT | 完全替换资源 | ✅ | ❌ |
| PATCH | 部分更新资源 | ❌* | ❌ |
| DELETE | 删除资源 | ✅ | ❌ |
| HEAD | 查询头部（如检查存在） | ✅ | ✅ |
| OPTIONS | 查询支持的方法 | ✅ | ✅ |

*PATCH 不严格幂等，但可设计为幂等（如带 If-Match）

```text
幂等：多次调用结果相同（可重试）
安全：不修改服务器状态（可缓存）
```

## HTTP 状态码

### 2xx 成功

```text
200 OK                  请求成功（GET/PUT/PATCH 默认）
201 Created             资源已创建（POST 创建）
202 Accepted            已接收，异步处理中
204 No Content          成功但无返回（DELETE 默认）
```

### 3xx 重定向

```text
301 Moved Permanently   永久迁移
302 Found               临时重定向
304 Not Modified        未修改（缓存生效）
```

### 4xx 客户端错误

```text
400 Bad Request         请求格式错误 / 参数错误
401 Unauthorized        未认证（缺 token / token 无效）
403 Forbidden           已认证但无权限
404 Not Found           资源不存在
405 Method Not Allowed  方法不支持
409 Conflict            冲突（如重复创建 / 版本冲突）
410 Gone                资源已永久删除
422 Unprocessable Entity 校验失败
429 Too Many Requests   限流
```

### 5xx 服务端错误

```text
500 Internal Server Error  服务器异常
502 Bad Gateway            网关错误
503 Service Unavailable    服务不可用
504 Gateway Timeout        网关超时
```

## 命名规范

```text
路径：
  - 复数（users / orders）
  - 小写
  - 连字符分隔（reset-password 而非 resetPassword）
  - 不带后缀（/users 不是 /users.json）

查询参数：
  - snake_case 或 camelCase（团队选一种坚持用）
  - 布尔值用 true/false（不要 1/0）

Header：
  - 标准 Header（Authorization / Content-Type）
  - 自定义用 X-（如 X-Request-Id）— 但 RFC 6648 已不推荐 X- 前缀
```

## 标准 CRUD 端点

```text
查询列表：
  GET /resources
  GET /resources?page=1&page_size=20

查询单个：
  GET /resources/{id}

创建：
  POST /resources
  → 201 Created + 资源完整内容
  → Header: Location: /resources/{new-id}

完全替换：
  PUT /resources/{id}
  → 200 OK + 替换后的资源

部分更新：
  PATCH /resources/{id}
  → 200 OK + 更新后的资源

删除：
  DELETE /resources/{id}
  → 204 No Content（默认）
  → 200 OK + 被删除的资源（如需要）
```

## 端点清单输出

```markdown
## 端点清单：[模块名]

| Method | Path | 用途 | 调用方 | 权限 | 成功状态码 | 失败状态码 | 幂等 | Mock |
|--------|------|------|--------|------|-----------|-----------|------|------|
| GET | /users | 查询用户列表 | 前端/后台 | admin | 200 | 401/403/500 | ✅ | ✅ |
| POST | /users | 创建用户 | 前端 | guest | 201 | 400/409/422/500 | ❌ | ✅ |
| GET | /users/{id} | 查询用户详情 | 前端 | self/admin | 200 | 401/403/404/500 | ✅ | ✅ |
| PATCH | /users/{id} | 更新用户 | 前端 | self/admin | 200 | 400/401/403/404/422/500 | ❌ | ✅ |
| DELETE | /users/{id} | 删除用户 | 后台 | admin | 204 | 401/403/404/500 | ✅ | ✅ |
| POST | /users/{id}/reset-password | 重置密码 | 后台 | admin | 202 | 401/403/404/500 | ❌ | ✅ |
| GET | /users/{id}/orders | 用户订单 | 前端 | self/admin | 200 | 401/403/404/500 | ✅ | ✅ |
```

## 工作流程

```text
1. 读取资源清单（来自 resource-modeling）
2. 对每个资源应用标准 CRUD
3. 识别需要的特殊端点（动作/查询变体）
4. 决定 HTTP 方法
5. 列出可能的状态码
6. 标注权限和幂等
7. 输出端点清单
8. 转交 request-response 设计字段
```

## 质量自检

```text
□ HTTP 方法用对了（不要 POST 做查询）
□ 状态码语义正确（不要 200 包错误）
□ 命名一致（复数 / 小写 / 连字符）
□ 幂等性标注清楚
□ 权限说明清楚
□ 是否考虑了 OPTIONS / HEAD
```

## 常见坑

1. **POST 做查询**——POST /users/search（应该 GET /users?keyword=）
2. **GET 修改数据**——GET /users/{id}/activate（应该 POST）
3. **DELETE 返回 200 + 完整数据**——通常应该 204
4. **POST 创建后只返回 id**——前端要再 GET 一次（应该返回完整资源）
5. **状态码乱用**——404 当 403、500 当 400
6. **路径动词化**——/getUser / /createOrder
7. **方法不一致**——同样的"取消"，有的 POST /cancel，有的 PATCH status
8. **404 用于权限不足**——应该用 403（或 404 隐藏存在性）

## 配套模板

- `templates/endpoint-inventory-template.md` — 端点清单 + HTTP 方法速查模板

## 与其他 skill 的协作

```text
上游：
  resource-modeling → 提供资源清单

平行：
  request-response → 详细字段设计
  error-handling → 失败状态码细化
  auth-permission → 权限规则

下游：
  openapi-mock → 写入 OpenAPI 文档
```

## 相关参考

- `references/endpoint-design-guide.md` — URL 命名、HTTP 方法语义、状态码使用、子资源、动作化端点、大厂范式（GitHub / Stripe / Google AIP）、自检清单
