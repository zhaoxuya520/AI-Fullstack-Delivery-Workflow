---
name: incident-response
description: 线上事故响应时使用。适用于服务不可用、性能退化、数据异常等生产事故。融合 Google SRE Incident Management + PagerDuty Response Framework。
---

# 事故响应（Incident Response）

参考来源：Google《Site Reliability Engineering》Chapter 14、PagerDuty Incident Response Guide、Atlassian Incident Management。

## 适用场景

- 服务不可用 / 部分不可用
- 性能严重退化（P99 > 5x 基线）
- 数据异常 / 丢失
- 安全事件
- 第三方依赖故障

## 核心原则

```text
1. 止血优先（Mitigate First）
   先恢复服务，再定位根因
   回滚 > 修复 > 扩容 > 降级

2. 角色明确
   Incident Commander（IC）：决策
   Communications Lead：通知
   Operations Lead：执行

3. 升级不犹豫
   5 分钟无进展 → 升级
   不确定 → 升级

4. 实时记录
   所有操作记录到时间线

5. 通知及时
   内部：Slack 频道
   外部：状态页 / 客户通知

6. 不追责
   事故中不讨论"谁的错"
   复盘时讨论"流程怎么改"
```

## 事故分级

| 级别 | 影响 | 响应时间 | 角色 |
|---|---|---|---|
| P1 Critical | 全用户不可用 / 数据丢失 | 立即 | IC + 全团队 |
| P2 High | 部分用户 / 核心功能降级 | 15 分钟 | IC + 相关人 |
| P3 Medium | 非核心功能 / 少量用户 | 1 小时 | On-call |
| P4 Low | 边缘问题 / 无用户感知 | 工作时间 | 排期修 |

## 响应流程

```text
1. 告警触发 / 用户报告
   ↓
2. On-call 确认（5 分钟内）
   - 是否真实事故？
   - 影响范围？
   - 分级（P1~P4）
   ↓
3. 开 Incident Channel（P1/P2）
   - Slack #incident-YYYY-MM-DD
   - 指定 IC
   ↓
4. 止血（优先级最高）
   - 回滚最近部署
   - 扩容
   - 降级（关闭非核心功能）
   - 切换到备用
   - 限流
   ↓
5. 通知
   - 内部：Slack + 邮件
   - 外部：状态页更新
   - 客户：如影响大
   ↓
6. 定位根因
   - 最近变更？（部署 / 配置 / 数据库）
   - 日志 / 指标 / 追踪
   - 第三方状态？
   ↓
7. 修复
   - 临时修复（hotfix）
   - 或：等止血稳定后排期修
   ↓
8. 验证恢复
   - 指标回到基线
   - 用户确认
   - 告警消除
   ↓
9. 关闭事故
   - 更新状态页
   - 通知恢复
   - 安排复盘
   ↓
10. 复盘（24~72 小时内）
    → postmortem skill
```

## 止血决策树

```text
最近有部署？
  YES → 回滚（最快）
  NO ↓

资源不足（CPU/Memory/连接池）？
  YES → 扩容
  NO ↓

第三方挂了？
  YES → 降级 / 切备用
  NO ↓

流量异常（攻击 / 爬虫）？
  YES → 限流 / 封 IP
  NO ↓

数据库问题？
  YES → 联系 DBA / 切从库
  NO ↓

不确定？
  → 回滚最近变更（兜底）
```

## IC（Incident Commander）职责

```text
□ 评估影响和分级
□ 分配角色
□ 决策止血方案
□ 控制节奏（不让人乱）
□ 决定何时升级
□ 决定何时关闭
□ 安排复盘
□ 不亲自排查（除非只有一人）
```

## 通知模板

### 内部通知

```text
[P1] 订单服务不可用

影响：所有用户无法创建订单
开始时间：14:30 UTC
当前状态：止血中（已回滚最近部署）
IC：@alice
频道：#incident-2026-05-19

下次更新：15:00 UTC
```

### 外部状态页

```text
[Investigating] 我们正在调查订单创建功能异常。
[Identified] 已定位问题，正在修复。
[Monitoring] 已修复，正在监控。
[Resolved] 问题已解决。影响时间：14:30~15:15 UTC。
```

## 配套模板

- `templates/incident-template.md` — 事故记录 + 时间线 + 影响 + 止血 + 后续

## 质量自检

```text
□ 5 分钟内确认
□ 分级正确
□ IC 指定
□ 止血优先
□ 时间线实时记录
□ 通知及时（内部 + 外部）
□ 升级不犹豫
□ 验证恢复
□ 安排复盘
□ 不追责
```

## 常见坑

1. **先定位再止血**——故障持续 30 分钟
2. **一个人扛**——疲劳出错
3. **不升级**——问题扩大
4. **不通知**——客户从社交媒体知道
5. **不记录时间线**——复盘无据
6. **追责**——下次不敢报告
7. **回滚犹豫**——"可能不是部署的问题"
8. **不验证恢复**——以为好了实际没好
9. **不安排复盘**——同样事故再来
10. **IC 亲自排查**——没人协调

## 与其他 skill 的协作

```text
下游：
  postmortem → 复盘
  on-call-runbook → Runbook 更新
  log-analysis → 定位根因
  
上游：
  devops-engineer monitoring-alerting → 告警触发
```
