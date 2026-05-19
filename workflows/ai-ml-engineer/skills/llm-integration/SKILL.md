---
name: llm-integration
description: |
  LLM 集成全流程。覆盖 OpenAI / Anthropic / Google / 开源模型接入、Prompt 工程、
  Function Calling、Agent 编排、Token 优化、安全防护、生产化部署。
  触发关键词：LLM、GPT、Claude、Gemini、Prompt、Function Calling、Tool Use、
  Agent、Chain、Structured Output、Streaming、Token、Rate Limit。
---

# LLM 集成（LLM Integration）

## 适用场景

当任务属于以下场景时使用本 skill：

- LLM API 接入（OpenAI / Anthropic / Google / 本地模型）
- Prompt 工程（System Prompt / Few-shot / Chain-of-Thought / Structured Output）
- Function Calling / Tool Use 设计与实现
- Agent 编排（多步推理 / 工具调用链 / 自主规划）
- Token 优化（成本控制 / 上下文压缩 / 缓存策略）
- 安全防护（Prompt 注入防御 / 输出过滤 / 权限隔离）
- 流式输出 / Server-Sent Events 集成

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| LLM API 调用 / Prompt 设计 / Agent 编排 | **本 skill** |
| 向量检索 + LLM 生成（RAG） | `rag-pipeline/` |
| 模型微调 / LoRA / 全量训练 | `model-training/` |
| 离线评估 / A/B 测试 / 基准测试 | `ml-evaluation/` |
| 推理服务部署 / GPU 调度 | `ai-deployment/` |

---

## 核心原则

```text
1. Prompt 即代码——版本管理、Code Review、回归测试
2. 先基线再优化——用最简方案建立 baseline，再迭代
3. 成本即架构决策——Token 用量直接影响产品可行性
4. 防御性设计——所有用户输入都可能是攻击
5. 可观测性优先——每次调用都要有 trace
```

---

## 模型选型决策表

| 需求特征 | 推荐模型 | 理由 |
|----------|----------|------|
| 最高智能 + 复杂推理 | Claude Opus / GPT-4o | 推理质量最佳 |
| 高速 + 低成本 | Claude Haiku / GPT-4o-mini | 延迟低、成本 1/10 |
| 长上下文（128K+） | Claude / Gemini 1.5 Pro | 原生支持长文档 |
| 本地部署 / 数据隐私 | Llama 3.1 70B / Qwen2 72B | 开源可控 |
| 多模态（图像+文本） | GPT-4o / Claude Opus / Gemini | 原生多模态 |
| 代码生成 | Claude Opus / GPT-4o / DeepSeek Coder | 代码特化 |
| 中文优化 | Qwen2 / GLM-4 / DeepSeek | 中文训练充分 |
| 边缘/嵌入式 | Phi-3 Mini / Llama 3.2 1B | 参数少、可量化 |

---

## 工具矩阵

### LLM API SDK

| 工具 | 用途 | 安装命令 |
|------|------|---------|
| **openai** | OpenAI 官方 SDK | `pip install openai` |
| **anthropic** | Anthropic 官方 SDK | `pip install anthropic` |
| **google-genai** | Google Gemini SDK | `pip install google-generativeai` |
| **litellm** | 统一多模型接口 | `pip install litellm` |
| **ollama** | 本地模型运行 | `curl -fsSL https://ollama.com/install.sh \| sh` |

### 编排框架

| 工具 | 用途 | 适用场景 |
|------|------|---------|
| **LangChain** | Chain / Agent / Tool 编排 | 复杂多步 Agent |
| **LlamaIndex** | 数据索引 + LLM 查询 | 知识库问答 |
| **Semantic Kernel** | .NET / Python 混合 Agent | 企业 .NET 项目 |
| **CrewAI** | 多 Agent 协作 | 多角色任务分工 |
| **Autogen** | 多 Agent 对话 | 研究型自主 Agent |

### 可观测性

| 工具 | 用途 | 集成方式 |
|------|------|---------|
| **LangSmith** | LLM 调用追踪 + 评估 | LangChain 原生 |
| **Langfuse** | 开源 LLM Observability | OpenTelemetry |
| **Helicone** | 代理层日志 + 缓存 | HTTP 代理 |
| **Weights & Biases** | 实验追踪 | Python SDK |

---

## 实操方法

### 1. 基础 API 调用模式

```python
# OpenAI 标准调用（含重试 + 超时 + 结构化输出）
import openai
from tenacity import retry, stop_after_attempt, wait_exponential

client = openai.OpenAI(
    api_key=os.environ["OPENAI_API_KEY"],
    timeout=30.0,
    max_retries=3,
)

@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=10))
def call_llm(messages: list[dict], model: str = "gpt-4o") -> str:
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=0.1,
        max_tokens=4096,
    )
    return response.choices[0].message.content
```

```python
# Anthropic 调用（含流式输出）
import anthropic

client = anthropic.Anthropic()

def stream_claude(prompt: str, system: str = ""):
    with client.messages.stream(
        model="claude-sonnet-4-20250514",
        max_tokens=4096,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    ) as stream:
        for text in stream.text_stream:
            yield text
```

### 2. Structured Output（结构化输出）

```python
# OpenAI 结构化输出（JSON Schema 强制）
from pydantic import BaseModel

class ProductReview(BaseModel):
    sentiment: str  # positive / negative / neutral
    confidence: float
    key_points: list[str]
    suggested_action: str

response = client.beta.chat.completions.parse(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "分析用户评价，输出结构化结果。"},
        {"role": "user", "content": user_review},
    ],
    response_format=ProductReview,
)
result: ProductReview = response.choices[0].message.parsed
```

### 3. Function Calling / Tool Use

```python
# 定义工具 schema
tools = [
    {
        "type": "function",
        "function": {
            "name": "search_knowledge_base",
            "description": "搜索内部知识库获取相关文档",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "搜索关键词"},
                    "top_k": {"type": "integer", "default": 5},
                    "filters": {
                        "type": "object",
                        "properties": {
                            "department": {"type": "string"},
                            "date_after": {"type": "string", "format": "date"},
                        },
                    },
                },
                "required": ["query"],
            },
        },
    }
]

# 调用并处理 tool_calls
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    tools=tools,
    tool_choice="auto",
)

if response.choices[0].message.tool_calls:
    for tool_call in response.choices[0].message.tool_calls:
        func_name = tool_call.function.name
        args = json.loads(tool_call.function.arguments)
        result = execute_tool(func_name, args)
        # 回传结果继续对话
        messages.append(response.choices[0].message)
        messages.append({
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps(result),
        })
```

### 4. Prompt 工程范式

```text
┌─────────────────────────────────────────────────────────┐
│ System Prompt 分层结构                                   │
├─────────────────────────────────────────────────────────┤
│ Layer 1: 角色定义（Who）                                 │
│   "你是一个专业的金融分析师..."                           │
│                                                         │
│ Layer 2: 能力边界（What）                                │
│   "你可以：分析财报、计算估值..."                         │
│   "你不可以：给出投资建议..."                             │
│                                                         │
│ Layer 3: 输出格式（How）                                 │
│   "使用 JSON 格式输出，包含字段..."                       │
│                                                         │
│ Layer 4: 约束 & 安全（Guard）                            │
│   "拒绝回答非金融问题..."                                │
│   "不输出个人隐私信息..."                                │
└─────────────────────────────────────────────────────────┘
```

### 5. Prompt 注入防御

```python
# 多层防御策略
class PromptGuard:
    def __init__(self):
        self.blocklist = [
            "ignore previous",
            "disregard above",
            "system prompt",
            "你的指令是",
            "忽略上面",
        ]
    
    def sanitize_input(self, user_input: str) -> str:
        """Layer 1: 输入过滤"""
        lower = user_input.lower()
        for pattern in self.blocklist:
            if pattern in lower:
                raise PromptInjectionError(f"检测到潜在注入: {pattern}")
        return user_input
    
    def wrap_user_input(self, user_input: str) -> str:
        """Layer 2: 输入隔离（XML 标签包裹）"""
        return f"<user_input>\n{user_input}\n</user_input>"
    
    def validate_output(self, output: str, allowed_format: str) -> bool:
        """Layer 3: 输出校验"""
        # 检查输出是否符合预期格式
        if allowed_format == "json":
            try:
                json.loads(output)
                return True
            except json.JSONDecodeError:
                return False
        return True
```

### 6. Token 成本优化

```text
┌─ 成本优化决策树 ────────────────────────────────────────┐
│                                                         │
│  请求特征 → 策略选择                                    │
│                                                         │
│  重复相同输入？ → Semantic Cache（命中率 30-60%）         │
│  上下文太长？  → Context Compression（保留关键信息）     │
│  简单任务？    → 小模型先试（Haiku/4o-mini）            │
│  批量处理？    → Batch API（50% 折扣，24h 内完成）      │
│  高频低变？    → Prompt Caching（Anthropic/OpenAI）     │
│                                                         │
│  大厂范式：                                             │
│  - Anthropic Prompt Caching: system prompt 缓存 90% 折扣 │
│  - OpenAI Batch API: 批量请求 50% 折扣                  │
│  - Router 模式: 简单→小模型，复杂→大模型                │
└─────────────────────────────────────────────────────────┘
```

```python
# 模型路由器实现
class ModelRouter:
    """根据任务复杂度自动选择模型，节省 60-80% 成本"""
    
    def __init__(self):
        self.classifier = self._load_classifier()
    
    def route(self, messages: list[dict]) -> str:
        complexity = self._estimate_complexity(messages)
        if complexity == "simple":
            return "gpt-4o-mini"  # $0.15/1M input
        elif complexity == "medium":
            return "claude-sonnet-4-20250514"  # $3/1M input
        else:
            return "claude-opus-4-20250514"  # $15/1M input
    
    def _estimate_complexity(self, messages: list[dict]) -> str:
        """基于消息长度、工具需求、推理深度评估"""
        total_tokens = sum(len(m["content"]) // 4 for m in messages)
        has_tools = any("tool" in str(m) for m in messages)
        if total_tokens < 500 and not has_tools:
            return "simple"
        elif total_tokens < 2000:
            return "medium"
        return "complex"
```

### 7. Agent 编排模式

```python
# ReAct Agent 模式（推理 + 行动循环）
class ReActAgent:
    def __init__(self, tools: list, model: str = "gpt-4o"):
        self.tools = {t["function"]["name"]: t for t in tools}
        self.model = model
        self.max_steps = 10
    
    async def run(self, task: str) -> str:
        messages = [
            {"role": "system", "content": REACT_SYSTEM_PROMPT},
            {"role": "user", "content": task},
        ]
        
        for step in range(self.max_steps):
            response = await self._call_llm(messages)
            
            if response.tool_calls:
                # 执行工具
                for call in response.tool_calls:
                    result = await self._execute_tool(call)
                    messages.append({"role": "tool", "content": result})
            else:
                # 最终回答
                return response.content
        
        return "达到最大步数限制，请拆分任务。"
```

---

## 生产化检查清单

```text
□ API Key 通过环境变量 / Secret Manager 注入（非硬编码）
□ 设置合理的 timeout（推荐 30s 普通 / 120s Agent）
□ 实现指数退避重试（429 / 500 / 503）
□ 配置 Rate Limit 管理（令牌桶 / 滑动窗口）
□ 流式输出用 SSE（改善用户体验）
□ 所有调用有 trace_id（可追踪调用链）
□ Prompt 版本化存储（Git / Prompt Registry）
□ 输入/输出 token 计数 → 成本监控
□ Prompt 注入防御（输入过滤 + 输出校验）
□ 敏感信息脱敏（PII 不进 LLM）
□ 模型降级策略（主模型不可用时切备用）
□ 响应质量采样评估（每日 5% 人工审核）
```

---

## 常见坑与解法

| # | 坑 | 症状 | 解法 |
|---|---|---|---|
| 1 | Prompt 没版本管理 | 改坏无法回滚 | Git 管理 + Prompt Registry |
| 2 | 不设 timeout | 卡死整个请求链 | 设 30s timeout + circuit breaker |
| 3 | 忽略 429 重试 | 高并发直接挂 | tenacity + exponential backoff |
| 4 | Token 不计数 | 月底账单爆炸 | 每次调用记录 usage |
| 5 | 硬编码模型名 | 换模型改 N 处 | 配置化 + 模型路由 |
| 6 | 忽略幻觉 | 输出事实错误 | Grounding + 检索增强 + 校验 |
| 7 | 长 prompt 不缓存 | 重复计费 | Anthropic Prompt Caching |
| 8 | Agent 无限循环 | 步数失控 | max_steps + 成本熔断 |
| 9 | 不做输出校验 | 格式随机变 | Structured Output + Pydantic |
| 10 | 忽略冷启动 | 首请求超时 | 预热 + 连接池复用 |

---

## 大厂实战案例

### Stripe: LLM 驱动的文档问答

```text
架构：User Query → Router → (Simple: Haiku | Complex: Opus) → RAG 增强 → 结构化回答
关键决策：
- 用 Router 模型做分流，70% 请求用小模型，成本降 60%
- 所有回答附带源文档引用（降低幻觉）
- Prompt 缓存命中率 45%，再降 40% 成本
```

### Notion: AI 写作助手

```text
架构：User Intent → Prompt Template Engine → Streaming LLM → Client Render
关键决策：
- 流式输出（首 token 200ms 内）
- 上下文窗口管理：只传当前 block ± 3 段
- 多级 Prompt：outline → draft → polish
```

### Cursor: 代码补全 + 编辑

```text
架构：Code Context → Fill-in-Middle Prompt → Speculative Decode → Inline Diff
关键决策：
- 用 FIM（Fill-in-Middle）格式构建 Prompt
- Speculative Decoding 加速生成
- 上下文排序：当前文件 > 导入文件 > 相似文件
```

---

## 与其他 skill 的协作

```text
上游：
  product-manager → AI 需求 + 用户场景
  api-designer → API 契约（LLM 接口规格）

下游：
  rag-pipeline → 当需要检索增强时
  ml-evaluation → Prompt A/B 测试 + 质量评估
  ai-deployment → 生产部署 + 监控
  backend-engineer → API 集成 + 业务逻辑
```

---

## 配套模板

- `templates/llm-integration-template.md` — 集成方案模板

## 配套文件

- `references/llm-integration-guide.md` — 深度参考指南
