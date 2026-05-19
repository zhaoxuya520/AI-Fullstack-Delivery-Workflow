# Templates 目录说明

## 当前结构（skills 架构）

具体的交付模板已迁移到对应 skill 下：

```text
workflows/product-manager/
├── templates/                    ← 跨 skill 通用模板（仅本目录）
└── skills/
    └── <skill-name>/
        └── templates/            ← 该 skill 的专属模板
```

## 各 skill 的模板入口

| 模板需求 | 位置 |
|---------|------|
| PRD / 需求评审 / 需求 brief | [prd-writing/templates/](../skills/prd-writing/templates/) |
| 用户故事 / 验收标准 | [user-story/templates/](../skills/user-story/templates/) |
| MVP 范围切分 | [mvp-scoping/templates/](../skills/mvp-scoping/templates/) |
| 优先级评分 | [prioritization/templates/](../skills/prioritization/templates/) |
| 产品发现 / 机会解决方案树 | [opportunity-tree/templates/](../skills/opportunity-tree/templates/) |
| 验证实验 PoL Probe | [pol-probe/templates/](../skills/pol-probe/templates/) |
| 产品定位声明 | [positioning/templates/](../skills/positioning/templates/) |
| Amazon PR/FAQ | [pr-faq/templates/](../skills/pr-faq/templates/) |
| Shape Up Pitch | [shape-up/templates/](../skills/shape-up/templates/) |
| HEART 指标 / 埋点 | [heart-metrics/templates/](../skills/heart-metrics/templates/) |
| 用户画像 / 用户旅程 | [customer-journey/templates/](../skills/customer-journey/templates/) |
| 产品路线图 | [roadmap/templates/](../skills/roadmap/templates/) |

## 留在本目录的跨 skill 模板

- `change-impact-template.md` — 需求变更影响评估（多 skill 协作时使用）
