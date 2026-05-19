# Repository 实现模板（多 ORM）

## 1. 模块信息

```text
聚合：
ORM：JPA / Prisma / TypeORM / Django ORM / SQLAlchemy / GORM / sqlc
Repository 接口：
事务策略：声明式 / 编程式
```

---

## 2. Repository 接口（面向业务）

```text
基本 CRUD：
  □ create(entity)
  □ findById(id)
  □ findByBusinessKey(...)        ← 用业务字段不用 id
  □ update(entity)
  □ delete(id)

业务查询（多个具体方法）：
  □ findByUserId(userId, status?)
  □ findRecent(days)
  □ findByOrderNumber(number)

批量操作：
  □ saveAll(entities)
  □ batchUpdateStatus(ids, status)
  □ deleteByIds(ids)

聚合查询：
  □ countByStatus()
  □ sumAmountByUser(userId)
```

---

## 3. 防 N+1 检查

| 查询方法 | 关联实体 | 加载策略 | 实现 |
|---|---|---|---|
| findByUserId | items, product | EAGER (join fetch) |  |
| findRecent | user | EAGER (include) |  |
| findById | items | LAZY |  |

---

## 4. 事务边界设计

| Service 方法 | 事务范围 | 隔离级别 | 只读? |
|---|---|---|---|
| createOrder | order + inventory + audit | READ_COMMITTED | ❌ |
| getOrders | - | READ_COMMITTED | ✅ |
| updateOrderStatus | order + audit | READ_COMMITTED | ❌ |

---

## 5. 索引依赖（与数据库工作流同步）

| 查询模式 | 依赖索引 | 备注 |
|---|---|---|
| WHERE user_id = ? AND status = ? ORDER BY created_at DESC | (user_id, status, created_at DESC) | ESR |
| WHERE order_number = ? | UNIQUE(order_number) |  |

---

## 6. 自定义 SQL 必要性

```text
□ 复杂 join（3 张表 +）
□ 窗口函数
□ 递归 CTE
□ 数据库特定功能（PG jsonb / MySQL FULLTEXT）
□ 聚合 + 分组 + having
□ 性能极致优化场景
```

---

## 7. 测试覆盖

```text
□ 单元测试：用 Mock Repository
□ 集成测试：用 Testcontainers + 真 DB
  □ findById（存在 / 不存在）
  □ 业务查询（每个方法）
  □ 批量操作
  □ 事务回滚
  □ 并发场景
  □ 性能基线（大数据量）
```

---

## 8. 性能验证

```text
□ EXPLAIN ANALYZE 关键查询
□ 主要查询 P99 < 100ms
□ 批量操作 < 1s（千条）
□ 慢查询日志监控
```

---

## 9. 自检

```text
□ 接口面向业务，不面向技术
□ 默认防 N+1
□ 事务边界明确
□ 不在事务内做外部调用
□ 批量操作用 bulk_*
□ 自定义 SQL 参数化
□ 大查询有 limit
□ 索引覆盖核心查询
□ 测试用真实 DB
□ 慢查询监控
```
