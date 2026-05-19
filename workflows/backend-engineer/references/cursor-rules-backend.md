# 后端 AI 编码规则集（Cursor/Claude/Copilot 通用）

> 来源：awesome-cursorrules + 社区最佳实践 + 大厂规范。
> 用途：AI 执行后端任务时自动加载，作为编码行为约束。

---

## Spring Boot 3 规则

```text
架构分层（强制）：
  Controller → 参数校验 + DTO 转换 + 调用 Service（不写业务）
  Service    → 业务逻辑（核心价值）+ 事务管理
  Repository → 数据访问（MyBatis-Plus / JPA）
  Manager    → 通用能力封装（缓存/MQ/第三方调用）

命名规范：
  Service 接口: XxxService
  Service 实现: XxxServiceImpl
  Controller:   XxxController（@RestController）
  Repository:   XxxRepository 或 XxxMapper
  DTO:          XxxRequest / XxxResponse / XxxVO / XxxDTO
  Entity:       Xxx（直接实体名）
  Config:       XxxConfig / XxxProperties

依赖注入：
  - 用构造器注入（不用 @Autowired 字段注入）
  - 用 @RequiredArgsConstructor（Lombok）
  - 接口编程（Service 定义接口）

异常处理：
  - 定义业务异常 BizException(code, message)
  - @RestControllerAdvice 全局处理
  - 不要 catch Exception 只 log 不抛
  - HTTP 状态码正确使用（不全返回 200）

配置：
  - 敏感配置用环境变量 ${DB_PASSWORD}
  - 多环境用 spring.profiles.active
  - 配置类用 @ConfigurationProperties（不用 @Value）

API 设计：
  - RESTful 规范（名词复数 /api/v1/users）
  - 统一返回格式 Result<T>
  - 分页用 PageRequest / PageResponse
  - 版本管理在 URL（/v1/ /v2/）
```

---

## NestJS 规则

```text
架构：
  - 模块化（每个功能一个 Module）
  - Controller → Service → Repository 三层
  - 用 DTO class + class-validator 做输入校验
  - 用 Pipes 做数据转换
  - 用 Guards 做认证授权
  - 用 Interceptors 做统一响应格式 + 日志

TypeScript：
  - 开启 strict
  - 所有 DTO 都是 class（不是 interface）
  - 用 class-validator 装饰器（@IsString, @IsEmail...）
  - Repository 返回值有明确类型

依赖注入：
  - 构造器注入（NestJS 默认）
  - 自定义 Provider 用 useFactory / useClass
  - 跨模块用 exports + imports

错误处理：
  - 用 NestJS 内置异常（NotFoundException, BadRequestException...）
  - 自定义 ExceptionFilter 做统一格式
  - 不要用 try/catch 包每个 service 方法

数据库（Prisma 推荐）：
  - schema.prisma 定义所有模型
  - 迁移用 prisma migrate dev
  - 查询用 Prisma Client（类型安全）
  - 复杂查询用 $queryRaw
```

---

## FastAPI 规则

```text
架构：
  routers/     → 路由定义（FastAPI Router）
  services/    → 业务逻辑
  models/      → SQLAlchemy / Pydantic 模型
  schemas/     → Pydantic 请求/响应 schema
  deps/        → 依赖注入（get_db, get_current_user）
  core/        → 配置、安全、异常

类型：
  - 所有函数参数有类型注解
  - 返回值有类型注解
  - Pydantic BaseModel 做 DTO（不用 dict）
  - 用 Annotated[type, Depends(...)] 做依赖注入

异步：
  - I/O 密集操作用 async def（数据库/HTTP）
  - CPU 密集用同步（或 run_in_executor）
  - 数据库用 async SQLAlchemy（asyncpg）
  - HTTP 客户端用 httpx（async）

安全：
  - JWT 认证用 Depends(get_current_user)
  - 密码用 bcrypt/argon2（passlib）
  - CORS 配置在 middleware
  - Rate limit 用 slowapi
  - 敏感配置用 pydantic-settings + .env

文档：
  - 所有路由有 docstring（Swagger 自动展示）
  - response_model 定义返回格式
  - responses 参数定义错误码
  - tags 分组
```

---

## Go (Gin/Fiber) 规则

```text
项目结构：
  cmd/          → 入口 main.go
  internal/     → 内部包（不对外暴露）
    handler/    → HTTP 处理器
    service/    → 业务逻辑
    repository/ → 数据访问
    model/      → 数据模型
    middleware/ → 中间件
  pkg/          → 可对外复用的包
  config/       → 配置
  migrations/   → DB 迁移

风格：
  - 接口小而精（1-3 个方法）
  - 错误处理：返回 error，不 panic
  - 不用全局变量（依赖注入）
  - Context 传递 trace_id / user_id
  - 不要 init()（除非必要）

并发：
  - goroutine 必须有 recover
  - channel 优先于 mutex
  - context.WithTimeout 所有外部调用
  - sync.Pool 复用大对象
  - errgroup 做并行任务
```

---

## 数据库操作通用规则

```text
查询：
  - 不要 SELECT *（列出需要的列）
  - 分页用游标（WHERE id > ?）不用 OFFSET
  - 批量操作用 batch（不逐条）
  - 大表查询加 LIMIT
  - JOIN 不超过 3 张表

事务：
  - 事务内不做 HTTP/MQ 调用
  - 事务越短越好
  - 读多写少用 READ COMMITTED
  - 金融场景用 SERIALIZABLE

索引：
  - 频繁查询的字段加索引
  - 联合索引注意最左前缀
  - 不要给每个列都加索引
  - 定期检查慢查询

迁移：
  - 每次变更一个 migration 文件
  - 先加列后删列（不要直接改列名）
  - 大表加索引用 CONCURRENTLY
  - 每次 migration 必须可回滚
```

---

## API 安全规则

```text
认证：
  - 所有接口默认需要认证（白名单式放开）
  - Token 存 httpOnly cookie 或 Authorization header
  - Token 有过期时间（access: 15min, refresh: 7d）

授权：
  - 校验资源属于当前用户（不只是角色）
  - 批量接口加数量限制
  - 管理员操作二次验证

输入：
  - 所有输入 schema 校验（不信任前端）
  - 文件上传限制类型 + 大小
  - 防 SQL 注入（参数化查询）
  - 防 XSS（输出编码）
  - 防 SSRF（URL 白名单）

输出：
  - 不返回密码/token/内部 ID
  - 错误不暴露堆栈/SQL
  - 添加安全头

限流：
  - IP 级全局限流
  - 用户级接口限流
  - 敏感操作严格限流（登录/注册/短信）
```
