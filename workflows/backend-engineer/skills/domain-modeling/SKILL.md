---
name: domain-modeling
description: 设计业务领域模型 / 实体 / 值对象 / 聚合 / 业务规则时使用。覆盖所有主流后端语言（Java / TS / Python / Go / Ruby / C#）。融合 DDD（Eric Evans）+ 充血模型 + 状态机模式。
---

# 领域建模（Domain Modeling）

参考来源：Eric Evans《Domain-Driven Design》、Vaughn Vernon《Implementing DDD》、Martin Fowler 充血模型 / 贫血模型、Robert Martin Clean Architecture。

## 适用场景

- 复杂业务规则需要清晰建模
- 状态流转 / 工作流（订单 / 审批 / 支付）
- 多种业务方式涉及同一对象
- 防止业务逻辑散落到 Service / Controller
- 重构贫血模型为充血模型

## 核心原则

```text
1. 业务规则放进 Domain Model
   不放 Controller，不放 Service，不放 Repository

2. 实体 vs 值对象
   实体（Entity）：有唯一身份（ID），可变
   值对象（Value Object）：无身份，不可变，靠属性比较

3. 聚合根（Aggregate Root）
   外部只能通过聚合根访问聚合内的实体
   一个事务只修改一个聚合

4. 业务不变量（Invariants）
   保证对象在任何时候都满足业务规则
   构造函数 / 工厂方法强制校验

5. 命令式 → 业务式 命名
   ❌ user.setStatus("active")
   ✅ user.activate()

6. 状态流转用状态机
   用方法表达状态转换
   非法转换抛异常

7. 不依赖框架
   Domain 层应该能独立编译运行
```

## 充血模型 vs 贫血模型

### 贫血模型（反模式，常见）

```java
// Order 只是数据容器
public class Order {
  private Long id;
  private String status;
  private BigDecimal totalAmount;
  // 全是 getter / setter
}

// 业务逻辑全在 Service
public class OrderService {
  public void cancelOrder(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    if (!order.getStatus().equals("paid")) {
      throw new IllegalStateException("...");
    }
    if (order.getCreatedAt().isBefore(now().minusDays(7))) {
      throw new IllegalStateException("...");
    }
    order.setStatus("cancelled");
    order.setCancelledAt(now());
    orderRepository.save(order);
  }
}
```

问题：
- 业务规则分散
- 同一规则在多处实现
- 容易绕过（`order.setStatus("cancelled")` 直接调）

### 充血模型（推荐）

```java
public class Order {
  private Long id;
  private OrderStatus status;
  private BigDecimal totalAmount;
  private LocalDateTime createdAt;
  private LocalDateTime cancelledAt;
  
  // 私有构造，强制使用工厂方法
  private Order() {}
  
  public static Order create(User user, List<OrderItem> items) {
    if (items.isEmpty()) {
      throw new IllegalArgumentException("Order must have at least one item");
    }
    Order order = new Order();
    order.status = OrderStatus.DRAFT;
    order.totalAmount = items.stream()
        .map(OrderItem::getSubtotal)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
    order.createdAt = LocalDateTime.now();
    return order;
  }
  
  // 业务方法（不是 setStatus）
  public void cancel() {
    if (this.status != OrderStatus.PAID) {
      throw new IllegalStateException("Only paid orders can be cancelled");
    }
    if (this.createdAt.isBefore(LocalDateTime.now().minusDays(7))) {
      throw new IllegalStateException("Cancellation window has expired");
    }
    this.status = OrderStatus.CANCELLED;
    this.cancelledAt = LocalDateTime.now();
  }
  
  public void pay() {
    if (this.status != OrderStatus.SUBMITTED) {
      throw new IllegalStateException("Only submitted orders can be paid");
    }
    this.status = OrderStatus.PAID;
  }
  
  // 没有 setStatus()，无法绕过业务规则
}
```

```java
// Service 变薄，编排为主
public class OrderService {
  public void cancelOrder(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    order.cancel();  // 业务规则由 Order 自己保证
    orderRepository.save(order);
  }
}
```

## 实体 vs 值对象

### 实体（Entity）

```java
public class User {
  private Long id;          // 唯一身份
  private String email;
  private String name;
  // ...
  
  // 相等性靠 ID
  @Override
  public boolean equals(Object o) {
    if (!(o instanceof User other)) return false;
    return id != null && id.equals(other.id);
  }
}
```

### 值对象（Value Object）

```java
// 不可变 + 靠属性比较
public record Money(BigDecimal amount, String currency) {
  public Money {
    if (amount.signum() < 0) {
      throw new IllegalArgumentException("Amount cannot be negative");
    }
    if (currency == null || currency.length() != 3) {
      throw new IllegalArgumentException("Currency must be ISO 4217");
    }
  }
  
  public Money add(Money other) {
    if (!this.currency.equals(other.currency)) {
      throw new IllegalStateException("Currency mismatch");
    }
    return new Money(this.amount.add(other.amount), this.currency);
  }
}

// 用法
Money price = new Money(new BigDecimal("99.99"), "USD");
Money total = price.add(shipping);  // 返回新对象，原对象不变
```

### 何时用什么

```text
有唯一身份（用户、订单、产品） → 实体
描述属性（金额、地址、日期范围、坐标） → 值对象
身份不可变（一旦创建就不变） → 值对象
状态会变化（订单状态、用户状态） → 实体
```

## 聚合（Aggregate）

```java
// 订单聚合：Order 是聚合根，OrderItem 在聚合内
public class Order {
  private Long id;
  private List<OrderItem> items = new ArrayList<>();
  
  public void addItem(Product product, int quantity) {
    if (this.status != OrderStatus.DRAFT) {
      throw new IllegalStateException("Cannot modify non-draft order");
    }
    this.items.add(new OrderItem(product, quantity));
    recalculateTotal();
  }
  
  public void removeItem(Long itemId) {
    if (this.status != OrderStatus.DRAFT) {
      throw new IllegalStateException("Cannot modify non-draft order");
    }
    this.items.removeIf(i -> i.getId().equals(itemId));
    recalculateTotal();
  }
  
  // OrderItem 不能被外部直接 new 或修改
  // 必须通过 Order 的方法
}
```

聚合规则：
- 外部代码持有聚合根的引用，不直接持有内部实体
- 一个事务只修改一个聚合
- 聚合之间用 ID 关联，不直接持有引用

## 状态机模式

```java
public enum OrderStatus {
  DRAFT,
  SUBMITTED,
  PAID,
  SHIPPED,
  DELIVERED,
  CANCELLED,
  REFUNDED;
}

public class Order {
  // 状态转换规则集中在一处
  private static final Map<OrderStatus, Set<OrderStatus>> ALLOWED_TRANSITIONS = Map.of(
    OrderStatus.DRAFT, Set.of(OrderStatus.SUBMITTED, OrderStatus.CANCELLED),
    OrderStatus.SUBMITTED, Set.of(OrderStatus.PAID, OrderStatus.CANCELLED),
    OrderStatus.PAID, Set.of(OrderStatus.SHIPPED, OrderStatus.REFUNDED),
    OrderStatus.SHIPPED, Set.of(OrderStatus.DELIVERED),
    OrderStatus.DELIVERED, Set.of(OrderStatus.REFUNDED)
    // CANCELLED / REFUNDED 是终态
  );
  
  private void transitionTo(OrderStatus newStatus) {
    Set<OrderStatus> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.status, Set.of());
    if (!allowed.contains(newStatus)) {
      throw new IllegalStateException(
        String.format("Cannot transition from %s to %s", this.status, newStatus)
      );
    }
    this.status = newStatus;
  }
  
  public void submit() { transitionTo(OrderStatus.SUBMITTED); }
  public void pay() { transitionTo(OrderStatus.PAID); }
  public void ship() { transitionTo(OrderStatus.SHIPPED); }
  public void deliver() { transitionTo(OrderStatus.DELIVERED); }
}
```

## TypeScript 范式

```typescript
// Value Object
export class Money {
  constructor(
    public readonly amount: number,
    public readonly currency: string,
  ) {
    if (amount < 0) throw new Error('Amount cannot be negative');
    if (currency.length !== 3) throw new Error('Currency must be ISO 4217');
  }
  
  add(other: Money): Money {
    if (this.currency !== other.currency) throw new Error('Currency mismatch');
    return new Money(this.amount + other.amount, this.currency);
  }
  
  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}

// Entity
export class Order {
  private constructor(
    public readonly id: number,
    private _status: OrderStatus,
    private _items: OrderItem[],
    private _total: Money,
  ) {}
  
  static create(items: OrderItem[]): Order {
    if (items.length === 0) throw new Error('Order must have items');
    const total = items.reduce(
      (sum, item) => sum.add(item.subtotal),
      new Money(0, items[0].currency),
    );
    return new Order(0, OrderStatus.DRAFT, items, total);
  }
  
  get status(): OrderStatus { return this._status; }
  
  cancel(): void {
    if (this._status !== OrderStatus.PAID) {
      throw new Error('Only paid orders can be cancelled');
    }
    this._status = OrderStatus.CANCELLED;
  }
}
```

## Python 范式

```python
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum

class OrderStatus(Enum):
    DRAFT = 'DRAFT'
    SUBMITTED = 'SUBMITTED'
    PAID = 'PAID'
    CANCELLED = 'CANCELLED'

# Value Object
@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str
    
    def __post_init__(self):
        if self.amount < 0:
            raise ValueError('Amount cannot be negative')
        if len(self.currency) != 3:
            raise ValueError('Currency must be ISO 4217')
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise ValueError('Currency mismatch')
        return Money(self.amount + other.amount, self.currency)

# Entity
@dataclass
class Order:
    id: int
    status: OrderStatus = OrderStatus.DRAFT
    items: list = field(default_factory=list)
    total: Money = None
    created_at: datetime = field(default_factory=datetime.utcnow)
    
    @classmethod
    def create(cls, items):
        if not items:
            raise ValueError('Order must have items')
        return cls(id=0, items=items, total=sum_items(items))
    
    def cancel(self):
        if self.status != OrderStatus.PAID:
            raise ValueError('Only paid orders can be cancelled')
        self.status = OrderStatus.CANCELLED
```

## Go 范式

```go
package model

type OrderStatus string

const (
    OrderStatusDraft     OrderStatus = "DRAFT"
    OrderStatusSubmitted OrderStatus = "SUBMITTED"
    OrderStatusPaid      OrderStatus = "PAID"
    OrderStatusCancelled OrderStatus = "CANCELLED"
)

// Value Object
type Money struct {
    Amount   int64  // 分
    Currency string
}

func NewMoney(amount int64, currency string) (Money, error) {
    if amount < 0 {
        return Money{}, errors.New("amount cannot be negative")
    }
    if len(currency) != 3 {
        return Money{}, errors.New("currency must be ISO 4217")
    }
    return Money{Amount: amount, Currency: currency}, nil
}

func (m Money) Add(other Money) (Money, error) {
    if m.Currency != other.Currency {
        return Money{}, errors.New("currency mismatch")
    }
    return Money{Amount: m.Amount + other.Amount, Currency: m.Currency}, nil
}

// Entity
type Order struct {
    id     int64
    status OrderStatus
    items  []OrderItem
    total  Money
}

func NewOrder(items []OrderItem) (*Order, error) {
    if len(items) == 0 {
        return nil, errors.New("order must have items")
    }
    return &Order{
        status: OrderStatusDraft,
        items:  items,
    }, nil
}

func (o *Order) Cancel() error {
    if o.status != OrderStatusPaid {
        return errors.New("only paid orders can be cancelled")
    }
    o.status = OrderStatusCancelled
    return nil
}
```

## 工作流程

```text
1. 识别业务实体（与 PM 沟通）
   ↓
2. 区分实体 vs 值对象
   ↓
3. 识别聚合（事务边界）
   ↓
4. 列业务不变量
   - 哪些规则任何时候都成立
   ↓
5. 列状态机（状态 + 转换）
   ↓
6. 用充血模型实现
   - 私有构造 + 工厂方法
   - 业务方法替代 setter
   - 不变量在构造时校验
   ↓
7. 写单元测试（核心）
   - 业务规则测试
   - 状态转换测试
   - 不变量违反测试
   ↓
8. Service 层只做编排
```

## 配套模板

- `templates/domain-model-template.md` — 实体 + 值对象 + 聚合 + 状态机 + 不变量 + 业务方法 + 测试

## 质量自检

```text
□ 实体 vs 值对象 区分清楚
□ 聚合根明确
□ 业务规则在 Domain，不在 Service
□ 用业务方法名（cancel/pay）替代 setter
□ 私有构造 + 工厂方法
□ 不变量在构造时校验
□ 状态机定义所有合法转换
□ 非法状态转换抛异常
□ 值对象不可变
□ 聚合事务边界 = 一个聚合
□ Domain 层不依赖框架
□ 单元测试覆盖业务规则
```

## 常见坑

1. **贫血模型**——业务逻辑全在 Service，Domain 退化为数据容器
2. **暴露 setter**——绕过业务规则
3. **金额用 float**——精度问题
4. **状态用 String**——编译期不安全
5. **状态转换分散**——同样规则多处实现
6. **聚合事务跨多个**——一致性难保证
7. **值对象可变**——共享时被改坏
8. **业务规则在 Controller**——重复 / 难测
9. **构造函数不校验不变量**——可创建非法对象
10. **Domain 依赖 Spring/NestJS**——失去独立性

## 与其他 skill 的协作

```text
上游：
  product-manager 工作流 → 业务实体 / 状态 / 规则
  database 工作流 → 数据模型映射

下游：
  api-implementation → Service 编排 Domain
  data-access → Domain ↔ ORM 映射
  testing-implementation → 单元测试 Domain
```

## 相关参考

- 项目根 `references/backend-frameworks-2026.md` — 框架与建模风格关系
