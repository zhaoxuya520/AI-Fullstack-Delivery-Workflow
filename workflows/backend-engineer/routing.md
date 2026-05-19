# 后端工程师工作流路由

## 触发关键词

```yaml
workflow: backend-engineer
name: 后端工程师工作流
keywords: [后端, 服务端, API 实现, 业务逻辑, ORM, 缓存, 队列, 认证, JWT, 微服务, Spring Boot, NestJS, Django, FastAPI, Express, Gin, Go, Java, Python, TypeScript]
entry: WORKFLOW.md
skills_routing: skills/routing.md
outputs: [接口实现, 业务代码, 单元测试, 集成测试, 配置, 部署说明]
```

## Skills 入口

进入 WORKFLOW.md 后按 `skills/routing.md` 路由到具体 skill。

| 用户意图 | Skill |
|---------|-------|
| 实现接口 / Controller | api-implementation |
| 业务规则 / 领域模型 / 状态机 | domain-modeling |
| ORM / 数据库查询 / N+1 | data-access |
| Redis / 缓存 / 失效 | caching-strategy |
| MQ / 异步任务 / Worker | async-jobs |
| 重试 / 熔断 / 限流 / 降级 | error-handling-resilience |
| JWT / OAuth / 登录 / 权限 | auth-implementation |
| 日志 / 指标 / 追踪 | observability |
| 单元测试 / 集成测试 / Mock | testing-implementation |
| Lint / Code Review / 规范 | code-quality |

## 进入前检查

```text
□ API 契约已定义（OpenAPI）
□ 数据模型已确认（DDL / ORM）
□ 技术栈已锁定
□ 验收标准清楚
□ 非功能要求明确（性能 / SLA）
```

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 需求不清 | product-manager |
| API 契约未定 | api-designer |
| 数据库 schema / 迁移 | database-engineer |
| 前端页面 / 组件 | frontend-engineer |
| 测试用例设计 | qa-engineer |
| CI/CD / Docker / K8s | devops-engineer |
| 监控告警 / 线上事故 | sre-operations |
| 安全漏洞 / 渗透 | security-engineer |

## 路由未命中

返回根 `../../routing.md` 选择其他工作流。
