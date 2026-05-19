# 数据分析 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "指标" / "北极星" / "AARRR" / "漏斗" / "GSM" / "指标体系" | [metric-design](metric-design/SKILL.md) |
| "SQL" / "查询" / "聚合" / "窗口函数" / "CTE" / "数据提取" | [sql-analysis](sql-analysis/SKILL.md) |
| "A/B 测试" / "实验" / "假设检验" / "显著性" / "样本量" / "置信度" | [ab-testing](ab-testing/SKILL.md) |
| "图表" / "仪表盘" / "可视化" / "Dashboard" / "看板" / "BI" | [data-visualization](data-visualization/SKILL.md) |
| "报告" / "洞察" / "分析报告" / "建议" / "复盘" / "汇报" | [analysis-report](analysis-report/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单指标查询（S 级） | sql-analysis |
| 单主题分析（M 级） | metric-design + sql-analysis + data-visualization |
| A/B 测试专项（L 级） | ab-testing + sql-analysis + metric-design + analysis-report |
| 季度业务复盘（XL 级） | 全部 5 个 skills |
| 指标体系从零搭建（L/XL 级） | metric-design + data-visualization + analysis-report |
| 异常归因分析（M 级） | sql-analysis + metric-design + analysis-report |

## 组合规则

```text
1. 任何涉及"为什么"的分析 → 必须加 analysis-report（给结论和建议）
2. 任何涉及"多少"的分析 → 必须加 sql-analysis（数据支撑）
3. 任何涉及"怎么衡量" → 必须加 metric-design（口径对齐）
4. 任何需要展示的 → 必须加 data-visualization（可视化）
5. 任何涉及"有没有效果" → 必须加 ab-testing（因果推断）
```

## 路由未命中

按 `CONTRIBUTING.md` 流程新增。
