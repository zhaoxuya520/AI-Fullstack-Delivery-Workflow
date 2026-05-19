---
name: quality-gate
description: 上线放行决策 / 阻断不达标交付时使用。适用于版本发布前门禁、CI/CD 自动门禁、阶段性质量评估。融合 SonarQube Quality Gate、DORA Change Failure Rate、Google Beyoncé Rule。
---

# 质量门禁（Quality Gate）

参考来源：SonarQube Quality Gate、DORA《Accelerate》Change Failure Rate、Google《Software Engineering at Google》Continuous Delivery、Microsoft Azure DevOps Quality Gates。

## 适用场景

- 版本发布前的最终决策
- CI/CD 流水线自动门禁
- 阶段性质量评估（每周 / 每迭代）
- 紧急修复的"快速通道"决策
- 与 DevOps 共同定义的放行规则

## 核心原则

```text
1. 门禁必须是明文标准
   不是"看心情"放行

2. 门禁分阻断 vs 警告
   阻断 = 不达标必拦
   警告 = 达标但要关注

3. 门禁要可自动化
   靠人工记忆 = 必有遗漏

4. 门禁可演进
   每次复盘评估调整

5. 门禁不能过严
   过严 = 永远放不出去
   过松 = 等于没有

6. 紧急通道明确
   什么情况能 bypass，谁能批准
```

## 三层门禁结构

### 1. 提交门禁（Pre-Commit / Pre-Push）

```text
触发：git commit / push 时

检查：
  □ 代码格式（Prettier / Black）
  □ Lint（ESLint / Pylint）
  □ 单元测试通过
  □ 类型检查（TypeScript / mypy）
  □ 安全扫描（密钥泄漏）

阻断：失败必须修复才能提交
人工：偶尔 --no-verify（不推荐）
```

### 2. CI 门禁（Pull Request / Merge Request）

```text
触发：PR / MR 创建或更新

检查：
  □ 单元测试 100% 通过
  □ 集成测试 100% 通过
  □ Smoke 套件通过
  □ 代码覆盖率 ≥ X%
  □ 静态扫描无 Critical
  □ 依赖安全扫描无高危
  □ Code Review 通过（≥ 1 人）

阻断：失败不能合并
警告：覆盖率下降 / 性能退化轻微
```

### 3. 发布门禁（Pre-Production）

```text
触发：准备上线

检查（必过）：
  □ 必测用例 100% 通过
  □ S0 / S1 Bug = 0
  □ Sanity 套件通过
  □ 性能 SLO 达标
  □ UAT 通过
  □ 安全审计通过
  □ 监控告警就绪
  □ 回滚方案就绪
  □ 灰度策略明确
  □ 已知问题清单业务方知悉

阻断：任一未达不放行
紧急通道：CTO + PM + SRE 三方签字
```

## 门禁标准模板

```yaml
quality_gates:
  commit:
    blocking:
      - lint_pass: required
      - unit_tests: 100%
      - type_check: required
      - secret_scan: clean
  
  merge:
    blocking:
      - unit_tests: 100%
      - integration_tests: 100%
      - smoke_tests: 100%
      - code_coverage_diff: "≥ -2%"  # 不能降太多
      - security_scan: no_critical
      - code_review_count: ≥ 1
    warning:
      - code_coverage_absolute: "< 80%"
      - performance_regression: "> 5%"
  
  release:
    blocking:
      - must_pass_tests: 100%
      - critical_bugs: 0
      - high_bugs: 0
      - sanity_suite: pass
      - perf_p99: "< SLO"
      - perf_error_rate: "< 0.1%"
      - uat: approved
      - rollback_plan: ready
      - monitoring: configured
      - canary_plan: defined
    warning:
      - medium_bugs: "> 5"
      - perf_regression_vs_baseline: "> 10%"
```

## 紧急修复门禁（Hotfix Gate）

```text
不能用常规门禁的场景：
  - 生产事故修复
  - 安全漏洞紧急补丁
  - 影响重大业务的紧急功能

简化门禁：
  □ 修复用例 100% 通过
  □ 受影响模块 Sanity 通过
  □ 已审视影响范围
  □ 回滚方案就绪
  □ 灰度发布（先 5% 再 100%）

签字要求：
  □ Tech Lead
  □ QA Lead
  □ SRE
  □ PM（业务影响评估）

后续要求：
  □ 24 小时内补完整测试
  □ 7 天内复盘
```

## 门禁度量（DORA）

```text
1. 部署频率（Deployment Frequency）
   - 高效团队：每天多次
   - 中等：每周到每月
   - 低效：每月到每季度

2. 变更前置时间（Lead Time for Changes）
   - 高效：< 1 天
   - 中等：1 周 ~ 1 月
   - 低效：> 1 月

3. 变更失败率（Change Failure Rate）
   - 高效：0~15%
   - 中等：16~30%
   - 低效：> 30%
   - 目标：< 15%

4. 平均恢复时间（MTTR）
   - 高效：< 1 小时
   - 中等：1 天 ~ 1 周
   - 低效：> 1 周
```

## 门禁数据自动化

```text
集成项：
  - GitHub Actions / GitLab CI / Jenkins
  - SonarQube：代码质量
  - Snyk / Dependabot：依赖安全
  - Allure / TestRail：测试结果
  - Datadog / Prometheus：性能监控

门禁脚本示例（GitHub Actions）：

  release-gate:
    runs-on: ubuntu-latest
    steps:
      - name: Check Critical Bugs
        run: |
          critical=$(curl ...jira API... | jq '.issues | length')
          if [ "$critical" -gt 0 ]; then
            echo "::error::Critical bugs found: $critical"
            exit 1
          fi
      
      - name: Check Test Coverage
        run: |
          coverage=$(cat coverage.json | jq '.total')
          if [ $(echo "$coverage < 80" | bc) -eq 1 ]; then
            echo "::warning::Coverage below 80%"
          fi
      
      - name: Check Performance
        run: |
          ./scripts/check-perf-slo.sh
```

## 门禁演进策略

```text
1. 起步阶段（项目早期）
   - 简单门禁：单元测试 + Lint
   - 阻断少，警告多

2. 成熟阶段（功能稳定）
   - 增加：集成测试 + Smoke
   - 增加：性能基线 + 覆盖率

3. 规模阶段（多团队 / 多服务）
   - 增加：契约测试 + 安全扫描
   - 自动化所有门禁

4. 卓越阶段
   - 增加：Chaos / 混沌工程门禁
   - DORA 高效区间
   - 变更失败率 < 5%
```

## 工作流程

```text
1. 与团队定义门禁标准
   - PM / Dev / QA / SRE 共同制定
   - 写入 quality-gate.yml

2. 实现自动化检查
   - 集成到 CI/CD
   - 失败有清晰错误信息

3. 监控门禁触发率
   - 多少次合并被拦
   - 多少次紧急通道
   - 多少次 bypass

4. 复盘门禁有效性
   - 漏放多少 Bug
   - 误拦多少（误判率）
   - 调整阈值

5. 团队培训
   - 门禁规则
   - 修复指南
```

## 质量自检

```text
□ 三层门禁明确（Commit / CI / Release）
□ 阻断规则清晰
□ 警告规则清晰
□ 数据自动化收集
□ 门禁失败有清晰错误信息
□ 紧急通道有签字流程
□ 门禁规则进版本控制
□ 复盘机制定期评估
□ DORA 指标跟踪
□ 团队达成共识
```

## 常见坑

1. **门禁靠人工记忆**——必有遗漏
2. **门禁过严**——开发绕过去
3. **门禁过松**——等于没有
4. **没有紧急通道**——线上事故没法快速修
5. **紧急通道没签字流程**——天天 bypass
6. **门禁不演进**——3 年前的标准用到现在
7. **不做有效性评估**——拦了多少假问题、漏了多少真问题不知道
8. **门禁失败信息不清晰**——不知道怎么修
9. **门禁规则散在多个地方**——配置漂移
10. **不与 DORA 关联**——没法量化质量演进

## 配套模板

- `templates/quality-gate-template.md` — 三层门禁定义 + YAML 配置 + 紧急通道流程 + DORA 跟踪 + 演进路线

## 与其他 skill 的协作

```text
上游：
  test-strategy → 退出条件作为门禁基础
  test-report → 报告数据作为门禁判断
  risk-based-testing → 风险等级作为门禁阈值
  performance-testing → SLO 作为门禁
  acceptance-testing → UAT 通过作为门禁

下游：
  DevOps 工作流 → 集成到 CI/CD
  SRE 工作流 → 监控 / 告警就绪
  项目经理工作流 → 里程碑门禁
```
