# 质量门禁定义模板

## 1. 项目信息

```text
项目：
团队：
负责人：
版本：
最后更新：
```

---

## 2. 三层门禁定义

### Commit 门禁（Pre-Commit / Pre-Push）

```yaml
commit_gate:
  blocking:
    lint:
      tool: eslint / pylint / golangci-lint
      threshold: 0 errors
    
    format:
      tool: prettier / black / gofmt
      threshold: 0 diffs
    
    type_check:
      tool: tsc / mypy
      threshold: 0 errors
    
    unit_tests:
      threshold: 100%
    
    secret_scan:
      tool: gitleaks / trufflehog
      threshold: 0 leaks
```

---

### CI 门禁（Pull Request）

```yaml
ci_gate:
  blocking:
    unit_tests:
      threshold: 100%
    
    integration_tests:
      threshold: 100%
    
    smoke_tests:
      threshold: 100%
    
    code_coverage_diff:
      threshold: "≥ -2%"
    
    security_scan:
      tool: snyk / dependabot
      threshold: 0 critical, 0 high
    
    code_review:
      min_approvers: 1
  
  warning:
    code_coverage_absolute:
      threshold: "≥ 80%"
    
    performance_regression:
      threshold: "≤ 5%"
    
    file_size_increase:
      threshold: "≤ 100 KB"
```

---

### Release 门禁（Pre-Production）

```yaml
release_gate:
  blocking:
    # 测试
    must_pass_tests: 100%
    sanity_suite: pass
    
    # Bug
    critical_bugs: 0
    high_bugs: 0
    
    # 性能
    p99_response_time: "< SLO"
    error_rate: "< 0.1%"
    
    # 业务
    uat_status: approved
    
    # 部署
    rollback_plan: ready
    monitoring: configured
    canary_plan: defined
    on_call_assigned: yes
  
  warning:
    medium_bugs: "≤ 5"
    perf_regression_vs_baseline: "≤ 10%"
    coverage_decrease: "≤ -1%"
```

---

## 3. 紧急修复通道（Hotfix Gate）

### 触发条件

```text
□ 生产事故修复
□ 安全漏洞紧急补丁
□ 重大业务影响功能
```

### 简化门禁

```yaml
hotfix_gate:
  blocking:
    fix_test: 100%
    affected_module_sanity: pass
    impact_analysis: documented
    rollback_plan: ready
    canary: 5% → 50% → 100%
```

### 签字要求

| 角色 | 签字 |
|---|---|
| Tech Lead | __________ |
| QA Lead | __________ |
| SRE | __________ |
| PM（业务影响） | __________ |

### 后续要求

```text
□ 24 小时内补完整测试
□ 7 天内复盘
□ 沉淀到 field-journal
□ 评估常规流程是否需要调整
```

---

## 4. DORA 指标跟踪

```text
当前等级评估：
  - 部署频率（DF）：
  - 变更前置时间（LT）：
  - 变更失败率（CFR）：
  - 平均恢复时间（MTTR）：

目标等级：
  - 高效区间（CFR < 15% / MTTR < 1h）

跟踪频率：每月评估
```

---

## 5. 门禁触发记录（每次发布填）

| 日期 | 版本 | Commit 通过 | CI 通过 | Release 通过 | 是否 bypass | 签字人 |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

---

## 6. 门禁有效性复盘（每月）

```text
本月门禁数据：
- 总提交数：X
- Commit 阻断：Y（%）
- CI 阻断：Z（%）
- Release 阻断：W
- 紧急通道使用：N

漏放 Bug：
- 数量：X
- 严重度：[列表]
- 根因：[门禁规则不全 / 门禁失效 / 误判]

误拦：
- 数量：X
- 影响：[延误时间]
- 根因：[阈值过严 / 误判]

调整建议：
1.
2.
```

---

## 7. 门禁演进路线

```text
当前阶段：起步 / 成熟 / 规模 / 卓越

下一步规划：
- [ ] 增加契约测试门禁
- [ ] 增加 Chaos 测试门禁
- [ ] 自动化覆盖率收集
- [ ] 集成 SonarQube
- [ ] 集成性能基线对比
```

---

## 8. 自检

```text
□ 三层门禁规则明确
□ 阻断 vs 警告划分清楚
□ 数据自动化收集
□ CI/CD 已集成
□ 紧急通道流程明确
□ DORA 指标跟踪
□ 月度复盘机制
□ 团队培训完成
□ 门禁规则进版本控制
□ 跨团队对齐
```
