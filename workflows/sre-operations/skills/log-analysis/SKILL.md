---
name: log-analysis
description: 日志分析和排障时使用。适用于生产问题定位、慢查询排查、错误追踪、日志搜索。融合 ELK / Loki + 结构化日志 + Trace ID 追踪。
---

# 日志分析（Log Analysis）

## 适用场景

- 生产问题根因定位
- 错误日志分析
- 慢请求追踪
- 用户行为追踪（合规范围内）
- 日志模式识别

## 核心原则

```text
1. Trace ID 是线索
   一个请求的所有日志用 trace_id 串联

2. 结构化日志
   JSON 格式，可搜索、可聚合

3. 从指标到日志
   先看 Grafana 定位时间范围
   再看日志定位具体请求

4. 不在日志里找"所有"
   先缩小范围（时间 + 服务 + 级别）

5. 日志不是监控
   日志用于排查，不用于告警
   告警用指标
```

## 排障流程

```text
1. 确定时间范围
   - 告警触发时间
   - 用户报告时间
   ↓
2. 确定服务
   - 哪个服务出问题
   - 上下游
   ↓
3. 看指标（Grafana）
   - 错误率突增？
   - 延迟突增？
   - QPS 变化？
   ↓
4. 看日志（Loki / ELK）
   - 过滤 ERROR / WARN
   - 用 trace_id 追踪
   ↓
5. 看追踪（Jaeger / Tempo）
   - 哪个 span 慢？
   - 哪个服务超时？
   ↓
6. 定位根因
   - 代码 Bug？
   - 配置错误？
   - 资源不足？
   - 第三方故障？
   ↓
7. 修复或升级
```

## Loki 查询（LogQL）

```text
# 基础：按服务 + 级别
{app="order-service"} |= "ERROR"

# 按 trace_id
{app="order-service"} |= "trace_id=abc123"

# JSON 解析 + 过滤
{app="order-service"} | json | level="error" | status_code >= 500

# 统计错误率
rate({app="order-service"} |= "ERROR" [5m])

# 按错误码分组
sum by (error_code) (
  count_over_time({app="order-service"} | json | level="error" [1h])
)
```

## ELK 查询（KQL）

```text
# 基础
service: "order-service" AND level: "ERROR"

# 时间范围
@timestamp >= "2026-05-19T14:00:00" AND @timestamp <= "2026-05-19T15:00:00"

# Trace ID
trace_id: "abc123"

# 状态码
response.status: >= 500

# 排除噪音
NOT message: "health check"
```

## 常见排障模式

### 错误突增

```text
1. 看错误率图（Grafana）→ 确定开始时间
2. 对比最近部署时间
3. 过滤 ERROR 日志
4. 按 error_code 分组 → 找最多的
5. 用 trace_id 看完整链路
6. 定位到具体代码 / 配置
```

### 延迟突增

```text
1. 看 P99 图 → 确定开始时间
2. 看追踪（Jaeger）→ 哪个 span 慢
3. 如果是 DB → 看慢查询日志
4. 如果是第三方 → 看第三方状态
5. 如果是 GC → 看 JVM / Node 指标
```

### 间歇性问题

```text
1. 收集多次发生的时间点
2. 找共同模式（定时任务？流量高峰？）
3. 对比正常 vs 异常时的日志差异
4. 看资源使用（是否接近上限时才出现）
```

## 配套模板

- `templates/troubleshooting-template.md` — 排障记录模板

## 质量自检

```text
□ 用 trace_id 追踪
□ 先缩小范围再搜索
□ 从指标到日志（不反过来）
□ 结构化查询（不 grep 全文）
□ 记录排障过程（复盘用）
□ 定位到根因（不停在现象）
```

## 常见坑

1. **grep 全文搜索**——太慢，用结构化查询
2. **不缩小时间范围**——日志太多
3. **不用 trace_id**——跨服务追不到
4. **只看自己服务**——问题可能在上游
5. **日志不结构化**——无法聚合分析
6. **不记录排障过程**——下次从零开始

## 与其他 skill 的协作

```text
上游：
  incident-response → 事故中排障
  devops-engineer monitoring-alerting → 指标入口

下游：
  postmortem → 根因分析
  backend-engineer → 代码修复
```
