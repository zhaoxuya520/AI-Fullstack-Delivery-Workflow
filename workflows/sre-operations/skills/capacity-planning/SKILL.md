---
name: capacity-planning
description: 容量规划时使用。适用于扩缩容决策、大促准备、成本优化、资源预测。融合 Google SRE Capacity Planning + 负载测试 + 成本模型。
---

# 容量规划（Capacity Planning）

## 适用场景

- 大促 / 活动前容量评估
- 日常扩缩容决策
- 成本优化
- 新服务资源预估
- 年度容量预算

## 核心原则

```text
1. 数据驱动
   基于历史指标预测，不靠猜

2. Buffer 预留
   目标利用率 60~70%，不是 100%

3. 瓶颈优先
   找最先压垮的资源

4. 成本感知
   扩容有成本，不是越多越好

5. 定期评审
   每月 / 每季度回顾
```

## 容量评估公式

```text
所需实例 = 峰值 QPS / 单实例 QPS × Buffer

示例：
  峰值 QPS = 10000
  单实例 QPS = 500（压测得出）
  Buffer = 1.5（50% 余量）
  
  实例数 = 10000 / 500 × 1.5 = 30

按 N+2 容灾：
  实际部署 = 32
```

## 工作流程

```text
1. 收集当前指标
   - CPU / Memory / QPS / 连接数
   - 历史峰值
   - 增长趋势

2. 预测未来负载
   - 线性增长 / 季节性
   - 大促倍数

3. 压测单实例容量
   - k6 / JMeter
   - 找拐点

4. 计算所需资源

5. 成本评估

6. 扩缩容方案
   - 手动 / HPA / KEDA

7. 验证（压测）

8. 文档化
```

## 配套模板

- `templates/capacity-plan-template.md` — 容量评估 + 预测 + 成本 + 方案

## 质量自检

```text
□ 基于数据（不靠猜）
□ 压测验证
□ Buffer 预留（50%+）
□ 成本评估
□ 扩缩容方案
□ 定期评审
□ 大促提前准备
□ 瓶颈识别
```

## 常见坑

1. **不压测就预估**——数字不可信
2. **利用率 100%**——没有 buffer
3. **只看 CPU**——可能瓶颈在连接池
4. **不考虑成本**——过度扩容
5. **不定期评审**——资源浪费

## 与其他 skill 的协作

```text
上游：
  devops-engineer monitoring-alerting → 指标数据
  
下游：
  devops-engineer kubernetes-orchestration → HPA 配置
  devops-engineer infrastructure-as-code → 资源申请
```
