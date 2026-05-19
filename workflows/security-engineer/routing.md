# 安全工程师工作流路由

## 触发关键词

```yaml
workflow: security-engineer
name: 安全工程师工作流
keywords: [安全评审, 漏洞, 权限风险, 依赖安全, XSS, SQL注入, SSRF, 越权, IDOR, 威胁建模, OWASP, 供应链]
entry: WORKFLOW.md
skills_routing: skills/routing.md
outputs: [安全报告, 风险等级, 修复建议, 安全Checklist]
```

## Skills 入口

| 用户意图 | Skill |
|---------|-------|
| 威胁建模 / STRIDE | threat-modeling |
| 代码审查 / SAST | code-security-review |
| XSS / SQLi / SSRF | web-vulnerability |
| 越权 / IDOR / Token | auth-security-audit |
| 依赖 / 镜像 / 供应链 | supply-chain-security |
| 安全报告 | security-report |

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 主动渗透 / 漏洞利用 | reverse-pentest |
| 代码修复 | backend-engineer / frontend-engineer |
| 部署安全配置 | devops-engineer |
| 线上事故 | sre-operations |

## 路由未命中

返回根 `../../routing.md`。
