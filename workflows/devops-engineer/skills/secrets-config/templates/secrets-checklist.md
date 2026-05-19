---
name: secrets-checklist
description: 密钥管理检查清单与轮换计划模板
---

# 密钥管理检查清单

## 密钥清单登记

| 密钥名称 | 类型 | 存储位置 | 所属服务 | 轮换周期 | 上次轮换 | 负责人 |
|---|---|---|---|---|---|---|
| DB_PASSWORD | 数据库密码 | Vault | user-service | 90 天 | YYYY-MM-DD | @team |
| JWT_SECRET | 签名密钥 | Vault | auth-service | 180 天 | YYYY-MM-DD | @team |
| AWS_ACCESS_KEY | 云凭证 | IAM Role | - | 动态 | N/A | @infra |

## 安全检查清单

```text
□ 代码扫描：无硬编码密钥
  - git-secrets / trufflehog 已集成 CI
  - pre-commit hook 拦截

□ 存储安全
  - 生产密钥在密钥管理服务中
  - 启用 encryption at rest
  - 访问日志已开启

□ 访问控制
  - 每服务独立策略
  - 最小权限原则
  - 环境隔离（dev 不能访问 prod）

□ 轮换计划
  - 所有密钥有轮换周期
  - 自动轮换已配置（如支持）
  - 双密钥过渡期已验证

□ CI/CD 安全
  - 使用 OIDC 联合认证
  - 无长期 Token 存储在 CI
  - PR 不能读取 prod secrets

□ 应急响应
  - 密钥泄露 SOP 已文档化
  - 紧急轮换流程已演练
  - 通知渠道已确认
```

## 轮换计划模板

```text
密钥：{{ secret_name }}
当前版本：v{{ N }}
轮换日期：YYYY-MM-DD

步骤：
1. 生成新密钥 v{{ N+1 }}
2. 配置应用同时接受 v{{ N }} 和 v{{ N+1 }}
3. 部署应用更新
4. 切换主密钥为 v{{ N+1 }}
5. 观察期（24h）确认无异常
6. 废弃 v{{ N }}
7. 更新密钥清单登记表

回滚：
- 如步骤 4 后异常 → 切回 v{{ N }}
- 通知相关团队
```
