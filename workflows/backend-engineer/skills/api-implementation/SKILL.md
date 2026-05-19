---
name: api-implementation
description: 把 OpenAPI 契约转成代码时使用。覆盖所有主流后端框架（Spring Boot / NestJS / Django / FastAPI / Gin / Express / Fastify / Hono / Rails / Laravel / ASP.NET Core）。融合 Clean Architecture 分层 + 框架范式。
---

# API 实现（API Implementation）

## 适用场景

- 按 OpenAPI 契约实现端点
- 多语言 / 多框架的统一分层
- 接口参数校验 / DTO / 响应序列化
- HTTP 中间件 / 拦截器 / 过滤器
- 跨语言通用模式（路由 / 控制器 / 服务）

## 核心原则

```text
1. 分层清晰
   Controller / Handler   → 接收请求、调用服务、返回响应
   Service / UseCase      → 业务逻辑、事务编排
   Repository / DAO       → 数据访问
   Domain Model           → 业务实体

2. 控制器薄如纸
   Controller 不写业务逻辑

3. DTO 与 Entity 分离
   接收输入 / 返回响应用 DTO
   ORM 实体不直接暴露给外部

4. 校验在边界
   入参校验在 Controller 层（用框架机制）
   业务规则校验在 Service 层

5. 错误统一处理
   全局错误处理器 + 异常映射

6. 不在 Controller 调多个 Service 拼装业务
   组合应该在 Service / UseCase 层
```

## 标准分层（语言无关）

```text
┌─────────────────────────────────────┐
│ Controller / Route Handler          │  HTTP 入口
│ - 解析请求 / 校验 / 调用 Service     │
│ - 返回 DTO / 错误转 HTTP 状态        │
└────────────────┬────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│ Service / UseCase                   │  业务逻辑
│ - 事务边界                          │
│ - 编排多个 Repository / 外部调用    │
│ - 业务规则校验                      │
└────────────────┬────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│ Repository / DAO                    │  数据访问
│ - 隐藏 ORM / SQL 细节               │
│ - 返回 Domain Model                 │
└────────────────┬────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│ Domain Model / Entity               │  业务实体
│ - 业务不变量                        │
│ - 值对象 / 实体                     │
└─────────────────────────────────────┘
```

## Spring Boot 范式

```java
// Controller
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
  private final OrderService orderService;
  
  @PostMapping
  public ResponseEntity<OrderDto> create(@Valid @RequestBody CreateOrderRequest req) {
    OrderDto order = orderService.createOrder(req);
    return ResponseEntity.status(HttpStatus.CREATED).body(order);
  }
  
  @GetMapping("/{id}")
  public OrderDto get(@PathVariable Long id) {
    return orderService.getOrder(id);
  }
}

// Service
@Service
@Transactional
public class OrderService {
  private final OrderRepository orderRepository;
  private final UserRepository userRepository;
  
  public OrderDto createOrder(CreateOrderRequest req) {
    User user = userRepository.findById(req.getUserId())
        .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    
    Order order = Order.create(user, req.getItems());  // 业务规则在 Domain
    Order saved = orderRepository.save(order);
    return OrderDto.from(saved);
  }
}

// Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
  List<Order> findByUserIdAndStatus(Long userId, OrderStatus status);
}

// Global Error Handler
@RestControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(ResourceNotFoundException.class)
  public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException e) {
    return ResponseEntity.status(404).body(new ErrorResponse("RESOURCE_NOT_FOUND", e.getMessage()));
  }
}
```

## NestJS 范式

```typescript
// Controller
@Controller('api/v1/orders')
export class OrderController {
  constructor(private orderService: OrderService) {}

  @Post()
  @HttpCode(201)
  async create(@Body() dto: CreateOrderDto): Promise<OrderResponseDto> {
    return this.orderService.createOrder(dto);
  }

  @Get(':id')
  async get(@Param('id', ParseIntPipe) id: number): Promise<OrderResponseDto> {
    return this.orderService.getOrder(id);
  }
}

// DTO with class-validator
export class CreateOrderDto {
  @IsInt() @IsPositive() userId: number;
  @IsArray() @ValidateNested({ each: true }) @Type(() => OrderItemDto) items: OrderItemDto[];
}

// Service
@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(Order) private orderRepo: Repository<Order>,
    private userRepo: UserRepository,
  ) {}

  @Transactional()
  async createOrder(dto: CreateOrderDto): Promise<OrderResponseDto> {
    const user = await this.userRepo.findOne(dto.userId);
    if (!user) throw new NotFoundException('User not found');
    
    const order = Order.create(user, dto.items);
    return OrderResponseDto.from(await this.orderRepo.save(order));
  }
}

// Global Exception Filter
@Catch(NotFoundException)
export class NotFoundFilter implements ExceptionFilter {
  catch(exception: NotFoundException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    response.status(404).json({
      error: { code: 'RESOURCE_NOT_FOUND', message: exception.message },
    });
  }
}
```

## Django (DRF) 范式

```python
# views.py
class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]
    
    def create(self, request):
        serializer = CreateOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = OrderService.create_order(
            user_id=serializer.validated_data['user_id'],
            items=serializer.validated_data['items'],
        )
        return Response(OrderSerializer(order).data, status=201)

# serializers.py
class CreateOrderSerializer(serializers.Serializer):
    user_id = serializers.IntegerField(min_value=1)
    items = OrderItemSerializer(many=True)

# services.py
class OrderService:
    @staticmethod
    @transaction.atomic
    def create_order(user_id, items):
        user = User.objects.get(id=user_id)
        order = Order.create(user=user, items=items)
        order.save()
        return order

# Custom exception handler (settings.py: REST_FRAMEWORK)
def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        response.data = {
            'error': {
                'code': exc.__class__.__name__,
                'message': str(exc),
            }
        }
    return response
```

## FastAPI 范式

```python
# main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

app = FastAPI()

@app.post("/api/v1/orders", status_code=201, response_model=OrderResponseDto)
async def create_order(
    dto: CreateOrderDto,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await order_service.create_order(db, dto, current_user)

# DTO with Pydantic
class CreateOrderDto(BaseModel):
    user_id: int = Field(gt=0)
    items: list[OrderItemDto] = Field(min_length=1)

# Service
class OrderService:
    @staticmethod
    async def create_order(db: Session, dto: CreateOrderDto, user: User) -> OrderResponseDto:
        order = Order.create(user, dto.items)
        db.add(order)
        db.commit()
        db.refresh(order)
        return OrderResponseDto.from_orm(order)

# Global exception handler
@app.exception_handler(ResourceNotFoundException)
async def not_found_handler(request, exc):
    return JSONResponse(
        status_code=404,
        content={"error": {"code": "RESOURCE_NOT_FOUND", "message": str(exc)}},
    )
```

## Go (Gin) 范式

```go
// handler/order.go
type OrderHandler struct {
    service *service.OrderService
}

func (h *OrderHandler) Create(c *gin.Context) {
    var req CreateOrderRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": gin.H{"code": "VALIDATION_ERROR", "message": err.Error()}})
        return
    }
    
    order, err := h.service.CreateOrder(c.Request.Context(), req)
    if err != nil {
        handleError(c, err)
        return
    }
    
    c.JSON(201, OrderResponseDTO{}.FromEntity(order))
}

// service/order.go
func (s *OrderService) CreateOrder(ctx context.Context, req CreateOrderRequest) (*model.Order, error) {
    user, err := s.userRepo.FindByID(ctx, req.UserID)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    
    order, err := model.NewOrder(user, req.Items)
    if err != nil {
        return nil, err
    }
    
    return s.orderRepo.Save(ctx, order)
}

// 路由 + 中间件
r := gin.Default()
r.Use(middleware.Logger())
r.Use(middleware.Recovery())
r.Use(middleware.Auth())

api := r.Group("/api/v1")
api.POST("/orders", h.Create)
api.GET("/orders/:id", h.Get)
```

## Express / Fastify 范式

```typescript
// Express
const router = express.Router();

router.post('/orders', authenticate, validate(createOrderSchema), async (req, res, next) => {
  try {
    const order = await orderService.create(req.body);
    res.status(201).json(order);
  } catch (err) {
    next(err);
  }
});

// 全局错误处理
app.use((err, req, res, next) => {
  if (err instanceof NotFoundError) {
    return res.status(404).json({ error: { code: 'NOT_FOUND', message: err.message } });
  }
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Internal Server Error' } });
});

// Fastify
fastify.post('/orders', {
  schema: { body: createOrderSchema, response: { 201: orderResponseSchema } },
  preHandler: [fastify.authenticate],
}, async (request, reply) => {
  const order = await orderService.create(request.body);
  reply.status(201).send(order);
});
```

## 工作流程

```text
1. 读取 OpenAPI 契约
   ↓
2. 选定技术栈 + 分层规范
   ↓
3. 创建 DTO（请求/响应）
   ↓
4. 实现 Controller（薄）
   ↓
5. 实现 Service（业务逻辑）
   ↓
6. 实现 Repository（数据访问）
   ↓
7. 全局错误处理器
   ↓
8. 单元测试 + 集成测试
   ↓
9. 验证：契约一致 + 错误码统一 + 校验完备
```

## 中间件 / 拦截器（横切关注点）

```text
通用层（建议每个服务都有）：
  □ 认证（auth）
  □ 鉴权（authorize）
  □ 请求 ID 生成（trace_id）
  □ 日志（access log）
  □ 异常捕获（global error handler）
  □ 请求体校验
  □ 限流（rate limit）
  □ CORS

按需层：
  □ 缓存
  □ 压缩
  □ 安全头（helmet 风格）
  □ 国际化
  □ Audit log
```

## 配套模板

- `templates/api-implementation-checklist.md` — 多框架实现检查清单 + 分层验证 + 中间件清单 + 测试覆盖

## 质量自检

```text
□ Controller 不超过 30 行（薄）
□ 业务逻辑全部在 Service
□ DTO 与 Entity 分离
□ 入参校验完备（用框架机制）
□ 全局错误处理器统一返回格式
□ 错误码与 API 设计契约一致
□ 中间件覆盖：auth + log + trace + error + validate
□ 路由命名符合 OpenAPI 路径
□ HTTP 状态码符合语义（POST → 201 / DELETE → 204）
□ 单元测试覆盖 Service 层
□ 集成测试覆盖端到端
□ 性能验证（满足 SLA）
```

## 常见坑

1. **Controller 写业务逻辑** → 难测、难复用
2. **DTO 与 Entity 共用** → API 改一下数据库改一下
3. **校验只在 Controller** → Service 被绕过时没保护
4. **每个端点单独错误处理** → 不一致、漏处理
5. **不用框架的中间件机制** → 每个端点重复代码
6. **Controller 直接调多个 Repository** → 业务逻辑分散
7. **全局错误处理器吃掉所有异常** → 调试困难
8. **DTO 字段命名与 OpenAPI 不一致** → 联调返工
9. **缺少请求 ID** → 无法追踪
10. **校验失败返回不一致格式** → 前端处理混乱

## 与其他 skill 的协作

```text
上游：
  api-designer 工作流 → OpenAPI 契约
  api 设计 endpoint-design / request-response → 详细规范

下游：
  domain-modeling → 业务规则实现
  data-access → 数据访问
  auth-implementation → 中间件
  testing-implementation → 测试
  observability → 日志中间件
```

## 相关参考

- 项目根 `references/backend-frameworks-2026.md` — 框架对比
- 项目根 `references/backend-tech-stack-guide.md` — 组件全景
