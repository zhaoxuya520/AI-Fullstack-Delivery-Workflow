# SRE/运维工作流（SRE Operations Workflow）

## 定位

SRE/运维工作流负责 **生产系统的可靠性、可用性和可恢复性**：事故响应、复盘、容量规划、SLO 管理、On-call、日志排障。

它不替代 DevOps（部署链路）、后端（业务代码）、安全（攻击面）。它负责 **生产环境运行时的稳定性保障**。

本工作流采用 **skills 模块化架构**。

---

## 适用场景

```text
线上事故响应（止血 → 定位 → 修复）
事后复盘（Postmortem）
容量规划（扩缩容 / 成本优化）
SLO / 错误预算管理
On-call 轮值 / Runbook 维护
日志分析 / 根因定位
性能瓶颈排查
灾备演练 / Chaos Engineering
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| CI/CD / Docker / K8s 配置 | devops-engineer |
| 业务代码修复 | backend-engineer / frontend-engineer |
| 安全漏洞 / 渗透 | security-engineer |
| 数据库迁移 / 优化 | database-engineer |
| 需求不清 | product-manager |

---

## 输入

### 必需输入

```text
告警信息 / 用户报告 / 监控异常
影响范围（用户 / 功能 / 区域）
时间线（何时开始）
当前状态（持续 / 已恢复）
```

### 可选输入

```text
日志 / 指标 / 追踪数据
最近变更（部署 / 配置 / 数据库）
历史类似事故
SLO / 错误预算状态
架构图
```

---

## 完整行为链

```text
1. 收到告警 / 报告
   ↓
2. 评估影响（P1~P4）
   ↓
3. 止血（优先恢复服务）
   ↓
4. 通知（利益相关方）
   ↓
5. 定位根因
   ↓
6. 修复（或协调修复）
   ↓
7. 验证恢复
   ↓
8. 复盘（Postmortem）
   ↓
9. 改进项跟踪
   ↓
10. 沉淀经验 → field-journal + Runbook
```

---

## Skills 模块总览

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [incident-response](skills/incident-response/SKILL.md) | 事故响应 | 止血 → 定位 → 修复 → 通知 |
| [postmortem](skills/postmortem/SKILL.md) | 事后复盘 | 时间线 + 5 Whys + 改进项 |
| [capacity-planning](skills/capacity-planning/SKILL.md) | 容量规划 | 预测 + 扩缩容 + 成本 |
| [reliability-engineering](skills/reliability-engineering/SKILL.md) | 可靠性工程 | SLO + 错误预算 + Chaos |
| [on-call-runbook](skills/on-call-runbook/SKILL.md) | On-call + Runbook | 轮值 + 操作手册 |
| [log-analysis](skills/log-analysis/SKILL.md) | 日志分析 | ELK / Loki + 根因定位 |

---

## 禁止行为

```text
❌ 不要先定位再止血（先恢复服务）
❌ 不要一个人扛（升级 + 协作）
❌ 不要不通知就修（利益相关方要知道）
❌ 不要不复盘（同样事故会再来）
❌ 不要复盘追责（追流程不追人）
❌ 不要 Runbook 不更新（过期 = 误导）
❌ 不要忽略错误预算（预算耗尽 = 冻结发布）
❌ 不要手动操作不记录（审计 + 复盘需要）
```

---

## 任务复杂度分级

```text
S 级（10~30 分钟）：单服务告警 / 已知问题
  → on-call-runbook + log-analysis

M 级（30 分钟~2 小时）：影响部分用户
  → incident-response + log-analysis + postmortem

L 级（2~8 小时）：重大事故 / 多服务
  → 全部 skills + 跨工作流协作

XL 级（8 小时+）：灾难恢复 / 数据丢失
  → 全部 + database-engineer + devops-engineer + 管理层
```

---

## 通用质量检查

```text
□ 止血优先（不是定位优先）
□ 影响评估（P1~P4）
□ 通知到位（利益相关方）
□ 时间线记录（精确到分钟）
□ 根因分析（5 Whys）
□ 改进项可执行
□ Runbook 更新
□ 错误预算跟踪
□ 复盘不追责
□ 经验沉淀（field-journal）
```

---

## 常见坑

```text
1. 先定位再止血 → 故障持续
2. 一个人扛 → 疲劳出错
3. 不通知 → 利益相关方不知情
4. 不复盘 → 同样事故重复
5. 复盘追责 → 团队不敢报告
6. Runbook 过期 → 误导操作
7. 告警太多 → 真问题被淹没
8. 不做容量规划 → 大促崩溃
9. 不做灾备演练 → 真灾难时慌
10. 手动操作不记录 → 无法复盘
```

---

## 与其他工作流的协作

### 上游

| 上游 | SRE 需要的输入 |
|---|---|
| devops-engineer | 监控配置、部署信息、基础设施 |
| backend-engineer | 应用日志、指标、健康检查 |
| database-engineer | 数据库状态、备份、迁移信息 |

### 下游

| 下游 | SRE 交付内容 |
|---|---|
| backend-engineer | Bug 修复需求 + 根因 |
| devops-engineer | 基础设施改进需求 |
| project-manager | 事故影响报告 + 改进项 |
| technical-writer | Postmortem 文档 + Runbook |

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow sre-operations
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

```text
是否形成新 Runbook？→ 加入 on-call-runbook
是否发现新告警规则？→ 更新 monitoring-alerting（DevOps）
是否需要容量调整？→ 更新 capacity-planning
是否需要写入 field-journal？
```
