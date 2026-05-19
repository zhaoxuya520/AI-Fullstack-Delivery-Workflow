---
name: infrastructure-as-code
description: 基础设施即代码实践，覆盖 Terraform / Pulumi / CloudFormation。关注状态管理、模块化设计、drift 检测、环境一致性、变更审计。
---

# 基础设施即代码（Infrastructure as Code）

参考来源：Terraform 官方文档、Pulumi 文档、AWS CloudFormation 文档、HashiCorp Best Practices、Infrastructure as Code（Kief Morris）。

## 适用场景

- 云基础设施初始化（VPC / EKS / RDS / S3）
- 多环境一致性管理（dev / staging / prod）
- 基础设施模块化与复用
- Drift 检测与修复
- 基础设施变更审计
- 灾备环境快速重建
- 成本优化（资源标签 + 生命周期）

## 核心原则

```text
1. 声明式优先
   描述期望状态，不描述步骤
   工具负责收敛到目标状态

2. 状态集中管理
   远程 backend（S3 / GCS / Terraform Cloud）
   状态锁防止并发修改

3. 模块化复用
   通用组件抽成模块
   模块有版本 + 文档

4. 环境隔离
   每环境独立状态文件
   变量文件区分环境差异

5. 变更可审计
   PR 触发 plan → 人工审批 → apply
   所有变更有记录

6. 最小权限
   IaC 执行角色只有必要权限
   不使用 admin 角色

7. 不可变基础设施
   修改 = 替换，不原地修改
   减少配置漂移
```

## 工作流程

```text
1. 规划基础设施
   - 画架构图（VPC / 子网 / 安全组）
   - 确定资源依赖关系
   - 选择 IaC 工具

2. 初始化项目结构
   - 目录按环境 / 层分离
   - 配置远程 backend
   - 设置状态锁

3. 编写模块
   - 网络层（VPC / Subnet / NAT）
   - 计算层（EKS / ECS / EC2）
   - 数据层（RDS / ElastiCache / S3）
   - 安全层（IAM / SG / KMS）

4. 环境变量化
   - terraform.tfvars 按环境
   - 敏感值从 Vault / SSM 读取
   - 输出值供下游使用

5. CI 集成
   - PR → terraform plan（自动评论）
   - merge → terraform apply（审批后）
   - 定时 → drift 检测

6. Drift 检测
   - 定期 terraform plan 对比
   - 告警非 IaC 变更
   - 修复或导入

7. 文档与标签
   - 资源标签（team / env / cost-center）
   - 模块 README
   - 变更日志
```

## 项目结构（Terraform）

```text
infrastructure/
├── modules/                    ← 可复用模块
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── eks-cluster/
│   └── rds/
├── environments/               ← 环境配置
│   ├── dev/
│   │   ├── main.tf            ← 调用模块
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── production/
├── .terraform-version
└── Makefile
```

## 工具对比

| 特性 | Terraform | Pulumi | CloudFormation |
|---|---|---|---|
| 语言 | HCL | TypeScript/Python/Go | YAML/JSON |
| 状态管理 | 远程 backend | Pulumi Cloud | AWS 托管 |
| 多云 | ✅ | ✅ | ❌（AWS only） |
| Drift 检测 | plan | preview | drift detection |
| 模块生态 | Registry 丰富 | 较少 | 嵌套栈 |
| 学习曲线 | 中 | 低（熟悉语言） | 中 |

## 质量自检

```text
□ 远程 backend 已配置（S3 + DynamoDB 锁）
□ 状态文件不在 git 中
□ 模块有 variables / outputs / README
□ 敏感值不硬编码（用 SSM / Vault）
□ 资源有标签（Name / Environment / Team / CostCenter）
□ PR 自动运行 plan
□ plan 输出作为 PR 评论
□ apply 需审批
□ Drift 检测定期运行
□ 模块有版本锁定
□ 最小权限 IAM 角色
□ 有 destroy 保护（prevent_destroy）
□ 输出值供下游消费
```

## 常见坑

1. **状态文件本地存储**——团队协作冲突、丢失即灾难
2. **不锁定 provider 版本**——升级后 plan 变化不可控
3. **硬编码 secrets**——泄露到 git
4. **不用模块**——环境间复制粘贴，drift 不一致
5. **手动修改资源**——状态漂移，plan 混乱
6. **不审批直接 apply**——误删生产资源
7. **大状态文件**——plan 慢、blast radius 大
8. **循环依赖**——模块间互相引用
9. **不打标签**——成本无法归属
10. **忽略 plan 输出**——没看到 destroy 就 apply
11. **不做 import**——已有资源重新创建
12. **workspace 滥用**——不如目录隔离清晰

## 配套模板

- `templates/terraform-module-template.md` — Terraform 模块标准结构模板

## 与其他 skill 的协作

```text
上游：
  架构设计 → 基础设施需求
  secrets-config → 敏感配置来源

下游：
  kubernetes-orchestration → 集群基础设施
  networking-gateway → 网络 / LB / DNS
  ci-cd-pipeline → 基础设施部署阶段
  monitoring-alerting → 监控基础设施
```
