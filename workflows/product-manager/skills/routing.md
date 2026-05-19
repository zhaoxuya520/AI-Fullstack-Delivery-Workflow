# 产品经理 Skills 路由矩阵

按用户意图、任务场景和期望产物，将任务路由到最合适的 skill。

---

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "帮我写 PRD" | [prd-writing](prd-writing/SKILL.md) |
| "拆成用户故事" | [user-story](user-story/SKILL.md) |
| "MVP 应该做什么" | [mvp-scoping](mvp-scoping/SKILL.md) |
| "怎么排优先级" | [prioritization](prioritization/SKILL.md) |
| "用户为什么需要这个" / "搞清楚需求" | [opportunity-tree](opportunity-tree/SKILL.md) |
| "先验证一下再做" / "做个原型" | [pol-probe](pol-probe/SKILL.md) |
| "我们做的是什么产品" / "怎么定位" | [positioning](positioning/SKILL.md) |
| "对齐一下产品愿景" / "新产品想法" | [pr-faq](pr-faq/SKILL.md) |
| "怎么排周期 / 控制范围" | [shape-up](shape-up/SKILL.md) |
| "怎么衡量成功" / "定指标" | [heart-metrics](heart-metrics/SKILL.md) |
| "用户怎么用我们的产品" | [customer-journey](customer-journey/SKILL.md) |
| "下半年做什么" / "路线图" | [roadmap](roadmap/SKILL.md) |

---

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 新产品从零定义 | pr-faq → positioning → opportunity-tree → mvp-scoping → prd-writing → roadmap |
| 已有产品新功能 | opportunity-tree → mvp-scoping → user-story → prd-writing → heart-metrics |
| 验证想法是否可行 | opportunity-tree → pol-probe |
| 完整需求文档输出 | prd-writing + user-story + heart-metrics |
| 决定先做什么 | prioritization + mvp-scoping |
| 季度规划 | roadmap + heart-metrics + prioritization |
| 需求变更评估 | prd-writing 的变更控制章节 |

---

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 5~15min | user-story（单条故事 + 验收标准） |
| M | 15~45min | prd-writing + user-story + mvp-scoping |
| L | 45~120min | prd-writing + opportunity-tree + heart-metrics + customer-journey |
| XL | 2h+ | pr-faq + positioning + opportunity-tree + roadmap + prd-writing |

---

## 路径交叉（跨 skill 场景）

```text
高不确定需求路径：
  opportunity-tree（探索机会）
  → pol-probe（验证假设）
  → mvp-scoping（确定范围）
  → prd-writing（输出 PRD）

成熟产品迭代路径：
  user-story（拆解需求）
  → prioritization（排优先级）
  → prd-writing（输出 PRD）
  → heart-metrics（定指标）

战略级规划路径：
  pr-faq（愿景对齐）
  → positioning（产品定位）
  → roadmap（阶段规划）
  → opportunity-tree（每个阶段的机会）

执行级交付路径：
  prd-writing（PRD）
  → user-story（用户故事）
  → heart-metrics（成功指标）
  → 转交项目经理拆排期
```

---

## 路由未命中处理

如果用户的请求在以上表格中都找不到匹配，按以下流程处理：

1. 先确认是否属于现有 skill 的边缘场景
2. 如果是全新类型，主动向用户提议新增 skill
3. 用户确认后，按 [CONTRIBUTING.md](CONTRIBUTING.md) 流程新增

新增 skill 后必须更新本路由矩阵。
