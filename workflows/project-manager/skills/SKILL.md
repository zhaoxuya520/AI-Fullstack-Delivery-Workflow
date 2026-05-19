# 项目经理 Skills 总控

本目录收录了项目经理工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [wbs-decomposition](wbs-decomposition/SKILL.md) | 任务分解为可执行工作包 | PMP / WBS 标准 |
| [critical-path](critical-path/SKILL.md) | 识别关键路径和并行机会 | CPM 关键路径方法 |
| [orchestration](orchestration/SKILL.md) | 选择编排模式（顺序/并发/交接/动态） | Microsoft Azure AI Agent Patterns |
| [handoff-protocol](handoff-protocol/SKILL.md) | 工作流间交接协议 | Skywork / Augment Code |
| [risk-management](risk-management/SKILL.md) | 风险识别和缓解 | PMBOK 风险矩阵 |
| [milestone-gate](milestone-gate/SKILL.md) | 里程碑设计和交付门禁 | Stage-Gate 方法 |
| [change-control](change-control/SKILL.md) | 变更影响评估和决策 | PMBOK 变更控制 |
| [progress-tracking](progress-tracking/SKILL.md) | 进度追踪和阻塞升级 | 任务状态机 + 三级升级 |
| [dora-metrics](dora-metrics/SKILL.md) | 交付效能度量 | Google DORA / Accelerate |
| [okr-alignment](okr-alignment/SKILL.md) | 项目与 OKR 对齐 | Google OKR Playbook |
| [shape-up-cycles](shape-up-cycles/SKILL.md) | Cycle 节奏管理 | Linear / Basecamp Shape Up |
| [retrospective](retrospective/SKILL.md) | 项目复盘 | Agile Retrospectives |

## 统一入口

1. 先读 `routing.md` — 按任务类型路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到项目需求 → 先判断复杂度
   - S/M 级 → 加载 wbs + handoff
   - L 级 → 加载 wbs + critical-path + orchestration + risk + milestone-gate
   - XL 级 → 加载所有 skills

2. 项目执行中 → 加载 progress-tracking
3. 需求变更 → 加载 change-control
4. 项目完成 → 加载 retrospective
5. 季度规划 → 加载 okr-alignment
6. 效能分析 → 加载 dora-metrics
```

## 新增 Skill

发现路由未命中时，按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成项目管理任务后，回写经验到 `../field-journal/`。
