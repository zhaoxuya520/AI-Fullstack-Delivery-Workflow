---
name: data-access
description: 实现持久化 / ORM / Repository 模式 / 防 N+1 / 事务管理时使用。覆盖所有主流 ORM（JPA/Hibernate / TypeORM / Prisma / Django ORM / SQLAlchemy / GORM / ActiveRecord / EF Core）。
---

# 数据访问（Data Access）

参考来源：Martin Fowler《Patterns of Enterprise Application Architecture》Repository / Unit of Work、各 ORM 官方文档、High Performance MySQL。

## 适用场景

- ORM / Repository 实现
- 跨 ORM 通用模式
- 防 N+1 查询
- 事务管理（声明式 / 编程式）
- 复杂查询 / 自定义 SQL
- 读写分离 / 多数据源

## 核心原则

```text
1. Repository 隐藏 ORM 细节
   Service 层不知道是 JPA 还是 MyBatis 还是 Prisma

2. 返回 Domain Model，不返回 ORM 实体（如果不同）
   或：DB 层 = Domain 层（统一）

3. 防 N+1 是默认要求
   主动用 join fetch / eager load / select_related

4. 事务边界 = 业务操作边界
   不在 Controller，不跨多个聚合

5. 不在事务里做外部调用
   HTTP / 邮件 / 第三方 → 长事务 → 锁死

6. 复杂查询用 SQL / Native Query
   ORM 不是万能锤

7. 写性能 vs 读性能 区别对待
   写：少索引、批量插入
   读：多索引、缓存
```

## Repository 模式

### Java + Spring Data JPA

```java
public interface OrderRepository extends JpaRepository<Order, Long> {
  // 自动派生
  List<Order> findByUserIdAndStatus(Long userId, OrderStatus status);
  
  // 自定义 JPQL（防 N+1）
  @Query("SELECT o FROM Order o " +
         "JOIN FETCH o.items i " +
         "JOIN FETCH i.product " +
         "WHERE o.userId = :userId")
  List<Order> findByUserIdWithItems(@Param("userId") Long userId);
  
  // 原生 SQL
  @Query(value = "SELECT * FROM orders WHERE created_at > :since", nativeQuery = true)
  List<Order> findRecent(@Param("since") LocalDateTime since);
  
  // 修改
  @Modifying
  @Query("UPDATE Order o SET o.status = :status WHERE o.id IN :ids")
  int updateStatus(@Param("ids") List<Long> ids, @Param("status") OrderStatus status);
}

// Service 用
@Service
@Transactional
public class OrderService {
  public List<OrderDto> getUserOrders(Long userId) {
    // 用 join fetch 防 N+1
    return orderRepository.findByUserIdWithItems(userId).stream()
        .map(OrderDto::from)
        .toList();
  }
}
```

### TypeScript + Prisma

```typescript
// schema.prisma
model Order {
  id        Int @id @default(autoincrement())
  userId    Int
  status    OrderStatus
  items     OrderItem[]
  createdAt DateTime @default(now())
  
  user      User @relation(fields: [userId], references: [id])
}

// Repository
@Injectable()
export class OrderRepository {
  constructor(private prisma: PrismaService) {}
  
  // 防 N+1：用 include
  async findByUserId(userId: number) {
    return this.prisma.order.findMany({
      where: { userId },
      include: {
        items: {
          include: { product: true }
        }
      }
    });
  }
  
  // 复杂查询：用 raw query
  async findRecent(days: number) {
    return this.prisma.$queryRaw<Order[]>`
      SELECT * FROM "Order"
      WHERE created_at > NOW() - INTERVAL '${days} days'
    `;
  }
  
  // 事务
  async transferOrder(orderId: number, newUserId: number) {
    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.findUnique({ where: { id: orderId } });
      if (!order) throw new NotFoundException();
      
      return tx.order.update({
        where: { id: orderId },
        data: { userId: newUserId, transferredAt: new Date() }
      });
    });
  }
}
```

### TypeScript + TypeORM

```typescript
@EntityRepository(Order)
export class OrderRepository extends Repository<Order> {
  async findByUserIdWithItems(userId: number): Promise<Order[]> {
    return this.createQueryBuilder('order')
      .leftJoinAndSelect('order.items', 'item')
      .leftJoinAndSelect('item.product', 'product')
      .where('order.userId = :userId', { userId })
      .getMany();
  }
}
```

### Python + Django ORM

```python
class OrderRepository:
    @staticmethod
    def find_by_user_id(user_id):
        # 防 N+1：select_related (一对一/一对多反向) + prefetch_related (一对多/多对多)
        return Order.objects.filter(user_id=user_id) \
            .select_related('user') \
            .prefetch_related('items__product') \
            .order_by('-created_at')
    
    @staticmethod
    def find_recent(days):
        return Order.objects.filter(
            created_at__gt=timezone.now() - timedelta(days=days)
        )
    
    @staticmethod
    @transaction.atomic
    def bulk_update_status(order_ids, new_status):
        return Order.objects.filter(id__in=order_ids).update(status=new_status)
```

### Python + SQLAlchemy 2

```python
class OrderRepository:
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def find_by_user_id(self, user_id: int) -> list[Order]:
        # 防 N+1：selectinload / joinedload
        stmt = (
            select(Order)
            .where(Order.user_id == user_id)
            .options(
                selectinload(Order.items).selectinload(OrderItem.product)
            )
            .order_by(Order.created_at.desc())
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()
    
    async def find_recent(self, days: int) -> list[Order]:
        stmt = select(Order).where(
            Order.created_at > datetime.utcnow() - timedelta(days=days)
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()
```

### Go + GORM

```go
type OrderRepository struct {
    db *gorm.DB
}

func (r *OrderRepository) FindByUserID(ctx context.Context, userID int64) ([]Order, error) {
    var orders []Order
    err := r.db.WithContext(ctx).
        Preload("Items.Product").  // 防 N+1
        Where("user_id = ?", userID).
        Order("created_at DESC").
        Find(&orders).Error
    return orders, err
}

func (r *OrderRepository) Transaction(ctx context.Context, fn func(*gorm.DB) error) error {
    return r.db.WithContext(ctx).Transaction(fn)
}
```

### Go + sqlc（推荐：类型安全 + 性能）

```sql
-- queries/order.sql

-- name: GetOrderByID :one
SELECT * FROM orders WHERE id = $1;

-- name: ListOrdersByUser :many
SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC;

-- name: UpdateOrderStatus :exec
UPDATE orders SET status = $2 WHERE id = $1;
```

```go
// 自动生成的代码（类型安全）
queries := order.New(db)
o, err := queries.GetOrderByID(ctx, 123)
orders, err := queries.ListOrdersByUser(ctx, userID)
```

## N+1 问题（必懂）

### 反例（最常见）

```typescript
// 1 个查询返回 100 个订单
const orders = await orderRepo.findAll();

// 100 次查询拿 user
for (const order of orders) {
  console.log(order.user.name);  // ← 触发懒加载，每个发 SQL
}

// 总查询数：1 + 100 = 101
```

### 解决方案

```typescript
// Prisma：include
const orders = await prisma.order.findMany({
  include: { user: true }
});

// TypeORM：leftJoinAndSelect
const orders = await this.repo.createQueryBuilder('order')
  .leftJoinAndSelect('order.user', 'user')
  .getMany();

// JPA：JOIN FETCH
@Query("SELECT o FROM Order o JOIN FETCH o.user WHERE ...")

// Django：select_related
Order.objects.select_related('user').all()

// SQLAlchemy：joinedload
session.query(Order).options(joinedload(Order.user)).all()

// 总查询数：1
```

### 进阶：DataLoader 模式（GraphQL 常用）

```typescript
// 批量收集 + 单次查询
const userLoader = new DataLoader(async (userIds: number[]) => {
  const users = await prisma.user.findMany({
    where: { id: { in: userIds } }
  });
  return userIds.map(id => users.find(u => u.id === id));
});

// 用法
const user1 = await userLoader.load(1);
const user2 = await userLoader.load(2);
// 实际只发 1 次 SQL（IN [1, 2]）
```

## 事务管理

### 声明式（推荐）

```java
// Spring：@Transactional
@Service
@Transactional
public class OrderService {
  public Order createOrder(...) {
    Order order = ...;
    orderRepo.save(order);
    inventoryRepo.decrement(...);  // 同一事务
    return order;
  }
}
```

```typescript
// NestJS + TypeORM 或 Prisma
@Injectable()
export class OrderService {
  async createOrder(dto: CreateOrderDto) {
    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.create({ data: ... });
      await tx.inventory.update({ where: ..., data: { stock: { decrement: 1 } } });
      return order;
    });
  }
}
```

```python
# Django: @transaction.atomic
@transaction.atomic
def create_order(...):
    order = Order.objects.create(...)
    Inventory.objects.filter(...).update(stock=F('stock') - 1)
    return order
```

### 编程式

```java
// 需要细粒度控制时
public Order createOrder(...) {
  return transactionTemplate.execute(status -> {
    Order order = orderRepo.save(...);
    inventoryRepo.decrement(...);
    return order;
  });
}
```

### 隔离级别

```java
@Transactional(isolation = Isolation.SERIALIZABLE)
public void criticalOperation() { ... }

// 默认 READ_COMMITTED 已能满足大多数业务
// 涉及金融并发用 SERIALIZABLE + 重试
```

### 嵌套事务（慎用）

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void independent() { 
  // 独立事务，外层失败不影响
}
```

## 批量操作

```java
// JPA
@Modifying
@Query("UPDATE Order o SET o.status = :status WHERE o.id IN :ids")
int batchUpdate(@Param("ids") List<Long> ids, @Param("status") OrderStatus status);

// 批量插入（需配置 hibernate.jdbc.batch_size）
List<Order> orders = ...;
orderRepo.saveAll(orders);

// Prisma
await prisma.order.createMany({
  data: [...],
  skipDuplicates: true,
});

// Django
Order.objects.bulk_create([...], batch_size=1000);

// 性能差距：循环单条 vs 批量 = 100x+
```

## 读写分离

```java
// Spring：@Transactional(readOnly = true) 路由到从库
@Transactional(readOnly = true)
public List<Order> getAllOrders() {
  return orderRepo.findAll();
}
```

```typescript
// Prisma：单独 client
const readReplica = new PrismaClient({
  datasources: { db: { url: process.env.DATABASE_REPLICA_URL } }
});

// 读用 readReplica，写用 prisma
```

## 多数据源

```java
// Spring：@Transactional("secondaryTransactionManager")
@Service
public class CrossDatabaseService {
  @Transactional("primaryTransactionManager")
  public void writeToPrimary() { ... }
  
  @Transactional("secondaryTransactionManager")
  public void writeToSecondary() { ... }
}
```

## 工作流程

```text
1. 设计 Repository 接口
   - 业务驱动：findByOrderNumber 而非 findById
   - 不暴露 ORM 类型
   ↓
2. 实现 Repository
   - 用 ORM 或 SQL 构建器
   - 防 N+1（join fetch / include）
   ↓
3. 事务策略
   - 声明式 @Transactional
   - 边界 = 业务操作边界
   ↓
4. 性能优化
   - 批量操作
   - 读写分离
   - 自定义 SQL
   ↓
5. 测试
   - 用真实 DB 或 Testcontainers
   - 不用 Mock 数据库
```

## 配套模板

- `templates/repository-template.md` — Repository 接口 / 实现 / 测试模板（多 ORM）

## 质量自检

```text
□ Repository 接口面向业务，不面向技术
□ 返回 Domain Model（如分层）
□ 默认防 N+1（join fetch / include）
□ 事务边界明确
□ 事务不包含外部调用
□ 批量操作使用 bulk_*
□ 自定义 SQL 有参数化（防注入）
□ 读多用 readOnly 事务（路由从库）
□ 大查询有 limit
□ 测试用真实 DB（Testcontainers）
□ 慢查询监控（pg_stat_statements / 慢日志）
□ ORM 配置 batch_size / fetch_size
```

## 常见坑

1. **N+1 查询**——性能崩溃，加个 include 解决
2. **事务包外部调用**——HTTP 30 秒导致锁
3. **循环 INSERT**——1000 次 SQL，应该 bulk_create
4. **OFFSET 深分页**——offset 100000 慢死
5. **不用参数化查询**——SQL 注入
6. **ORM 自动生成 SELECT \***——传输浪费
7. **懒加载在 Controller 触发**——事务已关，报错
8. **DTO 直接当实体用**——更新时全字段写
9. **不限制查询范围**——`findAll()` 大表崩溃
10. **批量更新不分批**——锁表
11. **跨服务用分布式事务（2PC）**——慎用，应该 Saga
12. **N+1 误以为是 ORM Bug**——其实是用法错
13. **不监控慢 SQL**——线上爆了才知道
14. **事务嵌套层数失控**——传播机制理解错

## 与其他 skill 的协作

```text
上游：
  domain-modeling → Domain 模型
  database 工作流 → 表结构 / 索引

下游：
  api-implementation → Service 调 Repository
  caching-strategy → 缓存读 vs DB 读
  observability → SQL 性能监控
  testing-implementation → 用 Testcontainers
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — ORM 选型
- database-engineer 工作流 query-review skill
