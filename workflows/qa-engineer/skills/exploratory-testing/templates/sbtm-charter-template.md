# SBTM Charter（探索式测试章程）

## 1. Charter 信息

```text
Charter 标题：
Charter ID：CH-[模块]-[序号]
预计时长：90 分钟（标准）/ 60 分钟（短）/ 120 分钟（深度）
执行人：
日期：
```

---

## 2. Charter 目标

```text
Explore [区域]
With [资源]
To discover [目标]

示例：
Explore the payment refund flow
With production-like test data and three roles
To discover edge cases around partial refunds and currency conversion
```

---

## 3. 选择的 Tour（启发式）

- [ ] Money Tour（核心赚钱功能）
- [ ] Landmark Tour（最常用功能）
- [ ] Garbage Collector（边角功能）
- [ ] Configuration Tour（配置组合）
- [ ] Locale Tour（多语言/时区）
- [ ] Failure Tour（断网/断电/超时）
- [ ] FedEx Tour（数据流追踪）
- [ ] Couch Potato（懒用户：什么都不点）
- [ ] Saboteur（破坏者：极端输入）
- [ ] Antisocial（最不寻常的输入）

---

## 4. Heuristics 检查清单

- [ ] **SFDIPOT** — Structure / Function / Data / Interfaces / Platform / Operations / Time
- [ ] **CRUSSPIC STMPL** — Capability / Reliability / Usability / Security / Scalability / Performance / Installability / Compatibility / Supportability / Testability / Maintainability / Portability / Localizability
- [ ] **Goldilocks** — 太大 / 太小 / 刚好

---

## 5. Session 报告（执行后填）

### 时间分配（占比合计 100%）

```text
测试设计 (Test Design) ：%
Bug 调查 (Bug Investigation) ：%
环境/工具 (Setup) ：%
被打断 (Interruptions) ：%
```

### 发现的问题

| # | 类型 | 描述 | 严重度 | 是否已记 Bug |
|---|------|------|--------|-------------|
| 1 | Bug |  |  |  |
| 2 | Issue（疑问） |  |  | - |
| 3 | 建议 |  |  | - |

### 覆盖到的功能/区域

```text
- 模块 A：[详细路径]
- 模块 B：[详细路径]
- 未覆盖（计划但没时间）：
```

### 数据/账号使用

```text
账号：
数据：
后置清理：
```

### Notes（实时观察）

```text
[时间戳] [观察]

13:05 - 启动 session，登录测试账号 user_a
13:15 - 在退款页面发现金额可输入负数 → 记 Bug-789
13:30 - 多币种切换时 UI 闪烁，未崩溃 → 记 Issue-12
14:00 - Money Tour 完成，转向 Failure Tour
14:25 - 断网重连后，订单状态丢失 → 记 Bug-790（高优）
14:35 - Session 结束
```

---

## 6. 跟进（Debrief）

```text
□ Bug 已录入跟踪系统
□ Issues 已与 PM/开发讨论
□ 未覆盖区域已记入下一轮 charter
□ 经验沉淀到 field-journal
□ 数据 / 账号 / 环境已清理或释放
```

---

## 7. 下一轮 Charter 建议

```text
基于本次发现，建议下一轮 explore：
1.
2.
```
