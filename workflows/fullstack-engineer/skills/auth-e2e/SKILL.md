---
name: auth-e2e
description: 端到端认证实现时使用。适用于注册 → 登录 → Token → 权限 → 前端守卫的全栈闭环。覆盖 NextAuth / Lucia / Supabase Auth / 自建 JWT。
---

# 端到端认证（Auth E2E）

## 适用场景

- 全栈项目认证实现（注册 → 登录 → 权限）
- NextAuth / Lucia / Supabase Auth 集成
- 自建 JWT + Refresh Token
- 前端路由守卫 + 后端中间件
- 社交登录（Google / GitHub）

## 核心原则

```text
1. 认证是端到端的
   DB users 表 + 后端 JWT + 前端守卫 = 一起做

2. 不自己写加密
   用 bcrypt / argon2

3. Token 存储安全
   HttpOnly Cookie（推荐）> localStorage

4. 前端守卫 ≠ 安全
   后端必须校验，前端只是 UX

5. 用现成方案优先
   NextAuth / Lucia / Supabase Auth > 自建
```

## 方案选型

| 方案 | 适合 | 复杂度 |
|---|---|---|
| **NextAuth.js (Auth.js)** | Next.js 项目 | 低 |
| **Lucia** | 任意 TS 框架 | 中 |
| **Supabase Auth** | Supabase 项目 | 低 |
| **Clerk** | SaaS（付费） | 极低 |
| **自建 JWT** | 完全控制 | 高 |
| **Django Auth** | Django 项目 | 低 |
| **Devise** | Rails 项目 | 低 |

## NextAuth.js（Next.js 推荐）

```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';
import GoogleProvider from 'next-auth/providers/google';

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    CredentialsProvider({
      async authorize(credentials) {
        const user = await db.user.findUnique({ where: { email: credentials.email } });
        if (!user) return null;
        const valid = await bcrypt.compare(credentials.password, user.password);
        if (!valid) return null;
        return { id: user.id, email: user.email, role: user.role };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) { token.role = user.role; token.id = user.id; }
      return token;
    },
    async session({ session, token }) {
      session.user.role = token.role;
      session.user.id = token.id;
      return session;
    },
  },
});
```

## 自建 JWT（完全控制）

### 后端

```typescript
// 注册
app.post('/auth/register', async (req, res) => {
  const { email, password, name } = registerSchema.parse(req.body);
  const hash = await bcrypt.hash(password, 12);
  const user = await db.user.create({ data: { email, password: hash, name } });
  const token = generateAccessToken(user);
  const refresh = generateRefreshToken(user);
  await db.refreshToken.create({ data: { token: refresh, userId: user.id } });
  
  res.cookie('refresh_token', refresh, { httpOnly: true, secure: true, sameSite: 'lax', maxAge: 7 * 24 * 60 * 60 * 1000 });
  res.json({ accessToken: token, user: { id: user.id, email, name } });
});

// 登录
app.post('/auth/login', async (req, res) => {
  const { email, password } = loginSchema.parse(req.body);
  const user = await db.user.findUnique({ where: { email } });
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ error: { code: 'INVALID_CREDENTIALS' } });
  }
  // ... 同上生成 token
});

// 刷新
app.post('/auth/refresh', async (req, res) => {
  const refreshToken = req.cookies.refresh_token;
  if (!refreshToken) return res.status(401).json({ error: { code: 'NO_REFRESH_TOKEN' } });
  
  const stored = await db.refreshToken.findUnique({ where: { token: refreshToken } });
  if (!stored) return res.status(401).json({ error: { code: 'INVALID_REFRESH_TOKEN' } });
  
  const user = await db.user.findUnique({ where: { id: stored.userId } });
  const newAccess = generateAccessToken(user);
  res.json({ accessToken: newAccess });
});

// 中间件
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: { code: 'UNAUTHORIZED' } });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ error: { code: 'TOKEN_EXPIRED' } });
  }
}
```

### 前端

```typescript
// 登录
async function login(email: string, password: string) {
  const res = await api.post('/auth/login', { email, password });
  setAccessToken(res.data.accessToken);
  setUser(res.data.user);
  router.push('/dashboard');
}

// Token 刷新（axios 拦截器）
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    if (error.response?.status === 401 && !error.config._retry) {
      error.config._retry = true;
      const { data } = await api.post('/auth/refresh');
      setAccessToken(data.accessToken);
      error.config.headers.Authorization = `Bearer ${data.accessToken}`;
      return api(error.config);
    }
    return Promise.reject(error);
  }
);

// 路由守卫（Next.js middleware）
export function middleware(request: NextRequest) {
  const token = request.cookies.get('access_token');
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}
```

## 端到端流程

```text
1. DB：users 表（email, password_hash, role）
2. 后端：注册 / 登录 / 刷新 / 中间件
3. 前端：登录表单 / Token 存储 / 路由守卫
4. 联调：Token 传递 / 刷新 / 过期处理
5. 测试：登录成功 / 失败 / 越权
```

## 配套模板

- `templates/auth-checklist.md` — 认证端到端清单

## 质量自检

```text
□ 密码 bcrypt / argon2
□ JWT 有过期时间（15 min）
□ Refresh Token 可撤销
□ Token 存 HttpOnly Cookie
□ 前端路由守卫
□ 后端中间件校验
□ 角色权限检查
□ 资源归属检查
□ 登录失败不暴露存在性
□ 社交登录（如需）
□ 测试覆盖（登录 / 越权）
```

## 常见坑

1. **Token 存 localStorage**——XSS 风险
2. **JWT 永不过期**——盗用永久有效
3. **前端守卫当安全**——直接调 API 绕过
4. **不刷新 Token**——用户频繁被踢
5. **密码明文存储**——数据泄露 = 全完
6. **登录暴露存在性**——"用户不存在" vs "密码错误"
7. **不限制登录尝试**——暴力破解
8. **社交登录不验证 email**——冒充

## 与其他 skill 的协作

```text
上游：
  database-schema-impl → users 表

下游：
  api-frontend-integration → Token 联调
  e2e-feature-delivery → 认证是功能的一部分
  backend-engineer auth-implementation（深度）
```
