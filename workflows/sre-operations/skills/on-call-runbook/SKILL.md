---
name: on-call-runbook
description: On-call 轮值和 Runbook 维护时使用。适用于值班制度设计、操作手册编写、升级路径定义。融合 PagerDuty On-call + Atlassian Runbook。
---

# On-call + Runbook

## 适用场景

- On-call 轮值制度设计
- Runbook（操作手册）编写
- 升级路径定义
- 告警响应流程
- 新人 On-call 培训

## 核心原则

```text
1. Runbook = 告警的"怎么办"
   每个告警必须有对应 Runbook

2. Runbook 可执行
   不是"检查一下"，是具体命令

3. 定期更新
   过期 Runbook = 误导

4. On-call 不是 24/7 一个人
   轮换 + 主副 + 升级

5. On-call 有补偿
   不是义务劳动
```

## On-call 制度

```text
轮值周期：每周
主值班：1 人
副值班：1 人（backup）
交接：周一上午 30 分钟

响应时间：
  P1：5 分钟
  P2：15 分钟
  P3：1 小时
  P4：工作时间

升级路径：
  5 min 无响应 → 副值班
  15 min 无响应 → Tech Lead
  30 min 无响应 → Engineering Manager
  1 hour 无响应 → CTO

补偿：
  - 值班津贴
  - 事故处理后调休
```

## Runbook 结构

```markdown
# [告警名] Runbook

## 告警信息
- 告警名：HighErrorRate
- 触发条件：error_rate > 5% 持续 2 分钟
- 严重度：P1
- 影响：用户无法 [功能]

## 快速诊断
1. 检查最近部署：`kubectl rollout history deployment/app`
2. 检查错误日志：`kubectl logs -l app=my-app --tail=100 | grep ERROR`
3. 检查依赖状态：[第三方状态页 URL]
4. 检查资源：`kubectl top pods -l app=my-app`

## 止血操作
### 如果是最近部署导致
kubectl rollout undo deployment/my-app

### 如果是资源不足
kubectl scale deployment/my-app --replicas=10

### 如果是第三方故障
启用降级开关：[Feature Flag URL]

## 验证恢复
1. 错误率回到 < 1%
2. P99 回到 < 500ms
3. 用户确认功能正常

## 升级条件
- 5 分钟内无法止血 → 升级
- 不确定根因 → 升级
- 数据丢失 → 立即升级

## 相关链接
- Dashboard：[URL]
- 日志：[URL]
- 最近部署：[URL]
- 联系人：[人 + 电话]
```

## Runbook 维护

```text
何时更新：
  - 每次事故后（复盘改进项）
  - 架构变更后
  - 新服务上线时
  - 季度评审

谁更新：
  - 事故 IC
  - 服务 Owner
  - On-call 发现过期时

评审：
  - 每季度全量 review
  - 标记过期 / 删除无用
```

## 配套模板

- `templates/runbook-template.md` — Runbook 标准模板

## 质量自检

```text
□ 每个告警有 Runbook
□ Runbook 有具体命令（不是"检查一下"）
□ 升级路径明确
□ On-call 轮换
□ 交接文档
□ 定期更新
□ 新人培训
□ 补偿制度
```

## 常见坑

1. **Runbook 过期**——误导操作
2. **Runbook 太抽象**——"检查日志"不可执行
3. **没有升级路径**——一个人扛到崩溃
4. **On-call 不轮换**——burnout
5. **不交接**——新值班不知道上周情况
6. **告警无 Runbook**——半夜被叫不知道做什么

## 与其他 skill 的协作

```text
上游：
  incident-response → 事故中用 Runbook
  postmortem → 复盘后更新 Runbook

下游：
  devops-engineer monitoring-alerting → 告警配置
```
