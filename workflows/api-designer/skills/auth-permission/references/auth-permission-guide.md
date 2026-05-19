# 认证鉴权设计指引（Auth & Permission Guide）

参考：OAuth 2.1（IETF Draft）、RFC 7519 JWT、RFC 6750 Bearer Token、OWASP API Security Top 10、Google Zanzibar、AWS IAM、Stripe API Keys。

## 1. 选型决策树

```text
调用方是浏览器 / 移动端 / 第三方？
  浏览器（同域）             → Cookie Session + CSRF Token
  浏览器（跨域 SPA）         → OAuth2 Authorization Code + PKCE + 短期 Access Token
  移动端                     → OAuth2 + Refresh Token + Token Rotation
  第三方服务到服务            → OAuth2 Client Credentials / mTLS / Signed Request
  脚本 / CI / Server-to-Server → API Key + IP 白名单
  内部微服务                 → mTLS / Service Mesh / 内部 JWT
  Webhook 接收方             → 签名验证（HMAC SHA256）
```

## 2. Token 类型对比

| 类型 | 存活期 | 撤销难度 | 性能 | 适用 |
|---|---|---|---|---|
| 不透明 Token（Opaque） | 长 | 容易（删 KV 即可） | 每次校验需查中心 | 高安全场景 |
| JWT 自包含 | 短（5~15 min） | 难（需黑名单） | 离线校验 | 高并发分布式 |
| Refresh Token | 长（7~30 天） | 容易（DB 标记） | 用于换 Access Token | 配合 JWT 使用 |
| API Key | 永久 / 手动撤销 | 容易 | 高 | Server-to-Server |

## 3. 权限模型对比

| 模型 | 适用 | 复杂度 | 代表系统 |
|---|---|---|---|
| RBAC（角色） | 角色固定、规则简单 | 低 | 多数后台系统 |
| ABAC（属性） | 字段级 / 条件式 | 中 | 金融、保险 |
| ReBAC（关系） | 共享、协作、组织树 | 高 | Google Drive / Notion / Linear（Zanzibar 模型） |
| RBAC + 资源归属 | 平衡的多租户 SaaS | 中 | Stripe / GitHub |

## 4. 大厂范式

### Stripe API Keys
- 区分 publishable key（前端可见）+ secret key（服务端）+ restricted key（细粒度权限）
- key 自带前缀：`sk_test_` / `sk_live_` / `rk_live_`，便于环境识别

### GitHub OAuth Apps + Fine-grained PAT
- OAuth scope 粒度：`repo`、`read:org`、`admin:repo_hook`
- Fine-grained PAT 限定到仓库 + 限定到权限类型 + 90 天默认过期

### AWS IAM Policy
- effect + action + resource + condition 四元组
- 显式 deny 优先于 allow

## 5. 字段级权限实现策略

```text
1. 标注字段敏感级别：public / internal / confidential / secret
2. 序列化时按角色筛选字段（响应中间件）
3. 字段写权限：在 schema 校验阶段拒绝
4. 不同角色看到不同 schema：用 OpenAPI discriminator 或多套 schema
```

## 6. 多租户隔离三层防御

```text
1. URL/Header 显式：/orgs/{org_id}/... 或 X-Tenant-Id
2. Token claim 中包含 tenant_id，与 URL 比对
3. 数据库查询强制 WHERE tenant_id = current.tenant_id
4. 行级安全（RLS, PostgreSQL）做兜底
```

## 7. 401 / 403 / 404 统一规范

| 场景 | 状态码 | 说明 |
|---|---|---|
| Token 缺失 / 无效 / 过期 | 401 | `WWW-Authenticate: Bearer error="invalid_token"` |
| 已认证但角色无权限 | 403 | 不暴露资源是否存在 |
| 资源不存在 | 404 | - |
| 资源存在但当前用户无权限看见 | 404（推荐）/ 403 | 隐私敏感场景用 404 隐藏存在性 |

## 8. 反模式

```text
❌ Token 写在 URL query（日志泄露）
❌ JWT 永不过期
❌ 权限检查只在前端做
❌ 角色硬编码到代码（应 RBAC + 配置化）
❌ 多租户依赖前端传 tenant_id 而不校验
❌ Refresh Token 不轮换（被盗后无法识别）
❌ 错误消息泄露存在性："用户不存在" vs "密码错误"
```

## 9. 安全自检清单

```text
□ 所有写接口都需认证
□ 所有跨用户读接口都校验资源归属
□ 字段级权限有显式定义
□ Token 有合理过期时间
□ Refresh Token 有轮换机制
□ Webhook / 回调有签名校验
□ API Key 不会出现在日志、URL 中
□ 失败不暴露存在性
□ 权限变更立即生效（缓存 TTL 合理）
□ 有审计日志（谁在何时对什么资源做了什么）
```
