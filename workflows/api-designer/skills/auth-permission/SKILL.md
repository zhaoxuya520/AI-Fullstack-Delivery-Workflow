---
name: auth-permission
description: 设计 API 认证鉴权和权限矩阵时使用。适用于多角色系统、租户隔离、字段级权限。优先使用 OAuth 2.0 / JWT + RBAC + 资源归属检查。
---

# 认证鉴权（Auth & Permission）

参考来源：[OAuth 2.0 RFC 6749](https://www.rfc-editor.org/rfc/rfc6749)、[JWT RFC 7519](https://www.rfc-editor.org/rfc/rfc7519)、RBAC 模型

## 适用场景

- API 的认证鉴权设计
- 多角色权限系统
- 多租户隔离
- 字段级权限
- 第三方集成（OAuth）

## 核心区分

```text
认证（Authentication）：你是谁？
  - 验证身份
  - 失败返回 401
  - 例：token 无效 / 过期

鉴权（Authorization）：你能做什么？
  - 验证权限
  - 失败返回 403
  - 例：已登录但无权访问该资源

租户隔离：你在哪个组织？
  - 跨组织数据隔离
  - 失败返回 403 或 404

资源归属：这个资源属于谁？
  - 用户只能操作自己的资源
  - 失败返回 403 或 404
```

## 认证方式

### 1. Bearer Token（最常见）

```text
Authorization: Bearer eyJhbGc...

适用：用户 API、移动 App
实现：通常用 JWT
```

### 2. API Key

```text
方式 1：Header
  X-API-Key: sk_live_abc123

方式 2：Query（不推荐，易泄露）
  /api/v1/users?api_key=xxx

适用：服务到服务、SDK、Webhook 验签
```

### 3. OAuth 2.0

```text
适用：第三方接入、开放平台
流程：
  1. 用户授权（authorization_code）
  2. 换取 token
  3. 调用 API
```

### 4. Session Cookie

```text
Cookie: session=abc123

适用：浏览器同站调用
注意：CSRF 防护必备
```

### 5. Basic Auth（仅内部）

```text
Authorization: Basic base64(username:password)

适用：内部工具、最简单接入
不适用：公开 API
```

## JWT 结构

```text
header.payload.signature

Payload 标准字段（claims）：
  iss: 签发者
  sub: 用户 ID
  aud: 接收方
  exp: 过期时间
  iat: 签发时间
  jti: JWT ID（用于撤销）

自定义字段：
  user_id: usr_abc
  email: user@example.com
  roles: ["admin", "developer"]
  tenant_id: org_xyz

注意：
  - JWT 只能验证不能撤销（除非加 jti 黑名单）
  - 短过期时间（15min~1h）+ refresh token
  - 不要存敏感信息（payload 可解码）
```

## 权限模型

### RBAC（角色权限）

```text
用户 → 角色 → 权限

角色示例：
  - admin：所有权限
  - manager：管理用户和订单
  - employee：查看订单
  - guest：仅查看公开资源

权限示例：
  - users:read
  - users:write
  - users:delete
  - orders:read
  - orders:approve
```

### ABAC（属性权限）

```text
基于属性的权限：
  - 用户属性：部门 / 角色 / 权限组
  - 资源属性：所有者 / 状态 / 标签
  - 环境属性：时间 / IP / 设备

适用：复杂权限场景（如金融审批）
```

### 资源归属

```text
即使有权限，还要检查资源归属：

用户 A 是 manager，能 read orders
但只能 read 自己组织的 orders
不能 read 用户 B 的组织的 orders

实现：
  WHERE tenant_id = current_user.tenant_id
  AND owner_id = current_user.id  -- 个人资源
```

## 权限矩阵

```markdown
## 权限矩阵：[模块名]

| 操作 | guest | user | manager | admin |
|------|-------|------|---------|-------|
| 查看公开商品 | ✅ | ✅ | ✅ | ✅ |
| 查看自己订单 | ❌ | ✅ self | ✅ team | ✅ all |
| 创建订单 | ❌ | ✅ | ✅ | ✅ |
| 取消订单 | ❌ | ✅ self | ✅ team | ✅ |
| 修改订单状态 | ❌ | ❌ | ✅ team | ✅ |
| 退款 | ❌ | ❌ | ❌ | ✅ |
| 删除用户 | ❌ | ❌ | ❌ | ✅ |

注：
  self = 仅自己的资源
  team = 仅本团队/组织的
  all = 所有
```

## 字段级权限

```text
不同角色看到的字段不同：

GET /users/{id}

普通用户看自己：
{
  "id", "email", "name", "phone",
  "address", "preferences",
  "created_at"
}

管理员看任何用户：
{
  "id", "email", "name", "phone",
  "address", "preferences",
  "ip_address", "last_login",
  "risk_score", "internal_notes",
  "created_at"
}

实现：响应序列化时根据角色筛选字段
```

## 多租户隔离

```text
方式 1：URL 显式
  /api/v1/orgs/{org_id}/users
  优点：明确
  缺点：URL 长

方式 2：Header
  X-Tenant-Id: org_xyz
  优点：URL 简洁
  缺点：易忘记设置

方式 3：从 token 提取（推荐）
  JWT payload 含 tenant_id
  服务端自动加过滤条件
  优点：安全 + 简洁
  缺点：跨租户场景需要特殊处理

任何方式都要服务端验证：
  user.tenant_id == resource.tenant_id
```

## 输出格式

```markdown
## 认证鉴权设计：[API 模块]

### 认证方式
- 用户 API：Bearer Token (JWT)
  - 过期时间：1 小时
  - Refresh Token：30 天
- 服务到服务：API Key
- Webhook：HMAC 签名

### 角色定义
- guest：未登录
- user：普通用户
- manager：团队管理员
- admin：系统管理员

### 权限矩阵
[见上方表格]

### 租户隔离
- 方式：JWT 含 tenant_id，服务端自动过滤
- 跨租户：仅 admin 可通过 ?tenant_id= 显式指定

### 字段权限
- 普通用户：脱敏字段（手机号显示 138****8000）
- 管理员：完整字段 + 内部字段

### 错误处理
- 401：token 缺失/无效/过期 → token_invalid / token_expired
- 403：已认证但无权限 → permission_denied
- 404：（隐私考虑）资源不存在 → not_found
```

## 工作流程

```text
1. 选择认证方式（Bearer / API Key / OAuth）
2. 列出角色清单
3. 列出操作清单
4. 画权限矩阵
5. 设计租户隔离方式
6. 标注字段级权限（如有）
7. 设计错误处理（401 vs 403 vs 404）
8. 输出鉴权说明
```

## 质量自检

```text
□ 是否区分 401（认证）和 403（鉴权）
□ 权限矩阵是否覆盖所有角色和操作
□ 是否考虑了资源归属（不只看角色）
□ 是否考虑了多租户隔离
□ 字段级权限是否定义
□ Token 过期策略是否合理（不要太久）
□ 是否避免了 token 在 URL 中
□ 错误响应是否泄露隐私
```

## 常见坑

1. **把权限简化为"需要登录"**——所有用户能做所有事
2. **只检查角色不检查归属**——manager 能看其他 team 的数据
3. **租户隔离漏洞**——忘记加 tenant_id 过滤
4. **JWT 过期时间太长**——24 小时甚至无过期 → 撤销难
5. **敏感信息进 JWT payload**——payload 可解码
6. **API Key 在 URL**——日志泄露
7. **403 和 404 不一致**——隐私考虑应统一返回 404 隐藏存在性
8. **字段权限缺失**——返回所有字段，靠前端隐藏

## 配套模板

- `templates/auth-permission-template.md` — 权限矩阵 + JWT payload + 认证流程模板

## 与其他 skill 的协作

```text
上游：
  resource-modeling → 资源清单
  endpoint-design → 端点清单

平行：
  error-handling → 401/403 错误码细化

下游：
  openapi-mock → 安全 schema
  转交安全工程师 → 安全评审
  转交后端 → 实现鉴权中间件
```

## 相关参考

- `references/auth-permission-guide.md` — 选型决策树、Token 类型对比、权限模型对比（RBAC/ABAC/ReBAC）、大厂范式（Stripe Keys / GitHub Fine-grained PAT / AWS IAM）、字段级权限、多租户三层防御、安全自检
