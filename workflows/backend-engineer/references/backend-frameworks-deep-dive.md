# 后端框架深度资料索引

> 覆盖主流后端框架的项目初始化、核心配置、生产模板、GitHub 优质资源。
> 最后更新：2026-05-19

---

## 1. Spring Boot 3（Java/Kotlin）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [spring-boot](https://github.com/spring-projects/spring-boot) | 75K+ | 官方源码 |
| [mall](https://github.com/macrozheng/mall) | 78K+ | 电商系统完整实现（最佳学习项目） |
| [JHipster](https://github.com/jhipster/generator-jhipster) | 22K+ | 全栈生成器（Spring Boot + Angular/React/Vue） |
| [RuoYi-Vue](https://github.com/yangzongzhuan/RuoYi-Vue) | 5K+ | 国内管理后台脚手架 |
| [SpringBoot-Labs](https://github.com/YunaiV/SpringBoot-Labs) | 20K+ | Spring Boot 各种场景 Demo |
| [pig](https://github.com/pig-mesh/pig) | 6K+ | 微服务权限管理系统 |
| [Spring Cloud Alibaba](https://github.com/alibaba/spring-cloud-alibaba) | 28K+ | 阿里微服务全家桶 |

### 快速初始化

```bash
# Spring Initializr（官方）
https://start.spring.io/

# 命令行创建
curl https://start.spring.io/starter.tgz \
  -d type=gradle-project \
  -d language=java \
  -d bootVersion=3.3.0 \
  -d baseDir=my-app \
  -d groupId=com.example \
  -d artifactId=my-app \
  -d dependencies=web,data-jpa,postgresql,validation,security,actuator \
  | tar -xzf -
```

### 推荐依赖组合

```text
基础 API：
  spring-boot-starter-web
  spring-boot-starter-validation
  springdoc-openapi-starter-webmvc (Swagger)
  mybatis-plus-spring-boot3-starter

认证安全：
  sa-token-spring-boot3-starter（国内轻量推荐）
  spring-boot-starter-security + jjwt（标准）

缓存队列：
  spring-boot-starter-data-redis
  spring-boot-starter-amqp (RabbitMQ)

监控：
  spring-boot-starter-actuator
  micrometer-registry-prometheus

工具：
  lombok
  mapstruct（对象转换）
  hutool-all（国内工具集）
```

---

## 2. NestJS（TypeScript）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [nest](https://github.com/nestjs/nest) | 68K+ | 官方源码 |
| [nestjs-realworld](https://github.com/lujakob/nestjs-realworld-example-app) | 3K+ | RealWorld 示例 |
| [awesome-nestjs](https://github.com/nestjs/awesome-nestjs) | 9K+ | NestJS 生态资源 |
| [nestjs-prisma-starter](https://github.com/fivethree-team/nestjs-prisma-starter) | 2K+ | NestJS + Prisma 脚手架 |
| [nestjs-query](https://github.com/doug-martin/nestjs-query) | 1K+ | 自动 CRUD 查询 |

### 快速初始化

```bash
# 创建项目
pnpm add -g @nestjs/cli
nest new my-app --package-manager pnpm

# 常用模块
nest g module auth
nest g controller auth
nest g service auth

# 推荐依赖
pnpm add @nestjs/config @nestjs/swagger
pnpm add prisma @prisma/client
pnpm add class-validator class-transformer
pnpm add @nestjs/jwt @nestjs/passport passport passport-jwt
pnpm add @nestjs/cache-manager cache-manager cache-manager-ioredis
pnpm add @nestjs/bull bull
```

### 推荐项目结构

```text
src/
├── main.ts
├── app.module.ts
├── common/
│   ├── decorators/       # @CurrentUser, @Public
│   ├── filters/          # AllExceptionsFilter
│   ├── guards/           # JwtAuthGuard, RolesGuard
│   ├── interceptors/     # TransformInterceptor, LoggingInterceptor
│   ├── pipes/            # ValidationPipe 配置
│   └── dto/              # PaginationDto, BaseResponse
├── modules/
│   ├── auth/             # 认证模块
│   ├── user/             # 用户模块
│   ├── order/            # 订单模块
│   └── ...
├── prisma/               # Prisma schema + 迁移
└── config/               # 环境配置
```

---

## 3. FastAPI（Python）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [fastapi](https://github.com/fastapi/fastapi) | 80K+ | 官方源码 |
| [full-stack-fastapi-template](https://github.com/fastapi/full-stack-fastapi-template) | 28K+ | 官方全栈模板 |
| [fastapi-best-practices](https://github.com/zhanymkanov/fastapi-best-practices) | 8K+ | FastAPI 最佳实践 |
| [sqlmodel](https://github.com/fastapi/sqlmodel) | 15K+ | FastAPI 作者的 ORM |
| [fastapi-users](https://github.com/fastapi-users/fastapi-users) | 5K+ | 开箱即用认证 |

### 快速初始化

```bash
# 创建项目
mkdir my-app && cd my-app
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 核心依赖
pip install fastapi uvicorn[standard]
pip install sqlalchemy[asyncio] asyncpg alembic
pip install pydantic-settings python-jose[cryptography] passlib[bcrypt]
pip install redis celery

# 运行
uvicorn app.main:app --reload --port 8000
```

### 推荐项目结构

```text
app/
├── main.py              # FastAPI 实例 + 中间件
├── core/
│   ├── config.py        # Settings (pydantic-settings)
│   ├── security.py      # JWT + 密码哈希
│   └── deps.py          # 依赖注入（get_db, get_current_user）
├── models/              # SQLAlchemy 模型
├── schemas/             # Pydantic 请求/响应
├── api/
│   ├── v1/
│   │   ├── auth.py
│   │   ├── users.py
│   │   └── orders.py
│   └── deps.py
├── services/            # 业务逻辑
├── repositories/        # 数据访问
└── alembic/             # 数据库迁移
```

---

## 4. Django（Python）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [django](https://github.com/django/django) | 81K+ | 官方源码 |
| [djangorestframework](https://github.com/encode/django-rest-framework) | 29K+ | REST API 框架 |
| [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django) | 12K+ | 生产级 Django 模板 |
| [django-ninja](https://github.com/vitalik/django-ninja) | 7K+ | FastAPI 风格 Django |
| [django-allauth](https://github.com/pennersr/django-allauth) | 9K+ | 社会化登录 |
| [awesome-django](https://github.com/wsvincent/awesome-django) | 9K+ | Django 生态资源 |

### 快速初始化

```bash
pip install django djangorestframework django-cors-headers
pip install psycopg2-binary django-environ django-filter
pip install djangorestframework-simplejwt
pip install celery redis django-celery-beat

django-admin startproject config .
python manage.py startapp users
python manage.py startapp orders
```

---

## 5. Go (Gin / Fiber / Echo)

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [gin](https://github.com/gin-gonic/gin) | 80K+ | Go HTTP 框架 |
| [fiber](https://github.com/gofiber/fiber) | 35K+ | Express 风格 Go 框架 |
| [echo](https://github.com/labstack/echo) | 30K+ | 高性能 Go 框架 |
| [go-zero](https://github.com/zeromicro/go-zero) | 30K+ | 微服务框架（好未来） |
| [kratos](https://github.com/go-kratos/kratos) | 24K+ | 微服务框架（B站） |
| [go-gin-api](https://github.com/xinliangnote/go-gin-api) | 6K+ | Gin 生产脚手架 |
| [project-layout](https://github.com/golang-standards/project-layout) | 50K+ | Go 项目标准结构 |

### 推荐项目结构（标准）

```text
cmd/
├── server/
│   └── main.go          # 入口
internal/
├── handler/             # HTTP 处理器
├── service/             # 业务逻辑
├── repository/          # 数据访问
├── model/               # 数据模型
├── middleware/          # 中间件
└── config/              # 配置
pkg/                     # 可对外复用的包
├── logger/
├── response/
└── validator/
api/                     # OpenAPI / Proto 定义
configs/                 # 配置文件
deployments/             # Docker / K8s
migrations/              # 数据库迁移
```

### Go 微服务框架对比

| 框架 | 出品 | 特点 | 适合 |
|------|------|------|------|
| **go-zero** | 好未来 | API + RPC 一体、自动代码生成 | 国内微服务 |
| **Kratos** | B站 | 标准化、插件化、DDD 友好 | 企业级微服务 |
| **Go Kit** | 社区 | 微服务工具集（非框架） | 灵活组合 |
| **Encore** | 创业公司 | 全栈一体化、声明式基础设施 | 快速 MVP |

---

## 6. Hono（Edge/Serverless TypeScript）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [hono](https://github.com/honojs/hono) | 22K+ | 14KB 超轻量框架 |
| [hono-examples](https://github.com/honojs/examples) | 1K+ | 官方示例 |

### 快速初始化

```bash
# Cloudflare Workers
pnpm create hono my-app -- --template cloudflare-workers

# Bun
pnpm create hono my-app -- --template bun

# Node.js
pnpm create hono my-app -- --template nodejs

# 依赖
pnpm add @hono/zod-validator zod
pnpm add drizzle-orm drizzle-kit
pnpm add @hono/swagger-ui
```

### 适用场景

```text
✅ 边缘函数（Cloudflare Workers / Vercel Edge）
✅ Serverless（AWS Lambda / Vercel Functions）
✅ Bun 运行时
✅ API Gateway / BFF 层
✅ 极致性能要求（14KB，0 依赖）
❌ 不适合：需要重度 DI / 复杂中间件（用 NestJS）
```

---

## 7. Express / Fastify（Node.js）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [express](https://github.com/expressjs/express) | 66K+ | 经典 Node 框架 |
| [fastify](https://github.com/fastify/fastify) | 33K+ | 高性能 Node 框架 |
| [express-best-practices](https://github.com/goldbergyoni/nodebestpractices) | 101K+ | Node.js 最佳实践（必读） |
| [bulletproof-nodejs](https://github.com/santiq/bulletproof-nodejs) | 6K+ | Express 生产架构 |

### Node.js 最佳实践精华（来自 goldbergyoni/nodebestpractices ⭐101K）

```text
项目结构：
  - 按功能模块划分（不按技术层）
  - 每个模块：routes + controller + service + model
  - 配置用环境变量（dotenv + joi 校验）

错误处理：
  - 区分操作错误和编程错误
  - 操作错误：正常处理（返回 4xx/5xx）
  - 编程错误：记录 + 重启进程
  - 异步错误用 express-async-errors 或 Fastify 原生

安全：
  - Helmet 中间件（安全头）
  - Rate Limiting（express-rate-limit）
  - CORS 白名单配置
  - 输入校验（Joi / Zod）
  - 不返回堆栈信息

性能：
  - 用 compression 中间件
  - 静态文件交给 CDN/Nginx
  - 数据库连接池
  - 用 PM2 / cluster 模式
```

---

## 8. Laravel（PHP）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [laravel](https://github.com/laravel/laravel) | 79K+ | 官方源码 |
| [laravel-best-practices](https://github.com/alexeymezenin/laravel-best-practices) | 13K+ | Laravel 最佳实践 |
| [filament](https://github.com/filamentphp/filament) | 20K+ | Laravel 管理面板 |
| [livewire](https://github.com/livewire/livewire) | 22K+ | Laravel 全栈组件 |

---

## 9. ASP.NET Core（C#）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [aspnetcore](https://github.com/dotnet/aspnetcore) | 36K+ | 官方源码 |
| [eShop](https://github.com/dotnet/eShop) | 6K+ | 微软官方微服务示例 |
| [CleanArchitecture](https://github.com/jasontaylordev/CleanArchitecture) | 17K+ | .NET Clean Architecture |
| [ABP Framework](https://github.com/abpframework/abp) | 13K+ | .NET 模块化应用框架 |

---

## 10. Rust（Axum / Actix）

### GitHub 优质资源

| 项目 | Stars | 说明 |
|------|-------|------|
| [axum](https://github.com/tokio-rs/axum) | 20K+ | Tokio 生态 Web 框架 |
| [actix-web](https://github.com/actix/actix-web) | 22K+ | 高性能 Rust Web |
| [zero-to-production](https://github.com/LukeMathWalker/zero-to-production) | 7K+ | Rust 后端实战书代码 |
| [realworld-axum](https://github.com/launchbadge/realworld-axum-sqlx) | 1K+ | RealWorld Axum 示例 |

---

## 11. 框架性能基准（2025 TechEmpower Round 23 参考）

```text
排名（每秒请求数，越高越好）：

Tier 1（极致性能）：
  Drogon (C++)          ~7,000,000
  Actix-web (Rust)      ~6,500,000
  Axum (Rust)           ~5,000,000
  ntex (Rust)           ~5,000,000

Tier 2（高性能）：
  ASP.NET Core (C#)     ~1,000,000
  Go Fiber              ~800,000
  Go Gin                ~700,000
  Fastify (Node)        ~300,000

Tier 3（良好）：
  NestJS + Fastify      ~180,000
  Spring Boot WebFlux   ~170,000
  FastAPI (async)       ~120,000
  Express (Node)        ~46,000

Tier 4（够用）：
  Django (sync)         ~20,000
  Rails                 ~15,000
  Laravel               ~12,000

实际业务中：
  90% 瓶颈在 DB/第三方调用，不在框架
  选型看：团队熟悉度 > 生态 > 性能
```

---

## 12. 快速选型决策表

```text
Java 团队 → Spring Boot 3（无脑选）
TS 全栈 → NestJS（重） 或 Hono（轻）
Python 数据/AI → FastAPI
Python 全功能 → Django
Go 高性能 → Gin / Fiber + go-zero（微服务）
PHP → Laravel（唯一选择）
C# 企业 → ASP.NET Core
Rust 极致 → Axum
边缘/Serverless → Hono
快速全栈 MVP → Next.js API Routes / Nuxt server/
需要 Admin → Django Admin / Laravel Filament / NestJS + AdminJS
```
