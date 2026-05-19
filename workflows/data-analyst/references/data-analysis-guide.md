# 数据分析实战指南

> 面向 APP / 小程序 / 网页产品。覆盖指标体系、SQL 分析、可视化、A/B 测试。

## 1. 产品指标体系

### 北极星指标 + AARRR

```text
┌─ 北极星指标（一个核心指标）──────────────────────────────┐
│                                                           │
│  电商：月 GMV / 月活跃买家数                              │
│  SaaS：月付费活跃用户数（Monthly Paid Active Users）     │
│  社交：日活跃用户数（DAU）                               │
│  内容：月阅读/观看时长                                    │
│  工具：周活跃使用次数                                     │
│                                                           │
│  选择标准：                                               │
│  - 反映用户获得核心价值                                   │
│  - 团队能影响（非纯外部因素）                             │
│  - 可量化可追踪                                           │
│  - 先行指标（预示未来收入）                               │
└───────────────────────────────────────────────────────────┘

┌─ AARRR 海盗指标 ─────────────────────────────────────────┐
│                                                           │
│  阶段        │ 关键指标               │ 计算              │
│  ─────────────────────────────────────────────────────── │
│  Acquisition │ 新用户注册数/下载量    │ 日/周/月          │
│  Activation  │ 激活率                 │ 完成核心动作/注册 │
│  Retention   │ 次日/7日/30日留存     │ 回访用户/同期用户 │
│  Revenue     │ ARPU / LTV / 付费转化  │ 收入/付费用户数   │
│  Referral    │ K-factor / 邀请转化    │ 邀请注册/发起邀请 │
└───────────────────────────────────────────────────────────┘
```

### 常用指标公式

```text
DAU/MAU Ratio（粘性）：
  DAU / MAU × 100%
  优秀：> 50%（如微信 70%+）
  一般：20~50%
  低频：< 20%

留存率：
  N日留存 = 第N天回访用户数 / 第0天新增用户数 × 100%

LTV（用户生命周期价值）：
  LTV = ARPU × 平均生命周期
  或 LTV = ARPU / 月流失率

CAC（获客成本）：
  CAC = 营销总成本 / 新增付费用户数
  健康标准：LTV / CAC > 3

转化漏斗：
  访问 → 注册 → 激活 → 付费
  每层转化率 = 本层用户数 / 上层用户数 × 100%
```

---

## 2. SQL 分析常用模式

### 留存分析

```sql
-- 7日留存率（PostgreSQL）
WITH cohort AS (
  SELECT 
    user_id,
    DATE(created_at) AS signup_date
  FROM users
  WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
),
activity AS (
  SELECT DISTINCT
    user_id,
    DATE(event_time) AS active_date
  FROM events
)
SELECT 
  c.signup_date,
  COUNT(DISTINCT c.user_id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN a.active_date = c.signup_date + 1 THEN c.user_id END) AS day1,
  COUNT(DISTINCT CASE WHEN a.active_date = c.signup_date + 7 THEN c.user_id END) AS day7,
  ROUND(COUNT(DISTINCT CASE WHEN a.active_date = c.signup_date + 7 THEN c.user_id END)::numeric 
    / COUNT(DISTINCT c.user_id) * 100, 2) AS retention_7d_pct
FROM cohort c
LEFT JOIN activity a ON c.user_id = a.user_id
GROUP BY c.signup_date
ORDER BY c.signup_date DESC;
```

### 漏斗分析

```sql
-- 注册→激活→付费漏斗
WITH funnel AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN event = 'register' THEN user_id END) AS step1_register,
    COUNT(DISTINCT CASE WHEN event = 'activate' THEN user_id END) AS step2_activate,
    COUNT(DISTINCT CASE WHEN event = 'purchase' THEN user_id END) AS step3_purchase
  FROM events
  WHERE event_time >= CURRENT_DATE - INTERVAL '7 days'
)
SELECT 
  step1_register,
  step2_activate,
  step3_purchase,
  ROUND(step2_activate::numeric / step1_register * 100, 1) AS reg_to_act_pct,
  ROUND(step3_purchase::numeric / step2_activate * 100, 1) AS act_to_pay_pct
FROM funnel;
```

### 分群分析（RFM）

```sql
-- RFM 用户分群
WITH rfm AS (
  SELECT 
    user_id,
    CURRENT_DATE - MAX(order_date)::date AS recency_days,
    COUNT(*) AS frequency,
    SUM(amount) AS monetary
  FROM orders
  WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
  GROUP BY user_id
)
SELECT 
  user_id,
  CASE 
    WHEN recency_days <= 7 AND frequency >= 5 AND monetary >= 1000 THEN '高价值活跃'
    WHEN recency_days <= 30 AND frequency >= 2 THEN '活跃用户'
    WHEN recency_days > 30 AND frequency >= 3 THEN '沉睡用户'
    WHEN recency_days > 60 THEN '流失用户'
    ELSE '一般用户'
  END AS user_segment
FROM rfm;
```

---

## 3. A/B 测试流程

```text
┌─ A/B 测试六步法 ─────────────────────────────────────────┐
│                                                           │
│  1. 假设 → "按钮颜色改为绿色会提升转化率 5%"             │
│  2. 样本量 → 计算所需用户数（α=0.05, power=0.8）        │
│  3. 分流 → 随机分配用户到 A/B 组（哈希分流）            │
│  4. 运行 → 运行足够时间（≥1个完整周期，通常7~14天）     │
│  5. 分析 → 统计检验（Z检验/卡方/Mann-Whitney）          │
│  6. 决策 → p<0.05 且效果有业务意义 → 全量上线           │
│                                                           │
│  常见陷阱：                                               │
│  ❌ 提前看数据就下结论（peek problem）                    │
│  ❌ 样本量不够就发布                                      │
│  ❌ 同时跑太多实验互相干扰                                │
│  ❌ 只看 p 值不看效果大小                                 │
│  ❌ 节假日/大促期间跑实验（分布异常）                     │
└───────────────────────────────────────────────────────────┘
```

### 样本量计算

```python
from statsmodels.stats.power import NormalIndPower

def sample_size(baseline: float, mde: float, alpha=0.05, power=0.80) -> int:
    """
    baseline: 当前转化率（如 0.05 = 5%）
    mde: 最小可检测效果（如 0.01 = 1个百分点提升）
    """
    import numpy as np
    effect_size = mde / np.sqrt(baseline * (1 - baseline))
    analysis = NormalIndPower()
    n = analysis.solve_power(effect_size, alpha=alpha, power=power, ratio=1)
    return int(np.ceil(n))

# 示例：当前转化率 5%，想检测 1% 提升
n = sample_size(0.05, 0.01)
# 每组需要 ~3800 用户，AB 共 ~7600 用户
```

---

## 4. 数据可视化选型

| 数据类型 | 推荐图表 | 工具 |
|----------|----------|------|
| 趋势变化 | 折线图 | ECharts / Recharts |
| 占比构成 | 饼图/环形图 | ECharts |
| 对比排名 | 柱状图 | ECharts / Recharts |
| 分布 | 直方图/箱线图 | Matplotlib / Plotly |
| 漏斗 | 漏斗图 | ECharts |
| 留存 | 留存矩阵热力图 | Seaborn / Plotly |
| 地理 | 地图 | ECharts / Mapbox |
| 关系 | 桑基图/网络图 | ECharts / D3 |
| 实时监控 | 仪表盘 | Grafana |

---

## 5. 报告模板结构

```text
## 分析报告标准结构

1. 背景与目标
   - 业务问题是什么？
   - 分析目标是什么？

2. 数据来源与口径
   - 使用了什么数据？
   - 时间范围？
   - 关键指标口径定义

3. 核心发现（不超过 3 条）
   - 用数据说话，每条配图/表

4. 详细分析
   - 按维度拆解
   - 对比/趋势/分群

5. 结论与建议
   - 明确可执行的行动项
   - 优先级排序
   - 预期影响（量化）

6. 附录
   - SQL 查询
   - 数据明细
   - 方法论说明
```

---

## 6. 常见坑

```text
1. 指标口径不统一 → 大家说的不是一回事
2. 只看均值不看分布 → 掩盖问题
3. 相关当因果 → 错误决策
4. 采样偏差 → 结论不可推广
5. 忽略季节性 → 同比/环比没意义
6. 数据清洗不够 → 垃圾进垃圾出
7. 过度解读小样本 → 随机波动当趋势
8. 不给行动建议 → 分析了等于没分析
9. 图表太花哨 → 信息淹没在装饰里
10. 不验证数据源 → 基础数据就是错的
```
