---
name: testing-implementation
description: 实现单元测试 / 集成测试 / 契约测试时使用。覆盖 JUnit 5 / Jest / Vitest / pytest / Go testing / RSpec / xUnit + Pact 契约测试 + Testcontainers。融合测试金字塔实现 + 双倍替身 + AAA 模式。
---

# 测试实现（Testing Implementation）

参考来源：Mike Cohn 测试金字塔、Martin Fowler《xUnit Test Patterns》、Kent Beck《Test-Driven Development》、Pact Foundation、Testcontainers 文档、Stripe / GitHub 测试实践。

## 适用场景

- 单元测试实现（业务逻辑、工具函数）
- 集成测试实现（DB、Redis、HTTP）
- 契约测试（消费者驱动 / Pact）
- E2E 测试（少量、关键路径）
- Mock / Stub / Fake 设计
- 测试数据管理
- 性能基准测试

## 核心原则

```text
1. 测试金字塔
   单元（70%）+ 集成（20%）+ E2E（10%）

2. AAA 模式
   Arrange（准备）+ Act（执行）+ Assert（断言）

3. 一个用例测一件事
   多个断言但围绕一个行为

4. 命名说明意图
   shouldReturnError_WhenAmountIsNegative
   不是 test_001 / testCreateOrder

5. 不测实现细节
   测行为输出，不测内部调用顺序

6. Mock 适度
   Mock 外部依赖
   不 Mock 自己写的代码

7. 集成测试用真实依赖
   用 Testcontainers，不用 H2 / Mock DB

8. 测试运行快
   单元 < 100ms，集成 < 5s，全套 < 5min
```

## 测试金字塔实现

```text
        /\
       /E2\         5~15 个：核心用户旅程，慢、贵
      /----\
     / 集成 \       50~200 个：API 端到端，DB / Redis
    /--------\
   /   单元   \    1000+：业务逻辑、工具函数
  /------------\
```

## AAA 模式

```java
@Test
void shouldCancelOrder_WhenStatusIsPaid() {
  // Arrange
  Order order = OrderFactory.create()
    .withStatus(OrderStatus.PAID)
    .build();
  
  // Act
  order.cancel();
  
  // Assert
  assertThat(order.getStatus()).isEqualTo(OrderStatus.CANCELLED);
  assertThat(order.getCancelledAt()).isNotNull();
}

@Test
void shouldThrowError_WhenCancelDraftOrder() {
  // Arrange
  Order order = OrderFactory.create()
    .withStatus(OrderStatus.DRAFT)
    .build();
  
  // Act + Assert
  assertThatThrownBy(() -> order.cancel())
    .isInstanceOf(IllegalStateException.class)
    .hasMessageContaining("Only paid orders");
}
```

## 单元测试范式

### Java + JUnit 5 + Mockito + AssertJ

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
  @Mock private OrderRepository orderRepo;
  @Mock private PaymentClient paymentClient;
  @InjectMocks private OrderService orderService;
  
  @Test
  void shouldCreateOrder_WithValidInput() {
    // Arrange
    CreateOrderRequest req = new CreateOrderRequest(1L, List.of(item1));
    User user = UserFactory.create(1L);
    given(userRepo.findById(1L)).willReturn(Optional.of(user));
    given(orderRepo.save(any(Order.class))).willAnswer(inv -> inv.getArgument(0));
    
    // Act
    OrderDto result = orderService.createOrder(req);
    
    // Assert
    assertThat(result.getStatus()).isEqualTo(OrderStatus.DRAFT);
    verify(orderRepo).save(any(Order.class));
  }
  
  @ParameterizedTest
  @ValueSource(ints = {-1, 0, 101})
  void shouldRejectInvalidQuantity(int qty) {
    OrderItem item = new OrderItem(productId, qty);
    assertThatThrownBy(() -> Order.create(user, List.of(item)))
      .isInstanceOf(IllegalArgumentException.class);
  }
}
```

### TypeScript + Jest

```typescript
describe('OrderService', () => {
  let service: OrderService;
  let orderRepo: jest.Mocked<OrderRepository>;
  let paymentClient: jest.Mocked<PaymentClient>;
  
  beforeEach(() => {
    orderRepo = createMock<OrderRepository>();
    paymentClient = createMock<PaymentClient>();
    service = new OrderService(orderRepo, paymentClient);
  });
  
  it('should create order with valid input', async () => {
    // Arrange
    const dto = { userId: 1, items: [{ productId: 100, qty: 2 }] };
    orderRepo.create.mockResolvedValue({ id: 1, status: 'DRAFT' } as Order);
    
    // Act
    const result = await service.createOrder(dto);
    
    // Assert
    expect(result.status).toBe('DRAFT');
    expect(orderRepo.create).toHaveBeenCalledWith(expect.objectContaining({
      userId: 1,
    }));
  });
  
  it.each([
    [-1, 'INVALID_QUANTITY'],
    [0, 'INVALID_QUANTITY'],
    [101, 'EXCEEDS_LIMIT'],
  ])('should reject quantity %i with error %s', async (qty, errorCode) => {
    const dto = { userId: 1, items: [{ productId: 100, qty }] };
    
    await expect(service.createOrder(dto)).rejects.toMatchObject({
      code: errorCode,
    });
  });
});
```

### TypeScript + Vitest（更快）

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('Order', () => {
  it('cancels paid order', () => {
    const order = Order.create(user, items);
    order.pay();
    
    order.cancel();
    
    expect(order.status).toBe('CANCELLED');
  });
});
```

### Python + pytest

```python
import pytest
from unittest.mock import Mock, patch

class TestOrderService:
    @pytest.fixture
    def order_repo(self):
        return Mock(spec=OrderRepository)
    
    @pytest.fixture
    def service(self, order_repo):
        return OrderService(order_repo)
    
    def test_create_order_with_valid_input(self, service, order_repo):
        # Arrange
        dto = CreateOrderDto(user_id=1, items=[item1])
        order_repo.create.return_value = Order(id=1, status='DRAFT')
        
        # Act
        result = service.create_order(dto)
        
        # Assert
        assert result.status == 'DRAFT'
        order_repo.create.assert_called_once()
    
    @pytest.mark.parametrize('qty,expected_error', [
        (-1, 'INVALID_QUANTITY'),
        (0, 'INVALID_QUANTITY'),
        (101, 'EXCEEDS_LIMIT'),
    ])
    def test_invalid_quantity(self, service, qty, expected_error):
        dto = CreateOrderDto(user_id=1, items=[ItemDto(product_id=1, qty=qty)])
        
        with pytest.raises(BusinessError) as exc_info:
            service.create_order(dto)
        assert exc_info.value.code == expected_error
```

### Go testing

```go
func TestOrderService_CreateOrder(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateOrderRequest
        want    OrderStatus
        wantErr bool
    }{
        {
            name:  "valid input",
            input: CreateOrderRequest{UserID: 1, Items: []Item{{ProductID: 100, Qty: 2}}},
            want:  OrderStatusDraft,
        },
        {
            name:    "invalid quantity",
            input:   CreateOrderRequest{UserID: 1, Items: []Item{{ProductID: 100, Qty: -1}}},
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := mocks.NewOrderRepository(t)
            mockRepo.On("Create", mock.Anything).Return(&Order{Status: tt.want}, nil)
            
            svc := NewOrderService(mockRepo)
            got, err := svc.CreateOrder(context.Background(), tt.input)
            
            if (err != nil) != tt.wantErr {
                t.Errorf("got err = %v, wantErr %v", err, tt.wantErr)
            }
            if !tt.wantErr && got.Status != tt.want {
                t.Errorf("got status = %v, want %v", got.Status, tt.want)
            }
        })
    }
}
```

## 集成测试（Testcontainers）

### Spring Boot + Testcontainers

```java
@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
class OrderControllerIT {
  @Container
  static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
    .withDatabaseName("test")
    .withUsername("test")
    .withPassword("test");
  
  @Container
  static GenericContainer<?> redis = new GenericContainer<>("redis:7")
    .withExposedPorts(6379);
  
  @DynamicPropertySource
  static void config(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
    registry.add("spring.redis.host", redis::getHost);
    registry.add("spring.redis.port", () -> redis.getMappedPort(6379));
  }
  
  @Autowired private MockMvc mockMvc;
  @Autowired private OrderRepository orderRepo;
  
  @Test
  void shouldCreateOrder() throws Exception {
    String body = """
      {"userId": 1, "items": [{"productId": 100, "qty": 2}]}
    """;
    
    mockMvc.perform(post("/api/v1/orders")
        .contentType(MediaType.APPLICATION_JSON)
        .content(body)
        .header("Authorization", "Bearer " + validToken))
      .andExpect(status().isCreated())
      .andExpect(jsonPath("$.status").value("DRAFT"));
    
    assertThat(orderRepo.count()).isEqualTo(1);
  }
}
```

### NestJS + Testcontainers

```typescript
import { PostgreSqlContainer } from '@testcontainers/postgresql';

describe('Order E2E', () => {
  let app: INestApplication;
  let postgres: StartedPostgreSqlContainer;
  
  beforeAll(async () => {
    postgres = await new PostgreSqlContainer('postgres:16').start();
    
    process.env.DATABASE_URL = postgres.getConnectionUri();
    
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    
    app = moduleRef.createNestApplication();
    await app.init();
  });
  
  afterAll(async () => {
    await app.close();
    await postgres.stop();
  });
  
  it('POST /orders creates order', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ userId: 1, items: [{ productId: 100, qty: 2 }] })
      .expect(201);
    
    expect(response.body.status).toBe('DRAFT');
  });
});
```

### Python + pytest + testcontainers

```python
import pytest
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope='session')
def postgres():
    with PostgresContainer('postgres:16') as pg:
        yield pg

@pytest.fixture(scope='session')
def app(postgres):
    os.environ['DATABASE_URL'] = postgres.get_connection_url()
    from main import app
    return app

def test_create_order(app, client):
    response = client.post('/api/v1/orders', json={
        'user_id': 1,
        'items': [{'product_id': 100, 'qty': 2}],
    }, headers={'Authorization': f'Bearer {valid_token}'})
    
    assert response.status_code == 201
    assert response.json()['status'] == 'DRAFT'
```

## 契约测试（Pact）

```text
消费者驱动契约测试：
  1. 前端（消费者）写期望的契约
  2. Pact Broker 存契约
  3. 后端（服务方）跑契约测试，验证能满足
  4. 双方都通过 = 联调安全

避免：
  - 接口已部署后才发现契约不一致
  - Mock 与真实服务行为不一致
```

```typescript
// 消费者侧（前端）
import { PactV3 } from '@pact-foundation/pact';

const provider = new PactV3({
  consumer: 'frontend',
  provider: 'order-service',
});

it('GET /orders/{id}', () => {
  provider
    .given('order 123 exists')
    .uponReceiving('a request for order 123')
    .withRequest({
      method: 'GET',
      path: '/api/v1/orders/123',
    })
    .willRespondWith({
      status: 200,
      body: { id: 123, status: 'PAID' },
    });
  
  return provider.executeTest(async (mockServer) => {
    const result = await orderApi.getOrder(123, mockServer.url);
    expect(result.status).toBe('PAID');
  });
});
```

```java
// 服务方侧（后端）
@Provider("order-service")
@PactBroker(host = "broker.example.com")
class OrderServiceContractTest {
  @State("order 123 exists")
  void orderExists() {
    orderRepo.save(Order.builder().id(123L).status(OrderStatus.PAID).build());
  }
  
  @TestTemplate
  @ExtendWith(PactVerificationInvocationContextProvider.class)
  void verify(PactVerificationContext context) {
    context.verifyInteraction();
  }
}
```

## 测试替身（Test Doubles）

| 类型 | 用途 | 示例 |
|---|---|---|
| **Mock** | 验证调用 | `verify(repo).save(any())` |
| **Stub** | 返回预设值 | `when(repo.find(1)).thenReturn(user)` |
| **Spy** | 真实对象 + 监视 | `Spy<EmailService>` |
| **Fake** | 简化实现 | `InMemoryOrderRepository` |
| **Dummy** | 占位（不被用）| `null` 替代 |

## 测试数据工厂

```typescript
// Fishery / Faker
import { Factory } from 'fishery';
import { faker } from '@faker-js/faker';

export const userFactory = Factory.define<User>(({ sequence }) => ({
  id: sequence,
  email: faker.internet.email(),
  name: faker.person.fullName(),
  createdAt: new Date(),
}));

// 用法
const user = userFactory.build();
const admin = userFactory.build({ role: 'admin' });
const users = userFactory.buildList(10);
```

## 性能基准测试

```java
// JMH（Java Microbenchmark Harness）
@Benchmark
@OutputTimeUnit(TimeUnit.NANOSECONDS)
public Order benchmarkOrderCreation() {
  return Order.create(user, items);
}
```

```typescript
// Vitest bench
import { bench } from 'vitest';

bench('order creation', () => {
  Order.create(user, items);
});
```

```go
func BenchmarkCreateOrder(b *testing.B) {
    user := User{ID: 1}
    items := []Item{{ProductID: 100, Qty: 2}}
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = NewOrder(user, items)
    }
}
```

## 测试覆盖率

```text
目标：
  - 业务逻辑（Service / Domain）：≥ 80%
  - Controller：≥ 60%
  - Repository：≥ 50%
  - 总体：≥ 70%

工具：
  - Java: JaCoCo
  - JS/TS: Jest --coverage / Vitest --coverage
  - Python: pytest-cov
  - Go: go test -cover

注意：覆盖率高 ≠ 测试好
  覆盖率只是基础线
```

## 工作流程

```text
1. TDD（推荐）
   - 先写测试（红）
   - 写代码让测试过（绿）
   - 重构（保绿）

2. 单元测试
   - 测纯业务逻辑
   - Mock 外部依赖
   - 快、可重复

3. 集成测试
   - 测端到端流程
   - 用 Testcontainers
   - 主路径 + 关键失败路径

4. 契约测试
   - 跨服务调用
   - 消费者驱动

5. E2E 测试
   - 关键用户旅程（5~15 条）
   - 慢但全面

6. 性能基准
   - 关键热路径
   - 监控退化
```

## 配套模板

- `templates/test-implementation-checklist.md` — 测试金字塔 + AAA + 测试替身 + Testcontainers + 覆盖率

## 质量自检

```text
□ 单元测试覆盖业务逻辑 ≥ 80%
□ 集成测试覆盖主路径
□ AAA 模式
□ 测试命名表达意图
□ 一个用例测一件事
□ 不测实现细节
□ Mock 适度（不 Mock 自己代码）
□ 集成测试用真依赖（Testcontainers）
□ 测试快（单元 < 100ms）
□ 测试独立（不依赖顺序）
□ 测试数据用工厂
□ 关键路径有 E2E
□ 跨服务有契约测试
□ 性能基准（热路径）
```

## 常见坑

1. **测实现细节**——重构时大量测试挂
2. **过度 Mock**——Mock 自己代码 = 测假
3. **用 H2 / SQLite 替代 PG**——行为差异
4. **测试数据手写**——下次跑环境变了
5. **测试顺序依赖**——并行就崩
6. **覆盖率追求 100%**——getter/setter 也测
7. **断言不精确**——`.toBeTruthy()` 而非具体值
8. **不写失败路径**——只测 happy path
9. **测试不快**——5 分钟跑完就没人跑
10. **测试不独立**——共享状态污染
11. **Mock 与真实行为不一致**——线上 Bug
12. **没有契约测试**——前后端联调返工
13. **重构没有测试网**——不敢改
14. **测试代码不维护**——"测试代码不重要"

## 与其他 skill 的协作

```text
上游：
  domain-modeling → 单元测试领域模型
  api-implementation → 集成测试 Controller
  data-access → 仓储测试

下游：
  qa-engineer 工作流 → QA 用例 + 测试策略
  automation-qa 工作流 → CI 集成
  observability → 测试时的日志
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — 测试工具
- qa-engineer 工作流测试方法论
