# AI Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "LLM" / "GPT" / "Prompt" / "Claude" / "对话" | [llm-integration](llm-integration/SKILL.md) |
| "RAG" / "向量" / "检索" / "知识库" / "Embedding" | [rag-pipeline](rag-pipeline/SKILL.md) |
| "训练" / "微调" / "数据集" / "PyTorch" | [model-training](model-training/SKILL.md) |
| "评估" / "指标" / "精确率" / "召回" / "F1" | [ml-evaluation](ml-evaluation/SKILL.md) |
| "部署" / "推理" / "GPU" / "TensorRT" / "ONNX" | [ai-deployment](ai-deployment/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| LLM 接入（S 级） | llm-integration |
| RAG 系统（M 级） | rag-pipeline + llm-integration + ml-evaluation |
| 模型训练（L 级） | model-training + ml-evaluation + ai-deployment |
| 完整 AI 产品（XL 级） | 全部 5 skills |

## 路由未命中

按 `CONTRIBUTING.md` 流程新增。
