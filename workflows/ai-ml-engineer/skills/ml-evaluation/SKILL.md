---
name: ml-evaluation
description: |
  模型评估全流程。覆盖分类/回归/排序/生成/RAG/LLM 评估、A/B 测试、
  在线监控、数据漂移检测、评估集构建、基准测试。
  触发关键词：评估、指标、Precision、Recall、F1、AUC、BLEU、ROUGE、
  A/B 测试、基准测试、数据漂移、模型监控、RAGAS、LLM-as-Judge。
---

# 模型评估（ML Evaluation）

## 适用场景

当任务属于以下场景时使用本 skill：

- 分类模型评估（Precision / Recall / F1 / AUC-ROC / 混淆矩阵）
- 回归模型评估（RMSE / MAE / R² / MAPE）
- 排序模型评估（NDCG / MAP / MRR）
- 生成模型评估（BLEU / ROUGE / BERTScore / Human Eval）
- LLM 评估（LLM-as-Judge / RAGAS / HELM / 人工评估）
- RAG 评估（检索精度 / 忠实度 / 相关性）
- A/B 测试设计与分析
- 在线监控（数据漂移 / 性能退化 / 异常检测）
- 评估集构建与维护

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| 模型/Prompt 评估 + 监控 | **本 skill** |
| LLM API 集成 | `llm-integration/` |
| RAG 管道搭建 | `rag-pipeline/` |
| 模型训练 / 微调 | `model-training/` |
| 部署 / 推理优化 | `ai-deployment/` |

---

## 核心原则

```text
1. 不评估 = 不知道效果——任何上线必须有评估
2. 基线是一切对比的锚点——先建 baseline 再优化
3. 离线评估 ≠ 线上效果——必须有 online metrics
4. 评估集代表生产分布——不用理想数据集自欺
5. 多维度评估——单一指标会误导决策
```

---

## 评估指标体系

### 分类任务

```text
┌─ 分类指标选择决策 ──────────────────────────────────────────┐
│                                                              │
│  场景                    │ 主指标         │ 辅助指标         │
│  ──────────────────────────────────────────────────────────  │
│  均衡分类                │ Accuracy       │ F1-macro         │
│  不均衡分类（欺诈/异常） │ F1 / PR-AUC   │ Recall@Precision │
│  排序相关（推荐/检索）   │ AUC-ROC       │ NDCG@K           │
│  多标签                  │ F1-micro      │ Hamming Loss      │
│  严重后果（医疗/安全）   │ Recall        │ Specificity       │
│                                                              │
│  黄金法则：                                                  │
│  - 正负样本均衡 → Accuracy                                  │
│  - 正负样本不均衡 → F1 或 PR-AUC                            │
│  - 关注阈值选择 → AUC-ROC                                   │
│  - 漏报代价大 → Recall 为主                                  │
│  - 误报代价大 → Precision 为主                               │
└──────────────────────────────────────────────────────────────┘
```

### LLM / 生成任务

```text
┌─ LLM 评估维度 ──────────────────────────────────────────────┐
│                                                              │
│  维度         │ 指标/方法              │ 适用场景            │
│  ──────────────────────────────────────────────────────────  │
│  忠实度       │ Faithfulness (RAGAS)   │ RAG 生成           │
│  相关性       │ Answer Relevancy       │ 问答系统           │
│  安全性       │ Toxicity / Bias 检测   │ 面向用户的 LLM     │
│  格式正确性   │ JSON Schema 校验       │ 结构化输出         │
│  指令遵循     │ Instruction Following  │ Agent / 助手       │
│  幻觉检测     │ Groundedness           │ 知识密集型任务     │
│  流畅度       │ Perplexity / 人工      │ 文本生成           │
│  创造性       │ 人工评估               │ 创意写作           │
│                                                              │
│  LLM 评估方法优先级：                                        │
│  1. 自动化指标（成本低、可扩展）                              │
│  2. LLM-as-Judge（中等成本、灵活）                           │
│  3. 人工评估（高成本、最可靠）                                │
└──────────────────────────────────────────────────────────────┘
```

---

## 工具矩阵

### 评估框架

| 工具 | 用途 | 安装 |
|------|------|------|
| **RAGAS** | RAG 端到端评估 | `pip install ragas` |
| **DeepEval** | LLM 评估框架 | `pip install deepeval` |
| **Promptfoo** | Prompt A/B 测试 | `npx promptfoo@latest` |
| **LangSmith** | 评估 + 追踪 | LangChain 生态 |
| **HELM** | 斯坦福全面基准 | 学术级评估 |

### 传统 ML 评估

| 工具 | 用途 | 安装 |
|------|------|------|
| **scikit-learn** | 分类/回归指标 | `pip install scikit-learn` |
| **scipy** | 统计检验 | `pip install scipy` |
| **statsmodels** | A/B 测试分析 | `pip install statsmodels` |

### 数据质量 & 漂移

| 工具 | 用途 | 安装 |
|------|------|------|
| **Evidently** | 数据漂移 + 模型监控 | `pip install evidently` |
| **Great Expectations** | 数据质量验证 | `pip install great-expectations` |
| **Cleanlab** | 数据标注质量 | `pip install cleanlab` |
| **NannyML** | 无标签性能估算 | `pip install nannyml` |

### 可视化

| 工具 | 用途 | 安装 |
|------|------|------|
| **Weights & Biases** | 实验对比可视化 | `pip install wandb` |
| **Matplotlib/Seaborn** | 静态图 | `pip install seaborn` |
| **Plotly** | 交互图 | `pip install plotly` |

---

## 实操方法

### 1. 分类模型完整评估

```python
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    roc_auc_score,
    precision_recall_curve,
    average_precision_score,
)
import numpy as np

def full_classification_eval(y_true, y_pred, y_prob=None):
    """分类模型全面评估"""
    
    # 1. 基础指标
    report = classification_report(y_true, y_pred, output_dict=True)
    print(classification_report(y_true, y_pred))
    
    # 2. 混淆矩阵
    cm = confusion_matrix(y_true, y_pred)
    print(f"\n混淆矩阵:\n{cm}")
    
    # 3. AUC（需要概率输出）
    if y_prob is not None:
        auc_roc = roc_auc_score(y_true, y_prob)
        auc_pr = average_precision_score(y_true, y_prob)
        print(f"\nAUC-ROC: {auc_roc:.4f}")
        print(f"AUC-PR: {auc_pr:.4f}")
    
    # 4. 阈值分析
    if y_prob is not None:
        precision, recall, thresholds = precision_recall_curve(y_true, y_prob)
        # 找 F1 最优阈值
        f1_scores = 2 * precision * recall / (precision + recall + 1e-8)
        best_idx = np.argmax(f1_scores)
        print(f"\n最优阈值: {thresholds[best_idx]:.3f} (F1={f1_scores[best_idx]:.4f})")
    
    return report
```

### 2. LLM-as-Judge 评估

```python
# 用强模型评估弱模型输出
import openai

JUDGE_PROMPT = """你是一个公正的评估专家。请评估以下 AI 回答的质量。

评估维度（每项 1-5 分）：
1. 准确性：信息是否正确、无幻觉
2. 完整性：是否回答了所有问题
3. 清晰度：表达是否清晰易懂
4. 相关性：是否与问题直接相关
5. 安全性：是否有有害/偏见内容

请以 JSON 格式输出：
{
    "accuracy": <1-5>,
    "completeness": <1-5>,
    "clarity": <1-5>,
    "relevance": <1-5>,
    "safety": <1-5>,
    "overall": <1-5>,
    "reasoning": "<评判理由>"
}

---
用户问题：{question}
AI 回答：{answer}
参考答案（可选）：{reference}
"""

def llm_judge(question: str, answer: str, reference: str = "") -> dict:
    """LLM-as-Judge 评估"""
    client = openai.OpenAI()
    
    response = client.chat.completions.create(
        model="gpt-4o",  # 用强模型做 judge
        messages=[{
            "role": "user",
            "content": JUDGE_PROMPT.format(
                question=question, answer=answer, reference=reference
            ),
        }],
        response_format={"type": "json_object"},
        temperature=0,
    )
    
    return json.loads(response.choices[0].message.content)


# 批量评估
def batch_evaluate(eval_set: list[dict], model_fn) -> dict:
    """批量评估 + 汇总"""
    scores = []
    for item in eval_set:
        answer = model_fn(item["question"])
        score = llm_judge(item["question"], answer, item.get("reference", ""))
        scores.append(score)
    
    # 汇总
    metrics = {}
    for key in ["accuracy", "completeness", "clarity", "relevance", "safety", "overall"]:
        values = [s[key] for s in scores]
        metrics[key] = {
            "mean": np.mean(values),
            "std": np.std(values),
            "min": min(values),
        }
    return metrics
```

### 3. RAG 评估（RAGAS）

```python
from ragas import evaluate
from ragas.metrics import (
    context_precision,
    context_recall,
    faithfulness,
    answer_relevancy,
    answer_correctness,
)
from datasets import Dataset

# 构建评估数据集
eval_data = {
    "question": [
        "公司的退货政策是什么？",
        "如何申请退款？",
    ],
    "answer": [
        "根据我们的政策，购买后30天内可以退货...",
        "您可以在用户中心提交退款申请...",
    ],
    "contexts": [
        ["退货政策：购买后30天内，保持原包装可退货..."],
        ["退款流程：登录用户中心 → 我的订单 → 申请退款..."],
    ],
    "ground_truth": [
        "购买后30天内可退货，需保持原包装。",
        "在用户中心的我的订单中提交退款申请。",
    ],
}

dataset = Dataset.from_dict(eval_data)

# 评估
results = evaluate(
    dataset=dataset,
    metrics=[
        context_precision,
        context_recall,
        faithfulness,
        answer_relevancy,
        answer_correctness,
    ],
)

print(results)
# 输出各维度分数
```

### 4. A/B 测试设计

```python
from scipy import stats
import numpy as np

def calculate_sample_size(
    baseline_rate: float,
    mde: float,          # Minimum Detectable Effect
    alpha: float = 0.05,
    power: float = 0.80,
) -> int:
    """计算 A/B 测试所需样本量"""
    from statsmodels.stats.power import NormalIndPower
    
    analysis = NormalIndPower()
    effect_size = mde / np.sqrt(baseline_rate * (1 - baseline_rate))
    
    n = analysis.solve_power(
        effect_size=effect_size,
        alpha=alpha,
        power=power,
        ratio=1.0,
        alternative="two-sided",
    )
    return int(np.ceil(n))


def analyze_ab_test(
    control_successes: int,
    control_total: int,
    treatment_successes: int,
    treatment_total: int,
) -> dict:
    """A/B 测试结果分析"""
    p_control = control_successes / control_total
    p_treatment = treatment_successes / treatment_total
    
    # Z 检验
    p_pooled = (control_successes + treatment_successes) / (control_total + treatment_total)
    se = np.sqrt(p_pooled * (1 - p_pooled) * (1/control_total + 1/treatment_total))
    z_stat = (p_treatment - p_control) / se
    p_value = 2 * (1 - stats.norm.cdf(abs(z_stat)))
    
    # 置信区间
    diff = p_treatment - p_control
    ci_95 = 1.96 * np.sqrt(
        p_control * (1-p_control) / control_total +
        p_treatment * (1-p_treatment) / treatment_total
    )
    
    return {
        "control_rate": p_control,
        "treatment_rate": p_treatment,
        "lift": (p_treatment - p_control) / p_control,
        "p_value": p_value,
        "significant": p_value < 0.05,
        "ci_95": (diff - ci_95, diff + ci_95),
    }
```

### 5. 数据漂移检测

```python
# 使用 Evidently 监控数据漂移
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, DataQualityPreset
import pandas as pd

def detect_drift(reference_df: pd.DataFrame, current_df: pd.DataFrame) -> dict:
    """检测数据漂移"""
    report = Report(metrics=[
        DataDriftPreset(),
        DataQualityPreset(),
    ])
    
    report.run(reference_data=reference_df, current_data=current_df)
    
    # 提取漂移结论
    result = report.as_dict()
    drift_detected = result["metrics"][0]["result"]["dataset_drift"]
    drifted_features = [
        col for col, info in result["metrics"][0]["result"]["drift_by_columns"].items()
        if info["drift_detected"]
    ]
    
    return {
        "dataset_drift": drift_detected,
        "drifted_features": drifted_features,
        "drift_share": len(drifted_features) / len(reference_df.columns),
    }
```

### 6. 评估集构建方法论

```text
┌─ 评估集构建最佳实践 ────────────────────────────────────────┐
│                                                              │
│  Step 1: 定义评估维度                                        │
│    - 功能正确性（正常场景）                                   │
│    - 边界处理（极端输入）                                     │
│    - 安全/对抗（注入/有害内容）                               │
│    - 公平性（不同群体表现一致）                               │
│                                                              │
│  Step 2: 构建数据                                            │
│    - 从生产日志采样（代表真实分布）                           │
│    - 人工构造边界 case                                       │
│    - 对抗样本（红队构造）                                     │
│    - 总量：100~500 条覆盖主要场景                            │
│                                                              │
│  Step 3: 标注                                                │
│    - 3 人交叉标注，取多数一致                                 │
│    - 计算 Cohen's Kappa（一致性 > 0.7）                      │
│    - 有争议样本专家终审                                       │
│                                                              │
│  Step 4: 维护                                                │
│    - 每月补充新 case（从 bad case 日志）                      │
│    - 版本化管理（v1.0, v1.1...）                             │
│    - 不得用于训练（严格隔离）                                 │
└──────────────────────────────────────────────────────────────┘
```

### 7. Prompt A/B 测试（Promptfoo）

```yaml
# promptfoo 配置文件 (promptfooconfig.yaml)
prompts:
  - id: prompt_v1
    raw: |
      你是一个客服助手。请用简洁的语言回答用户问题。
      问题：{{question}}
  - id: prompt_v2
    raw: |
      你是一个专业的客服助手。请按以下步骤回答：
      1. 理解问题核心
      2. 给出直接答案
      3. 补充相关建议
      问题：{{question}}

providers:
  - id: openai:gpt-4o-mini
  - id: anthropic:claude-sonnet-4-20250514

tests:
  - vars:
      question: "如何退货？"
    assert:
      - type: contains
        value: "退货"
      - type: llm-rubric
        value: "回答准确且包含具体步骤"
  - vars:
      question: "运费怎么算？"
    assert:
      - type: llm-rubric
        value: "提供了清晰的运费计算方式"
```

```bash
# 运行评估
npx promptfoo@latest eval
npx promptfoo@latest view  # 查看可视化结果
```

---

## 评估报告模板

```text
## 模型评估报告

### 基本信息
- 模型：[model_name] v[version]
- 评估日期：[date]
- 评估集版本：[eval_set_version]（[N] 条样本）
- 基线：[baseline_model]

### 核心指标
| 指标 | 基线 | 当前 | 变化 | 达标？ |
|------|------|------|------|--------|
| [metric_1] | x.xx | x.xx | +x.xx | ✅/❌ |
| [metric_2] | x.xx | x.xx | +x.xx | ✅/❌ |

### 分维度分析
- 正常场景：[score]
- 边界场景：[score]
- 对抗场景：[score]

### Bad Case 分析
| # | 输入 | 预期 | 实际 | 原因分析 |
|---|------|------|------|---------|
| 1 | ... | ... | ... | ... |

### 结论与建议
- [是否可以上线]
- [待改进方向]
- [下一步实验计划]
```

---

## 生产化检查清单

```text
□ 评估集与训练集严格隔离
□ 评估集覆盖主要场景 + 边界 + 对抗
□ 基线已建立可对比
□ 多维度评估（非单一指标）
□ 评估自动化（CI/CD 中运行）
□ 在线监控已配置（数据漂移 + 性能退化）
□ A/B 测试统计显著性已验证
□ 评估报告已归档
□ Bad case 已分析并反馈训练
□ 评估集定期更新（月度）
```

---

## 常见坑与解法

| # | 坑 | 症状 | 解法 |
|---|---|---|---|
| 1 | 评估集泄露给训练 | 指标虚高 | 严格隔离 + 数据指纹 |
| 2 | 单一指标决策 | 某维度严重缺陷 | 多维度 + 加权 |
| 3 | 评估集不代表生产 | 线上效果差 | 从生产日志采样 |
| 4 | A/B 测试样本不足 | P值不显著 | 先算 sample size |
| 5 | 忽略置信区间 | 随机波动当结论 | 报告 CI + p-value |
| 6 | 不做人工抽检 | 自动指标偏差 | 每周 50 条人工 |
| 7 | LLM Judge 偏见 | 评分不公 | 多 Judge + 校准 |
| 8 | 不监控漂移 | 模型静默退化 | Evidently 定期检测 |
| 9 | 忽略延迟/成本 | 只看质量 | 加入效率维度 |
| 10 | 评估不自动化 | 人工忘记做 | CI pipeline 强制 |

---

## 与其他 skill 的协作

```text
上游：
  model-training → 训练完的模型
  llm-integration → Prompt 优化后的方案
  rag-pipeline → RAG 管道输出

下游：
  ai-deployment → 评估通过 → 部署
  model-training → 评估不通过 → 迭代训练
  product-manager → 评估报告 → 产品决策
```

---

## 配套模板

- `templates/ml-evaluation-template.md` — 评估方案模板

## 配套文件

- `references/ml-evaluation-guide.md` — 深度参考指南
