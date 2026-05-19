# DevOps Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "Docker" / "容器" / "镜像" / "Dockerfile" | [containerization](containerization/SKILL.md) |
| "CI/CD" / "流水线" / "GitHub Actions" / "GitLab CI" | [ci-cd-pipeline](ci-cd-pipeline/SKILL.md) |
| "Terraform" / "基础设施" / "IaC" / "云资源" | [infrastructure-as-code](infrastructure-as-code/SKILL.md) |
| "K8s" / "Kubernetes" / "Helm" / "ArgoCD" / "Pod" | [kubernetes-orchestration](kubernetes-orchestration/SKILL.md) |
| "Nginx" / "域名" / "SSL" / "网关" / "负载均衡" | [networking-gateway](networking-gateway/SKILL.md) |
| "密钥" / "环境变量" / "Vault" / "配置中心" | [secrets-config](secrets-config/SKILL.md) |
| "灰度" / "蓝绿" / "金丝雀" / "回滚" / "发布" | [release-strategy](release-strategy/SKILL.md) |
| "监控" / "告警" / "Prometheus" / "Grafana" / "SLO" | [monitoring-alerting](monitoring-alerting/SKILL.md) |
| "容器编排" / "Docker Compose" / "Helm" / "编排" | [container-orchestration](container-orchestration/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单服务容器化（S 级） | containerization + ci-cd-pipeline |
| 多环境部署（M 级） | + secrets-config + release-strategy + networking-gateway |
| K8s 集群（L 级） | + kubernetes-orchestration + infrastructure-as-code + monitoring-alerting |
| 多集群 / 灾备（XL 级） | 全部 + SRE 协作 |

## 路由未命中

按 `CONTRIBUTING.md` 流程新增。
