# DevOps 工程师工作流路由

## 触发关键词

```yaml
workflow: devops-engineer
name: DevOps 工程师工作流
keywords: [Docker, CI/CD, GitHub Actions, GitLab CI, Kubernetes, Helm, Terraform, Nginx, 部署, 发布, 回滚, 监控, 告警, 容器, 镜像, 流水线]
entry: WORKFLOW.md
skills_routing: skills/routing.md
outputs: [Dockerfile, CI/CD 配置, K8s manifests, 部署文档, 监控配置, 回滚方案]
```

## Skills 入口

| 用户意图 | Skill |
|---------|-------|
| Docker / 容器 / 镜像 | containerization |
| CI/CD / 流水线 | ci-cd-pipeline |
| Terraform / IaC / 云资源 | infrastructure-as-code |
| K8s / Helm / ArgoCD | kubernetes-orchestration |
| Nginx / 域名 / SSL / 网关 | networking-gateway |
| 密钥 / 环境变量 / Vault | secrets-config |
| 灰度 / 蓝绿 / 回滚 | release-strategy |
| 监控 / 告警 / Prometheus | monitoring-alerting |

## 进入前检查

```text
□ 代码仓库可访问
□ 构建命令明确
□ 部署目标确定
□ 环境变量清单
□ 回滚要求明确
```

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 业务代码 | backend-engineer / frontend-engineer |
| 线上事故 | sre-operations |
| 安全漏洞 | security-engineer |
| 数据库迁移 | database-engineer |
| 测试用例 | qa-engineer |

## 路由未命中

返回根 `../../routing.md`。
