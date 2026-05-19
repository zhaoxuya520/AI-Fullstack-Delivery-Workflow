# 产品经理 Skills 总控

本目录收录了产品经理工作流的所有方法论 skills。每个 skill 是独立模块，可单独加载或组合使用。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [prd-writing](prd-writing/SKILL.md) | 完整 PRD 编写（14 节标准结构） | 业界标准 |
| [user-story](user-story/SKILL.md) | 用户故事拆解（INVEST + Given/When/Then） | Mike Cohn / Gherkin |
| [mvp-scoping](mvp-scoping/SKILL.md) | MVP 范围切分（MoSCoW + 非目标） | MoSCoW 方法 |
| [prioritization](prioritization/SKILL.md) | 优先级量化评分（RICE + ICE） | Intercom RICE / Sean Ellis ICE |
| [opportunity-tree](opportunity-tree/SKILL.md) | 高不确定需求探索（OST 框架） | Teresa Torres |
| [pol-probe](pol-probe/SKILL.md) | 验证实验设计（5 种 Probe 类型） | deanpeters/Product-Manager-Skills |
| [positioning](positioning/SKILL.md) | 产品定位声明（六要素模板） | Geoffrey Moore |
| [pr-faq](pr-faq/SKILL.md) | 新产品愿景对齐（PR + FAQ） | Amazon Working Backwards |
| [shape-up](shape-up/SKILL.md) | 固定时间可变范围（Pitch + Cycle） | Basecamp / Ryan Singer |
| [heart-metrics](heart-metrics/SKILL.md) | 产品指标设计（HEART + GSM） | Google HEART Framework |
| [customer-journey](customer-journey/SKILL.md) | 用户旅程地图（5 阶段模板） | Nielsen Norman Group |
| [roadmap](roadmap/SKILL.md) | 产品路线图（Now-Next-Later / OKR） | Janna Bastow / Google OKR |

## 统一入口

遇到产品经理类任务时，按以下顺序进入：

1. 先读 `routing.md` — 按用户意图路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到一个需求 → 先判断是否清晰
   - 不清晰 → opportunity-tree（探索）
   - 清晰 → 跳过

2. 范围是否定了 → 没定 → mvp-scoping
   - 多候选不知道选哪个 → prioritization

3. 是否需要量化指标 → 是 → heart-metrics

4. 是否需要写正式文档 → 是 → prd-writing
   - 故事级别 → user-story

5. 是否需要战略对齐 → 是 → pr-faq + positioning + roadmap
```

## 新增 Skill

发现路由未命中时，按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成产品经理任务后，回写经验到 `../field-journal/`。

- 新发现的方法论 → 提议新增 skill
- 新踩到的坑 → 更新对应 skill 的"常见坑"
- 新场景 → 更新 routing.md
