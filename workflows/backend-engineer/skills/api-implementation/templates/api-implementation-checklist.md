# API 实现检查清单（多框架适用）

## 1. 项目信息

```text
模块：
端点数：
框架：Spring Boot / NestJS / Django / FastAPI / Gin / Express / 其他
版本：
负责人：
```

---

## 2. 分层结构（必查）

| 层 | 文件 | 行数 | 职责 |
|---|---|---|---|
| Controller / Handler |  | < 30 行 | HTTP 入口、参数校验、调用 Service |
| Service / UseCase |  | - | 业务逻辑、事务、编排 |
| Repository / DAO |  | - | 数据访问、隐藏 ORM 细节 |
| Domain Model |  | - | 业务实体、值对象、不变量 |
| DTO |  | - | 输入 / 输出 |

---

## 3. 中间件 / 拦截器清单

| 类型 | 是否实现 | 实现位置 | 备注 |
|---|---|---|---|
| 认证 | ✅ | middleware/auth | JWT / Session / API Key |
| 鉴权 | ✅ | guards/policies | RBAC / ABAC |
| 请求 ID | ✅ | middleware/request-id | trace_id |
| 访问日志 | ✅ | middleware/log |  |
| 异常捕获 | ✅ | global error handler |  |
| 请求校验 | ✅ | DTO + decorator | class-validator / Pydantic / @Valid |
| 限流 | ⏳ | rate-limiter | Redis-based |
| CORS | ✅ | global | 仅信任源 |
| 安全头 | ✅ | helmet 风格 | XSS/CSRF |
| 压缩 | ⏳ | gzip / brotli |  |
| Audit log | ⏳ |  | 关键操作记录 |

---

## 4. 端点检查（每个端点必查）

| 端点 | Method | Path | 状态码 | 鉴权 | 校验 | 测试 |
|---|---|---|---|---|---|---|
|  |  |  | 201/200/204 | role |  | ✅ |

### 端点详细

```text
端点：POST /api/v1/orders
- DTO 类：CreateOrderDto / OrderResponseDto
- Service 方法：OrderService.createOrder()
- 鉴权：role IN (user, admin)
- 校验：@Valid / class-validator / Pydantic
- HTTP 状态码：201 Created
- 错误码：VALIDATION_ERROR / FORBIDDEN / RESOURCE_NOT_FOUND
- 单元测试：OrderServiceTest.testCreateOrder
- 集成测试：OrderControllerIT.testCreateOrder201
- OpenAPI：契约一致
```

---

## 5. 全局错误处理

```text
□ 已实现全局错误处理器
□ 错误响应统一格式：
  {
    "error": {
      "code": "ERROR_CODE",
      "message": "human-readable",
      "details": [...],
      "request_id": "req_xxx"
    }
  }
□ HTTP 状态码语义正确
□ 不暴露内部细节（stack trace / SQL）
□ 与 API 设计错误码表一致
```

---

## 6. 数据校验完整性

```text
□ 必填字段
□ 字段类型
□ 字段长度
□ 字段格式（email / url / regex）
□ 枚举值
□ 数值范围
□ 业务规则校验（在 Service 层）
□ JSON parse 错误返回 400 而非 500
```

---

## 7. 框架特定检查

### Spring Boot
```text
□ @Valid 在 Controller 参数
□ @Transactional 在 Service 方法
□ @RestControllerAdvice 全局错误
□ DTO 用 record 或 @Builder
□ 实体用 @Entity，DTO 不用
□ 用 Optional 或 throw，不返回 null
```

### NestJS
```text
□ DTO 用 class-validator + class-transformer
□ ValidationPipe 全局启用
□ 全局 ExceptionFilter
□ Guards 实现鉴权
□ Interceptors 处理日志/缓存
□ Pipes 处理转换/校验
```

### Django + DRF
```text
□ Serializer 校验
□ ViewSet 用泛型类
□ permission_classes 配置
□ @transaction.atomic 装饰器
□ 自定义 exception_handler
```

### FastAPI
```text
□ Pydantic v2 BaseModel
□ Depends() 注入
□ @app.exception_handler 全局
□ async/await 正确使用
□ response_model 指定返回类型
```

### Go (Gin)
```text
□ ShouldBindJSON 校验
□ context.Context 贯穿
□ error wrap (fmt.Errorf("%w", err))
□ middleware 注册顺序
□ 优雅关闭（graceful shutdown）
```

---

## 8. 测试覆盖

```text
□ 每个 Controller 至少 1 个集成测试
□ 每个 Service 方法至少 1 个单元测试
□ 失败路径覆盖：401 / 403 / 404 / 409 / 422 / 429
□ 边界值测试
□ 并发场景测试
```

---

## 9. 性能验证

```text
□ P99 响应时间 < SLO
□ 单实例 QPS ≥ 目标
□ 错误率 < 0.1%
□ 与上版本基线对比
```

---

## 10. 上线前自检

```text
□ 契约一致（OpenAPI vs 实现）
□ 错误码统一
□ 日志结构化 + trace_id
□ 不输出敏感信息
□ 配置非硬编码（用环境变量 / 配置中心）
□ 健康检查端点（/health）
□ Metrics 端点（/metrics）
□ Code Review 通过
□ 单元 + 集成测试通过
□ 与前端 / QA / DevOps 交接
```
