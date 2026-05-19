---
name: ci-cd-pipeline
description: CI/CD 流水线设计与实现，覆盖 GitHub Actions / GitLab CI / Jenkins。标准阶段：lint → test → build → scan → deploy。关注流水线性能、安全门禁、环境隔离。
---

# CI/CD 流水线（CI/CD Pipeline）

参考来源：GitHub Actions 官方文档、GitLab CI/CD 文档、Jenkins Pipeline 文档、DORA 指标、Continuous Delivery（Jez Humble）。

## 适用场景

- 新项目搭建 CI/CD 流水线
- 现有流水线优化（速度 / 可靠性）
- 多环境部署策略（dev → staging → prod）
- 安全门禁集成（SAST / DAST / 依赖扫描）
- Monorepo 流水线设计
- 自动化发布（语义化版本）

## 核心原则

```text
1. 快速反馈
   lint + unit test < 5 分钟
   全流水线 < 15 分钟

2. 失败即阻断
   任何阶段失败 → 不进入下一阶段
   安全扫描 HIGH → 阻断部署

3. 环境一致性
   CI 环境 = 生产环境（容器化）
   不依赖 CI runner 本地状态

4. 幂等可重试
   每次运行结果一致
   可安全重跑任何阶段

5. 最小权限
   每阶段只授予必要权限
   secrets 按环境隔离

6. 可观测
   每步有日志 + 耗时
   失败有明确错误信息

7. 主干开发
   PR → CI → merge → CD
   不维护长期分支
```

## 工作流程

```text
1. 确定流水线阶段
   - lint（代码风格 + 静态分析）
   - test（单元 + 集成）
   - build（编译 + 打包 + 镜像）
   - scan（安全扫描 + 许可证检查）
   - deploy（按环境分级）

2. 选择 CI 平台
   - GitHub Actions（GitHub 项目首选）
   - GitLab CI（GitLab 项目首选）
   - Jenkins（企业自建 / 复杂编排）

3. 设计触发规则
   - PR：lint + test + build
   - merge to main：全流程 + deploy staging
   - tag：deploy production
   - schedule：安全扫描 / 依赖更新

4. 配置缓存
   - 依赖缓存（node_modules / .m2 / go mod）
   - Docker 层缓存
   - 构建产物缓存

5. 集成安全门禁
   - SAST（Semgrep / CodeQL）
   - 依赖扫描（Trivy / Snyk）
   - 镜像扫描
   - License 检查

6. 环境部署
   - dev：自动部署（每次 merge）
   - staging：自动部署 + 冒烟测试
   - production：手动审批 / 自动（金丝雀）

7. 通知与报告
   - 失败通知（Slack / Teams）
   - 测试覆盖率报告
   - 部署记录
```

## 阶段详解

| 阶段 | 工具 | 耗时目标 | 失败策略 |
|---|---|---|---|
| lint | ESLint / Prettier / golangci-lint | <1min | 阻断 |
| test | Jest / pytest / go test | <5min | 阻断 |
| build | Docker / webpack / go build | <3min | 阻断 |
| scan | Trivy / Semgrep / CodeQL | <3min | HIGH 阻断 |
| deploy-staging | Helm / ArgoCD / Terraform | <5min | 阻断 |
| smoke-test | Playwright / curl | <2min | 回滚 |
| deploy-prod | 同 staging + 审批 | <5min | 回滚 |

## GitHub Actions 结构

```yaml
# .github/workflows/ci.yml 核心结构
name: CI/CD
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
    tags: ['v*']

jobs:
  lint:
    runs-on: ubuntu-latest
    steps: [checkout, setup, lint]

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps: [checkout, setup, test, coverage-upload]

  build:
    runs-on: ubuntu-latest
    needs: test
    steps: [checkout, docker-build, push-to-registry]

  scan:
    runs-on: ubuntu-latest
    needs: build
    steps: [trivy-scan, upload-sarif]

  deploy-staging:
    if: github.ref == 'refs/heads/main'
    needs: [build, scan]
    environment: staging
    steps: [deploy, smoke-test]

  deploy-prod:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: [build, scan]
    environment: production
    steps: [deploy, verify]
```

## 质量自检

```text
□ 流水线总耗时 < 15 分钟
□ lint + test 阶段 < 5 分钟
□ 依赖缓存已配置
□ Docker 层缓存已配置
□ 安全扫描集成（SAST + 依赖 + 镜像）
□ HIGH/CRITICAL 漏洞阻断部署
□ secrets 使用平台原生管理（不硬编码）
□ 环境隔离（dev / staging / prod）
□ 生产部署需审批或自动金丝雀
□ 失败通知已配置
□ 测试覆盖率有门槛
□ 流水线本身有版本控制
□ 可重试 / 幂等
```

## 常见坑

1. **不缓存依赖**——每次 CI 重新下载，耗时翻倍
2. **secrets 硬编码**——泄露到日志 / 仓库
3. **CI 环境与生产不一致**——本地过 CI 挂
4. **不并行**——串行跑 lint + test + build
5. **tag 触发无保护**——任何人可推 tag 触发部署
6. **不锁定 action 版本**——uses: actions/checkout@main 不安全
7. **测试不稳定（flaky）**——随机失败消耗信任
8. **无超时设置**——卡死的 job 占用 runner
9. **monorepo 全量构建**——改一个包触发所有
10. **deploy 无回滚**——失败后手动修复
11. **不上传产物**——调试困难
12. **分支策略混乱**——长期分支合并冲突

## 配套模板

- `templates/github-actions-template.md` — GitHub Actions 完整流水线模板

## 与其他 skill 的协作

```text
上游：
  containerization → 镜像构建步骤
  infrastructure-as-code → 部署基础设施

下游：
  kubernetes-orchestration → 部署目标
  release-strategy → 发布策略执行
  monitoring-alerting → 部署后验证
  secrets-config → CI secrets 管理
```
