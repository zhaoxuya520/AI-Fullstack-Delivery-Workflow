# 测试工程师工作流路由

## 关键词

测试, 测试用例, 测试计划, 功能测试, 回归测试, 验收测试, UAT, 缺陷, Bug, 复现, 探索式, 性能测试, 压测, 测试报告, 质量门禁, 测试策略, 测试数据

## 路由契约

```yaml
workflow: qa-engineer
name: 测试工程师工作流
keywords: [测试, 测试用例, 回归, UAT, 缺陷, Bug, 性能测试, 测试报告, 质量门禁]
entry: WORKFLOW.md
required_files:
  - WORKFLOW.md
  - routing.md
  - skills/SKILL.md
  - skills/routing.md
  - tool-index.md
  - pitfalls.md
  - field-journal/_index.md
outputs:
  - 测试计划
  - 测试用例
  - 缺陷报告
  - 回归套件
  - 测试报告
  - 质量门禁评估
```

## Skills 入口

进入 WORKFLOW.md 后按 `skills/routing.md` 路由到具体 skill。

| 用户意图 | Skill |
|---------|-------|
| 测试策略 / 测多深 | test-strategy |
| 测试用例设计 | test-case-design |
| 风险 / 优先级 | risk-based-testing |
| 探索式 / 无脚本 | exploratory-testing |
| 回归 / 影响分析 | regression-testing |
| Bug / 缺陷 / 复现 | bug-reporting |
| 验收 / UAT | acceptance-testing |
| API 测试 | api-testing |
| 性能 / 压测 | performance-testing |
| 测试数据 / 脱敏 | test-data-management |
| 测试报告 | test-report |
| 上线门禁 | quality-gate |

## 进入前检查

```text
□ 任务目标清楚
□ 输入材料齐全（PRD / API 契约 / 变更说明）
□ 期望产出清楚
□ 跨工作流协作识别（开发 / 安全 / DevOps）
□ 风险识别（数据 / 安全 / 生产）
```

## 路由未命中

如不属于本工作流，返回根 `routing.md` 选择其他工作流。

常见误判：

| 看起来像 QA 实际属于 | 应转到 |
|---|---|
| 自动化测试代码、CI 集成 | 自动化测试工作流 |
| 攻击面、漏洞挖掘 | 安全工程师工作流 |
| 线上监控、告警 | SRE/运维工作流 |
| 部署 CI/CD 链路问题 | DevOps 工作流 |
