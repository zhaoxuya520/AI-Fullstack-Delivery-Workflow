# 安全 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "威胁建模" / "STRIDE" / "攻击面" | [threat-modeling](threat-modeling/SKILL.md) |
| "代码审查" / "SAST" / "安全扫描" | [code-security-review](code-security-review/SKILL.md) |
| "XSS" / "SQL注入" / "SSRF" / "OWASP" | [web-vulnerability](web-vulnerability/SKILL.md) |
| "越权" / "IDOR" / "Token" / "认证审计" | [auth-security-audit](auth-security-audit/SKILL.md) |
| "依赖漏洞" / "供应链" / "镜像安全" | [supply-chain-security](supply-chain-security/SKILL.md) |
| "安全报告" / "风险等级" / "修复建议" | [security-report](security-report/SKILL.md) |
| "npm audit" / "Snyk" / "Trivy" / "依赖审计" / "密钥扫描" | [dependency-audit](dependency-audit/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| PR 安全审查（S 级） | code-security-review |
| 模块安全审计（M 级） | + web-vulnerability + auth-security-audit |
| 系统安全评审（L 级） | 全部 7 skills |
| 合规 / 红队（XL 级） | 全部 + reverse-pentest |

## 路由未命中

按 `CONTRIBUTING.md` 流程新增。
