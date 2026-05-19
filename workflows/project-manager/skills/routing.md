# 项目经理 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "把这个需求拆成任务" | [wbs-decomposition](wbs-decomposition/SKILL.md) |
| "排个期" / "做计划" | wbs + critical-path |
| "关键路径" / "哪些任务串行" | [critical-path](critical-path/SKILL.md) |
| "哪些可以并行" / "怎么编排" | [orchestration](orchestration/SKILL.md) |
| "怎么交接" / "工作流之间怎么传" | [handoff-protocol](handoff-protocol/SKILL.md) |
| "有什么风险" / "风险清单" | [risk-management](risk-management/SKILL.md) |
| "上线前 checklist" / "门禁" | [milestone-gate](milestone-gate/SKILL.md) |
| "需求改了" / "影响哪些任务" | [change-control](change-control/SKILL.md) |
| "进度怎么样" / "卡在哪了" | [progress-tracking](progress-tracking/SKILL.md) |
| "效能怎么样" / "交付速度" | [dora-metrics](dora-metrics/SKILL.md) |
| "对应哪个 OKR" / "战略对齐" | [okr-alignment](okr-alignment/SKILL.md) |
| "Sprint 怎么排" / "周期管理" | [shape-up-cycles](shape-up-cycles/SKILL.md) |
| "项目复盘" / "总结经验" | [retrospective](retrospective/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 新项目启动（M 级） | wbs-decomposition + handoff-protocol |
| 新项目启动（L 级） | wbs + critical-path + orchestration + risk + milestone-gate |
| 新项目启动（XL 级） | 全部 skills + okr-alignment |
| 项目执行中追踪 | progress-tracking + change-control |
| 季度/版本规划 | okr-alignment + shape-up-cycles + risk |
| 上线前最后检查 | milestone-gate + risk |
| 项目结束 | retrospective + dora-metrics |
| 团队效能优化 | dora-metrics + retrospective |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 10~30min | 不需要项目经理介入 |
| M | 1~3h | wbs-decomposition + handoff-protocol |
| L | 3~8h | wbs + critical-path + orchestration + handoff + risk + milestone-gate |
| XL | 8h+ | 全部 12 个 skills |

## 路径交叉

```text
项目启动路径：
  wbs-decomposition（拆任务）
  → critical-path（识别关键路径）
  → orchestration（决定编排模式）
  → handoff-protocol（定义交接）
  → risk-management（识别风险）
  → milestone-gate（设计门禁）

项目执行路径：
  progress-tracking（追踪状态）
  → change-control（处理变更）
  → milestone-gate（验证门禁）

战略对齐路径：
  okr-alignment（对齐 OKR）
  → shape-up-cycles（决定 Cycle）
  → wbs-decomposition（拆 Cycle 任务）

项目收尾路径：
  retrospective（复盘）
  → dora-metrics（度量效能）
  → 回写 field-journal
```

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增 skill。
