# 后端工程师 Skills 总控

本目录收录后端工程师工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [api-implementation](api-implementation/SKILL.md) | API 端点实现 | Clean Architecture + 分层（Controller/Service/Repository） |
| [domain-modeling](domain-modeling/SKILL.md) | 领域模型 / 业务逻辑 | Eric Evans DDD + 实体 / 值对象 / 聚合 |
| [data-access](data-access/SKILL.md) | ORM / 持久化 / 仓储 | Repository + Unit of Work + 防 N+1 |
| [caching-strategy](caching-strategy/SKILL.md) | 缓存策略 | Cache-Aside + Write-Through + TTL + 失效 |
| [async-jobs](async-jobs/SKILL.md) | 异步任务 / 队列 | At-least-once + 幂等 + 死信 + Outbox |
| [error-handling-resilience](error-handling-resilience/SKILL.md) | 错误处理 / 韧性 | Retry + Circuit Breaker + Bulkhead + Timeout |
| [auth-implementation](auth-implementation/SKILL.md) | 认证鉴权实现 | JWT / OAuth 2.1 / RBAC / 中间件 |
| [observability](observability/SKILL.md) | 日志 / 指标 / 追踪 | OpenTelemetry + 三大支柱 + 结构化日志 |
| [testing-implementation](testing-implementation/SKILL.md) | 测试实现 | 单元 + 集成 + 契约（Pact） + Mock |
| [code-quality](code-quality/SKILL.md) | 代码质量 / Review | SOLID + Lint + Code Review 标准 |
| [microservice-design](microservice-design/SKILL.md) | 微服务架构设计 | 服务拆分 + 通信 + 网关 + 分布式事务 |

## 统一入口

1. 先读 `routing.md` — 按后端任务路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到契约 → 实现 API
   - api-implementation（分层）
   - domain-modeling（业务规则）

2. 数据持久化
   - data-access（Repository + 防 N+1）
   - caching-strategy（缓存）

3. 异步和韧性
   - async-jobs（队列任务）
   - error-handling-resilience（重试/熔断）

4. 安全
   - auth-implementation（认证鉴权）

5. 可观测和测试
   - observability（日志/指标/追踪）
   - testing-implementation（测试）

6. 质量保障
   - code-quality（Lint + Review）
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成后端任务后，回写经验到 `../field-journal/`。
