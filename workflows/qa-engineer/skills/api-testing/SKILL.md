---
name: api-testing
description: 测试后端接口时使用。适用于 REST/GraphQL/RPC 接口测试、契约验证、API 集成测试。融合契约测试、Postman/REST Assured、OpenAPI 校验。
---

# API 接口测试（API Testing）

参考来源：Pact 契约测试、Postman API Testing Best Practices、Stripe API Testing Approach、ISTQB Foundation。

## 适用场景

- REST / GraphQL / RPC 接口测试
- API 契约验证（前后端解耦）
- 鉴权 / 权限矩阵测试
- 错误码 / HTTP 状态码测试
- 幂等 / 重试 / 并发测试
- Webhook / 异步任务测试
- 接口性能基线（与 performance-testing 协作）

## 核心原则

```text
1. API 测试是金字塔的中间层
   比 E2E 快、比单元真实

2. 测契约不是测代码
   后端能改实现，但不能破契约

3. 主路径 + 失败路径 + 边界路径
   8 个标准维度（见下文）

4. OpenAPI 是真相源
   测试与契约自动校验

5. 测试数据隔离
   不同测试用例不互相污染
```

## API 测试的 8 个标准维度（每个端点必测）

| 维度 | 用例数 | 示例 |
|---|---|---|
| 1. 成功路径 | 1~3 | 正常参数返回 200 + Schema |
| 2. 参数校验失败 | 多 | 必填缺失 / 格式错 / 长度超 / 类型错 |
| 3. 认证失败 | 1~2 | Token 缺失 / 过期 / 无效 |
| 4. 权限不足 | 1~3 | 无权限 / 越租户 / 越用户 |
| 5. 资源不存在 | 1 | ID 不存在返回 404 |
| 6. 资源冲突 | 1~2 | 状态冲突 / 版本冲突 / 唯一约束 |
| 7. 限流 | 1 | 超出 QPS 返回 429 + Retry-After |
| 8. 服务异常 | 1 | 模拟 500 时调用方处理 |

## 契约测试（Contract Testing）

```text
传统集成测试：
  调用方 + 真实服务 → 快但脆弱

契约测试：
  调用方 ↔ 契约（OpenAPI）↔ 服务方
  双方各自验证契约，不依赖对方在线

工具：
  - Pact（消费者驱动）
  - Spring Cloud Contract
  - OpenAPI 校验器（如 Dredd）
```

## 测试金字塔的 API 层

```text
     /\
    /E2\
   /----\
  / API  \  ← 这里：覆盖业务规则、错误处理、契约
 /--------\
/  单元   \
```

## 工作流程

```text
1. 拿到 OpenAPI 契约（或 API 文档）
   ↓
2. 列端点清单
   ↓
3. 每个端点按 8 维度设计用例
   ↓
4. 准备测试数据（前置 + 隔离）
   ↓
5. 执行测试（Postman/REST Assured/Karate/pytest）
   ↓
6. 校验：
   - HTTP 状态码
   - 响应 Schema（与 OpenAPI 比对）
   - 响应字段值
   - 数据库副作用（写操作）
   - 异步副作用（消息 / Webhook）
   - 日志（trace_id / 错误日志）
   ↓
7. 失败 → bug-reporting
   ↓
8. 转回归用例
```

## 鉴权测试矩阵

```text
对每个端点：

| 角色 | Token | 期望 |
|------|-------|------|
| guest | 无 | 401 |
| user | 自己资源 | 200 |
| user | 他人资源 | 403 或 404 |
| admin | 任意资源 | 200 |
| user | 跨租户 | 403 或 404 |
| user | Token 过期 | 401 |
| user | Token 篡改 | 401 |
```

## 幂等测试

```text
对所有 POST 创建 / 支付 / 扣减 类接口：

1. 同一 Idempotency-Key 调用两次
   - 预期：第二次返回首次结果，不重复创建

2. 不同 Idempotency-Key 同样请求体
   - 预期：创建两次（业务允许时）或拒绝（唯一约束时）

3. 网络中断后重试
   - 预期：可重试，结果一致

4. 并发同 key
   - 预期：仅一次成功
```

## 失败路径用例标准库

```text
通用失败用例（每个端点都要测）：

✓ 必填字段缺失 → 400 + VALIDATION_ERROR
✓ 字段类型错 → 400 + INVALID_TYPE
✓ 字段长度超限 → 400 + LENGTH_OUT_OF_RANGE
✓ 字段值非法（枚举外）→ 400 + INVALID_ENUM
✓ JSON 格式错 → 400 + JSON_PARSE_ERROR
✓ Content-Type 错 → 415
✓ 超大 body → 413
✓ 未认证 → 401 + WWW-Authenticate
✓ 已认证但无权限 → 403
✓ 资源不存在 → 404
✓ 资源冲突 → 409
✓ 业务校验失败 → 422
✓ 限流 → 429 + Retry-After
✓ 服务异常 → 500
```

## 性能基线（与 performance-testing 协作）

```text
对每个核心端点测：
  - P50 / P95 / P99 响应时间
  - 单实例 QPS
  - 错误率（对比基线）

工具：
  - k6 / wrk / Locust
  - Postman Runner（小规模）
  - Apache Bench（快速基线）
```

## 工具链

| 工具 | 用途 | 优势 | 劣势 |
|------|------|------|------|
| Postman / Apifox | 手工 / 半自动 | 易上手、UI 友好 | 大规模难管理 |
| REST Assured | Java 自动化 | 强类型、IDE 友好 | Java 栈限定 |
| Karate | DSL 自动化 | 易读、内置 Mock | 学习曲线 |
| pytest + requests | Python 自动化 | 灵活、生态强 | 需自建结构 |
| Pact | 契约测试 | 解耦消费者 / 服务 | 流程复杂 |
| Dredd | OpenAPI 校验 | 自动比对契约 | 灵活性差 |
| Schemathesis | 属性测试 | 自动生成 fuzz | 用例无业务感 |

## 常见 API Bug 类型

```text
1. 字段大小写不一致（status vs Status）
2. 时间字段时区不统一
3. 金额字段精度丢失（float）
4. ID 字段精度问题（JSON number 超 2^53）
5. 必填判断不严（null vs 缺失 vs 空字符串）
6. 错误码不稳定（同错误返回不同 code）
7. 分页参数边界（page=0 / page=-1）
8. 排序字段未限制（任意字段都能排序，性能爆炸）
9. 批量接口无上限（10000 条一起）
10. 删除接口幂等性（第二次返回 404 应该 204）
11. 异步接口同步返回错误码（200 包错误）
12. CORS 预检 OPTIONS 错误
13. Content-Length 不一致
14. Header 大小写敏感
15. 字符编码（UTF-8 / GBK 混用）
```

## 质量自检

```text
□ 每个端点 8 维度都覆盖
□ 鉴权矩阵完整测试
□ OpenAPI Schema 自动校验
□ 写接口有数据库副作用断言
□ 幂等测试覆盖所有写接口
□ 失败路径占比 ≥ 40%
□ 性能基线建立
□ 测试数据隔离
□ trace_id / request_id 验证
□ 与契约测试集成（如有）
```

## 常见坑

1. **只测 200**——50% Bug 在错误路径
2. **不校验 Schema**——字段类型变了没发现
3. **不测越权**——A 用户能访问 B 用户的资源
4. **不测幂等**——网络重试导致重复扣款
5. **测试数据不隔离**——并行执行就崩
6. **不测限流**——上线后被攻击才发现
7. **不验数据库副作用**——接口返 200 但数据没写
8. **不测异步副作用**——webhook / MQ 消息漏发
9. **Postman collection 不进版本控制**——丢了重写
10. **手工跑不集成 CI**——回归断层

## 配套模板

- `templates/api-test-template.md` — 单端点 8 维度测试 + 鉴权矩阵 + 幂等测试 + Schema 校验

## 与其他 skill 的协作

```text
上游：
  API 设计工作流 → OpenAPI 契约
  test-case-design → 用例方法
  test-data-management → 测试数据

下游：
  bug-reporting → 失败时记录
  regression-testing → 入回归套件
  performance-testing → 基线建立
  自动化测试工作流 → 实现自动化
```
