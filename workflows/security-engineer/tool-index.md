# 安全工程师工具索引

## SAST（静态分析）

| 工具 | 语言 | 用途 |
|---|---|---|
| Semgrep | 多语言 | 自定义规则 |
| SonarQube | 多语言 | 全面 |
| CodeQL | 多语言 | GitHub 深度 |
| Bandit | Python | Python 安全 |
| gosec | Go | Go 安全 |

## DAST（动态扫描）

| 工具 | 用途 |
|---|---|
| OWASP ZAP | 自动扫描 |
| Burp Suite | 手动 + 半自动 |
| Nuclei | 模板扫描 |

## SCA（依赖扫描）

| 工具 | 用途 |
|---|---|
| Snyk | 依赖 + 容器 |
| Dependabot | GitHub 自动 PR |
| Trivy | 容器 + 文件系统 |
| npm audit | npm |
| pip-audit | Python |

## 认证测试

| 工具 | 用途 |
|---|---|
| Burp Suite | 越权测试 |
| Postman | API 权限测试 |
| jwt.io | JWT 分析 |
| hashcat | 密码强度 |

## 威胁建模

| 工具 | 用途 |
|---|---|
| OWASP Threat Dragon | 可视化 |
| Microsoft TMT | 微软工具 |
| Mermaid | 数据流图 |

## 高风险操作

以下操作需要授权确认：
- 主动扫描目标系统
- 漏洞利用验证
- 密码破解测试
- 社会工程测试
- 生产环境测试
