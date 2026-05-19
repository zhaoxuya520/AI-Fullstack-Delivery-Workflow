# DevOps 工程师工具索引

## 使用原则

1. 优先复用项目已有工具链。
2. 生产操作必须通过 CI/CD，不手动。
3. 密钥不进代码 / 日志。
4. 工具缺失时先检查本文件和根 `../../tool-index.md`。

## 容器

| 工具 | 用途 |
|---|---|
| Docker | 容器构建 / 运行 |
| Podman | 无 daemon 替代 |
| Buildah | OCI 镜像构建 |
| Kaniko | CI 内构建（无 Docker daemon）|
| Trivy | 镜像漏洞扫描 |
| Dive | 镜像层分析 |

## CI/CD

| 工具 | 用途 |
|---|---|
| GitHub Actions | GitHub 原生 CI |
| GitLab CI | GitLab 原生 CI |
| Jenkins | 老牌 CI |
| CircleCI | 云 CI |
| ArgoCD | GitOps 部署 |
| Flux | GitOps 部署 |
| Drone CI | 轻量 CI |

## 基础设施

| 工具 | 用途 |
|---|---|
| Terraform | IaC 主流 |
| Pulumi | 编程语言 IaC |
| CloudFormation | AWS 原生 |
| Ansible | 配置管理 |
| Crossplane | K8s 原生 IaC |

## Kubernetes

| 工具 | 用途 |
|---|---|
| kubectl | K8s CLI |
| Helm | 包管理 |
| Kustomize | 配置覆盖 |
| ArgoCD | GitOps |
| k9s | TUI 管理 |
| Lens | GUI 管理 |
| Argo Rollouts | 金丝雀 / 蓝绿 |
| Flagger | 自动金丝雀 |

## 网络

| 工具 | 用途 |
|---|---|
| Nginx | 反向代理 / 负载均衡 |
| Traefik | 云原生网关 |
| Caddy | 自动 HTTPS |
| Cloudflare | CDN / DNS / WAF |
| cert-manager | K8s SSL 自动化 |
| ExternalDNS | K8s DNS 自动化 |

## 密钥 / 配置

| 工具 | 用途 |
|---|---|
| HashiCorp Vault | 密钥管理 |
| AWS Secrets Manager | AWS 密钥 |
| Azure Key Vault | Azure 密钥 |
| GCP Secret Manager | GCP 密钥 |
| SOPS | 加密配置文件 |
| External Secrets Operator | K8s 外部密钥同步 |
| dotenv-vault | .env 加密 |

## 监控

| 工具 | 用途 |
|---|---|
| Prometheus | 指标收集 |
| Grafana | 可视化 |
| Alertmanager | 告警路由 |
| Loki | 日志收集 |
| Tempo | 追踪 |
| PagerDuty | On-call |
| OpsGenie | On-call |
| UptimeRobot | Uptime 监控 |
| Sentry | 错误追踪 |

## 模板入口

各 skill 的模板在 `skills/<skill-name>/templates/`。

## 高风险工具边界

以下操作需要审批：
- 生产 K8s 集群变更
- Terraform apply（生产）
- DNS 变更
- SSL 证书操作
- 密钥轮换
- 数据库迁移触发
