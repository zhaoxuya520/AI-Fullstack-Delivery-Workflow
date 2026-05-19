---
name: threat-modeling
description: 威胁建模时使用。适用于新功能 / 新系统的安全设计评审。融合 STRIDE + Attack Tree + Microsoft SDL。
---

# 威胁建模（Threat Modeling）

## 适用场景

- 新功能安全设计评审
- 新系统架构安全评估
- 重大变更前安全分析
- 合规要求的威胁分析

## 核心原则

```text
1. 在设计阶段做（不是上线后）
2. STRIDE 六类威胁全覆盖
3. 关注数据流（不只是组件）
4. 输出可操作的缓解措施
5. 定期更新（架构变更时）
```

## STRIDE 模型

| 威胁 | 含义 | 示例 | 缓解 |
|---|---|---|---|
| **S**poofing | 身份伪造 | 伪造 JWT | 签名验证 + 过期 |
| **T**ampering | 数据篡改 | 修改请求体 | 签名 + 校验 |
| **R**epudiation | 抵赖 | 否认操作 | 审计日志 |
| **I**nformation Disclosure | 信息泄露 | 日志含密码 | 脱敏 + 加密 |
| **D**enial of Service | 拒绝服务 | 大量请求 | 限流 + CDN |
| **E**levation of Privilege | 权限提升 | 普通用户改 admin | RBAC + 校验 |

## 工作流程

```text
1. 画数据流图（DFD）
   - 外部实体 / 进程 / 数据存储 / 数据流
   ↓
2. 识别信任边界
   - 前端 ↔ 后端
   - 后端 ↔ 数据库
   - 内部 ↔ 第三方
   ↓
3. 对每个数据流应用 STRIDE
   ↓
4. 评估风险（概率 × 影响）
   ↓
5. 制定缓解措施
   ↓
6. 输出威胁模型文档
```

## 配套模板

- `templates/threat-model-template.md` — DFD + STRIDE 分析 + 缓解措施

## 质量自检

```text
□ DFD 完整（所有数据流）
□ 信任边界标注
□ STRIDE 六类全覆盖
□ 风险评估有依据
□ 缓解措施可执行
□ 与开发团队评审过
```

## 常见坑

1. **只看组件不看数据流**——漏传输层威胁
2. **不标信任边界**——不知道哪里需要校验
3. **缓解措施太抽象**——"加强安全"不可执行
4. **做完不更新**——架构变了模型没变
5. **不与开发评审**——开发不知道要做什么

## 与其他 skill 的协作

```text
下游：
  code-security-review → 按威胁模型重点审查
  web-vulnerability → 按威胁模型重点测试
  auth-security-audit → 权限提升威胁
  security-report → 威胁模型作为报告输入
```
