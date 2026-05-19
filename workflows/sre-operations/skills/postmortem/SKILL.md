---
name: postmortem
description: 事故复盘时使用。适用于 P1/P2 事故后 24~72 小时内的 Blameless Postmortem。融合 Google SRE Postmortem + 5 Whys + 改进项跟踪。
---

# 事后复盘（Postmortem）

参考来源：Google《Site Reliability Engineering》Chapter 15、Etsy Just Culture、PagerDuty Postmortem Guide。

## 适用场景

- P1 / P2 事故后（必做）
- P3 事故（可选，有学习价值时）
- 重复发生的问题
- "差点出事"（Near Miss）

## 核心原则

```text
1. Blameless（不追责）
   追流程不追人
   "为什么系统允许这个错误发生？"

2. 24~72 小时内完成
   记忆新鲜时写

3. 必须有改进项
   没有 Action Items 的复盘 = 没复盘

4. 改进项必须跟踪
   有负责人 + 截止时间 + 状态

5. 公开透明
   团队都能看到（学习）

6. 5 Whys 找根因
   不停在表面
```

## 复盘流程

```text
1. 事故关闭后 24 小时内
   - IC 发起复盘
   - 收集时间线 + 日志 + 指标
   ↓
2. 写 Postmortem 文档
   - 用模板
   - 时间线精确到分钟
   - 5 Whys 根因分析
   ↓
3. 复盘会议（30~60 分钟）
   - 参与人：IC + 相关工程师 + PM
   - 走时间线
   - 讨论根因
   - 确定改进项
   ↓
4. 改进项分配
   - 每项有负责人 + 截止时间
   - 录入 Jira / Linear
   ↓
5. 跟踪
   - 每周检查改进项状态
   - 下次复盘回看上次改进项
   ↓
6. 沉淀
   - field-journal
   - Runbook 更新
   - 告警规则更新
   - pitfalls 更新
```

## 5 Whys 方法

```text
规则：
  - 每个 Why 必须有证据
  - 不停在"人犯了错"
  - 追到系统 / 流程层面

示例：
  Why 1：用户无法登录
  Why 2：认证服务返回 500
  Why 3：Redis 连接超时
  Why 4：Redis 内存满了
  Why 5：没有配置 maxmemory-policy（淘汰策略）

  根因：Redis 配置缺失 + 没有内存告警
  
  不是根因：
  ❌ "运维忘了配置"（追责）
  ✅ "配置检查清单缺少 Redis 内存策略项"（流程）
```

## 改进项分类

```text
1. 检测改进（更早发现）
   - 新增告警规则
   - 降低告警阈值
   - 增加监控覆盖

2. 预防改进（不再发生）
   - 代码修复
   - 配置修复
   - 流程改进
   - 自动化检查

3. 缓解改进（影响更小）
   - 降级方案
   - 限流
   - 灾备切换
   - 回滚加速

4. 响应改进（恢复更快）
   - Runbook 更新
   - 告警路由优化
   - 升级路径优化
```

## 配套模板

- `templates/postmortem-template.md` — 完整 Postmortem 文档（摘要 + 时间线 + 5 Whys + 改进项）

## 质量自检

```text
□ 24~72 小时内完成
□ 时间线精确到分钟
□ 5 Whys 到系统层面
□ 不追责
□ 改进项有负责人 + 截止
□ 改进项可执行（不是"加强注意"）
□ 公开透明
□ 沉淀到 field-journal
□ Runbook 更新
□ 告警规则更新
```

## 常见坑

1. **追责**——"谁部署的？"→ 团队不敢报告
2. **5 Whys 停在表面**——"代码有 Bug"不是根因
3. **改进项太宽泛**——"加强监控"不可执行
4. **改进项不跟踪**——写完就忘
5. **不开会**——只写文档没讨论
6. **拖延**——2 周后才写，记忆模糊
7. **不公开**——只有当事人知道
8. **不回看**——上次改进项没人检查

## 与其他 skill 的协作

```text
上游：
  incident-response → 事故记录

下游：
  on-call-runbook → Runbook 更新
  reliability-engineering → SLO / 错误预算调整
  field-journal → 经验沉淀
  devops-engineer monitoring-alerting → 告警改进
```
