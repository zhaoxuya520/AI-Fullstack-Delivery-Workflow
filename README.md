# AI Full-stack Delivery Workflow

## 项目定位

`AI Full-stack Delivery Workflow` 是一个面向完整软件项目交付的 **AI 集合工作流总控系统**。

它不是单个岗位 Skill，而是一个 **项目交付总控 + 多岗位工作流集合**：总控负责识别任务、选择工作流、检查输入、调用工具、验证结果和沉淀经验；每个技术岗位都是一个独立工作流。

## 总体架构

```text
AI Full-stack Delivery Workflow
├─ README.md                 # 项目入口
├─ WORKFLOW.md               # 完整生命周期说明
├─ routing.md                # 总控路由规则
├─ RULES.md                  # 全局执行硬规则
├─ EVOLUTION.md              # 全局自进化协议
├─ workflow-map.md           # 工作流协作关系
├─ tool-index.md             # 全局工具索引
├─ CONTRIBUTING.md           # 新增/维护工作流规范
├─ workflows/                # 岗位工作流集合
├─ templates/                # 输入、验收、报告模板
├─ field-journal/            # 经验沉淀
└─ scripts/                  # 后续自动化脚本
```

## 岗位工作流集合

| 工作流 | 成熟度 | Skills | 入口 |
|--------|--------|--------|------|
| 产品经理工作流 | ready | 12 skills | `workflows/product-manager/WORKFLOW.md` |
| 项目经理工作流 | ready | 12 skills | `workflows/project-manager/WORKFLOW.md` |
| UI/UX 设计工作流 | ready | 14 skills | `workflows/ui-ux-designer/WORKFLOW.md` |
| API 设计工作流 | ready | 10 skills | `workflows/api-designer/WORKFLOW.md` |
| 前端工程师工作流 | ready | 10 skills | `workflows/frontend-engineer/WORKFLOW.md` |
| 后端工程师工作流 | ready | 10 skills | `workflows/backend-engineer/WORKFLOW.md` |
| 全栈工程师工作流 | ready | 6 skills | `workflows/fullstack-engineer/WORKFLOW.md` |
| 数据库工程师工作流 | ready | 6 skills | `workflows/database-engineer/WORKFLOW.md` |
| 测试工程师工作流 | ready | 12 skills | `workflows/qa-engineer/WORKFLOW.md` |
| 自动化测试工作流 | ready | 5 skills | `workflows/automation-qa/WORKFLOW.md` |
| DevOps 工程师工作流 | ready | 8 skills | `workflows/devops-engineer/WORKFLOW.md` |
| SRE/运维工作流 | ready | 6 skills | `workflows/sre-operations/WORKFLOW.md` |
| 安全工程师工作流 | ready | 5 skills | `workflows/security-engineer/WORKFLOW.md` |
| 逆向/渗透工作流 | ready | 14 模块 + 40+ CTF | `workflows/reverse-pentest/WORKFLOW.md` |
| 数据分析工作流 | ready | 5 skills | `workflows/data-analyst/WORKFLOW.md` |
| AI 集成工程师工作流 | ready | 5 skills | `workflows/ai-ml-engineer/WORKFLOW.md` |
| 技术文档工作流 | ready | 5 skills | `workflows/technical-writer/WORKFLOW.md` |

全部 17 个工作流已就绪，均具备：WORKFLOW.md + skills/ + tool-index.json + references/ + 自举支持。

不纳入本项目的非技术商业/支持岗位：客服/技术支持、运营、商务/销售、法务/合规。

## 单个工作流标准结构

每个岗位工作流都采用和逆向工作流同类的统一结构：

```text
workflows/<workflow-name>/
├─ WORKFLOW.md
├─ EVOLUTION.md
├─ routing.md
├─ tool-index.md
├─ pitfalls.md
├─ templates/
├─ references/
├─ scripts/
└─ field-journal/
   ├─ _index.md
   └─ _template.md
```

`reverse-pentest` 内置技能库提供 14 个技能模块和 40+ CTF 子技能：

```text
workflows/reverse-pentest/reverse-skill-private/skills/
```

可重复运行 `scripts/standardize-workflows.ps1` 为新增工作流补齐标准结构。

## 标准执行链路

```text
Input → Classify → Route → Execute → Verify → Document → Learn
```

1. 接收任务输入
2. 判断任务类型和缺失材料
3. 根据 `routing.md` 路由到岗位工作流
4. 读取对应 `workflows/<role>/WORKFLOW.md`
5. 检查工具、环境和项目上下文
6. 执行设计、开发、测试、安全验证或部署
7. 按 `templates/delivery-acceptance-criteria.md` 验收
8. 生成文档或报告
9. 按 `EVOLUTION.md` 执行自进化检查
10. 回写 `field-journal/`，必要时更新 routing/tool-index/pitfalls/templates/references/scripts

## 快速开始（AI 自举流程）

AI 首次进入本工作流时，按以下步骤自动配置：

```text
1. 读取本 README.md（你正在做的事）
2. 读取 routing.md → 识别任务属于哪个工作流
3. 进入对应 workflows/<role>/WORKFLOW.md
4. 读取该工作流的 tool-index.md / tool-index.json → 确认工具状态
5. 如果缺工具 → 调用 scripts/bootstrap-project.ps1 -Workflow <name> 自动安装
6. 如果安装失败 2 次 → 输出结构化手动引导，等用户确认
7. 开始执行任务
```

---

## 完整行为链（硬性流程，不可跳过）

```text
1. 读取本 README.md → 理解总控系统架构
   ↓
2. 读取 RULES.md → 加载全局硬规则
   ↓
3. 接收用户任务输入
   ↓
4. 检查输入完整性 → 缺关键信息先补问（不要猜）
   ↓
5. 读取 routing.md → 按关键词/意图/产物匹配目标工作流
   ↓
6. 检查 field-journal/_index.md → 是否有同类经验可复用
   ↓
7. 进入对应 workflows/<role>/WORKFLOW.md → 读取该角色完整流程
   ↓
8. 读取该工作流 tool-index.json → 确认工具可用
   ↓
9. 缺工具 → 调用 bootstrap-project.ps1 自动补齐
   ↓
10. 如自动补齐失败（2次）→ 输出结构化手动安装引导，等用户确认
    ↓
11. 读取 skills/routing.md → 路由到具体 skill 模块
    ↓
12. 加载对应 SKILL.md + references/ → 获取方法论 + 工具命令 + 代码范式
    ↓
13. 执行任务（设计/编码/测试/部署/分析/文档）
    ↓
14. 执行中遇到困难 → 换路径（不死磕一条路）
    ↓
15. 执行中持续向用户汇报进展
    ↓
16. 任务完成 → 按 templates/delivery-acceptance-criteria.md 验收
    ↓
17. 按 EVOLUTION.md 自进化检查
    ↓
18. 回写 field-journal（脱敏），更新 routing/tool-index/pitfalls（如需）
```

---

## 禁止行为

```text
❌ 不要跳过 routing.md 直接猜工作流
❌ 不要在输入不足时直接开始执行（先补问）
❌ 不要猜测工具路径或版本号（从 tool-index 获取）
❌ 不要跳过 field-journal 查询直接开始
❌ 不要在任务完成后跳过验收和经验沉淀
❌ 不要同一条路失败 2 次还继续（换方案）
❌ 不要沉默——遇到问题必须立即告知用户
❌ 不要在未确认授权时执行安全/渗透操作
❌ 不要硬编码密钥、Token、密码
❌ 不要跳过 Code Review
```

---

### 手动使用

```powershell
# 检测所有工作流工具状态（仅检测，不安装）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-project.ps1 -Check

# 安装指定工作流所需工具
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-project.ps1 -Workflow frontend-engineer

# 安装全部工作流工具
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-project.ps1
```

### 工具清单管理

- `scripts/bootstrap-manifest.json` — 所有工作流所需工具的机器可读清单
- `scripts/bootstrap-project.ps1` — 项目级自举脚本（不修改全局环境）
- 每个工作流目录下有 `tool-index.md`（人可读）和 `tool-index.json`（机器可读）

### 任务执行

1. 用 `templates/task-input-template.md` 描述任务。
2. 用 `routing.md` 判断进入哪个工作流。
3. 按对应 `workflows/<role>/WORKFLOW.md` 执行。
4. 用 `templates/delivery-acceptance-criteria.md` 检查交付。
5. 任务完成后按 `field-journal/_template.md` 回写经验。

## 多工作流协同

单任务只进一个工作流。跨层任务按生命周期顺序串联：

```text
新功能开发：
  产品经理 → 项目经理 → UI/UX → API 设计 → 数据库 → 后端 → 前端 → QA → DevOps → 文档

Bug 修复：
  QA → 前端/后端 → 自动化测试 → DevOps

安全检查：
  安全工程师 → 逆向/渗透 → 后端/前端修复 → QA 回归 → DevOps

AI 功能集成：
  产品经理 → AI 集成工程师 → 后端 → 前端 → QA
```

详见 `workflow-map.md` 和 `WORKFLOW.md`。

## 关键文档

- [WORKFLOW.md](WORKFLOW.md) — 完整项目生命周期
- [routing.md](routing.md) — 总控路由规则
- [RULES.md](RULES.md) — 全局执行规则
- [EVOLUTION.md](EVOLUTION.md) — 全局自进化协议
- [workflow-map.md](workflow-map.md) — 工作流协作图
- [tool-index.md](tool-index.md) — 工具索引
- [任务输入模板](templates/task-input-template.md)
- [交付验收标准](templates/delivery-acceptance-criteria.md)
- [经验沉淀模板](field-journal/_template.md)
