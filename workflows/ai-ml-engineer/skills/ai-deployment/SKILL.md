---
name: ai-deployment
description: AI 模型部署时使用。适用于推理服务 / GPU / TensorRT / 监控 / 扩缩容。
---

# ai-deployment

## 适用场景

- AI 模型部署时使用。适用于推理服务 / GPU / TensorRT / 监控 / 扩缩容。

## 核心原则

```text
1. 先验证可行性再工程化
2. 评估驱动迭代
3. 数据质量 > 模型复杂度
```n
## 配套模板

- `templates/ai-deployment-template.md`

## 质量自检

```text
[] 目标明确
[] 数据质量验证
[] 基线建立
[] 评估指标合理
[] 可复现
```n
## 常见坑

1. 不设基线就优化
2. 数据泄露
3. 过拟合
4. 不做离线评估就上线
5. 不监控线上效果

## 与其他 skill 的协作

```text
上游：data-analyst → 数据分析
下游：backend-engineer → API 集成
```n