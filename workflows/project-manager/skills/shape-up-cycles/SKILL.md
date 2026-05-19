---
name: shape-up-cycles
description: 管理交付节奏和 Cycle 时间盒时使用。适用于替代传统 Sprint、固定时间可变范围的项目、AI 工作流的快节奏管理。优先使用 Linear Cycles + Basecamp Shape Up + Cooldown 节奏。
---

# Cycle 节奏管理

参考来源：[Linear Cycles](https://everhour.com/blog/linear-vs-jira/)、[Basecamp Shape Up](https://basecamp.com/shapeup)

## 适用场景

- 替代传统 Sprint
- AI 工作流的快节奏交付
- 固定时间可变范围的项目
- 避免估算地狱
- 需要持续交付节奏

## 核心思想

```text
传统 Sprint：
  估算时间 → 排满 → 时间不够延期或砍质量

Cycle 模式：
  固定时间盒（Appetite）→ 时间到了交付当时最有价值的部分
  范围可调，时间不延

AI 工作流的优势：
  执行速度快，瓶颈在等待
  Cycle 节奏更适合短周期、高频交付
```

## Cycle 类型（AI 工作流适配）

```text
Micro Cycle：30~60 分钟
  - 一个功能点从设计到测试
  - 适合 S/M 级任务
  - 单工作流或 2 个工作流串行

Standard Cycle：2~4 小时
  - 一个完整模块
  - 适合 M/L 级任务
  - 多工作流协作

Extended Cycle：1 天（实际执行 6~8 小时 + 等待）
  - 跨多模块的大功能
  - 适合 L 级任务
  - 全流程参与

Multi-Day Cycle：2~5 天
  - 大型项目阶段
  - 适合 XL 级任务
  - 包含多个 Extended Cycle
```

## Cycle 规则

```text
1. 开始前明确目标和验收标准
   - 不是"做某些功能"
   - 而是"达到某个可验证的状态"

2. Cycle 内不接受新需求
   - 变更进入下一个 Cycle
   - 紧急 bug 例外（占用 cooldown）

3. 时间到了但没完成
   - 砍范围交付最有价值的部分
   - 不延期
   - 剩余范围进入下个 Cycle

4. Cycle 结束后必有 cooldown
   - 不能背靠背开始新 Cycle
   - cooldown 用于消化遗留问题
```

## Cooldown（冷却期）

```text
每个 Standard Cycle 后：15~30 分钟
每个 Extended Cycle 后：1~2 小时
每个 Multi-Day Cycle 后：半天到一天

Cooldown 用途：
  - 处理上个 Cycle 遗留的小问题
  - 更新文档和 field-journal
  - 为下个 Cycle 做准备
  - 团队/工作流回血
  - 不安排新的开发任务

为什么必须有 cooldown：
  - 防止技术债积累
  - 给文档更新留时间
  - 让经验沉淀下来
  - 避免连续高强度交付崩溃
```

## Cycle 内的关键活动

### Cycle Kickoff（开始）

```text
□ 明确 Cycle 目标
□ 定义验收标准
□ 列出 Cycle 内的任务（用 wbs-decomposition）
□ 标注关键路径和风险
□ 启动 progress-tracking
```

### Cycle 执行（中间）

```text
□ 按编排模式执行（来自 orchestration）
□ 实时维护任务状态
□ 阻塞按 L1/L2/L3 升级
□ 不接受新需求（除紧急 bug）
□ 时间预算监控
```

### Cycle End（结束）

```text
□ 验证 Cycle 目标是否达成
□ 时间到了砍范围（如果未完成）
□ 输出 Cycle 报告
□ 简短复盘（5 分钟）
```

### Cooldown（冷却）

```text
□ 处理遗留小问题
□ 更新 field-journal
□ 沉淀经验
□ 准备下个 Cycle
```

## Cycle 报告模板

```markdown
## Cycle 报告：[Cycle 名称]

### 基本信息

- Cycle 类型：Standard / Extended / Multi-Day
- 时间范围：[开始时间] ~ [结束时间]
- 实际耗时：X 小时

### Cycle 目标

[明确写出本 Cycle 要达成的目标]

### 完成情况

| 任务 | 状态 | 备注 |
|------|------|------|
| T1 | ✅ done | 按预期完成 |
| T2 | ✅ done | 比预期快 |
| T3 | ⚠️ rework | 验收未通过，下个 Cycle 修复 |
| T4 | ⏰ skipped | 时间不够，移到下个 Cycle |

### 关键交付物

- [产出 1]
- [产出 2]

### 阻塞和异常

- 阻塞 1：[描述] - 解决方式：[L1/L2/L3]
- 异常 1：[描述] - 影响：[评估]

### 下个 Cycle 准备

- 待修复：T3
- 待处理：T4
- 新需求：[列表]

### 简短复盘

- 做得好：[1~2 条]
- 待改进：[1~2 条]
- 沉淀：[field-journal 条目]
```

## Cycle vs Sprint 对比

```text
| 维度 | Cycle | Sprint |
|------|-------|--------|
| 时间盒 | 灵活（30min ~ 多天） | 固定（通常 2 周） |
| 范围 | 可变 | 固定 |
| 估算 | 不估，按 Appetite | 详细估算 |
| 仪式 | 简化（Kickoff + 简短复盘） | 完整（Planning/Daily/Review/Retro） |
| 节奏 | 连续 + Cooldown | 连续 Sprint |
| 适合 | AI 工作流 / 小团队 | 传统团队 / 大项目 |
```

## 工作流程

```text
1. Cycle 规划：
   - 确定 Cycle 类型（Micro/Standard/Extended/Multi-Day）
   - 设定 Appetite（时间盒）
   - 明确 Cycle 目标
   ↓
2. Kickoff：
   - 加载 wbs-decomposition + critical-path + orchestration
   - 列出任务
   - 启动 progress-tracking
   ↓
3. 执行：
   - 不接受新需求
   - 实时追踪状态
   - 时间监控
   ↓
4. End：
   - 验证目标
   - 必要时砍范围
   - 输出 Cycle 报告
   ↓
5. Cooldown：
   - 处理遗留
   - 更新 field-journal
   - 准备下个 Cycle
```

## 质量自检

```text
□ Cycle 目标是否可验证
□ Appetite 是否合理（不要 100h 的 Cycle）
□ 是否真的不接受新需求
□ 时间到了是否真的砍范围（不是延期）
□ 是否有 Cooldown
□ Cycle 报告是否输出
□ 简短复盘是否做了
```

## 常见坑

1. **没有 Appetite**——又陷入估算地狱
2. **Cycle 太长**——失去灵活性
3. **Cycle 太短**——开销大于收益
4. **接受 Cycle 内新需求**——破坏时间盒
5. **没有 Cooldown**——技术债累积
6. **Cooldown 被压缩**——"时间紧" → 失去消化时间
7. **不做简短复盘**——经验流失
8. **Cycle 报告流于形式**——不真实评估

## 配套模板

- `templates/cycle-kickoff-template.md` — Cycle 启动模板
- `templates/cycle-report-template.md` — Cycle 报告模板
- `templates/cooldown-checklist-template.md` — Cooldown 清单

## 与其他 skill 的协作

```text
上游：
  okr-alignment → 用 OKR 指导 Cycle 主题

平行：
  wbs-decomposition → Cycle 内的任务分解
  progress-tracking → Cycle 执行追踪

下游：
  retrospective → Cycle 复盘
  dora-metrics → Cycle 数据用于 DORA 计算
```
