---
name: secrets-config
description: 密钥与配置管理，覆盖 HashiCorp Vault / AWS Secrets Manager / K8s Secrets。12-Factor App 环境变量、配置中心、密钥轮换、零信任访问。
---

# 密钥与配置管理（Secrets & Configuration）

参考来源：HashiCorp Vault 文档、AWS Secrets Manager 文档、12-Factor App、NIST 密钥管理指南、External Secrets Operator 文档。

## 适用场景

- 应用密钥管理（数据库密码 / API Key / Token）
- 配置中心设计（多环境配置分发）
- 密钥轮换策略
- CI/CD 中的 secrets 注入
- Kubernetes Secrets 管理
- 证书生命周期管理
- 合规审计（谁在何时访问了什么）

## 核心原则

```text
1. 零硬编码
   代码中不出现任何密钥
   .env 文件不入 Git
   配置与代码分离

2. 最小权限
   每个服务只能访问自己的 secrets
   按环境隔离
   短期凭证优于长期凭证

3. 加密存储
   静态加密（at rest）
   传输加密（in transit）
   密钥加密密钥（KEK）分离

4. 自动轮换
   定期轮换（90 天内）
   轮换不中断服务
   旧密钥有过渡期

5. 审计追踪
   所有访问有日志
   异常访问告警
   定期审计权限

6. 12-Factor 配置
   环境变量注入
   不同环境不同值
   应用不关心来源

7. 灾备可恢复
   secrets 有备份
   恢复流程已演练
   不依赖单点
```

## 工作流程

```text
1. 密钥分类
   - 基础设施密钥（云 API Key / SSH Key）
   - 应用密钥（DB 密码 / JWT Secret / API Token）
   - 证书（TLS / mTLS / 签名证书）
   - 加密密钥（AES / RSA）

2. 选择存储方案
   - HashiCorp Vault（自建 / 多云）
   - AWS Secrets Manager（AWS 原生）
   - GCP Secret Manager（GCP 原生）
   - Azure Key Vault（Azure 原生）
   - K8s External Secrets Operator（K8s 集成）

3. 设计访问策略
   - 按服务 / 环境划分路径
   - RBAC / Policy 定义
   - 短期 Token（Vault lease）

4. 注入方式
   - 环境变量（12-Factor）
   - 文件挂载（K8s Volume）
   - SDK 直接读取（Vault Agent）
   - Init Container 预加载

5. 轮换策略
   - 自动轮换（Secrets Manager rotation）
   - 双密钥过渡（新旧并存）
   - 应用热加载（不重启）

6. CI/CD 集成
   - GitHub Secrets / GitLab CI Variables
   - Vault 动态凭证（CI 专用短期 Token）
   - OIDC 联合认证（无长期密钥）

7. 监控与审计
   - 访问日志
   - 异常检测（非工作时间 / 异常 IP）
   - 过期告警
   - 定期权限审计
```

## 方案对比

| 方案 | 适用场景 | 优势 | 劣势 |
|---|---|---|---|
| Vault | 多云 / 自建 | 功能全、动态凭证 | 运维复杂 |
| AWS Secrets Manager | AWS 原生 | 自动轮换、托管 | 锁定 AWS |
| K8s Secrets | K8s 内部 | 原生集成 | 默认 base64 非加密 |
| External Secrets | K8s + 外部源 | 同步外部到 K8s | 额外组件 |
| SOPS | Git 加密 | 版本控制友好 | 手动管理 |
| dotenv | 本地开发 | 简单 | 不适合生产 |

## 配置层次

```text
优先级（高 → 低）：
1. 环境变量（运行时注入）
2. 密钥管理服务（Vault / Secrets Manager）
3. ConfigMap / 配置文件
4. 应用默认值

规则：
- 密钥 → 必须从密钥管理服务获取
- 环境差异配置 → 环境变量 / ConfigMap
- 通用配置 → 应用默认值
- 本地开发 → .env（.gitignore）
```

## 质量自检

```text
□ 代码中无硬编码密钥（grep -r "password\|secret\|api_key"）
□ .env / .env.* 在 .gitignore 中
□ 生产密钥存储在密钥管理服务中
□ 每个服务独立的访问策略
□ 密钥有轮换计划（<= 90 天）
□ 轮换不中断服务（双密钥过渡）
□ CI/CD 使用短期凭证（OIDC / 动态 Token）
□ 访问日志已启用
□ 过期 / 即将过期密钥有告警
□ K8s Secrets 启用 encryption at rest
□ 灾备恢复流程已文档化
□ 新员工 / 离职有密钥权限变更流程
□ 定期审计（季度）
```

## 常见坑

1. **密钥硬编码**——泄露到 Git 历史，无法彻底清除
2. **.env 提交到 Git**——所有人可见
3. **K8s Secret 当安全**——默认只是 base64 编码
4. **不轮换**——泄露后长期有效
5. **共享密钥**——多服务用同一个，无法追踪
6. **CI 用长期 Token**——泄露影响面大
7. **不审计**——不知道谁访问了什么
8. **轮换中断服务**——没有双密钥过渡期
9. **密钥无备份**——Vault 挂了全部不可用
10. **环境变量日志泄露**——错误日志打印 env
11. **不区分环境**——dev 密钥能访问 prod
12. **离职不回收**——前员工仍有访问权

## 配套模板

- `templates/secrets-checklist.md` — 密钥管理检查清单与轮换计划模板

## 与其他 skill 的协作

```text
上游：
  infrastructure-as-code → Vault / KMS 基础设施
  ci-cd-pipeline → CI secrets 需求

下游：
  containerization → 运行时 secrets 注入
  kubernetes-orchestration → K8s Secrets / External Secrets
  networking-gateway → SSL 证书管理
  monitoring-alerting → 密钥过期告警
```
