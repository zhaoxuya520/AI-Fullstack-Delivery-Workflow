---
name: coverage-reporting
description: 测试覆盖率收集和报告时使用。适用于覆盖率目标设定、CI 集成、PR 评论、趋势跟踪。
---

# 覆盖率报告（Coverage Reporting）

## 适用场景

- 覆盖率目标设定
- CI 覆盖率收集
- PR 覆盖率评论
- 覆盖率趋势跟踪
- 覆盖率门禁

## 核心原则

```text
1. 覆盖率是基线不是目标
   80% 覆盖率 ≠ 80% 质量

2. 关注增量覆盖率
   新代码 ≥ 80%，比总覆盖率更有意义

3. 不追求 100%
   getter / setter / 配置不需要测

4. 分层看
   业务逻辑 ≥ 90%
   Controller ≥ 60%
   工具函数 ≥ 80%

5. 趋势比绝对值重要
   覆盖率不能下降
```

## 工具

| 工具 | 语言 | 用途 |
|---|---|---|
| **Codecov** | 多语言 | SaaS 报告 + PR 评论 |
| **Coveralls** | 多语言 | SaaS 报告 |
| **SonarQube** | 多语言 | 自建 + 质量门禁 |
| **Istanbul / c8** | JS/TS | 收集器 |
| **JaCoCo** | Java | 收集器 |
| **coverage.py** | Python | 收集器 |
| **go test -cover** | Go | 内置 |

## 覆盖率目标

| 层 | 目标 | 说明 |
|---|---|---|
| Domain / Service | ≥ 90% | 核心业务 |
| Controller | ≥ 60% | 集成测试覆盖 |
| Utils | ≥ 80% | 工具函数 |
| 总体 | ≥ 70% | 基线 |
| 增量（新代码） | ≥ 80% | PR 门禁 |

## CI 集成

```yaml
# Vitest 覆盖率
- run: pnpm test:coverage
- uses: codecov/codecov-action@v4
  with:
    files: coverage/lcov.info
    fail_ci_if_error: true

# 门禁：覆盖率不能下降
- name: Coverage check
  run: |
    COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
    if (( $(echo "$COVERAGE < 70" | bc -l) )); then
      echo "Coverage below threshold: $COVERAGE%"
      exit 1
    fi
```

## 配套模板

- `templates/coverage-config-template.md` — 覆盖率配置 + 目标 + CI

## 质量自检

```text
□ 覆盖率目标设定
□ CI 自动收集
□ PR 评论（增量）
□ 门禁（不能下降）
□ 趋势跟踪
□ 分层目标
□ 不追求 100%
```

## 常见坑

1. **追求 100%**——测 getter 浪费时间
2. **只看总覆盖率**——新代码 0% 也能过
3. **不设门禁**——覆盖率持续下降
4. **覆盖率 = 质量**——覆盖了不等于测对了
5. **不看趋势**——单点数据无意义

## 与其他 skill 的协作

```text
上游：
  unit/integration/e2e → 测试代码产生覆盖率

下游：
  ci-test-integration → CI 收集
  qa-engineer quality-gate → 门禁条件
```
