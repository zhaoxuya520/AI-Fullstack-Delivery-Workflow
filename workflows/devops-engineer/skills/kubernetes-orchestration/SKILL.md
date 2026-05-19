---
name: kubernetes-orchestration
description: Kubernetes 工作负载编排，覆盖 Deployment / Service / Ingress / HPA / PDB。Helm Chart 管理、ArgoCD GitOps 部署、资源调优、高可用设计。
---

# Kubernetes 编排（Kubernetes Orchestration）

参考来源：Kubernetes 官方文档、Helm 文档、ArgoCD 文档、CNCF 最佳实践、Production Kubernetes（Josh Rosso）。

## 适用场景

- 应用部署到 Kubernetes 集群
- Helm Chart 编写与管理
- GitOps 工作流设计（ArgoCD / Flux）
- 自动伸缩配置（HPA / VPA / KEDA）
- 高可用与容灾（PDB / Pod Anti-Affinity）
- 资源请求与限制调优
- 服务网格集成（Istio / Linkerd）

## 核心原则

```text
1. 声明式管理
   所有资源 YAML 在 Git 中
   kubectl apply，不 kubectl edit

2. GitOps 单一真相源
   Git 仓库 = 集群期望状态
   ArgoCD / Flux 自动同步

3. 资源限制必设
   requests = 保证资源
   limits = 上限（防止 noisy neighbor）

4. 高可用默认
   replicas >= 2
   PDB 保证滚动更新不中断
   Pod Anti-Affinity 分散节点

5. 健康检查三件套
   livenessProbe：进程存活
   readinessProbe：可接收流量
   startupProbe：慢启动保护

6. 标签规范
   app.kubernetes.io/name
   app.kubernetes.io/version
   app.kubernetes.io/component

7. Namespace 隔离
   按团队 / 环境 / 服务域划分
   RBAC 按 namespace 授权
```

## 工作流程

```text
1. 设计资源清单
   - Deployment / StatefulSet / DaemonSet
   - Service（ClusterIP / NodePort / LoadBalancer）
   - Ingress / IngressRoute
   - ConfigMap / Secret
   - HPA / PDB

2. 编写 Helm Chart
   - Chart.yaml（元数据）
   - values.yaml（默认值）
   - templates/（资源模板）
   - 环境 override（values-prod.yaml）

3. 配置健康检查
   - livenessProbe（HTTP / TCP / exec）
   - readinessProbe（HTTP /health/ready）
   - startupProbe（慢启动应用）

4. 资源调优
   - 压测确定 requests
   - limits = 2x requests（初始）
   - VPA 推荐后调整

5. 自动伸缩
   - HPA：CPU / Memory / 自定义指标
   - KEDA：基于队列深度 / 请求数
   - 设置 min / max replicas

6. GitOps 部署
   - ArgoCD Application 定义
   - 自动同步 / 手动同步
   - 同步窗口（生产限制时段）

7. 可观测性
   - ServiceMonitor（Prometheus）
   - 日志标签（结构化）
   - 分布式追踪注入

8. 安全加固
   - NetworkPolicy 限制流量
   - PodSecurityStandard
   - ServiceAccount 最小权限
```

## 资源配置参考

| 资源类型 | 关键配置 | 注意事项 |
|---|---|---|
| Deployment | replicas / strategy / resources | 滚动更新 maxSurge / maxUnavailable |
| Service | type / port / targetPort | ClusterIP 为默认 |
| Ingress | host / path / TLS | 注解因 controller 而异 |
| HPA | min / max / metrics | 冷却时间避免抖动 |
| PDB | minAvailable / maxUnavailable | 保证滚动更新可用性 |
| NetworkPolicy | ingress / egress rules | 默认 deny all |

## Helm Chart 结构

```text
charts/my-app/
├── Chart.yaml
├── values.yaml              ← 默认值
├── values-staging.yaml      ← staging 覆盖
├── values-production.yaml   ← production 覆盖
├── templates/
│   ├── _helpers.tpl         ← 模板函数
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── pdb.yaml
│   ├── configmap.yaml
│   └── serviceaccount.yaml
└── README.md
```

## 质量自检

```text
□ 所有 Pod 设置 resources.requests 和 limits
□ livenessProbe + readinessProbe 已配置
□ replicas >= 2（生产环境）
□ PDB 已配置（minAvailable >= 1）
□ Pod Anti-Affinity 分散节点
□ 滚动更新策略合理（maxSurge / maxUnavailable）
□ HPA 已配置（CPU + 自定义指标）
□ NetworkPolicy 限制不必要流量
□ Secrets 不硬编码在 YAML 中
□ 标签规范（app / version / component）
□ Namespace 隔离
□ Helm values 按环境分离
□ ArgoCD 同步策略已配置
□ RBAC 最小权限
```

## 常见坑

1. **不设 resource limits**——单 Pod 吃光节点资源
2. **replicas=1**——单点故障，更新即中断
3. **无 PDB**——节点维护时全部驱逐
4. **readinessProbe 缺失**——未就绪即接流量，502
5. **liveness = readiness 相同**——依赖不可用时被杀
6. **HPA 指标单一**——只看 CPU，内存 OOM
7. **不用 Helm values 分环境**——生产配置写死
8. **kubectl edit 修改**——GitOps 漂移
9. **latest 标签**——不可回滚
10. **不设 terminationGracePeriodSeconds**——强杀丢请求
11. **Secret 明文在 Git**——安全事故
12. **Ingress 无 rate limit**——DDoS 打穿

## 配套模板

- `templates/k8s-deployment-template.md` — Deployment + Service + Ingress + HPA + PDB 完整模板

## 与其他 skill 的协作

```text
上游：
  containerization → 镜像产物
  infrastructure-as-code → 集群基础设施（EKS / GKE）
  ci-cd-pipeline → 构建触发部署

下游：
  networking-gateway → Ingress / Service Mesh
  monitoring-alerting → ServiceMonitor / 告警规则
  release-strategy → 金丝雀 / 蓝绿部署
  secrets-config → K8s Secrets / External Secrets
```
