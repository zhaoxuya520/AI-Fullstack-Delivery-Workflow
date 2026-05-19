# 项目经理工作流工具索引

## 1. 模板工具

| 工具/模板 | 用途 | 位置 |
|---|---|---|
| 项目计划模板 | 输出完整交付计划 | `templates/project-plan-template.md` |
| WBS 任务分解模板 | 拆分任务、负责人、依赖和验收 | `templates/wbs-template.md` |
| 里程碑计划模板 | 定义阶段节点和门禁 | `templates/milestone-plan-template.md` |
| 任务依赖图模板 | 用 Mermaid 表达 DAG 和关键路径 | `templates/task-dag-template.md` |
| 风险登记册模板 | 管理风险、概率、影响和缓解方案 | `templates/risk-register-template.md` |
| 交付门禁模板 | 检查需求、开发、测试、上线门禁 | `templates/delivery-gate-checklist.md` |
| 工作流交接模板 | 规范上游产物、上下文和验收标准 | `templates/handoff-plan-template.md` |
| 进度报告模板 | 输出状态、阻塞、风险和下一步 | `templates/status-report-template.md` |
| 变更控制模板 | 分析变更影响和决策 | `templates/change-control-template.md` |
| 项目复盘模板 | 复盘目标、时间线、风险和经验 | `templates/retrospective-template.md` |

---

## 2. 方法工具

| 方法 | 用途 | 适用场景 |
|---|---|---|
| WBS | 把项目目标拆成可执行任务 | 任意中大型项目 |
| 依赖分析 | 识别任务先后关系 | 排期、并行判断 |
| 关键路径法 | 找到决定项目总工期的依赖链 | 多任务、多工作流项目 |
| 风险矩阵 | 判断风险优先级 | 上线前、跨系统项目 |
| 交付门禁 | 防止低质量产物流入下一阶段 | 阶段切换、发布前 |
| 变更控制 | 管理需求变更对范围、时间、风险的影响 | 需求变更、临时插单 |
| 状态机 | 跟踪 todo/in_progress/blocked/review/rework/done | 执行期管理 |
| Cycle | 用时间盒管理 AI 工作流交付节奏 | 小步快跑、多轮迭代 |
| 编排模式 | 顺序、并发、交接、动态编排 | 多工作流协同 |
| 项目复盘 | 沉淀估算、交接和风险经验 | 项目结束后 |

---

## 3. 图表工具

| 工具 | 用途 |
|---|---|
| Mermaid gantt | 甘特图和里程碑计划 |
| Mermaid flowchart | DAG、依赖关系、工作流交接 |
| Mermaid sequenceDiagram | 跨工作流交互顺序 |
| Markdown 表格 | 任务列表、风险登记册、门禁清单 |
| JSON | 自动化任务计划和工具对接 |

---

## 4. 脚本工具

| 脚本 | 用途 | 位置 |
|---|---|---|
| 项目计划检查脚本 | 检查项目计划是否包含核心章节 | `scripts/check-project-plan.ps1` |

---

## 5. 参考资料

| 资料 | 用途 | 位置 |
|---|---|---|
| 项目管理方法参考 | WBS、关键路径、风险、门禁、变更 | `references/project-methods.md` |
| 工作流编排指南 | 顺序、并发、交接、动态、混合编排 | `references/orchestration-guide.md` |
| 交付门禁指南 | 阶段门禁和上线门禁 | `references/delivery-gate-guide.md` |
| 风险和变更指南 | 风险登记、阻塞升级、变更控制 | `references/risk-change-guide.md` |
| 公开资料索引 | 外部公开方法来源 | `references/public-source-index.md` |

---

## 6. 使用原则

```text
1. 没有 PRD 或功能范围，不直接拆任务。
2. 先分析依赖，再排期。
3. 能并行的任务并行，但不能绕过契约和门禁。
4. 每个任务必须有负责工作流、依赖、工期和验收标准。
5. 每个里程碑必须有可验证门禁。
6. 变更必须先评估影响，再改计划。
7. 阻塞必须标注原因、影响和下一步，不允许沉默等待。
8. 项目结束必须复盘，并按 EVOLUTION.md 判断是否回写经验。
```
