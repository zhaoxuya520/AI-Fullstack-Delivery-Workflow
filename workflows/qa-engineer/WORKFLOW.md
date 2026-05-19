# 测试工程师工作流（QA Engineer Workflow）

## 定位

测试工程师工作流负责把 PRD、API 契约、UI 流程、数据规则、变更说明，转化为 **可复现、可追溯、可量化、可回归** 的测试策略、测试用例、缺陷记录、质量门禁和测试报告。

它不替代自动化测试工作流（CI/CD 测试代码）、安全工程师工作流（攻击面）、SRE 工作流（线上监控），而是负责 **上线前的功能正确性、业务可用性、回归稳定性** 验证。

本工作流采用 **skills 模块化架构**：总控负责路由和通用规则，具体方法论拆分成独立 skills，按需加载。

---

## 适用场景

```text
测试策略 / 测试金字塔 / 测试范围
测试用例设计（等价类 / 边界值 / 决策表 / 状态转换）
功能测试 / 回归测试 / 验收测试
风险驱动测试 / 优先级排序
探索式测试 / Session-Based Testing
API 测试 / 接口契约测试
性能测试基线 / 容量评估
缺陷记录 / 复现 / 严重度 / 根因
测试数据管理（生成 / 隔离 / 清理）
测试报告 / 覆盖率 / 上线门禁
```

---

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| PRD、验收标准、业务规则不清 | 产品经理工作流 |
| 自动化测试代码、CI 集成、覆盖率收集 | 自动化测试工作流 |
| API 契约、错误码定义、Mock 不全 | API 设计工作流 |
| 数据库结构、迁移、查询优化 | 数据库工程师工作流 |
| 攻击面、漏洞利用、渗透测试 | 安全工程师工作流 |
| 线上监控、告警、故障复盘 | SRE/运维工作流 |
| 部署 CI/CD 链路问题 | DevOps 工作流 |

---

## 输入

### 必需输入

```text
PRD 或功能范围
验收标准
用户角色和权限范围
核心业务流程和状态流转
API 契约（端点 + 错误码）
变更说明（新功能 / Bug 修复 / 重构）
```

### 可选输入

```text
UI/UX 设计稿（页面字段、空/错/无权限状态）
数据模型（实体、字段、唯一性、状态）
历史 Bug 列表（同模块 / 同类问题）
SLA 目标（性能 / 容量 / 可用性）
测试环境信息（数据、账号、第三方依赖）
合规要求（PII、审计、保留期）
```

### 输入不足时先补问

```text
1. 验收标准是什么？（不只是"能用"）
2. 哪些角色 / 租户 / 字段权限边界要覆盖？
3. 哪些状态流转、并发、冲突场景？
4. 失败路径（空、超时、限流、网络抖动、数据冲突）覆盖到哪一档？
5. 是否有性能 / 数据量基线？
6. 是否有同模块历史 Bug 需要回归？
7. 测试环境是否能复现真实数据 / 第三方 / 异常？
```

---

## 完整行为链（硬性流程）

```text
1. 读取 PRD / API 契约 / UI 流程 / 验收标准 / 变更说明
   ↓
2. 检查 field-journal/_index.md → 是否有同模块测试经验可复用
   ↓
3. 读取 skills/routing.md → 路由到需要的 skills
   ↓
4. 判断测试复杂度（S/M/L/XL）→ 选择产出粒度
   ↓
5. 风险评估：识别高风险路径（用 risk-based-testing skill）
   ↓
6. 加载命中 skills → 按 skill 内方法设计用例 / 执行测试 / 记录缺陷
   ↓
7. 输出测试报告 + 质量门禁评估
   ↓
8. 转交开发修复 / 自动化测试 / 安全 / DevOps
   ↓
9. 按 EVOLUTION.md 沉淀经验 → 回写 field-journal
```

---

## Skills 模块总览

每个 skill 独立可用，按需组合。详细路由见 `skills/routing.md`。

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [test-strategy](skills/test-strategy/SKILL.md) | 测试策略 / 范围 / 分层 | 测试金字塔 + 测试象限 + Beyoncé Rule |
| [test-case-design](skills/test-case-design/SKILL.md) | 测试用例设计 | 等价类 + 边界值 + 决策表 + 状态转换 |
| [risk-based-testing](skills/risk-based-testing/SKILL.md) | 风险驱动测试 | 概率 × 影响矩阵 + 优先级排序 |
| [exploratory-testing](skills/exploratory-testing/SKILL.md) | 探索式测试 | SBTM Charter + Heuristics + Tour |
| [regression-testing](skills/regression-testing/SKILL.md) | 回归测试 | Impact Analysis + 回归套件维护 |
| [bug-reporting](skills/bug-reporting/SKILL.md) | 缺陷报告 | 复现步骤 + 严重度/优先级 + 根因 |
| [acceptance-testing](skills/acceptance-testing/SKILL.md) | UAT 验收测试 | Given-When-Then + 业务对齐 |
| [api-testing](skills/api-testing/SKILL.md) | API 接口测试 | 成功/失败/边界/权限/幂等 |
| [performance-testing](skills/performance-testing/SKILL.md) | 性能测试 | 吞吐 + 延迟 + 并发 + 容量 |
| [test-data-management](skills/test-data-management/SKILL.md) | 测试数据管理 | 生成 + 隔离 + 清理 + 敏感脱敏 |
| [test-report](skills/test-report/SKILL.md) | 测试报告输出 | 覆盖率 + 缺陷分布 + 风险结论 |
| [quality-gate](skills/quality-gate/SKILL.md) | 质量门禁 | 上线前 must-pass + 可放行条件 |

---

## 禁止行为

```text
❌ 不要在验收标准不清时直接写用例（会漏 50% 场景）
❌ 不要只测成功路径
❌ 不要把"测试用例"写成"操作步骤"（缺少预期 / 前置 / 后置）
❌ 不要让 Bug 缺复现步骤
❌ 不要用"严重"/"一般"凭感觉打优先级（要按矩阵）
❌ 不要让回归套件无限膨胀（要剪枝）
❌ 不要把性能问题留给 SRE 上线后发现
❌ 不要让测试数据污染生产环境
❌ 不要绕过质量门禁让 Bug 进生产
❌ 不要把"测试通过"等同于"质量合格"（覆盖率不等于质量）
❌ 不要跳过工作流交接和经验沉淀
```

---

## 任务复杂度分级

```text
S 级（10~30 分钟）：单 Bug 验证 / 单接口测试
  → test-case-design + bug-reporting

M 级（30~120 分钟）：单功能模块测试
  → test-strategy + test-case-design + risk-based-testing + bug-reporting + test-report

L 级（2~6 小时）：跨模块功能 + 回归
  → 加 regression-testing + acceptance-testing + api-testing + test-data-management

XL 级（6 小时+）：版本发布 / 上线前完整测试
  → 全部 12 个 skills + quality-gate 重点
```

---

## 通用质量检查

```text
□ 验收标准是否完全覆盖？
□ 高风险路径是否优先测？
□ 失败路径（空 / 错 / 超时 / 限流 / 权限不足 / 冲突）是否覆盖？
□ 边界值是否覆盖（0 / 1 / 最大 / 最大+1 / null / 空字符串）？
□ 状态转换是否覆盖（合法转换 + 非法转换）？
□ 权限矩阵是否每个角色都测？
□ Bug 是否 100% 可复现？
□ 严重度和优先级是否按矩阵打？
□ 回归套件是否包含本次变更影响范围？
□ 测试数据是否隔离 / 不污染 / 可清理？
□ 测试报告是否给出"建议是否放行"的明确结论？
□ 经验是否沉淀到 field-journal？
```

---

## 常见坑（跨 skill 通用）

```text
1. 验收标准不清就开测，发现一半推倒重来
2. 只按 PRD 正向测，漏失败路径 50%+
3. 边界值漏测：0、1、最大、最大+1、负数、超长字符串
4. 状态转换只测合法路径，漏非法转换（已支付订单再次支付）
5. 权限测试只测自己角色，漏跨角色 / 跨租户越权
6. Bug 报告缺复现步骤，开发反复回退
7. "严重 Bug" 凭感觉打，分布失真
8. 回归套件无差别全跑，时间爆炸
9. 测试数据手工造，下次不可复现
10. 性能问题留到生产
11. 第三方依赖没 Mock，CI 时断时续
12. 同 Bug 反复出现没回归用例
13. 报告只列数字，不给放行结论
14. 质量门禁靠口头约定，没明文标准
```

具体 skill 内的常见坑见各 skill 的 SKILL.md。

---

## 与其他工作流的协作

### 上游

| 上游工作流 | QA 需要的输入 |
|---|---|
| 产品经理工作流 | PRD、验收标准、用户故事、业务规则、权限范围 |
| UI/UX 设计工作流 | 页面流程、状态、字段校验、空/错/权限不足展示 |
| API 设计工作流 | OpenAPI 契约、错误码、权限矩阵、Mock |
| 数据库工程师工作流 | 实体、状态、唯一性约束、迁移说明 |
| 前端 / 后端 / 全栈工作流 | 变更说明、新增 / 修复 / 重构清单、单元测试结果 |

### 下游

| 下游工作流 | QA 交付内容 |
|---|---|
| 自动化测试工作流 | 用例（标注哪些可自动化 / 优先自动化） |
| 安全工程师工作流 | 越权 / 鉴权失败 / 敏感数据泄露的可疑场景 |
| DevOps 工作流 | 质量门禁评估 + 放行 / 回滚建议 |
| SRE/运维工作流 | 测试环境性能数据 / 容量评估 |
| 技术文档工作流 | 已知问题清单 / 发布说明 / 缺陷分布 |
| 项目经理工作流 | 缺陷趋势 / 风险结论 / 是否能按里程碑放行 |

---

## 多任务与中断处理

```text
1. 多模块并行：每个独立维护测试套件 + 缺陷列表，避免互相阻塞
2. 中途中断：保存当前进度（已执行用例 + 待复测 Bug + 待确认问题）
3. 紧急 Bug 验证：暂停常规测试，按 risk-based-testing 抢占处理
4. 测试阻塞（环境 / 数据 / 依赖）：记录阻塞原因 + 升级路径
```

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow qa-engineer
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

任务完成后按 `EVOLUTION.md` 检查：

```text
是否形成新的测试用例模板？→ 加入对应 skill 的 templates/
是否发现新的缺陷模式？→ 更新 pitfalls.md 和对应 skill
是否需要新增风险类别？→ 更新 risk-based-testing
是否需要补充探索式 charter？→ 更新 exploratory-testing
是否需要写入 field-journal？
是否需要新增 skill？→ 按 CONTRIBUTING.md 流程
```
