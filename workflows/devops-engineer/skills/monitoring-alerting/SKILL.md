---
name: monitoring-alerting
description: 配置监控和告警时使用。适用于 Prometheus / Grafana / Loki / PagerDuty / SLO 定义 / 告警规则设计。融合 Google SRE 四大黄金信号 + USE Method + 告警分级。
---

# 监控与告警（Monitoring & Alerting）

参考来源：Google《Site Reliability Engineering》、Brendan Gregg USE Method、Prometheus 官方、Grafana Labs、PagerDuty Incident Response。

## 适用场景

- 监控系统搭建（Prometheus + Grafana）
- 日志收集（Loki / ELK）
- 告警规则设计
- SLO / SLI 定义
- 仪表盘设计
- On-call 配置

## 核心原则

```text
1. 四大黄金信号（Google SRE）
   Latency / Traffic / Errors / Saturation

2. USE Method（Brendan Gregg）
   每种资源：Utilization / Saturation / Errors

3. 告警基于 SLO，不基于阈值
   "错误预算消耗 > 50%" 比 "CPU > 80%" 有意义

4. 告警可操作
   收到告警 → 知道做什么
   不可操作的告警 = 噪音

5. 分级告警
   P1（立即）/ P2（1 小时）/ P3（工作时间）/ P4（下周）

6. 不 alert fatigue
   宁可少告警，不可多到忽略
```

## 监控栈选型

| 组件 | 开源 | SaaS |
|---|---|---|
| **指标** | Prometheus + Grafana | Datadog / New Relic |
| **日志** | Loki / ELK | Datadog Logs / Splunk |
| **追踪** | Jaeger / Tempo | Datadog APM / Honeycomb |
| **告警** | Alertmanager | PagerDuty / OpsGenie |
| **Uptime** | Blackbox Exporter | UptimeRobot / Better Stack |
| **错误** | Sentry（自建） | Sentry Cloud |
| **APM** | OpenTelemetry | Datadog / Dynatrace |

## 四大黄金信号

```yaml
# Prometheus 规则示例

# 1. Latency（延迟）
- record: http_request_duration_seconds:p99
  expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

# 2. Traffic（流量）
- record: http_requests_per_second
  expr: rate(http_requests_total[5m])

# 3. Errors（错误率）
- record: http_error_rate
  expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 4. Saturation（饱和度）
- record: cpu_saturation
  expr: 1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))
```

## SLO / SLI 定义

```text
SLI（Service Level Indicator）：
  - 可用性：成功请求 / 总请求
  - 延迟：P99 < 500ms 的请求比例
  - 吞吐：每秒处理请求数

SLO（Service Level Objective）：
  - 可用性 SLO：99.9%（每月允许 43 分钟不可用）
  - 延迟 SLO：99% 请求 P99 < 500ms
  - 错误 SLO：错误率 < 0.1%

错误预算（Error Budget）：
  - 月预算 = 1 - SLO = 0.1% = 43 分钟
  - 消耗 > 50% → 冻结发布
  - 消耗 > 80% → 专注稳定性
```

```yaml
# Prometheus SLO 告警（Burn Rate）
groups:
  - name: slo-alerts
    rules:
      # 1 小时 burn rate > 14.4（快速消耗）→ P1
      - alert: HighErrorBudgetBurn_1h
        expr: |
          (
            rate(http_requests_total{status=~"5.."}[1h])
            / rate(http_requests_total[1h])
          ) > 14.4 * 0.001
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Error budget burning fast (1h window)"
      
      # 6 小时 burn rate > 6 → P2
      - alert: HighErrorBudgetBurn_6h
        expr: |
          (
            rate(http_requests_total{status=~"5.."}[6h])
            / rate(http_requests_total[6h])
          ) > 6 * 0.001
        for: 5m
        labels:
          severity: warning
```

## 告警规则设计

### 分级

| 级别 | 含义 | 响应时间 | 通知方式 |
|---|---|---|---|
| P1 Critical | 服务不可用 / 数据丢失 | 立即 | 电话 + Slack |
| P2 High | 功能降级 / 性能退化 | 1 小时 | Slack + 邮件 |
| P3 Medium | 非紧急但需关注 | 工作时间 | Slack |
| P4 Low | 信息性 | 下周 | 邮件 |

### 好告警 vs 坏告警

```text
好告警：
  ✅ "订单创建错误率 > 5% 持续 2 分钟"
  ✅ "错误预算消耗 > 50%"
  ✅ "数据库连接池使用 > 90%"

坏告警：
  ❌ "CPU > 80%"（可能正常）
  ❌ "磁盘 > 70%"（太早）
  ❌ "某个 Pod 重启了"（可能正常）
  ❌ "日志有 ERROR"（太多噪音）
```

### 告警模板

```yaml
- alert: HighErrorRate
  expr: http_error_rate > 0.05
  for: 2m
  labels:
    severity: critical
    team: backend
  annotations:
    summary: "High error rate: {{ $value | humanizePercentage }}"
    description: "Error rate > 5% for 2 minutes"
    runbook: "https://wiki.example.com/runbooks/high-error-rate"
    dashboard: "https://grafana.example.com/d/xxx"
```

## Grafana 仪表盘设计

### 推荐 5 个 Dashboard

```text
1. 服务总览（Golden Signals）
   - QPS / 错误率 / P50 / P99 / 饱和度
   - 按服务分组

2. 业务指标
   - 订单数 / 支付成功率 / 注册数
   - 按时间对比（vs 昨天 / 上周）

3. 基础设施
   - CPU / Memory / Disk / Network
   - 按节点 / Pod 分组

4. 数据库
   - 连接数 / 慢查询 / 锁等待 / 复制延迟

5. 发布追踪
   - 部署时间线
   - 发布前后指标对比
```

## Prometheus + Grafana 部署

```yaml
# docker-compose（快速启动）
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  alertmanager:
    image: prom/alertmanager:latest
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    ports:
      - "9093:9093"
```

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alerts/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:8080']
    metrics_path: '/metrics'
```

## 日志收集（Loki）

```yaml
# Loki + Promtail
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - ./promtail.yml:/etc/promtail/config.yml
```

```text
日志规范：
  - JSON 格式（结构化）
  - 含 trace_id / service / level / timestamp
  - 不输出 PII / Token
  - 保留期：7~30 天
```

## On-call 配置

```text
轮值：
  - 每周轮换
  - 主 + 副（backup）
  - 交接文档

升级路径：
  P1：5 分钟无响应 → 升级到副
  P1：15 分钟无响应 → 升级到 Tech Lead
  P1：30 分钟无响应 → 升级到 CTO

工具：
  - PagerDuty / OpsGenie / Grafana OnCall
  - Slack 集成
  - 电话 + 短信
```

## 配套模板

- `templates/monitoring-setup-template.md` — 监控配置 + SLO + 告警规则 + 仪表盘
- `templates/alert-rule-template.md` — 告警规则与发布门禁

## 质量自检

```text
□ 四大黄金信号覆盖
□ SLO / SLI 定义
□ 告警基于 SLO（不基于阈值）
□ 告警分级（P1~P4）
□ 告警可操作（有 Runbook）
□ 不 alert fatigue
□ 仪表盘覆盖（5 个）
□ 日志结构化 + 集中
□ On-call 配置
□ 升级路径
□ 错误预算跟踪
□ 发布后监控
```

## 常见坑

1. **CPU > 80% 告警**——可能正常，应该看 SLO
2. **告警太多**——alert fatigue，重要的被忽略
3. **告警不可操作**——收到不知道做什么
4. **不分级**——所有告警都是 P1
5. **没有 Runbook**——半夜被叫起来不知道怎么修
6. **日志不结构化**——搜索困难
7. **不监控业务指标**——只盯技术指标
8. **SLO 不定义**——不知道什么算"正常"
9. **不做错误预算**——永远在救火
10. **On-call 不轮换**——一个人扛

## 与其他 skill 的协作

```text
上游：
  ci-cd-pipeline → 部署后触发监控
  release-strategy → 发布后观察
  kubernetes-orchestration → K8s 指标

下游：
  sre-operations 工作流 → 事故响应
  backend-engineer observability → 应用层指标
```
