# 监控配置模板

## 1. 项目信息

```text
服务名：
监控栈：Prometheus + Grafana / Datadog / 其他
告警通道：PagerDuty / Slack / 邮件
负责人：
```

## 2. SLO 定义

| SLI | SLO | 错误预算（月） |
|---|---|---|
| 可用性 | 99.9% | 43 分钟 |
| P99 延迟 | < 500ms | - |
| 错误率 | < 0.1% | - |

## 3. 告警规则

| 告警名 | 条件 | 持续 | 级别 | Runbook |
|---|---|---|---|---|
| HighErrorRate | error_rate > 5% | 2m | P1 | [link] |
| HighLatency | p99 > 1s | 5m | P2 | [link] |
| DiskFull | disk > 90% | 5m | P2 | [link] |
| PodCrashLoop | restarts > 3 | 5m | P2 | [link] |

## 4. 仪表盘

| Dashboard | 内容 | URL |
|---|---|---|
| 服务总览 | QPS / 错误率 / P99 | [link] |
| 业务指标 | 订单 / 支付 / 注册 | [link] |
| 基础设施 | CPU / Memory / Disk | [link] |

## 5. On-call

```text
轮值周期：每周
主值班：
副值班：
升级路径：5min → 副 → 15min → Lead → 30min → CTO
```

## 6. 自检

```text
□ 四大黄金信号
□ SLO 定义
□ 告警分级
□ Runbook 链接
□ 仪表盘可用
□ On-call 配置
□ 日志收集
□ 不 alert fatigue
```
