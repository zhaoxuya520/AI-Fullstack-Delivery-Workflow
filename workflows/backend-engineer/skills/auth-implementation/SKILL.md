---
name: auth-implementation
description: 实现认证和鉴权时使用。覆盖 Spring Security / NestJS Guards / Django Auth / FastAPI Depends / Passport / Auth0 集成。融合 OAuth 2.1 + JWT + RBAC + 中间件实现。
---

# 认证鉴权实现（Auth Implementation）

参考来源：OAuth 2.1 IETF Draft、RFC 7519 JWT、OWASP Authentication Cheat Sheet、各框架 Security 文档、Stripe / GitHub Auth 实现。

## 适用场景

- 用户登录 / 注册
- JWT / Session 管理
- OAuth 2.0 集成（社交登录）
- RBAC / ABAC 鉴权中间件
- 资源归属校验（不能改别人的数据）
- 字段级权限（不同角色看不同字段）
- 多租户隔离

## 核心原则

```text
1. 认证 vs 鉴权
   认证（Authentication）：你是谁
   鉴权（Authorization）：你能做什么

2. 不自己写加密
   用框架 / 标准库的 password hashing

3. JWT 必须有过期时间
   Access Token：5~15 分钟
   Refresh Token：7~30 天

4. Token 不放 URL
   日志 / 缓存 / 浏览器历史会泄露

5. Refresh Token 必须可撤销
   存储到 DB，不能纯无状态

6. 资源归属必查
   认证通过 ≠ 有权限改这条数据

7. 字段级权限按角色筛选响应
   不靠前端隐藏

8. 多租户三层防御
   应用层 + DB RLS + 测试
```

## 密码哈希

```text
推荐：
  - bcrypt（最常用）
  - argon2id（最新最强，OWASP 推荐）
  - scrypt

成本因子（2026 推荐）：
  bcrypt: cost = 12
  argon2id: time=3, memory=64MB, parallelism=4

绝不：
  ❌ MD5
  ❌ SHA1 / SHA256（无 salt）
  ❌ 自己组合
```

```java
// Spring Security
@Bean
public PasswordEncoder passwordEncoder() {
  return new BCryptPasswordEncoder(12);
}

String hash = passwordEncoder.encode(rawPassword);
boolean matches = passwordEncoder.matches(rawPassword, hash);
```

```typescript
// Node bcrypt
import bcrypt from 'bcrypt';

const hash = await bcrypt.hash(password, 12);
const matches = await bcrypt.compare(password, hash);

// 或 argon2
import argon2 from 'argon2';

const hash = await argon2.hash(password, { type: argon2.argon2id });
const matches = await argon2.verify(hash, password);
```

```python
# Python passlib
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=['argon2', 'bcrypt'], deprecated='auto')

hash = pwd_context.hash(password)
matches = pwd_context.verify(password, hash)
```

## JWT 实现

### Spring Security + JWT

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
      .csrf(csrf -> csrf.disable())
      .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
      .authorizeHttpRequests(auth -> auth
        .requestMatchers("/api/auth/**").permitAll()
        .requestMatchers("/api/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated())
      .oauth2ResourceServer(o -> o.jwt(jwt -> 
        jwt.jwtAuthenticationConverter(jwtAuthConverter())))
      .build();
  }
  
  @Bean
  public JwtDecoder jwtDecoder() {
    return NimbusJwtDecoder.withSecretKey(secretKey()).build();
  }
}

// JWT 生成
@Service
public class JwtService {
  public String generateAccessToken(UserDetails user) {
    return Jwts.builder()
      .setSubject(user.getUsername())
      .claim("roles", user.getAuthorities())
      .claim("tenant_id", user.getTenantId())
      .setIssuedAt(new Date())
      .setExpiration(Date.from(Instant.now().plus(15, ChronoUnit.MINUTES)))
      .signWith(secretKey, SignatureAlgorithm.HS256)
      .compact();
  }
}
```

### NestJS + Passport JWT

```typescript
// auth.module.ts
@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '15m' },
    }),
  ],
  providers: [AuthService, JwtStrategy],
})
export class AuthModule {}

// jwt.strategy.ts
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get('JWT_SECRET'),
    });
  }
  
  async validate(payload: any) {
    return {
      userId: payload.sub,
      email: payload.email,
      roles: payload.roles,
      tenantId: payload.tenant_id,
    };
  }
}

// 用法
@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrderController {
  @Get(':id')
  async get(@Param('id') id: number, @CurrentUser() user: User) {
    return this.orderService.getOrder(id, user);
  }
}

// Roles 守卫
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}
  
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) return true;
    
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some(role => user.roles?.includes(role));
  }
}

// 装饰器
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// 用法
@Get('admin')
@Roles('admin')
async adminOnly() { ... }
```

### Django Auth

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': ['rest_framework.permissions.IsAuthenticated'],
}

# Custom Permission
class IsResourceOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user_id == request.user.id

# View
class OrderViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsResourceOwner]
    
    def get_queryset(self):
        # 多租户：默认按 tenant 过滤
        return Order.objects.filter(tenant_id=self.request.user.tenant_id)
```

### FastAPI

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError

oauth2_scheme = OAuth2PasswordBearer(tokenUrl='token')

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        user_id = payload.get('sub')
        if user_id is None:
            raise HTTPException(status_code=401)
    except JWTError:
        raise HTTPException(status_code=401)
    
    user = await get_user_by_id(user_id)
    if user is None:
        raise HTTPException(status_code=401)
    return user

async def require_admin(user = Depends(get_current_user)):
    if 'admin' not in user.roles:
        raise HTTPException(status_code=403)
    return user

# 用法
@app.get('/orders/{id}')
async def get_order(id: int, user = Depends(get_current_user)):
    return await order_service.get(id, user)

@app.delete('/users/{id}')
async def delete_user(id: int, user = Depends(require_admin)):
    return await user_service.delete(id)
```

## OAuth 2.0 集成

### 授权码流程（Authorization Code + PKCE）

```text
1. 用户点"用 Google 登录"
2. 后端生成 state + code_verifier
3. 重定向到 Google
   https://accounts.google.com/o/oauth2/auth
   ?client_id=...
   &redirect_uri=...
   &response_type=code
   &scope=openid email profile
   &state=...
   &code_challenge=...
   &code_challenge_method=S256
4. 用户授权后 Google 重定向回
   /callback?code=xxx&state=xxx
5. 后端校验 state，用 code 换 access_token
6. 用 access_token 拿用户信息
7. 创建本地用户 + 生成 JWT
```

### NestJS OAuth

```typescript
// 用 passport-google-oauth20
@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor() {
    super({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: process.env.GOOGLE_CALLBACK_URL,
      scope: ['email', 'profile'],
    });
  }
  
  async validate(accessToken, refreshToken, profile, done) {
    const { id, emails, displayName } = profile;
    let user = await this.userService.findByOauthId('google', id);
    if (!user) {
      user = await this.userService.createFromOauth({
        provider: 'google',
        oauthId: id,
        email: emails[0].value,
        name: displayName,
      });
    }
    done(null, user);
  }
}
```

## RBAC 实现

### 模型

```sql
-- 角色
CREATE TABLE roles (id, name);  -- admin, manager, user, guest

-- 权限
CREATE TABLE permissions (id, resource, action);
-- (orders, read), (orders, create), (orders, update), (orders, delete)

-- 角色-权限多对多
CREATE TABLE role_permissions (role_id, permission_id);

-- 用户-角色
CREATE TABLE user_roles (user_id, role_id);
```

### Casbin 通用方案（多语言支持）

```python
# Python
import casbin

enforcer = casbin.Enforcer('rbac_model.conf', 'rbac_policy.csv')

# 检查权限
if enforcer.enforce(user_id, 'orders', 'read'):
    # 允许
```

```text
# rbac_model.conf
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act
```

```text
# rbac_policy.csv
p, admin, orders, read
p, admin, orders, write
p, manager, orders, read
g, alice, admin
g, bob, manager
```

## 资源归属校验（必做）

```typescript
// NestJS 范式
@Injectable()
export class ResourceOwnerGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const orderId = request.params.id;
    
    const order = await this.orderRepo.findById(orderId);
    if (!order) throw new NotFoundException();
    
    // 不是 admin 必须是资源所有者
    if (!user.roles.includes('admin') && order.userId !== user.userId) {
      throw new ForbiddenException();
    }
    
    return true;
  }
}
```

## 字段级权限

```typescript
// 序列化时按角色筛选
export class UserResponseDto {
  id: number;
  email: string;
  name: string;
  
  // 仅 admin 可见
  @Expose({ groups: ['admin'] })
  ipAddress?: string;
  
  @Expose({ groups: ['admin'] })
  riskScore?: number;
}

// 用 class-transformer
const dto = plainToClass(UserResponseDto, user, {
  groups: user.roles.includes('admin') ? ['admin'] : [],
});
```

## 多租户隔离

```typescript
// 1. 中间件提取 tenant
@Injectable()
export class TenantMiddleware implements NestMiddleware {
  use(req, res, next) {
    req.tenantId = req.user?.tenantId;
    if (!req.tenantId) throw new UnauthorizedException();
    next();
  }
}

// 2. ORM 默认过滤（TypeORM 范式）
@EventSubscriber()
export class TenantSubscriber implements EntitySubscriberInterface {
  beforeQuery(event: any) {
    const tenantId = AsyncLocalStorage.get('tenantId');
    if (event.entityClass && tenantId) {
      event.queryBuilder.andWhere('entity.tenantId = :tenantId', { tenantId });
    }
  }
}

// 3. PostgreSQL RLS（兜底，详见 database 工作流）
```

## 工作流程

```text
1. 选定认证方式
   - JWT（无状态）/ Session（有状态）
   - OAuth（第三方登录）

2. 实现密码哈希（bcrypt / argon2）

3. 实现 JWT
   - Access Token（短）
   - Refresh Token（长，可撤销）
   - 包含必要 claims（user_id, roles, tenant_id）

4. 实现认证中间件
   - 解析 Token
   - 注入 user 到 context

5. 实现鉴权
   - 角色检查（@Roles）
   - 资源归属检查
   - 字段级权限（响应序列化）

6. 多租户隔离
   - 三层防御

7. 测试
   - 越权用例
   - 跨租户用例
   - Token 过期 / 篡改

8. 安全自检
   - 密码强度
   - HTTPS 强制
   - CSRF 防护
   - CORS 配置
```

## 配套模板

- `templates/auth-implementation-checklist.md` — 认证 + JWT + 鉴权 + 多租户 + 安全自检完整清单

## 质量自检

```text
□ 密码用 bcrypt / argon2（不自创）
□ JWT 有过期时间
□ Refresh Token 可撤销
□ Token 不放 URL
□ HTTPS 强制
□ 鉴权三层（认证 + 角色 + 资源归属）
□ 字段级权限（响应序列化）
□ 多租户隔离三层
□ 越权测试覆盖
□ 跨租户测试覆盖
□ 不暴露存在性（"用户不存在" vs "密码错误"）
□ 失败日志不含敏感信息
□ 安全 header（HSTS / CSP / X-Frame-Options）
```

## 常见坑

1. **MD5 / SHA256 存密码**——彩虹表攻击
2. **JWT 永不过期**——盗用永久有效
3. **Refresh Token 不可撤销**——撤销账号无效
4. **Token 在 URL**——日志泄露
5. **资源归属不检查**——A 改 B 数据
6. **字段权限靠前端**——直接调 API 拿到全字段
7. **多租户依赖 URL 传 tenant_id**——可篡改
8. **登录失败暴露存在性**——枚举攻击
9. **password reset token 永久有效**——必须短 TTL
10. **2FA 不强制**——账号被盗
11. **OAuth state 不校验**——CSRF
12. **PKCE 不用**——code interception
13. **JWT 用对称密钥但分发到客户端**——伪造 Token
14. **角色硬编码**——配置不灵活

## 与其他 skill 的协作

```text
上游：
  api-designer auth-permission → 权限矩阵
  database 工作流 → users / roles / permissions 表

下游：
  api-implementation → 中间件挂载
  observability → 鉴权日志
  testing-implementation → 越权测试
  security-engineer 工作流 → 评审
```

## 相关参考

- api-designer/auth-permission/references/auth-permission-guide.md
- 项目根 `references/backend-tech-stack-guide.md` — Auth SaaS 选型
