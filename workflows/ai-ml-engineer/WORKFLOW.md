# AI/算法工程师工作流（AI/ML Engineer Workflow）

## 定位

AI/算法工程师工作流负责在全栈交付链路中处理 **AI/机器学习相关的设计、实现、评估与部署**：LLM 集成、RAG 管道、模型训练、评估指标、推理部署。

它不替代数据分析工作流（数据探索 / 指标设计 / BI）。它负责 **AI 能力的工程化落地**——从 Prompt 到生产推理。

本工作流采用 **skills 模块化架构**。

---

## 适用场景

```text
LLM 集成（OpenAI / Anthropic / 本地模型 / Prompt 工程）
RAG 管道（向量化 / 检索 / 生成 / 评估）
模型训练（数据准备 / 训练 / 评估 / 部署）
评估指标（精确率 / 召回率 / F1 / A/B 测试）
AI 部署（推理服务 / GPU 调度 / 边缘推理 / 模型监控）
特征工程 / 数据管道
Prompt 优化 / Chain 编排
向量数据库选型与调优
模型压缩 / 量化 / 蒸馏
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 数据探索 / BI / 报表 | data-analyst |
| 需求目标不清 | product-manager |
| API 契约设计 | api-designer |
| 数据库表结构设计 | database-engineer |
| CI/CD 流水线配置 | devops-engineer |
| 安全审计 / 渗透 | security-engineer |
| 前端 UI 集成 | frontend-engineer |
| 后端业务逻辑 | backend-engineer |

---

## 输入

```text
必需：
  - 业务目标 / AI 需求描述
  - 数据来源和格式
  - 技术栈约束（Python 版本 / GPU / 云平台）
  - 验收标准（精度 / 延迟 / 成本）

可选：
  - 上游模型或 Prompt
  - 已有训练数据
  - 性能基线
  - 部署环境（K8s / Serverless / Edge）
  - 预算约束（GPU 时长 / API 调用）
```

## 输入不足时补问

```text
1. AI 需求的业务目标是什么？衡量成功的指标？
2. 数据在哪？格式、规模、标注情况？
3. 延迟、精度、成本的优先级排序？
4. 目标环境（云 / 本地 / 边缘）？GPU 可用性？
5. 是否需要持续学习 / 在线更新？
```

---

## 完整行为链

```text
1. 读取输入（业务目标 / 数据 / 约束 / 验收标准）
   ↓
2. 检查 field-journal/_index.md → 是否有同类经验
   ↓
3. 读取 skills/routing.md → 路由到需要的 skills
   ↓
4. 判断任务复杂度（S / M / L / XL）→ 选择产出粒度
   ↓
5. 加载命中的 skills → 按方法执行
   ↓
6. 实验验证（指标对比 / A/B / 回归测试）
   ↓
7. 输出交付物 + 验证结果 + 交接说明
   ↓
8. 转交下游工作流
   ↓
9. 按 EVOLUTION.md 判断 → 回写 field-journal
```

---

## Skills 模块总览

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [llm-integration](skills/llm-integration/SKILL.md) | LLM 集成 | OpenAI / Anthropic / 本地模型 / Prompt 工程 |
| [rag-pipeline](skills/rag-pipeline/SKILL.md) | RAG 管道 | 向量化 / 检索 / 生成 / 评估 |
| [model-training](skills/model-training/SKILL.md) | 模型训练 | 数据准备 / 训练 / 评估 / 部署 |
| [ml-evaluation](skills/ml-evaluation/SKILL.md) | 评估指标 | 精确率 / 召回率 / F1 / A/B |
| [ai-deployment](skills/ai-deployment/SKILL.md) | AI 部署 | 推理服务 / GPU / 边缘 / 监控 |

---

## 禁止行为

```text
❌ 不要跳过数据验证直接训练
❌ 不要用测试集调参
❌ 不要忽略推理延迟和成本
❌ 不要硬编码 API Key
❌ 不要忽略模型版本管理
❌ 不要用全量数据做首次实验
❌ 不要忽略数据漂移监控
❌ 不要在生产直接替换模型（无灰度）
❌ 不要忽略 Token 成本估算
❌ 不要把评估和训练数据混用
```

---

## 任务复杂度分级

```text
S 级（30 分钟~2 小时）：单个 Prompt 优化 / 单接口 LLM 调用
  → llm-integration

M 级（2~8 小时）：RAG 管道搭建 / 单模型微调
  → llm-integration + rag-pipeline 或 model-training

L 级（1~3 天）：完整 AI 功能（训练 + 评估 + 部署）
  → model-training + ml-evaluation + ai-deployment

XL 级（3 天+）：AI 系统架构（多模型 + 监控 + 持续学习）
  → 全部 5 skills + 跨工作流协作
```

---

## 通用质量检查

```text
□ 数据质量已验证（缺失值 / 分布 / 标注一致性）
□ 训练集 / 验证集 / 测试集正确划分
□ 指标选择与业务目标匹配
□ 基线对比已完成
□ 推理延迟满足 SLA
□ 成本估算已给出（GPU / API Token）
□ 模型版本可追溯
□ 数据漂移有监控
□ 回滚方案已确认
□ 交付物可被下游接手
□ 敏感数据 / PII 已脱敏
□ Prompt 注入防护已考虑
```

---

## 常见坑

```text
1. 数据泄露（训练数据包含测试信息）→ 指标虚高
2. 忽略 Token 成本 → 上线后账单爆炸
3. Prompt 没有版本管理 → 改坏无法回滚
4. RAG 检索质量差 → 生成结果幻觉严重
5. 模型没有灰度上线 → 一次性切换风险大
6. 只看离线指标 → 线上效果不符预期
7. GPU 资源不释放 → 浪费成本
8. 向量库索引不重建 → 检索性能退化
9. 忽略冷启动延迟 → 首次请求超时
10. 不做模型压缩 → 边缘设备跑不动
```

---

## 与其他工作流的协作

### 上游

| 上游 | AI 工程师需要的输入 |
|---|---|
| product-manager | AI 需求 + 业务目标 + 验收标准 |
| data-analyst | 数据探索报告 + 特征建议 |
| database-engineer | 数据表结构 + 查询接口 |
| api-designer | API 契约（AI 接口规格） |

### 下游

| 下游 | AI 工程师交付内容 |
|---|---|
| backend-engineer | 模型 API + SDK + 调用说明 |
| frontend-engineer | AI 功能集成指南 |
| devops-engineer | 部署配置 + 资源需求 |
| sre-operations | 监控指标 + 告警规则 |
| qa-engineer | AI 测试策略 + 评估数据集 |

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow ai-ml-engineer
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

```text
是否形成新 Prompt 模板？→ 加入 llm-integration/templates
是否发现新评估方法？→ 更新 ml-evaluation
是否遇到部署新模式？→ 更新 ai-deployment
是否遇到新坑？→ 更新 pitfalls.md
是否需要新工具？→ 更新 tool-index.md
是否有可复用经验？→ 写入 field-journal
```
