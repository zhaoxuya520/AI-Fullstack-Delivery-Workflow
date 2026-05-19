---
name: shape-up
description: 需要快速交付且范围可协商时使用。适用于固定时间盒下的功能开发、避免无限延期、Sprint 替代方案。优先使用 Basecamp Shape Up 的 Pitch + Appetite + Cycle 方法。
---

# Shape Up（固定时间，可变范围）

参考来源：[Basecamp Shape Up](https://basecamp.com/shapeup)（Ryan Singer）

## 适用场景

- 不想被永远延期的功能
- 范围有讨论空间的需求
- 替代传统 Sprint
- 避免估算地狱
- AI 工作流的快速交付

## 不适用场景

- 范围必须 100% 完整的功能（如合规需求）
- 紧急 bug 修复（不需要 shaping）
- 探索性研究（适合 [pol-probe](../pol-probe/SKILL.md)）

## 核心原则

```text
传统方式：
  先估算"需要多少时间" → 时间到了砍范围 → 永远延期

Shape Up：
  先决定"愿意投入多少时间"（Appetite）
  → 时间到了交付当时最有价值的部分
  → 不延期，但范围可调
```

## 三个核心概念

### 1. Appetite（食量）

**先决定愿意投入多少时间，再决定做什么。**

```text
传统估算：
  "这个功能要 5 天"
  → 经常变成 10 天

Shape Up Appetite：
  "我们愿意花 3 天做这个功能"
  → 3 天后必须交付，但可能不是完整版

AI 工作流的 Appetite 定义：
  Small Batch：15~45 分钟（一个功能点）
  Big Batch：1~3 小时（一个完整模块）
  Extended：3~8 小时（跨多模块的大功能）
```

### 2. Pitch（提案）

不是任务清单，而是结构化的"该做什么 + 不做什么"提案。

**Pitch 五要素：**

```text
1. Problem（问题）
   要解决的具体痛点是什么
   
2. Appetite（时间预算）
   愿意花多少时间
   
3. Solution（方案轮廓）
   "fat marker sketch"——粗略的方案，不是细节设计
   
4. Rabbit Holes（已识别的坑）
   可能让团队陷进去出不来的风险点
   提前排除
   
5. No-gos（明确不做）
   防止范围蔓延
```

### 3. Cycle（周期）

固定的时间盒，结束时必须交付。

```text
Basecamp 原版：6 周 cycle + 2 周 cooldown

AI 工作流适配：
  Micro Cycle：30~60 分钟（一个功能点从设计到测试）
  Standard Cycle：2~4 小时（一个完整模块）
  Extended Cycle：1 天（跨多模块的大功能）
  
Cooldown：每个 Extended 后 15~30 分钟
  - 处理遗留小问题
  - 更新文档和 field-journal
  - 准备下个 cycle
```

## 工作流程

```text
1. Shaping 阶段（写 Pitch）
   ↓
2. Betting 阶段（决定本期做什么）
   ↓
3. Building 阶段（在 Cycle 内交付）
   ↓
4. Cooldown 阶段（清理 + 复盘）
```

### 1. Shaping（提前准备）

```text
□ 写出 Problem（用用户语言）
□ 设定 Appetite（时间盒）
□ 画 fat marker sketch（粗略方案，不是细节）
□ 列 Rabbit Holes（已知风险）
□ 列 No-gos（明确不做）
```

### 2. Betting（决定做什么）

```text
□ 评估每个 Pitch 的价值和成本
□ 选定本期 Cycle 要做的 Pitch
□ 一旦选定，本期不接受新需求
```

### 3. Building（执行）

```text
□ 团队/工作流自主决定具体实现
□ Hill Chart 追踪进度（不是百分比）
   - 上山：还在搞清楚怎么做
   - 山顶：搞清楚了
   - 下山：在执行
□ 时间预算到了 → 砍范围交付，不延期
```

### 4. Cooldown（冷却期）

```text
□ 处理上个 Cycle 遗留的小问题
□ 更新文档和 field-journal
□ 团队/工作流回血
□ 不接新的开发任务
```

## Pitch 模板

```markdown
# Pitch: [功能名]

## Problem

[用 1~2 段描述用户当前遇到的问题，要具体到能看到痛点]

例：
设计师每次评审需要在 Figma 评论、Slack、邮件三个地方追状态。
这导致每周浪费 8+ 小时在手动同步上，而且经常漏掉评审反馈。

## Appetite

**Standard Cycle：3 小时（AI 工作流）**

## Solution（fat marker sketch）

[简单的方案描述，重点是"做什么"不是"怎么做"]

例：
- 在 Figma 文件中嵌入一个评审状态面板
- 评审 reviewers 列表 + 状态（待评审/已通过/有意见）
- 一键发送 Slack 通知给未完成评审的人
- 历史评审记录可查

[可以配粗糙的草图]

## Rabbit Holes

⚠️ Figma API 可能不支持嵌入式面板
   → 提前调研，如不支持就改用浏览器扩展

⚠️ Slack 通知容易变成噪音
   → 默认每天一次汇总，紧急情况手动触发

## No-gos

❌ 不做权限管理（谁能修改评审状态）→ 后续版本
❌ 不做评审模板（每种设计稿不同的评审项）→ 后续版本
❌ 不做评审报告（统计每个 reviewer 的响应时间）→ 后续版本
❌ 不集成除 Figma + Slack 外的工具
```

## Hill Chart 追踪进度

```text
        山顶（搞清楚了）
        ／＼
       ／  ＼
      ／    ＼
上山／      ＼下山
（探索）    （执行）

任务在哪个阶段？
  - 上山：还有未知，需要研究
  - 山顶：方案清晰，但还没开始执行
  - 下山：在执行，剩下的是已知工作
```

进度报告不说"完成 60%"，说"已经过了山顶，在下山"。

## 质量自检

```text
□ 是否先定 Appetite 再设计方案
□ Problem 是否用用户语言
□ Solution 是否 fat marker（不过度细节化）
□ Rabbit Holes 是否真的提前识别（不是事后补）
□ No-gos 是否明确（不能"暂时不做"模糊化）
□ 时间到了是否真的砍范围（不是延期）
```

## 常见坑

1. **没有 Appetite，先估算**——又陷入估算地狱
2. **Solution 过度细节化**——失去了团队/工作流的发挥空间
3. **No-gos 模糊**——"暂时不做" → 应该明确"本期不做"
4. **Rabbit Holes 事后补**——失去了风险预防的意义
5. **时间到了硬延期**——破坏了 Shape Up 的核心
6. **没有 Cooldown**——永远在赶进度，技术债积累
7. **Hill Chart 用百分比**——失去了"探索 vs 执行"的区别

## 配套模板

- `templates/pitch-template.md` — Pitch 五要素模板
- `templates/hill-chart-template.md` — Hill Chart 追踪模板
- `templates/appetite-guide.md` — AI 工作流的 Appetite 选择指南

## 与其他 skill 的协作

```text
上游：
  opportunity-tree → 提供问题和方案候选
  prioritization → 决定哪个 Pitch 先做

平行：
  prd-writing → Pitch 是 PRD 的轻量替代品（适合小团队）

下游：
  Pitch 通过 → 转交项目经理（拆 Cycle 排期）
  Pitch 通过 → 直接转交开发工作流执行
```
