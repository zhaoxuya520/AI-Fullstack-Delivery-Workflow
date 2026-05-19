# SRE/运维工作流路由

## 触发关键词

```yaml
workflow: sre-operations
name: SRE/运维工作流
keywords: [监控, 日志, 告警, 故障, 线上问题, 性能瓶颈, 容量, 复盘, SLO, On-call, Runbook, 事故, Postmortem]
entry: WORKFLOW.md
skills_routing: skills/routing.md
outputs: [故障分析, 根因说明, 监控规则, 复盘文档, Runbook, 容量方案]
```

## Skills 入口

| 用户意图 | Skill |
|---------|-------|
| 线上故障 / 止血 | incident-response |
| 复盘 / Postmortem | postmortem |
| 容量 / 扩缩容 | capacity-planning |
| SLO / 错误预算 / Chaos | reliability-engineering |
| On-call / Runbook | on-call-runbook |
| 日志排查 / 定位 | log-analysis |

## 进入前检查

```text
□ 告警信息 / 用户报告
□ 影响范围
□ 时间线
□ 当前状态
```

## 转出规则

| 场景 | 转出到 |
|------|--------|
| CI/CD / 部署配置 | devops-engineer |
| 业务代码修复 | backend-engineer / frontend-engineer |
| 安全漏洞 | security-engineer |
| 数据库问题 | database-engineer |

## 路由未命中

返回根 `../../routing.md`。
