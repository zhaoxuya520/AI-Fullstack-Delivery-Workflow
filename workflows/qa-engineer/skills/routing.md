# 测试 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "测试计划" / "测试范围" / "测多深" | [test-strategy](test-strategy/SKILL.md) |
| "测试用例" / "怎么设计用例" / "覆盖" | [test-case-design](test-case-design/SKILL.md) |
| "风险" / "优先级" / "先测哪个" | [risk-based-testing](risk-based-testing/SKILL.md) |
| "探索式" / "无脚本" / "不知道测什么" | [exploratory-testing](exploratory-testing/SKILL.md) |
| "回归" / "改了 A 影响 B" / "回归套件" | [regression-testing](regression-testing/SKILL.md) |
| "Bug" / "缺陷" / "怎么写报告" / "复现" | [bug-reporting](bug-reporting/SKILL.md) |
| "验收" / "UAT" / "Given-When-Then" | [acceptance-testing](acceptance-testing/SKILL.md) |
| "接口测试" / "API 测试" / "Postman" | [api-testing](api-testing/SKILL.md) |
| "性能" / "压测" / "并发" / "容量" | [performance-testing](performance-testing/SKILL.md) |
| "测试数据" / "造数据" / "脱敏" | [test-data-management](test-data-management/SKILL.md) |
| "测试报告" / "总结" / "覆盖率" | [test-report](test-report/SKILL.md) |
| "上线门禁" / "能不能放行" / "must pass" | [quality-gate](quality-gate/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单 Bug 验证（S 级） | bug-reporting + test-case-design |
| 单接口测试（S 级） | api-testing + test-case-design |
| 单功能模块（M 级） | test-strategy + test-case-design + risk-based-testing + bug-reporting + test-report |
| 跨模块功能（L 级） | + regression-testing + acceptance-testing + api-testing + test-data-management |
| 版本发布（XL 级） | 全部 12 skills + quality-gate 重点 |
| 性能专项 | test-strategy + performance-testing + test-report |
| 探索式专项 | exploratory-testing + bug-reporting + risk-based-testing |
| UAT 阶段 | acceptance-testing + bug-reporting + test-report |
| 紧急修复验证 | risk-based-testing + bug-reporting + regression-testing |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 10~30min | test-case-design + bug-reporting |
| M | 30~120min | + test-strategy + risk-based-testing + test-report |
| L | 2~6h | + regression-testing + acceptance-testing + api-testing + test-data-management |
| XL | 6h+ | 全部 + quality-gate |

## 路径交叉

```text
新功能模块测试：
  test-strategy（定范围）
  → risk-based-testing（排优先级）
  → test-case-design（设计用例）
  → api-testing（接口层）
  → acceptance-testing（业务层）
  → bug-reporting（记录缺陷）
  → regression-testing（修复后回归）
  → test-report（输出报告）
  → quality-gate（放行评估）

紧急 Bug 修复验证：
  bug-reporting（理解 Bug）
  → risk-based-testing（评估影响范围）
  → test-case-design（针对性用例）
  → regression-testing（影响范围回归）

性能专项：
  test-strategy（定基线）
  → performance-testing（执行）
  → test-data-management（生产规模数据）
  → test-report（吞吐 / 延迟 / 容量结论）

上线前总测：
  test-strategy（确认范围已覆盖）
  → regression-testing（核心套件）
  → quality-gate（must-pass 检查）
  → test-report（放行报告）
```

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增。
