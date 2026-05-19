# 领域模型设计模板

## 1. 业务上下文

```text
模块：
业务定位：
关键术语（与 PM 同步）：
```

---

## 2. 实体清单

| 实体名 | 唯一身份 | 状态字段 | 聚合根? | 备注 |
|---|---|---|---|---|
| Order | id | status | ✅ |  |
| OrderItem | id | - | ❌（属于 Order） |  |
| User | id | status | ✅ |  |

---

## 3. 值对象清单

| 值对象 | 属性 | 不变量 | 业务方法 |
|---|---|---|---|
| Money | amount, currency | amount ≥ 0, currency 是 ISO 4217 | add, subtract, multiply |
| Address | street, city, country | 字段非空 | format |
| DateRange | start, end | start ≤ end | overlap, contains |

---

## 4. 聚合边界

```text
聚合：Order
  - 聚合根：Order
  - 内部实体：OrderItem
  - 外部关联：UserId、ProductId（仅 ID）
  - 事务边界：一个事务只修改一个 Order

聚合：User
  - 聚合根：User
  - 内部值对象：Address、Email
  - 外部关联：TenantId
```

---

## 5. 状态机

### Order 状态机

```text
       ┌─────────┐
       │  DRAFT  │
       └────┬────┘
            │ submit()
            ↓
       ┌──────────┐    cancel()
       │SUBMITTED ├─────────────┐
       └────┬─────┘             │
            │ pay()             │
            ↓                   ↓
       ┌─────────┐  cancel() ┌────────────┐
       │  PAID   │──────────→│ CANCELLED  │
       └────┬────┘           └────────────┘
            │ ship()
            ↓
       ┌──────────┐
       │ SHIPPED  │
       └────┬─────┘
            │ deliver()
            ↓
       ┌────────────┐ refund() ┌────────────┐
       │ DELIVERED  ├──────────→│  REFUNDED  │
       └────────────┘           └────────────┘
```

### 合法转换表

| 当前状态 | 允许的下一状态 | 终态 |
|---|---|---|
| DRAFT | SUBMITTED, CANCELLED | ❌ |
| SUBMITTED | PAID, CANCELLED | ❌ |
| PAID | SHIPPED, REFUNDED | ❌ |
| SHIPPED | DELIVERED | ❌ |
| DELIVERED | REFUNDED | ❌ |
| CANCELLED | - | ✅ |
| REFUNDED | - | ✅ |

---

## 6. 业务不变量

```text
Order：
  - items 不能为空
  - total = sum(items.subtotal)
  - DRAFT 状态才能修改 items
  - 状态转换必须符合状态机
  
User：
  - email 唯一（在租户内）
  - email 格式合法
  - status 转换：active ↔ suspended
```

---

## 7. 业务方法清单

| 实体 | 方法 | 输入 | 前置 | 后置 | 异常 |
|---|---|---|---|---|---|
| Order | submit() | - | status=DRAFT | status=SUBMITTED | InvalidStateError |
| Order | pay() | - | status=SUBMITTED | status=PAID | InvalidStateError |
| Order | cancel() | - | status ∈ {DRAFT, SUBMITTED, PAID} | status=CANCELLED | InvalidStateError |
| Order | addItem(product, qty) | Product, int | status=DRAFT, qty > 0 | items 增加 | InvalidStateError |
| Money | add(other) | Money | currency 一致 | 返回新 Money | CurrencyMismatch |

---

## 8. 实现代码

```text
[语言/框架]
[贴上 Order / Money / 等核心代码]
```

---

## 9. 单元测试覆盖

```text
□ 工厂方法（合法 + 非法输入）
□ 每个业务方法的成功路径
□ 每个业务方法的失败路径（前置不满足）
□ 所有合法状态转换
□ 所有非法状态转换抛异常
□ 不变量违反场景
□ 值对象的相等性
□ 边界情况（空、零、最大）
```

---

## 10. 自检

```text
□ 实体 vs 值对象 区分明确
□ 聚合根唯一
□ 不变量在构造时校验
□ 用业务方法名替代 setter
□ 状态机集中定义
□ 非法转换抛异常
□ 值对象不可变
□ Domain 层独立（不依赖框架）
□ 单元测试覆盖完整
□ 与 PM 业务术语一致
```
