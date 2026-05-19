---
name: rag-pipeline
description: |
  RAG（检索增强生成）管道全流程。覆盖文档处理、Embedding、向量存储、检索策略、
  重排序、生成优化、评估迭代、生产化部署。
  触发关键词：RAG、向量检索、Embedding、知识库、文档问答、向量数据库、
  Chunking、Reranking、Hybrid Search、语义搜索。
---

# RAG 管道（RAG Pipeline）

## 适用场景

当任务属于以下场景时使用本 skill：

- 知识库 / 文档问答系统搭建
- 向量化策略设计（Chunking / Embedding 选型）
- 向量数据库选型与调优（Pinecone / Weaviate / Qdrant / pgvector）
- 检索策略优化（Hybrid Search / Reranking / Query Expansion）
- RAG 评估与迭代（检索质量 / 生成质量 / 端到端）
- 多模态 RAG（图片 / 表格 / PDF 解析）
- Agentic RAG（动态检索 + 工具调用）

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| 文档切分 / 向量化 / 检索 / 生成 | **本 skill** |
| LLM API 调用 / Prompt 优化 | `llm-integration/` |
| 离线评估 / 基准测试 | `ml-evaluation/` |
| Embedding 模型微调 | `model-training/` |
| RAG 服务部署 / 扩缩容 | `ai-deployment/` |

---

## 核心原则

```text
1. 检索质量决定生成上限——垃圾进，垃圾出
2. Chunking 是 RAG 的灵魂——切不好，后面全白搭
3. 评估驱动迭代——用数据说话，不凭感觉
4. 混合检索 > 纯向量——关键词 + 语义互补
5. 简单方案先跑通——别一上来就上复杂架构
```

---

## RAG 架构总览

```text
┌──────────────────────────────────────────────────────────────────┐
│                        RAG Pipeline                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────┐    ┌──────────┐    ┌──────────┐    ┌────────────┐  │
│  │ 文档处理 │───→│ Embedding │───→│ 向量存储 │    │  Query 处理│  │
│  │ Ingestion│    │ 向量化   │    │ Vector DB│    │  + Routing │  │
│  └─────────┘    └──────────┘    └──────────┘    └─────┬──────┘  │
│                                        ↑                │         │
│                                        │    ┌───────────▼──────┐ │
│                                        └────│ 检索 + Reranking │ │
│                                             └───────────┬──────┘ │
│                                                         │         │
│                                             ┌───────────▼──────┐ │
│                                             │ 上下文组装 + 生成 │ │
│                                             └──────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## 工具矩阵

### 文档处理

| 工具 | 用途 | 安装/使用 |
|------|------|----------|
| **Unstructured** | PDF/DOCX/HTML 解析 | `pip install unstructured[all-docs]` |
| **LlamaParse** | 高质量 PDF 解析（表格/图片） | LlamaIndex Cloud API |
| **PyMuPDF** | 快速 PDF 文本提取 | `pip install pymupdf` |
| **Docling** | IBM 文档解析（结构化） | `pip install docling` |
| **MarkItDown** | Office → Markdown | `pip install markitdown` |

### Embedding 模型

| 模型 | 维度 | 中文 | 成本 | 推荐场景 |
|------|------|------|------|---------|
| **text-embedding-3-large** | 3072 | 良好 | $0.13/1M | 通用首选 |
| **text-embedding-3-small** | 1536 | 良好 | $0.02/1M | 低成本 |
| **BGE-M3** | 1024 | 优秀 | 免费（本地） | 中文 + 多语言 |
| **GTE-Qwen2** | 1024 | 优秀 | 免费（本地） | 中文优化 |
| **Cohere embed-v3** | 1024 | 良好 | $0.10/1M | 多语言 |
| **Jina embeddings v3** | 1024 | 优秀 | API / 本地 | 长文本 8192 token |

### 向量数据库

| 数据库 | 类型 | 适用规模 | 特色 |
|--------|------|----------|------|
| **Pinecone** | 托管 SaaS | 1B+ 向量 | 零运维、高可用 |
| **Weaviate** | 开源/托管 | 100M+ | 混合搜索原生支持 |
| **Qdrant** | 开源/托管 | 100M+ | Rust 高性能、过滤强 |
| **pgvector** | PG 扩展 | 10M 以内 | 已有 PG 生态直接用 |
| **ChromaDB** | 嵌入式 | 1M 以内 | 原型快速验证 |
| **Milvus** | 开源/托管 | 1B+ | GPU 加速、分布式 |

### 编排框架

| 工具 | 用途 | 特色 |
|------|------|------|
| **LlamaIndex** | 全功能 RAG 框架 | 管道化、可组合 |
| **LangChain** | Chain 编排 | 生态广、集成多 |
| **Haystack** | 生产级 RAG | Deepset 出品、企业友好 |

---

## 实操方法

### 1. Chunking 策略

```python
# 推荐：语义分块（按段落/标题自然边界）
from langchain.text_splitter import RecursiveCharacterTextSplitter

# 通用配置（中文优化）
splitter = RecursiveCharacterTextSplitter(
    chunk_size=512,         # Token 数（非字符数）
    chunk_overlap=64,       # 重叠防丢上下文
    separators=[
        "\n## ",           # Markdown H2 优先
        "\n### ",          # Markdown H3
        "\n\n",            # 段落分隔
        "\n",              # 换行
        "。",              # 中文句号
        ". ",              # 英文句号
        " ",               # 空格
    ],
    length_function=lambda t: len(t) // 2,  # 粗略中文 token 估算
)

chunks = splitter.split_text(document_text)
```

```text
┌─ Chunk Size 决策表 ──────────────────────────────────────┐
│                                                           │
│  文档类型        │ 推荐 chunk_size │ 推荐 overlap        │
│  ─────────────────────────────────────────────────────── │
│  技术文档        │ 512 tokens      │ 64 tokens           │
│  法律合同        │ 1024 tokens     │ 128 tokens          │
│  对话/FAQ        │ 256 tokens      │ 32 tokens           │
│  代码            │ 按函数/类切分   │ 含签名上下文        │
│  论文/学术       │ 768 tokens      │ 96 tokens           │
│                                                           │
│  原则：chunk 太大 → 噪音多；chunk 太小 → 上下文丢失      │
│  经验值：大多数场景 512 ± 128 是最优区间                   │
└───────────────────────────────────────────────────────────┘
```

### 2. Embedding + 索引

```python
# 使用 OpenAI Embedding（批量优化）
import openai
from typing import list

client = openai.OpenAI()

def batch_embed(texts: list[str], model: str = "text-embedding-3-large") -> list[list[float]]:
    """批量 embedding，自动处理 API 限制"""
    BATCH_SIZE = 2048  # OpenAI 最大批量
    all_embeddings = []
    
    for i in range(0, len(texts), BATCH_SIZE):
        batch = texts[i:i + BATCH_SIZE]
        response = client.embeddings.create(model=model, input=batch)
        all_embeddings.extend([item.embedding for item in response.data])
    
    return all_embeddings
```

```python
# 写入 Qdrant
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct

client = QdrantClient(url="http://localhost:6333")

# 创建 collection
client.create_collection(
    collection_name="knowledge_base",
    vectors_config=VectorParams(size=3072, distance=Distance.COSINE),
)

# 批量写入
points = [
    PointStruct(
        id=i,
        vector=embedding,
        payload={
            "text": chunk,
            "source": metadata["source"],
            "page": metadata["page"],
            "chunk_index": i,
        },
    )
    for i, (chunk, embedding) in enumerate(zip(chunks, embeddings))
]
client.upsert(collection_name="knowledge_base", points=points)
```

### 3. 检索策略

```python
# 混合检索（Hybrid Search）= 向量 + BM25
from qdrant_client.models import SearchRequest, FusionQuery

# 方案 A：Qdrant 原生混合搜索
results = client.query_points(
    collection_name="knowledge_base",
    query=query_embedding,            # 语义检索
    using="dense",
    query_filter=None,
    limit=20,                          # 先检索多一些
)

# 方案 B：RRF (Reciprocal Rank Fusion) 手动融合
def reciprocal_rank_fusion(
    semantic_results: list,
    keyword_results: list,
    k: int = 60,
    top_n: int = 10,
) -> list:
    """RRF 融合：语义 + 关键词结果"""
    scores = {}
    for rank, doc in enumerate(semantic_results):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (k + rank + 1)
    for rank, doc in enumerate(keyword_results):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (k + rank + 1)
    
    sorted_ids = sorted(scores, key=scores.get, reverse=True)[:top_n]
    return sorted_ids
```

### 4. Reranking（重排序）

```python
# Cohere Reranker（效果最佳）
import cohere

co = cohere.Client(api_key=os.environ["COHERE_API_KEY"])

def rerank(query: str, documents: list[str], top_n: int = 5) -> list:
    response = co.rerank(
        model="rerank-v3.5",
        query=query,
        documents=documents,
        top_n=top_n,
    )
    return [(r.index, r.relevance_score) for r in response.results]
```

```text
┌─ 检索链路推荐配置 ───────────────────────────────────────┐
│                                                           │
│  初检索 → 粗排 → 精排 → 生成                             │
│                                                           │
│  Stage 1: 向量检索 top_k=20 + BM25 top_k=20             │
│  Stage 2: RRF 融合去重 → top 15                          │
│  Stage 3: Reranker 精排 → top 5                          │
│  Stage 4: 组装 context → LLM 生成                        │
│                                                           │
│  为什么不直接 top_k=5？                                   │
│  - 向量检索 recall@5 约 60%，recall@20 约 85%            │
│  - Reranker 在大候选集上才能发挥精排价值                   │
└───────────────────────────────────────────────────────────┘
```

### 5. 生成优化

```python
# 上下文组装 + 生成
def generate_answer(query: str, contexts: list[dict]) -> str:
    """RAG 生成：带源引用"""
    context_text = "\n\n".join([
        f"[来源 {i+1}] {ctx['source']}（第{ctx['page']}页）:\n{ctx['text']}"
        for i, ctx in enumerate(contexts)
    ])
    
    system_prompt = """你是一个知识库助手。根据提供的参考文档回答问题。
规则：
1. 仅基于参考文档回答，不要编造
2. 如果文档中没有相关信息，明确说"未找到相关信息"
3. 引用来源编号，如 [来源 1]
4. 保持回答简洁准确"""
    
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"参考文档：\n{context_text}\n\n问题：{query}"},
        ],
        temperature=0.1,
    )
    return response.choices[0].message.content
```

### 6. RAG 评估

```python
# 使用 RAGAS 框架评估
from ragas import evaluate
from ragas.metrics import (
    context_precision,    # 检索到的文档与问题的相关性
    context_recall,       # 是否检索到了所有相关文档
    faithfulness,         # 生成答案是否忠实于上下文
    answer_relevancy,     # 生成答案与问题的相关性
)

# 准备评估数据集
eval_dataset = {
    "question": questions,
    "answer": generated_answers,
    "contexts": retrieved_contexts,
    "ground_truth": ground_truth_answers,
}

results = evaluate(
    dataset=eval_dataset,
    metrics=[context_precision, context_recall, faithfulness, answer_relevancy],
)
print(results)
# {'context_precision': 0.82, 'context_recall': 0.75, 'faithfulness': 0.91, 'answer_relevancy': 0.88}
```

```text
┌─ RAG 评估指标解读 ───────────────────────────────────────┐
│                                                           │
│  指标              │ 含义           │ 目标值              │
│  ─────────────────────────────────────────────────────── │
│  context_precision │ 检索精度       │ > 0.80             │
│  context_recall    │ 检索召回       │ > 0.75             │
│  faithfulness      │ 忠实度         │ > 0.90             │
│  answer_relevancy  │ 回答相关性     │ > 0.85             │
│                                                           │
│  诊断路径：                                               │
│  - faithfulness 低 → Prompt 问题或幻觉                   │
│  - context_recall 低 → 检索策略/Embedding 问题           │
│  - context_precision 低 → Chunk 太大或无关内容多         │
│  - answer_relevancy 低 → Prompt 跑偏或 context 不对     │
└───────────────────────────────────────────────────────────┘
```

---

## 向量数据库选型决策

| 决策因素 | Pinecone | Qdrant | pgvector | ChromaDB |
|----------|----------|--------|----------|----------|
| 规模 1B+ | ✅ | ✅ | ❌ | ❌ |
| 零运维 | ✅ | 部分 | ❌ | ✅ |
| 混合搜索 | ✅ | ✅ | 部分 | ❌ |
| 本地开发 | ❌ | ✅ | ✅ | ✅ |
| 过滤性能 | 良好 | 优秀 | 优秀 | 一般 |
| 成本 | 高 | 中 | 低 | 免费 |
| 推荐场景 | 企业SaaS | 通用首选 | 已有PG | 原型验证 |

---

## 生产化检查清单

```text
□ Embedding 模型版本固定（换模型需全量重建索引）
□ Chunk 元数据完整（source / page / timestamp）
□ 增量索引策略（文档更新不全量重建）
□ 检索超时设置（推荐 2s）
□ 向量库备份策略（每日快照）
□ 监控指标（检索延迟 / 空结果率 / Reranker 耗时）
□ 缓存热门查询（Redis / 语义缓存）
□ 文档权限隔离（用户只能检索其有权文档）
□ PII 脱敏（入库前过滤）
□ 索引重建 SOP（定期 / 模型升级时）
```

---

## 常见坑与解法

| # | 坑 | 症状 | 解法 |
|---|---|---|---|
| 1 | Chunk 太大 | 检索精度低，噪音多 | 减小到 512 token |
| 2 | Chunk 太小 | 上下文断裂，答案不完整 | 加 overlap + parent-child |
| 3 | 不做 Reranking | top-5 质量不稳 | 加 Cohere/BGE Reranker |
| 4 | 只用向量检索 | 精确关键词召回差 | 混合检索 (向量+BM25) |
| 5 | Embedding 模型换了不重建 | 新旧向量不兼容 | 换模型 = 全量重建 |
| 6 | 不评估就上线 | 不知道效果好坏 | RAGAS / 人工评估集 |
| 7 | 忽略文档更新 | 知识过时 | 增量管道 + TTL |
| 8 | 不设检索阈值 | 无关文档也拿来生成 | score 阈值过滤 |
| 9 | PDF 表格丢失 | 结构化信息无法检索 | LlamaParse / 专用解析 |
| 10 | 幻觉未防护 | 编造不存在的内容 | "未找到" fallback + 引用 |

---

## 与其他 skill 的协作

```text
上游：
  llm-integration → LLM API 调用 + Prompt 设计
  data-analyst → 数据探索 + 文档质量分析

下游：
  ml-evaluation → RAG 评估 + A/B 测试
  ai-deployment → RAG 服务部署 + 监控
  backend-engineer → API 集成
```

---

## 配套模板

- `templates/rag-pipeline-template.md` — RAG 方案设计模板

## 配套文件

- `references/rag-pipeline-guide.md` — 深度参考指南
