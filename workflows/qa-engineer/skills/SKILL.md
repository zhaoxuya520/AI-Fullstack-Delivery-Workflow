# 测试工程师 Skills 总控

本目录收录测试工程师工作流的所有方法论 skills。

## 当前 Skills

| Skill | 适用场景 | 来源 |
|-------|---------|------|
| [test-strategy](test-strategy/SKILL.md) | 测试策略 / 范围 / 分层 | Mike Cohn 测试金字塔 + Brian Marick 测试象限 + Google Beyoncé Rule |
| [test-case-design](test-case-design/SKILL.md) | 测试用例设计 | ISTQB 黑盒方法 + 等价类 + 边界值 + 决策表 + 状态转换 |
| [risk-based-testing](risk-based-testing/SKILL.md) | 风险驱动测试 | Hans Schaefer + James Bach RBT |
| [exploratory-testing](exploratory-testing/SKILL.md) | 探索式测试 | James Bach SBTM + Elisabeth Hendrickson Heuristics |
| [regression-testing](regression-testing/SKILL.md) | 回归测试 | Impact Analysis + Test Suite Pruning |
| [bug-reporting](bug-reporting/SKILL.md) | 缺陷报告 | Cem Kaner + ISTQB 缺陷生命周期 |
| [acceptance-testing](acceptance-testing/SKILL.md) | UAT 验收测试 | Given-When-Then + Specification by Example |
| [api-testing](api-testing/SKILL.md) | API 接口测试 | Postman + REST Assured + 契约测试 |
| [performance-testing](performance-testing/SKILL.md) | 性能测试 | Google SRE Workbook + Brendan Gregg USE Method |
| [test-data-management](test-data-management/SKILL.md) | 测试数据管理 | TDM 最佳实践 + GDPR 数据脱敏 |
| [test-report](test-report/SKILL.md) | 测试报告输出 | ISTQB Test Summary Report |
| [quality-gate](quality-gate/SKILL.md) | 质量门禁 | DORA + SonarQube Quality Gate |

## 统一入口

1. 先读 `routing.md` — 按测试任务类型路由
2. 再进入对应 SKILL.md
3. 需要模板时进入 `<skill>/templates/`

## 工作思路

skills 可以按需组合：

```text
1. 拿到需求 → 先定策略
   - test-strategy（测试策略）

2. 风险评估 → 优先级
   - risk-based-testing（风险驱动）

3. 设计用例
   - test-case-design（黑盒方法）
   - exploratory-testing（探索式补充）

4. 执行测试
   - api-testing（接口）
   - acceptance-testing（验收）
   - performance-testing（性能）

5. 缺陷处理
   - bug-reporting（记录缺陷）
   - regression-testing（修复后回归）

6. 数据和环境
   - test-data-management（测试数据）

7. 输出和门禁
   - test-report（报告）
   - quality-gate（放行评估）
```

## 新增 Skill

按 `CONTRIBUTING.md` 流程新增。

## 自动进化

每次完成测试任务后，回写经验到 `../field-journal/`。
