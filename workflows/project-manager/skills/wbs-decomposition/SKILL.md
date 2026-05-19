---
name: wbs-decomposition
description: 把项目目标分解为可执行工作包时使用。适用于项目启动、Sprint 规划、需求拆任务。优先使用 WBS（Work Breakdown Structure）逐层分解到 5~60 分钟粒度。
---

# WBS 任务分解

## 适用场景

- 项目启动时把 PRD 拆成执行任务
- Sprint/Cycle 规划
- 复杂功能拆解为子任务
- 给工作流分派工作

## 核心原则

```text
分解到可执行粒度（不是越细越好）：
  - AI 工作流：每个任务 5~60 分钟
  - 超过 1 小时的任务继续拆
  - 不到 5 分钟的任务可以合并

每个任务必须满足：
  □ 有明确的负责工作流
  □ 有可验证的完成标准
  □ 工期可估算
  □ 输出物明确
```

## 标准 WBS 层级

```text
项目目标
  → 阶段（需求/设计/开发/测试/部署）
    → 工作流（前端/后端/QA/DevOps...）
      → 任务（具体可交付的工作单元）
        → 验收标准
```

## 任务清单模板

```markdown
| # | 任务 | 工作流 | 依赖 | 工期 | 状态 | 验收标准 |
|---|------|--------|------|------|------|---------|
| 1 | PRD 评审 | product-manager | - | 15min | done | PRD 已输出，验收标准已定义 |
| 2 | API 契约设计 | api-designer | #1 | 20min | todo | OpenAPI 文档已输出 |
| 3 | 数据库设计 | database-engineer | #1 | 15min | todo | DDL + 迁移脚本就绪 |
| 4 | 后端开发 | backend-engineer | #2, #3 | 45min | todo | 接口可调用，测试通过 |
| 5 | 前端开发 | frontend-engineer | #2 | 45min | todo | 页面可用，联调通过 |
| 6 | 联调 | fullstack-engineer | #4, #5 | 20min | todo | 端到端流程通过 |
| 7 | QA 测试 | qa-engineer | #6 | 30min | todo | 测试报告已输出 |
| 8 | 安全检查 | security-engineer | #4 | 20min | todo | 安全报告已输出 |
| 9 | 部署 | devops-engineer | #7, #8 | 15min | todo | 服务上线，健康检查通过 |
| 10 | 文档 | technical-writer | #9 | 15min | todo | README + API 文档已输出 |
```

## 任务 JSON 结构（机器可读）

```json
{
  "project": "用户管理模块",
  "tasks": [
    {
      "id": "T1",
      "name": "PRD 评审",
      "workflow": "product-manager",
      "dependencies": [],
      "estimated_minutes": 15,
      "status": "done",
      "acceptance": "PRD 已输出，验收标准已定义",
      "artifacts": ["docs/prd.md"]
    }
  ]
}
```

## 工期估算（AI 节奏）

```text
简单任务（生成单文档/单文件）：5~15 分钟
中等任务（实现一个接口/一组测试）：15~45 分钟
复杂任务（多文件联动/架构设计）：30~90 分钟
人工节点（审批/确认）：标注"等待"，不计入 AI 工期

瓶颈通常不在 AI 速度，而在：
  - 人工审批/确认
  - 外部依赖
  - 工作流间交接质量

缓冲策略：
  - 联调缓冲：15~30 分钟
  - 返工缓冲：每个里程碑后预留一轮
```

## 工作流程

```text
1. 读取 PRD/功能范围
   ↓
2. 识别需要哪些工作流参与
   ↓
3. 按阶段（需求/设计/开发/测试/部署）拆顶层任务
   ↓
4. 每个顶层任务拆到工作流粒度
   ↓
5. 每个工作流任务拆到 5~60 分钟粒度
   ↓
6. 每个任务定义验收标准
   ↓
7. 输出任务清单（含 ID、依赖、工期、负责工作流）
   ↓
8. 转交 critical-path skill 识别关键路径
```

## 质量自检

```text
□ 每个任务是否 ≤ 60 分钟（超过就继续拆）
□ 每个任务是否有明确负责工作流
□ 每个任务是否有可验证完成标准
□ 任务总数是否合理（M 级 5~10 个，L 级 10~20 个，XL 级 20+）
□ 是否标注了人工等待节点
□ 是否覆盖了所有阶段（不漏文档/部署/安全）
```

## 常见坑

1. **拆得太粗**——一个"开发后端"任务 4 小时
2. **拆得太细**——把"打开 IDE"也算成任务
3. **没有验收标准**——任务"完成"的定义模糊
4. **忘了非开发任务**——文档、测试、部署、安全
5. **把人工等待算成 AI 工期**——估算虚高
6. **不留缓冲**——联调和返工时间没预留

## 配套模板

- `templates/wbs-template.md` — 任务清单 Markdown 模板
- `templates/project-plan-template.md` — 完整项目计划模板（含里程碑和资源）
- `templates/task-json-template.json` — 机器可读 JSON 模板

## 与其他 skill 的协作

```text
上游：
  产品经理 PRD / 用户故事

下游：
  critical-path → 识别关键路径
  orchestration → 决定编排模式
  handoff-protocol → 定义交接
  progress-tracking → 追踪状态
```
