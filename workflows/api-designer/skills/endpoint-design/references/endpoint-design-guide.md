# 端点设计指引（Endpoint Design Guide）

参考：RFC 7231（HTTP Semantics）、RFC 9110（HTTP）、GitHub REST API Guidelines、Microsoft REST API Guidelines、Google AIP（API Improvement Proposals）、Stripe API。

## 1. URL 命名规范

```text
✅ 集合：/orders                              （复数名词）
✅ 资源：/orders/{order_id}
✅ 子资源：/orders/{order_id}/items
✅ 筛选：/orders?status=paid&limit=20
✅ 动作（无法 CRUD 表达）：/orders/{id}/cancel

❌ /getOrder?id=xxx                            （动词 + Query）
❌ /Orders                                     （大写）
❌ /order_list                                 （非复数）
❌ /orders/{id}/cancel-order                  （冗余资源名）
❌ /api/v1/orders/list                         （冗余 list）
```

## 2. HTTP 方法语义

| 方法 | 幂等 | 安全 | 用途 | 典型状态码 |
|---|---|---|---|---|
| GET | 是 | 是 | 查询 | 200, 404 |
| POST | 否 | 否 | 创建 / 非幂等动作 | 201, 200, 400, 409 |
| PUT | 是 | 否 | 整体替换 / 幂等写入 | 200, 204, 404 |
| PATCH | 否 | 否 | 局部更新 | 200, 204, 404 |
| DELETE | 是 | 否 | 删除 | 204, 404 |
| HEAD | 是 | 是 | 元信息 | 200, 404 |
| OPTIONS | 是 | 是 | CORS / 能力查询 | 200 |

注意：
- POST 创建时返回 201 + Location header
- PUT / DELETE 成功无内容返回 204
- DELETE 第二次调用建议返回 204（幂等）而非 404

## 3. 状态码使用范式

### 2xx 成功
- 200 OK：通用成功（GET / PATCH 返回新资源）
- 201 Created：创建成功（POST）
- 202 Accepted：已接受异步处理（任务排队）
- 204 No Content：成功无 body（PUT / DELETE）

### 3xx 重定向
- 301 永久重定向（API 路径迁移）
- 304 Not Modified（配合 ETag 缓存）

### 4xx 客户端错误
- 400 Bad Request：JSON 解析失败 / 参数缺失
- 401 Unauthorized：未认证
- 403 Forbidden：无权限
- 404 Not Found：资源不存在
- 405 Method Not Allowed：方法不支持
- 409 Conflict：版本 / 状态冲突
- 410 Gone：资源已永久删除（区别于 404）
- 422 Unprocessable Entity：业务校验失败（JSON 合法但语义错）
- 429 Too Many Requests：限流（带 Retry-After）

### 5xx 服务器错误
- 500 Internal Server Error：未预期错误
- 502 Bad Gateway：上游错误
- 503 Service Unavailable：维护 / 过载
- 504 Gateway Timeout：上游超时

## 4. 端点粒度选择

```text
原子端点：单一资源 CRUD
  POST /orders
  GET /orders/{id}

聚合端点：组合查询（前端常用）
  GET /orders/{id}/summary       含 items + payments + shipping

批量端点：性能优化
  POST /orders/batch              多资源原子提交
  POST /orders:batchUpdate        Google AIP 风格

复合操作（事务）
  POST /orders/{id}/checkout      含支付 + 库存扣减 + 状态流转
```

## 5. 资源 ID 设计

| 方式 | 优点 | 缺点 | 适用 |
|---|---|---|---|
| 自增整数 | 易读 | 暴露规模、可枚举 | 内部系统 |
| UUID v4 | 不可枚举 | 无序、占空间 | 通用 |
| UUID v7 / ULID | 时间有序 + 不可枚举 | 较新 | 推荐 |
| 业务前缀 + ID | 可读、可追踪 | 自定义实现 | Stripe（`cus_xxx` / `pi_xxx`）|
| Slug | SEO / 易读 | 唯一性挑战 | 公开内容 |

## 6. 子资源 vs 关联资源

```text
父子从属关系（删父删子）：
  /orgs/{org_id}/members/{user_id}     ← member 属于 org

独立资源 + 关联：
  /users/{user_id}                     ← user 独立存在
  /orgs/{org_id}/members?user_id=xxx   ← 关系作为 query

避免：
  /orgs/{org_id}/users/{user_id}       ← user 不属于某个 org
```

## 7. 动作化端点（RPC 风格）的合理使用

允许使用动作化端点的场景：
- 不能用单一 CRUD 表达的状态流转：`POST /orders/{id}/cancel`
- 跨资源原子操作：`POST /transfers/{id}/refund`
- 计算 / 模拟：`POST /orders:simulate`（Google AIP 用 `:` 分隔）

控制使用频率：
- 一个资源动作化端点不超过 5 个
- 优先考虑能否用 PATCH 修改 status

## 8. 大厂范式速查

| 风格 | 代表 | 特点 |
|---|---|---|
| 标准 REST | GitHub | 严格 CRUD，复数名词，分页用 link header |
| 类 REST + 业务前缀 ID | Stripe | `cus_xxx`、列表用 cursor 分页 |
| 类 RPC + 资源风格 | Google AIP | 动作用 `:`，批量用 `:batchGet` |
| GraphQL | Facebook / GitHub v4 | 查询字段可选 |

## 9. 端点设计自检

```text
□ 路径用复数名词，不含动词
□ 方法语义符合 HTTP 规范
□ 成功状态码符合语义（POST→201，PUT/DELETE→204）
□ 失败状态码区分 401 / 403 / 404 / 409 / 422
□ 资源 ID 不可枚举
□ 动作化端点有充分理由
□ 子资源关系合理（非误用）
□ 命名风格一致（kebab-case 路径，snake_case/camelCase 字段）
□ 同一模块所有端点遵循同一风格
□ 限流端点返回 Retry-After
```
