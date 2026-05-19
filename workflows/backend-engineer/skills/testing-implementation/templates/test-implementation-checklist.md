# 测试实现检查清单

## 1. 项目信息

```text
模块：
测试框架：JUnit 5 / Jest / Vitest / pytest / Go testing / RSpec / xUnit
集成测试：Testcontainers / WireMock / MockServer
契约测试：Pact / Spring Cloud Contract
负责人：
```

---

## 2. 测试金字塔分布

| 层级 | 数量 | 工具 | 时长 |
|---|---|---|---|
| 单元 | 100~1000 | JUnit/Jest/pytest | < 1min |
| 集成 | 50~200 | Testcontainers | < 5min |
| 契约 | 10~50 | Pact | < 2min |
| E2E | 5~15 | Playwright/Cypress | < 10min |

---

## 3. 单元测试

### 覆盖范围

| 类型 | 覆盖率目标 | 当前 |
|---|---|---|
| Domain（核心）| ≥ 90% |  |
| Service | ≥ 80% |  |
| Controller | ≥ 60% |  |
| Repository | ≥ 50% |  |
| Util | ≥ 80% |  |

### 必测场景（每个公共方法）

```text
□ 主路径成功
□ 边界值（0, 1, max, max+1, null, ""）
□ 失败路径（每种异常）
□ 状态转换（合法 + 非法）
□ 并发场景（如适用）
```

### AAA 模式检查

```text
□ Arrange：测试数据用工厂
□ Act：单一行为调用
□ Assert：精确断言（不是 truthy）
□ 命名：should{Action}_When{Condition}
```

---

## 4. 集成测试

### Testcontainers 配置

```text
□ Postgres / MySQL（如用 DB）
□ Redis（如用缓存）
□ Kafka / RabbitMQ（如用 MQ）
□ 第三方服务 Mock（WireMock）
```

### 测试场景

```text
□ POST 创建（201 + DB 写入）
□ GET 查询（200 + 数据匹配）
□ PUT/PATCH 更新（DB 状态变化）
□ DELETE 删除（DB 删除 + 返回 204）
□ 失败路径：401 / 403 / 404 / 409 / 422 / 429
□ 幂等接口（同 key 多次调用）
□ 并发场景（乐观锁冲突）
□ 异步触发（事件发出）
```

---

## 5. 契约测试

### 消费者契约

```text
□ 前端 / 移动端写期望
□ Pact Broker 发布
□ 服务方拉取验证
□ 不通过 = 阻塞合并
```

### 必测端点

```text
□ 高频调用接口
□ 跨团队接口
□ 公开 API
```

---

## 6. 测试数据

```text
□ 测试数据用 Factory（不手写）
□ 每个用例独立数据
□ 测试间隔离（transaction rollback / truncate）
□ 不依赖固定 ID
□ 不污染生产
```

### Factory 模板

```typescript
const user = userFactory.build();
const admin = userFactory.build({ role: 'admin' });
const users = userFactory.buildList(10);
const order = orderFactory.build({ user, items: itemFactory.buildList(3) });
```

---

## 7. Mock 策略

### Mock 范围

```text
✅ Mock：
  - 第三方 HTTP API
  - 邮件 / 短信发送
  - 时间（用 Clock）
  - 随机数（用 seeded）

❌ 不 Mock：
  - 自己写的 Service / Domain（用真实）
  - 数据库（用 Testcontainers）
  - 简单工具函数
```

---

## 8. 性能基准

```text
□ 关键热路径有 benchmark
□ 与上版本对比
□ 退化 > 10% 阻塞合并
```

### 基准脚本

```text
□ Order 创建：< 5ms
□ JSON 序列化：< 1ms
□ 加密 / 哈希：< 10ms
```

---

## 9. CI 集成

```text
□ 每次 PR 跑单元 + 集成测试
□ 失败阻塞合并
□ 覆盖率报告（PR 评论）
□ 测试结果归档
□ 慢测试隔离（@Slow）
□ 并行执行（多 worker）
```

### CI 配置示例

```yaml
test:
  - name: Unit tests
    run: npm run test:unit
    timeout: 5m
  - name: Integration tests
    run: npm run test:integration
    timeout: 15m
  - name: Coverage
    run: npm run test:coverage
    upload: codecov
```

---

## 10. 测试质量审视

```text
□ 测试名称读得出意图
□ 测试数据有意义（不是 'asdf'）
□ 测试独立（任意顺序）
□ 测试快（单元 < 100ms）
□ 失败信息清晰（哪条断言失败）
□ 没有 .skip / .only 留生产
□ 没有 sleep（用 await/poll）
□ 没有 console.log 调试
```

---

## 11. 自检

```text
□ 测试金字塔分布合理
□ 单元覆盖业务逻辑 ≥ 80%
□ 集成覆盖主路径
□ AAA 模式
□ Mock 适度
□ Testcontainers 用真依赖
□ 契约测试（跨服务）
□ Factory 测试数据
□ CI 集成
□ 失败阻塞合并
```
