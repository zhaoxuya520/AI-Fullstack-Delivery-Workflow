---
name: code-security-review
description: 代码安全审查时使用。适用于 PR 审查 / SAST 扫描 / 手动代码审计。融合 OWASP Code Review Guide + Semgrep + SonarQube。
---

# 代码安全审查（Code Security Review）

## 适用场景

- PR 安全审查
- SAST 工具扫描
- 手动代码审计
- 新依赖引入评估
- 敏感操作审查

## 核心原则

```text
1. 自动化 + 手动结合
   工具找已知模式，人找业务逻辑漏洞

2. 关注输入边界
   所有外部输入都不可信

3. 关注权限检查
   每个写操作都要校验权限

4. 关注敏感数据
   日志 / 响应 / 缓存中不能有密钥 / PII
```

## SAST 工具

| 工具 | 语言 | 特点 |
|---|---|---|
| **Semgrep** | 多语言 | 自定义规则、快 |
| **SonarQube** | 多语言 | 全面、企业级 |
| **CodeQL** | 多语言 | GitHub 原生、深度 |
| **Snyk Code** | 多语言 | AI 辅助 |
| **Bandit** | Python | Python 专用 |
| **ESLint Security** | JS/TS | 前端安全规则 |
| **SpotBugs** | Java | Java 安全 |
| **gosec** | Go | Go 安全 |

## 审查清单（每次 PR）

```text
输入校验：
  □ 所有外部输入有校验（类型 / 长度 / 格式）
  □ SQL 参数化（不拼接）
  □ HTML 转义（防 XSS）
  □ 路径不拼接用户输入（防路径穿越）
  □ URL 不直接用用户输入（防 SSRF）
  □ 正则不用用户输入（防 ReDoS）

认证鉴权：
  □ 写操作有认证
  □ 资源归属校验（不能改别人的）
  □ 角色权限校验
  □ 不暴露存在性

敏感数据：
  □ 不日志输出密钥 / Token / PII
  □ 不在响应中返回内部信息
  □ 密码用 bcrypt / argon2
  □ 敏感配置用环境变量

依赖：
  □ 新依赖已评估（Stars / 维护 / 安全历史）
  □ 版本锁定
  □ 无已知高危漏洞
```

## 配套模板

- `templates/security-review-checklist.md` — PR 安全审查清单

## 质量自检

```text
□ SAST 工具集成 CI
□ 手动审查关键路径
□ 输入校验完整
□ 权限检查完整
□ 敏感数据不泄露
□ 依赖安全
□ 发现问题有修复建议
```

## 常见坑

1. **只跑工具不手动**——漏业务逻辑
2. **不审查权限**——IDOR 最常见
3. **日志输出 Token**——泄露
4. **新依赖不评估**——引入恶意包
5. **SQL 拼接**——注入

## 与其他 skill 的协作

```text
上游：
  threat-modeling → 重点审查区域

下游：
  security-report → 发现纳入报告
  backend-engineer → 修复
```
