# OWASP Web 安全实战指南

> 面向 APP / 小程序 / 网页项目的安全评审与防护。覆盖 OWASP Top 10 2021 + API Security Top 10。

## 1. OWASP Top 10 (2021) 速查

| # | 风险 | 场景 | 防御 |
|---|------|------|------|
| A01 | 访问控制失效 | 越权访问他人数据 | RBAC + 资源级权限校验 |
| A02 | 加密失败 | 明文存密码/传输 | bcrypt + TLS + AES |
| A03 | 注入 | SQL/XSS/命令注入 | 参数化查询 + 输出编码 |
| A04 | 不安全设计 | 缺少限流/验证 | 威胁建模 + 安全设计 |
| A05 | 安全配置错误 | Debug 模式上线 | 安全基线 + 自动扫描 |
| A06 | 脆弱过时组件 | 已知CVE依赖 | SCA + 自动升级 |
| A07 | 认证失败 | 弱密码/无MFA | 强密码策略 + MFA |
| A08 | 数据完整性失败 | 不安全反序列化 | 签名校验 + CSP |
| A09 | 日志监控不足 | 攻击无感知 | 安全日志 + SIEM |
| A10 | SSRF | 内网请求伪造 | URL 白名单 + 网络隔离 |

---

## 2. 常见漏洞与修复代码

### SQL 注入防御

```java
// ❌ 错误：字符串拼接
String sql = "SELECT * FROM users WHERE id = " + userId;

// ✅ 正确：参数化查询
@Query("SELECT u FROM User u WHERE u.id = :id")
User findById(@Param("id") Long id);

// ✅ MyBatis-Plus
queryWrapper.eq("id", userId);  // 自动参数化
```

```typescript
// ❌ 错误：模板字符串
const result = await db.query(`SELECT * FROM users WHERE id = ${id}`);

// ✅ 正确：Prisma（天然防注入）
const user = await prisma.user.findUnique({ where: { id } });

// ✅ 正确：参数化
const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
```

### XSS 防御

```typescript
// ❌ 错误：直接渲染用户输入
element.innerHTML = userInput;

// ✅ React 默认安全（自动转义）
return <div>{userInput}</div>;

// ✅ 需要富文本时用 DOMPurify
import DOMPurify from 'dompurify';
const clean = DOMPurify.sanitize(userHtml);

// ✅ CSP 头配置
// Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'
```

### CSRF 防御

```typescript
// ✅ 方案1：SameSite Cookie（现代浏览器默认）
res.cookie('session', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'Strict',  // 或 'Lax'
});

// ✅ 方案2：Double Submit Cookie
// 前端从 cookie 读 csrf token，放到请求头
// 后端对比 header 和 cookie 中的 token

// ✅ 方案3：API 用 Bearer Token（不用 Cookie）
// Authorization: Bearer <jwt>  — 天然免疫 CSRF
```

### 越权防御（IDOR）

```typescript
// ❌ 错误：只校验登录，不校验资源归属
app.get('/api/orders/:id', authMiddleware, async (req, res) => {
  const order = await db.order.findById(req.params.id);
  res.json(order);  // 任何登录用户都能看任何订单！
});

// ✅ 正确：校验资源属于当前用户
app.get('/api/orders/:id', authMiddleware, async (req, res) => {
  const order = await db.order.findFirst({
    where: { id: req.params.id, userId: req.user.id },  // 加 userId 过滤
  });
  if (!order) return res.status(404).json({ error: 'Not found' });
  res.json(order);
});
```

---

## 3. API 安全检查清单

```text
认证：
  □ 所有 API 端点都需要认证（除公开接口）
  □ Token 有过期时间（access: 15min, refresh: 7d）
  □ 登录失败有次数限制（5次锁定15分钟）
  □ 密码使用 bcrypt/argon2 哈希（cost ≥ 12）

授权：
  □ 每个 API 校验用户对资源的权限（不只是角色）
  □ 列表接口按用户/租户过滤（不返回他人数据）
  □ 管理员操作有二次验证
  □ 批量操作有数量限制

输入：
  □ 所有输入经过校验（Zod / Joi / @Valid）
  □ 文件上传限制类型和大小
  □ 分页参数有上限（pageSize ≤ 100）
  □ 搜索输入防 ReDoS（正则超时保护）

输出：
  □ 不返回敏感字段（password / token / 内部ID）
  □ 错误响应不暴露堆栈/SQL/内部路径
  □ 响应有安全头（X-Frame-Options / CSP / HSTS）

限流：
  □ 全局限流（如 100 req/min/IP）
  □ 敏感端点加强限流（登录 5/min，短信 1/min）
  □ 429 响应包含 Retry-After 头

传输：
  □ 全站 HTTPS（HSTS preload）
  □ API 密钥不在 URL 中传递
  □ WebSocket 连接要认证
```

---

## 4. 安全头配置

```nginx
# Nginx 安全头（推荐配置）
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "0";  # 现代浏览器建议关闭（用CSP替代）
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.example.com;" always;
```

---

## 5. 依赖安全扫描命令

```bash
# Node.js
npm audit
pnpm audit
npx snyk test

# Java
./gradlew dependencyCheckAnalyze   # OWASP Dependency-Check
mvn org.owasp:dependency-check-maven:check

# Python
pip install safety && safety check
pip install pip-audit && pip-audit

# 容器镜像
trivy image myapp:latest
docker scout cves myapp:latest

# Git 历史密钥扫描
gitleaks detect --source .

# IaC 扫描
trivy config .
checkov -d .
```

---

## 6. 安全开发生命周期（SDL）

```text
需求阶段：
  - 威胁建模（STRIDE）
  - 安全需求清单

设计阶段：
  - 安全架构评审
  - 最小权限原则
  - 数据分类（PII/敏感/公开）

编码阶段：
  - 安全编码规范
  - SAST 扫描（Semgrep / SonarQube）
  - 代码安全 Review

测试阶段：
  - SCA 依赖扫描
  - DAST 动态扫描（ZAP）
  - 渗透测试（授权）

部署阶段：
  - 容器镜像扫描
  - 密钥管理（Vault/KMS）
  - 安全配置基线

运维阶段：
  - 安全监控 + 告警
  - 漏洞响应 SOP
  - 定期安全审计
```
