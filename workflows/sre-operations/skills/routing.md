# SRE Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "线上故障" / "服务挂了" / "告警" / "止血" | [incident-response](incident-response/SKILL.md) |
| "复盘" / "Postmortem" / "根因" / "5 Whys" | [postmortem](postmortem/SKILL.md) |
| "容量" / "扩容" / "缩容" / "成本" / "大促" | [capacity-planning](capacity-planning/SKILL.md) |
| "SLO" / "错误预算" / "可靠性" / "Chaos" | [reliability-engineering](reliability-engineering/SKILL.md) |
| "On-call" / "Runbook" / "操作手册" / "轮值" | [on-call-runbook](on-call-runbook/SKILL.md) |
| "日志" / "排查" / "定位" / "慢查询" / "追踪" | [log-analysis](log-analysis/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单服务告警（S 级） | on-call-runbook + log-analysis |
| 部分用户影响（M 级） | incident-response + log-analysis + postmortem |
| 重大事故（L 级） | 全部 |
| 容量规划 / 大促 | capacity-planning + reliability-engineering |
| SLO 评审 | reliability-engineering + postmortem |

## 路由未命中

按 `CONTRIBUTING.md` 流程新增。
