# [告警名] Runbook

## 告警信息
```text
告警名：
触发条件：
严重度：P1 / P2 / P3
影响：
```

## 快速诊断（< 2 分钟）
```bash
# 1. 检查最近部署
kubectl rollout history deployment/[app]

# 2. 检查错误日志
kubectl logs -l app=[app] --tail=100 | grep ERROR

# 3. 检查资源
kubectl top pods -l app=[app]

# 4. 检查依赖
curl -s [health-check-url]
```

## 止血操作

### 场景 A：最近部署导致
```bash
kubectl rollout undo deployment/[app]
```

### 场景 B：资源不足
```bash
kubectl scale deployment/[app] --replicas=[N]
```

### 场景 C：第三方故障
```text
启用降级：[Feature Flag / 配置]
```

### 场景 D：数据库问题
```text
联系 DBA：[联系方式]
```

## 验证恢复
```text
□ 错误率 < 1%
□ P99 < [SLO]
□ 告警消除
□ 用户确认
```

## 升级条件
```text
□ 5 分钟无法止血
□ 不确定根因
□ 数据丢失
□ 影响扩大
```

## 相关链接
```text
Dashboard：[URL]
日志：[URL]
部署历史：[URL]
联系人：[人 + 电话]
```

## 最后更新
```text
日期：
更新人：
原因：
```
