---
name: pagination-filtering
description: 设计列表接口的分页、筛选、排序、搜索时使用。适用于所有列表 API。优先使用 cursor 分页（大数据）或 offset 分页（小数据）+ 统一筛选/排序规范。
---

# 分页、筛选、排序、搜索

参考来源：[Stripe API Pagination](https://stripe.com/docs/api/pagination)、[GitHub REST API](https://docs.github.com/en/rest/guides/using-pagination-in-the-rest-api)

## 适用场景

- 所有列表接口
- 数据量大的查询
- 复杂筛选场景
- 全文搜索

## 分页方式

### 1. Offset 分页（页码分页）

```text
GET /users?page=1&page_size=20
GET /users?offset=0&limit=20

响应：
{
  "data": [...],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 156,
    "total_pages": 8
  }
}

适用：
  ✅ 数据量小（< 10 万）
  ✅ 需要跳页（用户去第 5 页）
  ✅ 需要 total（显示"共 156 条"）

不适用：
  ❌ 数据量大（性能差，深分页 OFFSET 慢）
  ❌ 高并发更新（数据可能错位）
```

### 2. Cursor 分页（游标分页）

```text
GET /users?cursor=usr_abc123&limit=20

响应：
{
  "data": [...],
  "pagination": {
    "next_cursor": "usr_xyz789",
    "has_more": true
  }
}

适用：
  ✅ 数据量大（无穷滚动）
  ✅ 实时数据流
  ✅ 性能要求高
  ✅ 数据频繁更新

不适用：
  ❌ 需要跳页
  ❌ 需要精确 total

实现：
  cursor 通常是排序字段的值（id / created_at）
  WHERE id > cursor ORDER BY id LIMIT 20
```

### 3. Time-based 分页

```text
GET /events?since=2026-01-15T00:00:00Z&until=2026-01-16T00:00:00Z

适用：日志、事件流、时间相关数据
```

### 选择决策

```text
后台管理 / 小数据 → offset
公开 API / 大数据 / 信息流 → cursor
日志 / 事件 → time-based
```

## 筛选（Filtering）

### 基础筛选

```text
GET /users?status=active
GET /users?role=admin
GET /users?created_after=2026-01-01
```

### 多值筛选

```text
GET /users?status=active,inactive
GET /users?role=admin&role=manager   （重复参数）
```

### 范围筛选

```text
GET /products?price_min=10&price_max=100
GET /orders?created_after=2026-01-01&created_before=2026-01-31
```

### 操作符筛选（高级）

```text
GET /products?price[gte]=10&price[lte]=100
GET /products?stock[gt]=0
GET /products?name[like]=phone

操作符：
  eq  - 等于
  ne  - 不等于
  gt  - 大于
  gte - 大于等于
  lt  - 小于
  lte - 小于等于
  in  - 在列表中
  nin - 不在列表中
  like - 模糊匹配
```

### 全文搜索

```text
GET /products?q=iphone
GET /products?keyword=iphone

参数名：q / keyword / search
搜索范围：通常服务端定义（如 name + description）
```

## 排序（Sorting）

```text
GET /users?sort=created_at        升序（默认）
GET /users?sort=-created_at       降序（- 前缀）
GET /users?sort=-priority,name    多字段排序

或：
GET /users?sort_by=created_at&order=desc
```

## 字段选择（Sparse Fieldsets）

```text
GET /users/{id}?fields=id,name,email
返回：只包含这三个字段

GET /orders/{id}?include=items,user
返回：默认字段 + 嵌套关联

适用：
  - 移动端节省流量
  - 性能优化
  - 减少敏感字段返回
```

## 统一规范模板

```markdown
## 列表接口规范

### 分页参数（offset 风格）
- page: integer, default=1, min=1
- page_size: integer, default=20, min=1, max=100

### 分页响应
{
  "data": [...],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 156,
    "total_pages": 8,
    "has_next": true,
    "has_previous": false
  }
}

### 筛选参数
- 单值：?status=active
- 多值：?status=active,inactive
- 范围：?created_after=...&created_before=...

### 排序
- 单字段：?sort=created_at（升序）
- 单字段降序：?sort=-created_at
- 多字段：?sort=-priority,name

### 搜索
- 全文：?q=keyword

### 字段选择
- 包含：?fields=id,name,email
- 关联：?include=user,items
```

## 完整示例

```text
GET /products?
  q=phone&
  category=electronics&
  price_min=100&
  price_max=1000&
  in_stock=true&
  sort=-rating,-created_at&
  page=1&
  page_size=20&
  fields=id,name,price,rating

→
{
  "data": [
    {
      "id": "prd_001",
      "name": "iPhone 15",
      "price": 999,
      "rating": 4.8
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 87,
    "total_pages": 5,
    "has_next": true,
    "has_previous": false
  }
}
```

## 工作流程

```text
1. 评估数据量和查询场景
2. 选择分页方式（offset / cursor / time）
3. 列出可筛选字段
4. 决定支持的操作符（基础 / 高级）
5. 列出可排序字段和默认排序
6. 决定是否支持搜索
7. 决定是否支持字段选择
8. 写入 OpenAPI 参数定义
9. 输出列表接口规范
```

## 质量自检

```text
□ 全 API 用同一种分页方式（不要混用）
□ page_size 有上限（防止滥用，max 100）
□ 排序字段命名一致（- 前缀降序）
□ 筛选参数有校验（防注入）
□ 搜索的 q 参数有最小长度
□ 列表响应有 total 或 has_more
□ 大数据集用 cursor 不用 offset
□ 默认排序明确（不能不排序）
```

## 常见坑

1. **不同端点不同分页风格**——/users 用 page，/orders 用 cursor
2. **page_size 无上限**——攻击者请求 page_size=10000
3. **OFFSET 深分页慢**——OFFSET 100000 LIMIT 20 性能差
4. **排序字段未限制**——?sort=password_hash 暴露字段
5. **不返回 total**——前端无法显示"共 X 条"
6. **筛选直接拼 SQL**——SQL 注入风险
7. **搜索全表扫描**——无索引，数据量大时崩溃
8. **响应格式不一**——有的 data 有的 items 有的 results

## 配套模板

- `templates/pagination-filter-sort-template.md` — 分页参数 + 筛选参数 + 列表响应结构模板

## 与其他 skill 的协作

```text
上游：
  endpoint-design → 列表端点清单

平行：
  request-response → 列表响应结构

下游：
  openapi-mock → OpenAPI 参数定义
  转交后端 → 数据库索引设计（database-engineer 协作）
```
