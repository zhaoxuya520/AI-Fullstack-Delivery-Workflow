# DevOps 工程师工作流（DevOps Engineer Workflow）

## 定位

DevOps 工程师工作流负责把代码变成 **可部署、可回滚、可观测、可自愈** 的生产服务：容器化、CI/CD 流水线、基础设施即代码、Kubernetes 编排、网络网关、密钥配置、发布策略、监控告警。

它不替代后端工程师（业务代码）、SRE（线上运维 / 事故响应）、安全工程师（攻击面）。它负责 **从代码提交到生产运行的全链路自动化**。

本工作流采用 **skills 模块化架构**。

---

## 适用场景

```text
Docker / Podman 容器化
CI/CD 流水线（GitHub Actions / GitLab CI / Jenkins）
基础设施即代码（Terraform / Pulumi / CloudFormation）
Kubernetes 部署 / Helm / ArgoCD / GitOps
Nginx / Traefik / API Gateway / 负载均衡
密钥管理 / 配置中心 / 环境变量
发布策略（灰度 / 蓝绿 / 金丝雀 / 回滚）
监控告警（Prometheus / Grafana / PagerDuty）
日志收集（ELK / Loki）
SSL / DNS / CDN 配置
```

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 业务代码实现 | backend-engineer / frontend-engineer |
| 线上事故响应 / 复盘 | sre-operations |
| 安全漏洞 / 渗透 | security-engineer |
| 数据库迁移 / 优化 | database-engineer |
| 测试用例设计 | qa-engineer |
| 需求不清 | product-manager |

---

## 输入

### 必需输入

```text
代码仓库（Git URL）
构建命令（build / test / lint）
运行环境（Node / Python / Java / Go）
部署目标（云 / K8s / VPS / Serverless）
环境变量清单
健康检查端点
回滚要求
```

### 可选输入

```text
现有 CI/CD 配置
Dockerfile（如已有）
Kubernetes manifests
Terraform state
监控需求（SLO / 告警规则）
域名 / SSL 证书
第三方依赖（数据库 / Redis / MQ）
```

### 输入不足时先补问

```text
1. 代码用什么语言 / 框架？构建命令是什么？
2. 部署到哪里？（AWS / GCP / Azure / 自建 / Vercel）
3. 是否需要数据库 / Redis / MQ？
4. 环境变量有哪些？哪些是密钥？
5. 是否需要多环境（dev / staging / prod）？
6. 回滚策略是什么？
7. 监控 / 告警需求？
8. 域名 / SSL 是否已有？
```

---

## 完整行为链

```text
1. 读取代码仓库 / 构建命令 / 部署目标
   ↓
2. 检查 field-journal → 是否有同类部署经验
   ↓
3. 读取 skills/routing.md → 路由到需要的 skills
   ↓
4. 判断复杂度（S/M/L/XL）
   ↓
5. 容器化（Dockerfile）
   ↓
6. CI/CD 流水线
   ↓
7. 基础设施（如需 IaC）
   ↓
8. 部署 + 发布策略
   ↓
9. 监控 + 告警
   ↓
10. 验证 + 交接
    ↓
11. 沉淀经验 → field-journal
```

---

## Skills 模块总览

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [containerization](skills/containerization/SKILL.md) | Docker / 镜像优化 | 多阶段构建 + 安全扫描 |
| [ci-cd-pipeline](skills/ci-cd-pipeline/SKILL.md) | CI/CD 流水线 | GitHub Actions / GitLab CI / Jenkins |
| [infrastructure-as-code](skills/infrastructure-as-code/SKILL.md) | IaC | Terraform / Pulumi / CloudFormation |
| [kubernetes-orchestration](skills/kubernetes-orchestration/SKILL.md) | K8s 部署 | Deployment / Helm / ArgoCD / GitOps |
| [networking-gateway](skills/networking-gateway/SKILL.md) | 网络 / 网关 | Nginx / Traefik / DNS / SSL / CDN |
| [secrets-config](skills/secrets-config/SKILL.md) | 密钥 / 配置 | Vault / AWS SM / K8s Secrets / .env |
| [release-strategy](skills/release-strategy/SKILL.md) | 发布策略 | 灰度 / 蓝绿 / 金丝雀 / 回滚 |
| [monitoring-alerting](skills/monitoring-alerting/SKILL.md) | 监控告警 | Prometheus / Grafana / SLO / PagerDuty |
| [container-orchestration](skills/container-orchestration/SKILL.md) | 容器编排 | Docker / K8s / Helm 部署 |

---

## 禁止行为

```text
❌ 不要在没有健康检查的情况下部署
❌ 不要把密钥写进代码 / Dockerfile / CI 日志
❌ 不要没有回滚方案就上生产
❌ 不要跳过 staging 直接部署 prod
❌ 不要用 latest 标签部署生产镜像
❌ 不要 root 用户运行容器
❌ 不要没有资源限制（CPU / Memory）
❌ 不要没有监控就上线
❌ 不要手动部署（必须自动化）
❌ 不要 force push 到 main
```

---

## 任务复杂度分级

```text
S 级（30 分钟~2 小时）：单服务 Dockerfile + CI
  → containerization + ci-cd-pipeline

M 级（2~8 小时）：多环境 + 密钥 + 部署
  → + secrets-config + release-strategy + networking-gateway

L 级（1~3 天）：K8s + IaC + 监控
  → + kubernetes-orchestration + infrastructure-as-code + monitoring-alerting

XL 级（3 天+）：多集群 / 多区域 / 灾备
  → 全部 8 skills + SRE 协作
```

---

## 通用质量检查

```text
□ Dockerfile 多阶段 + 非 root + 资源限制
□ CI/CD 流水线：lint → test → build → deploy
□ 环境变量不硬编码
□ 密钥用 Vault / Secrets Manager
□ 健康检查配置（liveness + readiness）
□ 回滚方案可执行（< 5 min）
□ 监控覆盖（CPU / Memory / 错误率 / P99）
□ 告警配置（不 alert fatigue）
□ SSL / HTTPS 强制
□ 日志收集（结构化 + 集中）
□ 镜像扫描（Trivy / Snyk）
□ 不用 latest 标签
□ 资源限制（requests / limits）
□ 多环境隔离（dev / staging / prod）
□ 文档化（部署手册）
```

---

## 常见坑

```text
1. 密钥进代码 / 日志 → 泄露
2. 没有健康检查 → K8s 不知道服务挂了
3. latest 标签 → 不可追溯
4. root 运行容器 → 安全风险
5. 没有资源限制 → OOM 杀邻居
6. 手动部署 → 不可重复
7. 没有回滚 → 故障时慌
8. staging 跳过 → 生产才发现问题
9. CI 太慢 → 开发不愿跑
10. 告警太多 → alert fatigue
11. 不监控就上线 → 出事才知道
12. DNS TTL 太长 → 切换慢
13. SSL 过期 → 服务不可用
14. 镜像太大 → 部署慢
15. 不扫描镜像 → 漏洞进生产
```

---

## 与其他工作流的协作

### 上游

| 上游 | DevOps 需要的输入 |
|---|---|
| backend-engineer | Dockerfile、构建命令、健康检查、配置 |
| frontend-engineer | 构建产物、环境变量、部署配置 |
| database-engineer | 迁移命令、备份策略 |
| project-manager | 发布计划、里程碑 |

### 下游

| 下游 | DevOps 交付内容 |
|---|---|
| sre-operations | 监控配置、告警规则、Runbook |
| qa-engineer | 测试环境、Preview 环境 |
| security-engineer | 镜像扫描结果、网络策略 |
| technical-writer | 部署文档、运维手册 |

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow devops-engineer
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
是否形成新的 CI/CD 模板？→ 加入对应 skill 的 templates/
是否发现新的部署坑？→ 更新 pitfalls.md
是否需要新增工具？→ 更新 tool-index.md
是否需要写入 field-journal？
```
