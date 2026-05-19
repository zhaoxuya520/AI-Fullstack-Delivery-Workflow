# Templates 目录说明

具体交付模板已迁移到对应 skill 下：

| 模板需求 | 位置 |
|---------|------|
| Dockerfile / Compose | [containerization/templates](../skills/containerization/templates/) |
| CI/CD 流水线 | [ci-cd-pipeline/templates](../skills/ci-cd-pipeline/templates/) |
| Terraform 模块 | [infrastructure-as-code/templates](../skills/infrastructure-as-code/templates/) |
| K8s 部署 | [kubernetes-orchestration/templates](../skills/kubernetes-orchestration/templates/) |
| Nginx / 网关 | [networking-gateway/templates](../skills/networking-gateway/templates/) |
| 密钥配置 | [secrets-config/templates](../skills/secrets-config/templates/) |
| 监控告警 | [monitoring-alerting/templates](../skills/monitoring-alerting/templates/) |

可复用模板优先放到对应 `skills/<skill>/templates/` 下；跨 skill 模板再放根 `templates/`。
