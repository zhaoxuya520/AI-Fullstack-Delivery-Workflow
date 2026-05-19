---
name: prioritization
description: 量化排序功能/需求/实验时使用。适用于 backlog 排序、季度规划、决定先做什么。优先使用 RICE 评分（有数据时）或 ICE 评分（快速决策时）。
---

# 优先级量化评分

## 适用场景

- Backlog 太多，需要排序
- 团队对优先级有分歧
- 季度规划要从 50 个候选选 10 个
- 验证实验排序（哪个先做）

## 不适用场景

- 还在探索机会阶段（应先用 [opportunity-tree](../opportunity-tree/SKILL.md)）
- MVP 切分（应直接用 [mvp-scoping](../mvp-scoping/SKILL.md) 的 MoSCoW）
- 战略级方向选择（量化框架不能替代战略判断）

## 两个核心框架

### RICE 评分（有用户数据时优先）

参考来源：[Intercom RICE](https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/)

```text
公式：RICE = (Reach × Impact × Confidence) / Effort
```

四个因子：

| 因子 | 含义 | 评分方式 |
|------|------|---------|
| **R**each | 影响多少用户 | 具体数字（如：每月 2000 个用户） |
| **I**mpact | 对每个用户的影响程度 | 3=巨大 / 2=高 / 1=中 / 0.5=低 / 0.25=极低 |
| **C**onfidence | 估算的置信度 | 100%=有数据 / 80%=有证据 / 50%=猜测 |
| **E**ffort | 工作量 | AI 工作流以分钟数计 |

**示例：**

```text
功能 A：商品搜索功能
  Reach: 5000（每月活跃用户都会用）
  Impact: 2（高，直接影响转化）
  Confidence: 80%（竞品数据支持）
  Effort: 90 min（AI 实现）
  RICE = (5000 × 2 × 0.8) / 90 = 88.9

功能 B：商品评分系统
  Reach: 1000（只有买家会用）
  Impact: 1（中，影响决策）
  Confidence: 50%（猜测）
  Effort: 60 min
  RICE = (1000 × 1 × 0.5) / 60 = 8.3

→ 功能 A 优先（RICE 更高）
```

### ICE 评分（快速决策时优先）

参考来源：Sean Ellis（增长黑客之父）

```text
公式：ICE = Impact × Confidence × Ease
```

三个因子（每项 1~10 分）：

| 因子 | 含义 |
|------|------|
| **I**mpact | 对目标的影响 |
| **C**onfidence | 估算置信度 |
| **E**ase | 实现难度（10 = 很容易，1 = 极难） |

**适用：**
- 实验排序（A/B 测试候选）
- 增长策略快速排序
- 不需要精确用户数据时

## 使用决策树

```text
有真实用户数据吗？
  ├─ 有 → RICE
  └─ 没有 → ICE

需要排序的项目数量？
  ├─ < 10 个 → ICE 即可
  ├─ 10~30 个 → RICE 或 ICE 都可
  └─ > 30 个 → 先 ICE 粗筛，再 RICE 精排前 10

时间预算？
  ├─ 1 小时 → ICE
  └─ 半天 → RICE
```

## 工作流程

```text
1. 列出所有候选项
   ↓
2. 选择评分框架（RICE / ICE）
   ↓
3. 逐项打分
   ↓
4. 计算总分并排序
   ↓
5. 检查 Top 5 是否符合直觉
   - 符合 → 输出结果
   - 不符合 → 重新审视评分（哪里高估/低估了）
   ↓
6. 输出排序表 + 推荐执行顺序
   ↓
7. 标注前 N 项进入下一阶段
```

## 输出格式

```markdown
## 优先级评分结果（RICE）

| # | 功能 | Reach | Impact | Confidence | Effort | RICE | 排序 |
|---|------|-------|--------|------------|--------|------|------|
| 1 | 商品搜索 | 5000 | 2 | 0.8 | 90 | 88.9 | P0 |
| 2 | 用户登录优化 | 8000 | 1 | 1.0 | 60 | 133.3 | P0 |
| 3 | 商品评分 | 1000 | 1 | 0.5 | 60 | 8.3 | P2 |
| ... |

### 推荐执行顺序

P0（本期必做）：用户登录优化、商品搜索
P1（本期争取）：[排名 3-5]
P2（下期考虑）：[排名 6+]

### 评分依据

- 用户登录优化的 Reach：来自最近一周的 PV 数据
- 商品评分的 Confidence 较低：缺乏类似产品对比数据
```

## 质量自检

```text
□ 是否选对了框架（RICE 用于有数据，ICE 用于快速）
□ Reach 是否用了具体数字（不是"很多用户"）
□ Confidence 是否标注了依据（数据/证据/猜测）
□ Effort 是否包含了所有相关工作流的工作量
□ Top 5 排序是否符合直觉（不符合说明评分有问题）
□ 是否标注了 P0/P1/P2 切分线
```

## 常见坑

1. **Reach 用百分比代替绝对数**——"50% 用户" → 应该是"X 千个用户"
2. **Impact 全打 3**——所有功能都"巨大"，等于没区分
3. **Confidence 全是 100%**——掩盖了不确定性
4. **Effort 只算开发**——忘了设计/QA/部署/运维
5. **盲信公式**——RICE 是辅助，不能替代战略判断
6. **频繁调整评分凑结果**——为了让某个功能排第一反复改分
7. **不写依据**——别人无法理解和复审

## 配套模板

- `templates/rice-template.md` — RICE 评分模板
- `templates/ice-template.md` — ICE 评分模板
- `templates/prioritization-result-template.md` — 排序结果输出模板

## 与其他 skill 的协作

```text
上游：
  opportunity-tree → 提供候选机会和方案
  mvp-scoping → 提供候选功能列表

平行：
  prd-writing → 排序结果作为 PRD 第 6 节优先级依据

下游：
  转交项目经理 → 按 P0/P1/P2 拆排期
```
