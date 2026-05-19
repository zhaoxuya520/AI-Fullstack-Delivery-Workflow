# 安全工程师工作流（Security Engineer Workflow）

## 定位

安全工程师工作流负责 **发现、评估和修复安全风险**：威胁建模、代码审查、漏洞检测、认证审计、供应链安全、安全报告。

它不替代逆向/渗透工作流（主动攻击验证）、DevOps（部署安全配置）、后端（代码修复）。它负责 **防御视角的安全保障**。

需要主动攻击验证（渗透测试 / CTF / 漏洞利用）时，转交 `reverse-pentest` 工作流。

---

## 适用场景

```text
威胁建模（新功能 / 新系统）
代码安全审查（SAST / 手动）
依赖漏洞扫描
Web 漏洞检测（OWASP Top 10）
认证鉴权审计（越权 / IDOR）
供应链安全（依赖 / 镜像 / CI）
安全报告输出
合规评审（GDPR / PCI / 等保）
安全培训 / 安全意识
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 主动渗透 / 漏洞利用 / CTF | reverse-pentest |
| 业务代码修复 | backend-engineer / frontend-engineer |
| CI/CD 安全配置 | devops-engineer |
| 线上事故响应 | sre-operations |
| 数据库权限 / RLS | database-engineer |

---

## 输入

```text
必需：
  - 目标系统（代码仓库 / URL / 架构图）
  - 审查范围（全量 / 增量 / 模块）
  - 授权确认

可选：
  - 已知漏洞历史
  - 合规要求
  - 威胁模型（如已有）
  - 第三方依赖清单
```

---

## 完整行为链

```text
1. 确认授权和范围
   ↓
2. 威胁建模（新系统 / 新功能）
   ↓
3. 代码安全审查（SAST + 手动）
   ↓
4. 依赖 / 供应链扫描
   ↓
5. Web 漏洞检测（DAST / 手动）
   ↓
6. 认证鉴权审计
   ↓
7. 输出安全报告
   ↓
8. 跟踪修复
   ↓
9. 验证修复
   ↓
10. 沉淀经验
```

---

## Skills 模块总览

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [threat-modeling](skills/threat-modeling/SKILL.md) | 威胁建模 | STRIDE + Attack Tree |
| [code-security-review](skills/code-security-review/SKILL.md) | 代码安全审查 | SAST + 手动 + 依赖扫描 |
| [web-vulnerability](skills/web-vulnerability/SKILL.md) | Web 漏洞 | OWASP Top 10 + DAST |
| [auth-security-audit](skills/auth-security-audit/SKILL.md) | 认证鉴权审计 | 越权 / IDOR / Token |
| [supply-chain-security](skills/supply-chain-security/SKILL.md) | 供应链安全 | 依赖 / 镜像 / CI |
| [security-report](skills/security-report/SKILL.md) | 安全报告 | 风险等级 + 修复建议 |
| [dependency-audit](skills/dependency-audit/SKILL.md) | 依赖安全审计 | npm audit / Snyk / Trivy / 密钥扫描 |

---

## 禁止行为

```text
❌ 不要未经授权就扫描 / 测试
❌ 不要只报漏洞不给修复建议
❌ 不要把安全报告发给未授权人员
❌ 不要在报告中包含可直接利用的 PoC（除非授权）
❌ 不要忽略低危漏洞（可能组合利用）
❌ 不要只跑工具不做手动审查
❌ 不要把安全当"最后一步"（应该贯穿）
```

---

## 任务复杂度分级

```text
S 级（30 分钟~2 小时）：单 PR 安全审查 / 依赖扫描
  → code-security-review

M 级（2~8 小时）：模块级安全审计
  → + web-vulnerability + auth-security-audit

L 级（1~3 天）：系统级安全评审
  → 全部 6 skills

XL 级（3 天+）：合规审计 / 红队演练
  → 全部 + reverse-pentest 协作
```

---

## 通用质量检查

```text
□ 授权确认
□ 范围明确
□ OWASP Top 10 覆盖
□ 认证鉴权审计
□ 依赖扫描
□ 报告有风险等级
□ 报告有修复建议
□ 修复已验证
□ 不泄露敏感信息
□ 经验沉淀
```

---

## 常见坑

```text
1. 只跑工具不手动 → 漏业务逻辑漏洞
2. 只报漏洞不给修复 → 开发不知道怎么修
3. 安全最后做 → 返工成本高
4. 忽略 IDOR → 最常见的高危
5. 不测越权 → A 能改 B 数据
6. 依赖不扫描 → 已知漏洞进生产
7. 报告太技术 → PM 看不懂
8. 不验证修复 → 以为修了实际没修
9. 不做威胁建模 → 不知道重点在哪
10. 安全报告泄露 → 二次风险
```

---

## 与其他工作流的协作

### 上游

| 上游 | 安全需要的输入 |
|---|---|
| backend-engineer | 代码、接口清单、权限点 |
| frontend-engineer | 前端代码、CSP 配置 |
| api-designer | API 契约、权限矩阵 |
| devops-engineer | 基础设施配置、镜像 |
| database-engineer | 数据权限、敏感字段 |

### 下游

| 下游 | 安全交付内容 |
|---|---|
| backend-engineer | 漏洞修复需求 + 修复建议 |
| frontend-engineer | XSS / CSP 修复 |
| devops-engineer | 镜像扫描结果、网络策略 |
| reverse-pentest | 需要主动验证的漏洞 |
| project-manager | 安全风险报告 |
| technical-writer | 安全文档 |

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow security-engineer
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
是否发现新漏洞模式？→ 更新对应 skill
是否需要新扫描规则？→ 更新 tool-index
是否需要写入 field-journal？
```
