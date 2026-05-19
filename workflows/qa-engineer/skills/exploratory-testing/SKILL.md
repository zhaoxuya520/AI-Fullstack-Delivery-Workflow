---
name: exploratory-testing
description: 无明确用例或需要发现未知未知时使用。适用于新功能首次测、复杂业务流程、Bug 修复后扩散探索。融合 James Bach SBTM、Elisabeth Hendrickson Heuristics、Tour-Based Testing。
---

# 探索式测试（Exploratory Testing）

参考来源：James Bach《Session-Based Test Management》、Elisabeth Hendrickson《Explore It!》、Michael Bolton《Rapid Testing》。

## 适用场景

- 新功能首次测试（用例无法穷举）
- 复杂业务流程 / 多角色交互
- Bug 修复后扩散性探索
- 重构后的"行为应不变"验证
- 上线前最后一轮兜底
- 已用例覆盖但担心漏点

## 核心原则

```text
1. 探索 = 学习 + 设计 + 执行 同时进行
   不是"无脑点"，是有意识地观察和推理

2. 时间盒（Session）
   90 分钟一段，避免无限发散

3. Charter（章程）
   每个 session 有明确 Mission

4. 实时记录
   边测边写笔记，事后整理

5. Heuristics 驱动
   用启发式（如 SFDIPOT）系统覆盖维度
```

## SBTM（Session-Based Test Management）

```text
1. Charter（章程）
   - 一句话说明本次 session 的 Mission
   - 例：Explore [area] with [resources] to discover [info]

2. Time-box（时间盒）
   - 60min 短 / 90min 标准 / 120min 深度
   - 不超过 120min（注意力下降）

3. Note-taking（实时笔记）
   - 时间戳 + 观察 + 假设 + 问题

4. Debrief（事后梳理）
   - 总结发现 + 时间分布 + 遗漏区域
```

## Charter 模板

```text
Explore [测试区域]
With [测试资源]
To discover [想发现的信息]

示例：
Explore the order refund flow
With production-like test data and three roles (admin/agent/customer)
To discover edge cases around partial refunds, multi-currency, and concurrent refund attempts
```

## 测试 Tour（James Whittaker / Elisabeth Hendrickson）

| Tour 名 | 关注点 | 典型发现 |
|---|---|---|
| Money Tour | 核心赚钱功能 | 支付 / 订阅 / 计费漏洞 |
| Landmark Tour | 最常用的功能 | 高频路径 Bug |
| Garbage Collector | 边角功能 | 长尾 / 遗留代码问题 |
| Configuration Tour | 各种配置组合 | 设置交叉问题 |
| Locale Tour | 多语言 / 时区 | i18n / 时区 / RTL |
| Failure Tour | 断网 / 断电 / 超时 | 容错 / 恢复 |
| FedEx Tour | 数据从入到出 | 数据完整性 |
| Couch Potato | 什么都不点 | 默认行为 |
| Saboteur | 极端输入 | 边界 / 安全 |
| Antisocial | 最不常见输入 | 边缘场景 |

## Heuristics（启发式速查）

### SFDIPOT（产品维度）
- **S**tructure：组件 / 文件 / 模块
- **F**unction：能做什么
- **D**ata：输入 / 输出 / 状态
- **I**nterfaces：UI / API / 数据库
- **P**latform：浏览器 / 设备 / OS
- **O**perations：用户怎么用
- **T**ime：时间 / 时序 / 性能

### CRUSSPIC STMPL（质量属性）
Capability / Reliability / Usability / Security / Scalability / Performance / Installability / Compatibility / Supportability / Testability / Maintainability / Portability / Localizability

### Goldilocks（边界）
- 太大 / 太小 / 刚好

## 工作流程

```text
1. 准备阶段（10 分钟）
   - 写 Charter
   - 选 Tour 或 Heuristics
   - 准备测试数据 / 账号
   - 打开记录工具（笔记 / 录屏）

2. Session 阶段（60~120 分钟）
   - 按 Charter 探索
   - 实时记录：时间戳 + 观察 + 问题
   - 发现 Bug 立刻记，不深入修
   - 记录"想测但没测"的区域

3. Debrief（15 分钟）
   - 整理 Bug → 录入跟踪系统
   - 标记遗漏区域 → 下次 Charter
   - 时间分布：测试 / 调查 Bug / Setup 占比

4. 沉淀
   - 经验 → field-journal
   - 高价值 Charter → 模板复用
```

## 笔记格式

```text
[时间戳] [类型] [内容]

13:05 [Setup] 启动测试账号 user_a, 余额 1000
13:10 [Test] 退款 50%，预期 500，实际 500 ✓
13:15 [Bug?] 输入负数 -100 没拦截，金额变 -100 → 记 Bug-789
13:30 [Question] 多币种汇率刷新时机不明，问产品
13:45 [Test] Failure Tour：断网，重连后状态丢失 → Bug-790
```

## 时间盒分配建议

```text
60 分钟 session：
  - 5 min Setup
  - 50 min Testing
  - 5 min Debrief

90 分钟 session（标准）：
  - 10 min Setup
  - 70 min Testing
  - 10 min Debrief

120 分钟 session：
  - 15 min Setup
  - 90 min Testing
  - 15 min Debrief
```

注意：超过 90 分钟疲劳率上升，建议拆两段。

## 与基于用例测试的对比

| 维度 | 探索式 | 基于用例 |
|------|--------|---------|
| 覆盖未知 | 强 | 弱（只覆盖写到的） |
| 可重复 | 弱（依赖人） | 强 |
| 学习曲线 | 高 | 低 |
| 自动化 | 不能 | 可以 |
| 适合阶段 | 新功能 / 复杂业务 | 回归 / CI |

→ 互补关系，不是替代

## 质量自检

```text
□ Charter 写清楚了 Mission（不是"测一下功能"）
□ 选定了 Tour 或 Heuristics
□ 时间盒控制在 90 分钟内
□ 实时记录有时间戳
□ 发现的 Bug 都录入了跟踪系统
□ Debrief 总结了时间分布
□ 标记了"想测但没测"
□ 高价值 Charter 沉淀到 field-journal
```

## 常见坑

1. **没有 Charter 就开测**——失去聚焦，30 分钟点遍 UI 然后下班
2. **时间盒过长**——3 小时一气测，后期效率为 0
3. **不记笔记**——发现 Bug 但描述不清
4. **深陷某个 Bug 调查**——本来 90 分钟探索，1 小时调试一个 Bug
5. **不做 Debrief**——发现没整理，遗忘
6. **只测 UI**——忽略 API / 数据库 / 日志
7. **不复用 Charter**——下次同模块从零想
8. **把"无聊地点击"当探索**——没有思考维度
9. **不配合用例测试**——以为探索能替代回归

## 配套模板

- `templates/sbtm-charter-template.md` — Charter + Heuristics 选项 + Session 报告 + Debrief 清单

## 与其他 skill 的协作

```text
上游：
  risk-based-testing → 高风险区域优先 charter
  test-strategy → 探索式占比由策略决定

平行：
  test-case-design → 探索发现的 Bug 转化为回归用例

下游：
  bug-reporting → 发现 Bug 录入
  regression-testing → 高价值 Charter 转化为回归用例
  field-journal → Charter 复用
```
