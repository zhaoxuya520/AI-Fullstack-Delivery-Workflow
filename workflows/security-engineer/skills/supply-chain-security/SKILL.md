---
name: supply-chain-security
description: 供应链安全时使用。适用于依赖漏洞扫描 / 镜像安全 / CI 投毒防护 / SBOM。融合 SLSA + Sigstore + Snyk + Trivy。
---

# 供应链安全（Supply Chain Security）

## 适用场景

- 依赖漏洞扫描（npm / pip / Maven）
- 容器镜像安全扫描
- CI/CD 流水线安全
- SBOM（软件物料清单）
- 恶意包检测

## 核心原则

```text
1. 依赖 = 攻击面
   每个依赖都可能有漏洞

2. 锁定版本
   lockfile 必须提交

3. 定期扫描
   不是一次性，是持续的

4. 最小依赖
   不需要的不装

5. 镜像也要扫
   基础镜像可能有漏洞
```

## 工具

| 工具 | 用途 |
|---|---|
| Snyk | 依赖 + 容器 + 代码 |
| Dependabot | GitHub 自动 PR |
| Trivy | 容器 + 文件系统 |
| npm audit | npm 依赖 |
| pip-audit | Python 依赖 |
| OWASP Dependency-Check | Java |
| Grype | 容器扫描 |
| Syft | SBOM 生成 |
| cosign | 镜像签名 |

## CI 集成

```yaml
# GitHub Actions
- name: Trivy scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'my-app:${{ github.sha }}'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'
```

## 配套模板

- `templates/dependency-audit-template.md` — 依赖审计报告

## 质量自检

```text
□ CI 集成依赖扫描
□ CI 集成镜像扫描
□ 高危漏洞阻塞合并
□ lockfile 提交
□ 定期更新依赖
□ SBOM 生成
□ 新依赖评估流程
```

## 常见坑

1. **不扫描**——已知漏洞进生产
2. **不锁版本**——构建不可复现
3. **不更新**——漏洞累积
4. **只扫不修**——扫描结果无人看
5. **typosquatting**——安装错误包名

## 与其他 skill 的协作

```text
上游：
  devops-engineer ci-cd-pipeline → CI 集成

下游：
  security-report → 扫描结果纳入报告
  backend/frontend → 修复
```
