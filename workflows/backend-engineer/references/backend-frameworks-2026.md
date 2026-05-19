# 后端框架全景指引 2026

参考：TechEmpower Round 23、State of JS 2025、Stack Overflow 2025、各框架官方文档、GitHub stars 与 npm/Maven/PyPI 下载量。

> 本文档持续更新。AI 工作流每次新建后端项目前都应快速过一遍。

## 1. 选型决策树

```text
首先回答 4 个问题：

Q1：业务体量？
  小（< 10 万用户）→ 任何成熟框架都行，看团队栈
  中（10~100 万）→ 主流框架 + 性能优化
  大（百万+）→ 企业级框架 / 自研 / 微服务

Q2：团队语言能力？
  Java/Kotlin 优势 → Spring Boot
  Python 优势 → Django / FastAPI
  TypeScript 优势 → NestJS / Fastify / Hono
  Go 优势 → Gin / Fiber / Echo
  PHP 优势 → Laravel
  C# 优势 → ASP.NET Core
  Ruby 优势 → Rails

Q3：业务特征？
  企业级 / 金融 → Spring Boot, ASP.NET Core
  AI / 数据 → FastAPI / Django
  实时 / WebSocket → Phoenix, NestJS, Spring WebFlux
  Edge / Serverless → Hono, Encore, Cloudflare Workers
  快速 MVP → Rails, Laravel, Django, NestJS
  超高并发 → Go, Rust, ASP.NET Core

Q4：交付时间？
  < 1 周（POC）→ Rails / Laravel / Django + Admin
  1 月 → 主流任意
  3 月+（核心）→ 投资学习曲线值得
```

## 2. 框架完整档案

### Spring Boot 3 (Java/Kotlin)

```text
官网: spring.io
最新版本: 3.4 (2025)
GitHub Stars: 75K+
适合: 企业级、金融、电商、内容平台

核心特性：
  - 约定大于配置（auto-configuration）
  - Spring Cloud（微服务）：Eureka / Gateway / Config
  - Spring Data：JPA / R2DBC / Redis / MongoDB
  - Spring Security（认证 / 授权工业级标准）
  - Spring WebFlux（响应式）
  - GraalVM Native（启动 100ms、内存减半）
  - Project Loom 虚拟线程（Java 21+）

性能（TechEmpower R23）:
  - Spring MVC: ~170,000 req/s
  - Spring WebFlux: ~250,000 req/s
  - Spring Native AOT: 启动 ~100ms

生态：
  Maven Central: 数百万构件
  Spring Boot Starters: 100+ 官方
  Spring Cloud: Netflix / Alibaba / Azure / AWS

大厂用：阿里巴巴、Netflix、Walmart、Allianz
```

### NestJS

```text
官网: nestjs.com
最新版本: 11 (2025)
GitHub Stars: 70K+
适合: 中大型 TS 项目、企业 SaaS、需要结构化的团队

核心特性：
  - Angular 风格（DI、装饰器、模块）
  - 可换底层（Express / Fastify）
  - 完整生态：Guards / Interceptors / Pipes / Filters
  - GraphQL / WebSocket / Microservices 一等公民
  - 内置 Swagger 自动生成

性能：
  - NestJS + Express: ~46K req/s
  - NestJS + Fastify: ~180K req/s

冷启动：~500ms~2000ms（不适合 Edge）

生态：
  npm @nestjs/* 数十个官方包
  社区：CASL（权限）、Bull（队列）、TypeORM/Prisma

大厂用：Adidas、Roche、Société Générale
```

### Express.js

```text
官网: expressjs.com
最新版本: 5 (2025 release)
GitHub Stars: 65K+
适合: 简单 API、POC、教学

核心特性：
  - 极简（核心 ~1MB）
  - 中间件链
  - 海量第三方中间件

性能：
  - ~46K req/s（本身瓶颈不在框架）

劣势：
  - 无结构、需自己拼
  - TypeScript 支持靠社区
  - Express 4 维护多年，5 才正式发布
  
生态：每月 npm 下载 4000 万+
```

### Fastify

```text
官网: fastify.io
最新版本: 5 (2024-2025)
GitHub Stars: 33K+
适合: 替代 Express、API 性能优化

核心特性：
  - 2-3x Express 性能
  - 内置 JSON Schema 验证
  - 插件系统
  - TypeScript 友好

性能：
  - ~95K req/s（Express 2x）

何时用：你已经在用 Express，想性能升级
```

### Hono

```text
官网: hono.dev
最新版本: 4 (2025)
GitHub Stars: 22K+
适合: Edge / Serverless / 跨运行时

核心特性：
  - 14KB（极小）
  - 跨运行时（Bun / Deno / Cloudflare Workers / Node / AWS Lambda）
  - Web Standards API（Request/Response）
  - JSX 内置（用于 SSR）
  - 性能堪比 Fastify

何时用：Cloudflare Workers / Vercel Edge / Bun 项目
```

### Encore.ts

```text
官网: encore.dev
GitHub Stars: 6K+ （新兴）
适合: 全栈 TS 微服务、想要 BaaS 体验

核心特性：
  - 类型安全 RPC
  - 自动基础设施（数据库 / 队列 / 缓存）
  - 9x Express 性能
  - 内置 Tracing / Metrics
  - Local Dev Dashboard

劣势：
  - 框架锁定（vendor lock-in）
  - 相对新

何时用：新项目 + 团队接受 opinionated 工具链
```

### Django

```text
官网: djangoproject.com
最新版本: 5.1 (2025)
GitHub Stars: 80K+
适合: CRUD 后台、内容平台、MVP

核心特性：
  - Batteries-included（ORM / Admin / Auth / Forms）
  - Django REST Framework（API）
  - Channels（WebSocket / Async）
  - django-allauth（社交登录）
  - django-celery（异步任务）

性能：
  - 同步：~20K req/s
  - 异步（5+）：显著提升

生态：PyPI django-* 数千包

大厂用：Instagram、Pinterest、Disqus、Mozilla
```

### FastAPI

```text
官网: fastapi.tiangolo.com
最新版本: 0.115 (2025)
GitHub Stars: 80K+
适合: AI/ML 后端、现代 Python API、微服务

核心特性：
  - 类型注解驱动
  - 自动生成 OpenAPI
  - async/await 原生
  - Pydantic 数据校验
  - Starlette（底层 ASGI）

性能：
  - ~120K req/s（async）

何时用：Python 团队、AI 模型服务、新项目
```

### Flask

```text
官网: flask.palletsprojects.com
GitHub Stars: 68K+
适合: 微服务、简单 API、教学

核心特性：
  - 极简
  - WSGI（同步）
  - Flask-RESTful / Flask-SQLAlchemy / Flask-Login

何时用：简单工具、传统 Python 团队
```

### Gin (Go)

```text
官网: github.com/gin-gonic/gin
GitHub Stars: 80K+
适合: 高并发 API、微服务

核心特性：
  - 极简路由
  - 中间件链
  - 性能极致

性能：
  - ~150K req/s

生态：Gonic / GORM / Echo 共用社区
```

### Fiber (Go)

```text
官网: gofiber.io
GitHub Stars: 35K+
适合: Express 用户转 Go

核心特性：
  - Express 风格 API
  - Go 性能（~12M req/s 微基准）

劣势：
  - 不基于 net/http（有兼容问题）
```

### Echo (Go)

```text
官网: echo.labstack.com
GitHub Stars: 30K+
适合: 中间件丰富、模板渲染需求

核心特性：与 Gin 类似，多模板支持
```

### Rails

```text
官网: rubyonrails.org
最新版本: 8 (2024)
GitHub Stars: 56K+
适合: 快速 MVP、内容平台、敏捷开发

核心特性：
  - 约定大于配置
  - ActiveRecord ORM
  - Hotwire（替代 SPA）
  - Solid Cache / Solid Queue / Solid Cable（自带）

何时用：1 人 startup、Ruby 团队、需要快出 MVP

大厂用：GitHub、Shopify、Airbnb（部分）、Basecamp
```

### Laravel

```text
官网: laravel.com
最新版本: 11 (2024)
GitHub Stars: 78K+
适合: PHP 全栈、CMS、电商

核心特性：
  - Eloquent ORM
  - Blade 模板
  - Livewire（SPA-like）
  - Laravel Octane（Swoole / RoadRunner，10x 性能）
  - Forge / Vapor（部署）

何时用：PHP 团队、CMS / 电商
```

### ASP.NET Core

```text
官网: dotnet.microsoft.com
最新版本: 9 (2024)
GitHub Stars: 35K+
适合: 企业级、Windows 生态、跨平台高性能

核心特性：
  - Minimal API（轻量）
  - MVC / Web API
  - SignalR（WebSocket）
  - EF Core（ORM）
  - Native AOT（启动快）

性能：
  - Minimal API: ~1,000,000 req/s（TechEmpower 顶级）

大厂用：Microsoft、Stack Overflow、Walmart
```

### Axum (Rust)

```text
官网: github.com/tokio-rs/axum
GitHub Stars: 22K+
适合: 极致性能、内存敏感、安全关键

核心特性：
  - 类型安全路由
  - Tokio 运行时
  - tower 中间件生态
  - 零成本抽象

何时用：性能 / 内存极致、Rust 团队

劣势：学习曲线陡、生态不如 Java/Node
```

### Phoenix (Elixir)

```text
官网: phoenixframework.org
GitHub Stars: 22K+
适合: 实时应用、聊天、协作工具

核心特性：
  - LiveView（服务端推送 UI）
  - 200 万 WebSocket / 节点
  - Ecto ORM

何时用：Discord 风格实时、Erlang/OTP 优势
```

## 3. 跨语言性能对比（TechEmpower R23 简版）

```text
JSON serialization (req/s, 越高越好):

ASP.NET Core (Minimal API)   ███████████████████████████████ 7M
Axum (Rust)                  ████████████████████████████ 6.5M
Go Fiber                     ██████████████████████████ 6M
Spring Boot (WebFlux)        ████████████ 2.8M
NestJS + Fastify             ███████ 1.6M
FastAPI (uvicorn workers)    █████ 1.2M
Express                      ██ 460K
Django (sync)                █ 200K

注：业务复杂时差距大幅缩小（90% 时间在 DB / IO）
```

## 4. 大厂技术栈案例

### Netflix（混合架构）
```text
- 前端 BFF: Node.js
- 推荐 / 视频处理: Java / Spring Boot
- 数据管道: Python
- 实时通信: Erlang / Elixir 部分
```

### Uber
```text
- 主服务: Go (从 Node 迁移)
- 数据处理: Python
- ML 服务: Python + FastAPI
- 调度: Java
```

### Airbnb
```text
- 主服务: Java / Spring Boot
- 数据 / ML: Python
- BFF: Node.js
- 实时: Kotlin
```

### Shopify
```text
- 主服务: Rails
- 边缘: Cloudflare Workers / Hono
- 实时: Erlang
- 数据: Spark / Python
```

### Stripe
```text
- 主服务: Ruby（自定义 Sorbet 类型）
- 实时: Kotlin
- 数据: Scala
- API 网关: Go
```

### GitHub
```text
- 主服务: Rails
- 高并发组件: Go
- 工具: Python
```

### Discord
```text
- 实时: Elixir / Phoenix（聊天）
- API: Rust（关键服务）
- 工具: Python
```

## 5. 微服务 vs 单体决策

```text
单体优先（< 10 人团队 / 早期创业）：
  ✅ Spring Boot (Modulith)
  ✅ Django
  ✅ Rails
  ✅ Laravel
  ✅ NestJS
  → 后期可拆

微服务（成熟阶段、多团队）：
  ✅ Spring Boot + Spring Cloud
  ✅ Encore.ts（自动化）
  ✅ Go (Gin/Fiber)
  ✅ Kubernetes + Istio

不推荐：
  ❌ 早期就微服务（运维成本爆炸）
  ❌ 单体超过 100 万行不拆（开发体验崩溃）
```

## 6. 框架升级策略

```text
非 LTS 版本：每年升级（持续）
LTS 版本：每 2~3 年大升级（小心）

升级步骤：
  1. 看 Release Notes（Breaking Changes）
  2. 升级测试环境
  3. 跑全套测试
  4. 灰度发布

不推荐：跳版本升级（如 Spring Boot 2 → 3 中间跳过 2.7）
```

## 7. 选型反模式

```text
❌ "用最火的框架"
   → 火 ≠ 适合你

❌ "性能基准最高"
   → 业务瓶颈不在框架

❌ "团队不熟也要上"
   → 学习成本 > 性能收益

❌ "微服务起步"
   → 运维爆炸

❌ "追新潮"
   → 生态未成熟，遇 bug 无人修
```

## 8. 持续学习资源

```text
官方文档（首选）：
  - spring.io/projects/spring-boot
  - docs.nestjs.com
  - docs.djangoproject.com
  - fastapi.tiangolo.com

技术博客：
  - Encore.dev/articles（框架对比）
  - Martin Fowler 博客
  - High Scalability

性能基准：
  - TechEmpower Benchmarks（每年 Round）

GitHub Trending：
  - https://github.com/trending/[language]?since=monthly

调研报告：
  - State of JS / State of Python
  - Stack Overflow Developer Survey
  - JetBrains Developer Ecosystem
```
