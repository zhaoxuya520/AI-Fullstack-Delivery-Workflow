# 产品经理工作流工具索引

## 1. 文档与模板工具

| 工具/模板 | 用途 | 位置 |
|---|---|---|
| 产品发现 Brief | 在写 PRD 前验证用户问题、目标和关键假设 | `templates/discovery-brief-template.md` |
| 机会-方案-实验树 | 把产品目标拆成机会点、方案和验证实验 | `templates/opportunity-solution-tree-template.md` |
| 用户画像和用户旅程模板 | 描述用户、阶段、痛点、机会点和异常旅程 | `templates/persona-journey-template.md` |
| PRD 模板 | 输出完整产品需求文档 | `templates/prd-template.md` |
| 需求澄清模板 | 把模糊需求问清楚 | `templates/requirement-brief-template.md` |
| MVP 范围模板 | 定义第一版边界 | `templates/mvp-scope-template.md` |
| 用户故事模板 | 拆解用户价值和功能 | `templates/user-story-template.md` |
| 验收标准模板 | 定义可测试验收条件 | `templates/acceptance-criteria-template.md` |
| 产品指标模板 | 定义目标、信号、指标、埋点和防护指标 | `templates/product-metrics-template.md` |
| 路线图模板 | 定义阶段目标、能力、指标、依赖和风险 | `templates/roadmap-template.md` |
| 需求评审模板 | 评审需求完整性和风险 | `templates/requirement-review-template.md` |
| 变更影响模板 | 分析需求变更影响范围 | `templates/change-impact-template.md` |

---

## 2. 分析方法

| 方法 | 用途 | 适用场景 |
|---|---|---|
| 5W1H | 澄清背景 | 模糊想法、老板原话、客户反馈 |
| 用户需求 | 从用户目标而非内部假设定义问题 | 服务设计、需求发现 |
| 产品发现 | 在交付前验证问题和方案 | 高不确定性需求、新产品、新功能 |
| 四类风险 | 检查价值、可用性、可行性、商业可行性 | 需求评审、发现阶段 |
| 机会-方案-实验树 | 从目标拆到机会、方案、验证 | 多方案选择、探索型需求 |
| 用户故事 | 描述用户价值 | 功能拆解、任务交接 |
| INVEST | 检查用户故事质量 | Backlog 梳理、开发前评审 |
| Given/When/Then | 写可测试验收标准 | QA 交接、自动化验收 |
| MoSCoW | 功能优先级 | MVP 切分、版本规划 |
| RICE | 定量优先级 | 多功能排序、有数据基础 |
| Kano | 体验价值分类 | 用户体验功能、满意度功能 |
| HEART | 定义产品体验指标 | 体验改进、功能上线复盘 |
| Goals-Signals-Metrics | 从目标推导指标 | 指标设计、埋点建议 |
| 用户旅程 | 串联场景 | 多页面、多角色、多步骤流程 |
| 产品路线图 | 对齐阶段目标和 Backlog | 版本规划、跨团队协作 |
| 影响地图 | 目标到功能映射 | 防止功能偏离业务目标 |
| 风险矩阵 | 标记需求风险 | 大项目、跨系统、上线前评审 |

---

## 3. 公开参考资料

| 资料 | 用途 | 位置 |
|---|---|---|
| 公开资料索引 | 记录参考来源和可复用要点 | `references/public-source-index.md` |
| 产品发现指南 | 发现阶段、四类风险、机会点、验证实验 | `references/product-discovery-guide.md` |
| 产品指标指南 | HEART、Goals-Signals-Metrics、防护指标 | `references/product-metrics-guide.md` |
| 优先级和路线图指南 | MoSCoW、RICE、Kano、路线图和 Backlog | `references/prioritization-roadmap-guide.md` |
| PRD 质量检查 | PRD 完整性和下游可交付性 | `references/prd-quality-checklist.md` |
| 下游交接指南 | 产品向各岗位工作流交付信息 | `references/handoff-guide.md` |

---

## 4. 图表工具

| 工具 | 用途 |
|---|---|
| Mermaid flowchart | 用户流程、业务流程 |
| Mermaid sequenceDiagram | 用户-系统-第三方交互 |
| Mermaid journey | 用户旅程 |
| Mermaid mindmap | 功能拆解、机会-方案-实验树 |
| Markdown 表格 | 优先级、功能清单、风险清单 |

---

## 5. 下游交接工具

| 交接对象 | 推荐交付物 |
|---|---|
| 项目经理 | 功能清单、优先级、依赖、风险、路线图 |
| UI/UX | 用户角色、场景、页面目标、用户流程、用户旅程 |
| API 设计 | 业务资源、操作、权限、异常场景 |
| 数据库 | 业务实体、关系、数据生命周期 |
| 前端 | 页面需求、交互状态、验收标准 |
| 后端 | 业务规则、权限、状态流转、异常规则 |
| QA | 主路径、异常路径、验收标准、指标口径 |
| 安全 | 权限、敏感数据、风险场景、防护指标 |
| 数据分析 | 指标定义、埋点事件、观察周期 |

---

## 6. 工具使用原则

```text
1. 高不确定需求先做产品发现，再写 PRD。
2. 先定义问题和目标，再定义功能。
3. 用户故事必须能通过 INVEST 或验收标准检查。
4. 指标必须从目标推导，不能只写访问量。
5. 路线图表达目标和阶段判断，不等于不可变承诺。
6. 涉及跨工作流任务时，用交接模板明确输入输出。
7. 每次新增有复用价值的模板，放入 templates/ 并更新本文件。
```

---

## 7. 待补充工具记录格式

```text
工具/模板名称：
用途：
适用场景：
输入：
输出：
存放位置：
是否需要同步根 tool-index：是/否
```
