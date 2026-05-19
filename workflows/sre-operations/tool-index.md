# SRE/运维工具索引

## 使用原则

1. 生产操作必须记录。
2. 不手动改生产配置（用 IaC / GitOps）。
3. 工具缺失时先检查本文件。

## 监控

| 工具 | 用途 |
|---|---|
| Prometheus | 指标收集 |
| Grafana | 可视化 |
| Alertmanager | 告警路由 |
| Loki | 日志收集 |
| Tempo | 追踪 |
| Sentry | 错误追踪 |

## On-call

| 工具 | 用途 |
|---|---|
| PagerDuty | On-call 管理 |
| OpsGenie | On-call 管理 |
| Grafana OnCall | 开源 On-call |
| Slack | 事故频道 |

## 排障

| 工具 | 用途 |
|---|---|
| kubectl | K8s 操作 |
| k9s | K8s TUI |
| stern | 多 Pod 日志 |
| tcpdump | 网络抓包 |
| strace | 系统调用追踪 |
| perf | Linux 性能分析 |

## Chaos

| 工具 | 用途 |
|---|---|
| Litmus Chaos | K8s 故障注入 |
| Chaos Mesh | K8s 故障注入 |
| Gremlin | SaaS 故障注入 |
| toxiproxy | 网络故障模拟 |

## 容量

| 工具 | 用途 |
|---|---|
| k6 | 压测 |
| Locust | 压测 |
| Kubernetes HPA | 自动扩缩 |
| KEDA | 事件驱动扩缩 |

## 高风险操作

以下操作需要双人确认：
- 生产数据库操作
- K8s 集群变更
- DNS 变更
- 密钥轮换
- 灾备切换
