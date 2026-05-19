# 认证鉴权实现检查清单

## 1. 模块信息

```text
项目：
认证方式：JWT / Session / OAuth / 混合
框架：Spring Security / NestJS Guards / Django Auth / FastAPI
负责人：
```

---

## 2. 密码安全

```text
□ 哈希算法：bcrypt(cost=12) / argon2id
□ 不自创算法
□ 密码强度：≥ 8 字符 + 复杂度
□ 密码重置 Token TTL：15 分钟
□ 失败登录限流（5 次 / 15 分钟）
□ 失败不暴露存在性
```

---

## 3. JWT 配置

```text
□ Access Token TTL：15 分钟
□ Refresh Token TTL：7 天
□ Refresh Token 存 DB 可撤销
□ Token 在 Header（不在 URL）
□ Claims：sub, exp, iat, roles, tenant_id, jti
□ HTTPS 强制
□ 算法：HS256（密钥）/ RS256（公私钥）
□ 密钥轮换机制
```

---

## 4. OAuth（如有）

```text
□ Authorization Code + PKCE
□ state 参数防 CSRF
□ scope 最小权限
□ Redirect URI 严格白名单
□ ID Token 验证（Google/Apple）
□ Refresh Token 安全存储
```

---

## 5. 鉴权三层

### 第一层：认证（Authentication）

```text
□ 中间件：JwtAuthGuard / @Authenticated
□ Token 解析失败返 401
□ Token 过期返 401
□ 用户不存在返 401
```

### 第二层：角色（Role-based）

```text
□ 角色定义：guest / user / manager / admin
□ 中间件：RolesGuard / @Roles
□ 配置驱动（不硬编码）
□ 缺权限返 403
```

### 第三层：资源归属（Ownership）

```text
□ 业务对象 user_id 字段
□ 守卫：ResourceOwnerGuard
□ 不是 owner 返 403 / 404（隐私场景用 404）
□ admin 可绕过
```

---

## 6. 字段级权限

| 字段 | 公开 | user | manager | admin |
|---|---|---|---|---|
| id | ✅ | ✅ | ✅ | ✅ |
| email | ❌ | self only | team only | ✅ |
| ip_address | ❌ | ❌ | ❌ | ✅ |
| risk_score | ❌ | ❌ | ❌ | ✅ |

实现：响应序列化时按角色筛选。

---

## 7. 多租户隔离

```text
□ 应用层：中间件提取 tenant_id
□ ORM 层：默认 WHERE tenant_id = ?
□ DB 层：PostgreSQL RLS（兜底）
□ 测试层：跨租户越权用例
```

---

## 8. CSRF 防护（Web）

```text
□ SameSite cookie
□ CSRF Token（如用 Cookie 认证）
□ 严格 CORS（白名单源）
```

---

## 9. 安全 Header

```text
□ Strict-Transport-Security（HSTS）
□ X-Content-Type-Options: nosniff
□ X-Frame-Options: DENY
□ Content-Security-Policy
□ Referrer-Policy: strict-origin-when-cross-origin
```

---

## 10. 速率限制

| 端点 | 限制 | 维度 |
|---|---|---|
| POST /auth/login | 5/15min | IP |
| POST /auth/register | 3/min | IP |
| POST /auth/forgot-password | 3/15min | IP + email |
| 通用 API | 100/min | user |

---

## 11. 日志

```text
□ 登录成功 / 失败
□ 鉴权失败
□ 角色变更
□ 资源归属拒绝

绝不记录：
  ❌ 密码
  ❌ JWT Token
  ❌ Refresh Token
  ❌ API Key
```

---

## 12. 测试用例

### 认证

```text
□ 正常登录
□ 密码错误
□ Token 过期
□ Token 篡改
□ Refresh Token 流程
□ 密码重置流程
```

### 鉴权

```text
□ 角色不足返 403
□ A 改 B 数据返 403/404
□ 跨租户访问返 403/404
□ admin 可访问任意
□ 字段级权限筛选正确
```

---

## 13. 自检

```text
□ 密码 bcrypt/argon2
□ JWT 有 TTL
□ Refresh Token 可撤销
□ HTTPS 强制
□ 三层鉴权
□ 多租户三层防御
□ CSRF / CORS / 安全 Header
□ 速率限制
□ 越权测试覆盖
□ 不暴露敏感信息
```
