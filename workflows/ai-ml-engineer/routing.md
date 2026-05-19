# AI/算法工程师工作流路由

## 触发关键词

```yaml
workflow: ai-ml-engineer
name: AI/算法工程师工作流
keywords: [AI, 机器学习, LLM, RAG, 推荐, 分类, 预测, 向量库, Embedding, PyTorch, 训练, 模型]
entry: WORKFLOW.md
skills_routing: skills/routing.md
```n
## Skills 入口

| 用户意图 | Skill |
|---------|-------|
| LLM / Prompt / GPT | llm-integration |
| RAG / 向量 / 知识库 | rag-pipeline |
| 训练 / 微调 | model-training |
| 评估 / 指标 | ml-evaluation |
| 部署 / 推理 | ai-deployment |

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 后端 API 实现 | backend-engineer |
| 数据分析 | data-analyst |
| 部署 CI/CD | devops-engineer |

## 路由未命中

返回根 `../../routing.md`。
