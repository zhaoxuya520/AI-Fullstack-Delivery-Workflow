# 自动化测试工作流（Automation QA Workflow）

## 定位

自动化测试工作流负责把手工测试用例转化为 **可重复、可维护、可集成 CI 的自动化测试**：单元测试、集成测试、E2E 测试、API 契约测试、性能自动化、CI 测试流水线。

它不替代 QA 工程师工作流（测试策略 / 手工测试 / 探索式）。它负责 **测试的自动化实现和 CI 集成**。

本工作流采用 **skills 模块化架构**。

---

## 适用场景

```text
单元测试实现（Jest / Vitest / pytest / JUnit）
集成测试（Testcontainers / Supertest）
E2E 测试（Playwright / Cypress）
API 契约测试（Pact / Dredd）
性能自动化（k6 / Locust）
CI 测试流水线（覆盖率 / 质量门禁）
测试数据管理
Flaky 测试修复
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 测试策略 / 用例设计 | qa-engineer |
| 手工测试 / 探索式 | qa-engineer |
| CI/CD 流水线配置 | devops-engineer |
| 性能问题排查 | sre-operations |
| 安全测试 | security-engineer |

---

## 输入

```text
必需：
  - 测试用例（来自 qa-engineer）
  - 代码仓库
  - 技术栈（语言 / 框架）
  - 测试环境

可选：
  - 覆盖率目标
  - 性能基线
  - API 契约（OpenAPI）
  - CI 配置
```

---

## 完整行为链

```text
1. 读取测试用例 + 技术栈
   ↓
2. 选择测试框架
   ↓
3. 实现单元测试
   ↓
4. 实现集成测试
   ↓
5. 实现 E2E 测试（关键路径）
   ↓
6. API 契约测试（如有）
   ↓
7. 性能自动化（如需）
   ↓
8. CI 集成（覆盖率 + 质量门禁）
   ↓
9. 维护（Flaky 修复 / 更新）
   ↓
10. 沉淀经验
```

---

## Skills 模块总览

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [unit-testing](skills/unit-testing/SKILL.md) | 单元测试 | Jest / Vitest / pytest / JUnit |
| [integration-testing](skills/integration-testing/SKILL.md) | 集成测试 | Testcontainers / Supertest |
| [e2e-testing](skills/e2e-testing/SKILL.md) | E2E 测试 | Playwright / Cypress |
| [api-contract-testing](skills/api-contract-testing/SKILL.md) | API 契约测试 | Pact / Dredd / Schemathesis |
| [ci-test-integration](skills/ci-test-integration/SKILL.md) | CI 测试集成 | GitHub Actions / GitLab CI |
| [coverage-reporting](skills/coverage-reporting/SKILL.md) | 覆盖率报告 | Codecov / Istanbul / JaCoCo |

---

## 禁止行为

```text
❌ 不要测实现细节（测行为）
❌ 不要过度 Mock（Mock 自己的代码）
❌ 不要让 Flaky 测试留在 CI
❌ 不要测试数据污染环境
❌ 不要 E2E 测试太多（金字塔）
❌ 不要没有 CI 集成的测试
❌ 不要覆盖率追求 100%（测 getter/setter）
❌ 不要测试代码不维护
```

---

## 任务复杂度分级

```text
S 级（30 分钟~2 小时）：单模块单元测试
  → unit-testing

M 级（2~8 小时）：模块集成测试 + CI
  → + integration-testing + ci-test-integration

L 级（1~3 天）：全栈自动化测试套件
  → 全部 6 skills

XL 级（3 天+）：大型项目测试体系建设
  → 全部 + qa-engineer 协作
```

---

## 通用质量检查

```text
□ 测试金字塔分布合理（单元 70% / 集成 20% / E2E 10%）
□ 测试独立（不依赖顺序）
□ 测试快（单元 < 100ms）
□ 测试数据隔离
□ Flaky 率 < 1%
□ 覆盖率 ≥ 80%（核心业务）
□ CI 集成（PR 阻塞）
□ 失败信息清晰
□ 测试代码可维护
□ 不测实现细节
```

---

## 常见坑

```text
1. 测实现细节 → 重构时大量挂
2. 过度 Mock → 测假
3. Flaky 测试不修 → 干扰真问题
4. E2E 太多 → 慢且脆弱
5. 测试数据不隔离 → 并行就崩
6. 覆盖率追 100% → 测 getter
7. 不进 CI → 形同虚设
8. 测试代码不维护 → 越来越难跑
9. 不用 Testcontainers → H2 行为不同
10. 不用 Page Object → E2E 重复代码
```

---

## 与其他工作流的协作

### 上游

| 上游 | 自动化测试需要的输入 |
|---|---|
| qa-engineer | 测试用例 + 测试策略 |
| backend-engineer | 代码 + 接口文档 |
| frontend-engineer | 组件 + 页面 |
| api-designer | OpenAPI 契约 |

### 下游

| 下游 | 自动化测试交付内容 |
|---|---|
| devops-engineer | CI 测试配置 |
| qa-engineer | 自动化覆盖率报告 |
| project-manager | 测试质量指标 |

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow automation-qa
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

```text
是否形成新测试模板？→ 加入对应 skill
是否发现新 Flaky 模式？→ 更新 pitfalls
是否需要新工具？→ 更新 tool-index
```
