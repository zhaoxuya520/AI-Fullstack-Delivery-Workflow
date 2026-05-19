# 后端 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "实现这个接口" / "写 API" / "Controller" | [api-implementation](api-implementation/SKILL.md) |
| "业务规则" / "领域模型" / "状态流转" | [domain-modeling](domain-modeling/SKILL.md) |
| "数据库查询" / "ORM" / "Repository" / "N+1" | [data-access](data-access/SKILL.md) |
| "Redis 缓存" / "缓存击穿" / "失效策略" | [caching-strategy](caching-strategy/SKILL.md) |
| "MQ" / "异步任务" / "Worker" / "定时任务" | [async-jobs](async-jobs/SKILL.md) |
| "重试" / "熔断" / "降级" / "限流" | [error-handling-resilience](error-handling-resilience/SKILL.md) |
| "JWT" / "OAuth" / "登录" / "权限中间件" | [auth-implementation](auth-implementation/SKILL.md) |
| "日志" / "指标" / "trace" / "OpenTelemetry" | [observability](observability/SKILL.md) |
| "单元测试" / "集成测试" / "Mock" / "Pact" | [testing-implementation](testing-implementation/SKILL.md) |
| "Lint" / "Code Review" / "代码规范" | [code-quality](code-quality/SKILL.md) |
| "微服务" / "服务拆分" / "gRPC" / "网关" / "分布式事务" | [microservice-design](microservice-design/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单端点实现（S 级） | api-implementation + testing-implementation |
| CRUD 模块（M 级） | + domain-modeling + data-access + auth-implementation |
| 复杂业务（L 级） | + caching-strategy + async-jobs + error-handling-resilience + observability |
| 核心服务（XL 级） | 全部 10 skills + code-quality 重点 |
| 性能优化专项 | data-access + caching-strategy + observability |
| 重构 | code-quality + testing-implementation + domain-modeling |
| 第三方集成 | error-handling-resilience + async-jobs + observability |
| 安全加固 | auth-implementation + error-handling-resilience |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 10~30min | api-implementation + testing-implementation |
| M | 30~120min | + domain-modeling + data-access + auth-implementation |
| L | 2~6h | + caching + async + resilience + observability |
| XL | 6h+ | 全部 + code-quality |

## 路径交叉

```text
新功能模块实现：
  api-implementation（端点）
  → domain-modeling（业务）
  → data-access（持久化）
  → auth-implementation（权限）
  → testing-implementation（测试）
  → observability（日志/指标）
  → code-quality（Review）

性能优化：
  observability（定位瓶颈）
  → data-access（N+1 / SQL 优化）
  → caching-strategy（缓存）
  → async-jobs（异步化）

重构：
  testing-implementation（先补测试）
  → code-quality（Lint）
  → domain-modeling（重塑模型）
  → api-implementation（接口稳定）

第三方集成：
  api-implementation（封装客户端）
  → error-handling-resilience（重试/熔断）
  → async-jobs（异步化）
  → observability（追踪）
```

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增。
