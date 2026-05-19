# REST 资源建模指南

## 1. 资源优先

REST 路径优先表达资源，而不是动作。

```text
推荐：GET /orders/{orderId}
谨慎：POST /getOrderDetail
```

## 2. 集合和单个资源

```text
GET /resources           查询集合
POST /resources          创建资源
GET /resources/{id}      查询单个资源
PATCH /resources/{id}    局部更新
DELETE /resources/{id}   删除或撤销
```

## 3. 子资源

```text
GET /projects/{projectId}/members
POST /projects/{projectId}/members
DELETE /projects/{projectId}/members/{memberId}
```

## 4. 动作化端点例外

当操作不是简单 CRUD，而是业务动作或状态转换时可使用动作端点。

```text
POST /orders/{orderId}/cancel
POST /invoices/{invoiceId}/pay
POST /reviews/{reviewId}/approve
```

必须说明：

```text
副作用
状态变化
幂等性
可重试性
权限
错误码
```

## 5. 命名规则

```text
路径使用名词。
集合使用复数。
ID 命名保持一致。
Query 只表达查询条件。
不要把内部表名暴露成路径。
```
