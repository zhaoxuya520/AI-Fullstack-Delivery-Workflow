---
name: release-strategy
description: 设计发布策略时使用。适用于灰度 / 蓝绿 / 金丝雀 / 滚动更新 / 回滚方案。融合 Progressive Delivery + Feature Flags + 自动回滚。
---

# 发布策略（Release Strategy）

参考来源：Weaveworks Progressive Delivery、Argo Rollouts、Flagger、LaunchDarkly Feature Flags、Google SRE Release Engineering。

## 适用场景

- 生产发布方案设计
- 灰度 / 蓝绿 / 金丝雀选型
- 回滚方案设计
- Feature Flag 管理
- 数据库迁移与代码发布协调
- 多环境发布流程

## 核心原则

```text
1. 渐进式发布（Progressive Delivery）
   不一次性全量，逐步放量

2. 可观测驱动
   每个阶段看指标再决定继续 / 回滚

3. 回滚 < 5 分钟
   任何发布都必须能快速回滚

4. 代码与配置分离
   Feature Flag 控制功能开关

5. 数据库先于代码
   Schema 兼容变更先上，代码后上

6. 自动化优先
   人工审批可以有，但执行必须自动
```

## 发布策略对比

| 策略 | 停机 | 风险 | 复杂度 | 适合 |
|---|---|---|---|---|
| **滚动更新** | 无 | 中 | 低 | K8s 默认 |
| **蓝绿部署** | 无 | 低 | 中 | 快速切换 |
| **金丝雀** | 无 | 极低 | 高 | 核心服务 |
| **灰度（百分比）** | 无 | 低 | 中 | 用户级控制 |
| **Feature Flag** | 无 | 极低 | 中 | 功能级控制 |
| **大爆炸** | 可能 | 高 | 低 | 内部工具 |

## 滚动更新（Rolling Update）

```yaml
# K8s 默认策略
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%        # 最多多 25% Pod
      maxUnavailable: 25%  # 最多少 25% Pod
```

```text
流程：
  旧 Pod: [A] [A] [A] [A]
  → 新建 1 个新 Pod: [A] [A] [A] [A] [B]
  → 删 1 个旧 Pod: [A] [A] [A] [B]
  → 新建 1 个新 Pod: [A] [A] [A] [B] [B]
  → ...
  → 全部替换: [B] [B] [B] [B]

优点：零停机、简单
缺点：新旧版本共存期间可能不兼容
```

## 蓝绿部署（Blue-Green）

```text
流程：
  1. 当前生产（Blue）正常运行
  2. 部署新版本到 Green 环境
  3. 验证 Green（健康检查 + 冒烟测试）
  4. 切换流量：Blue → Green
  5. 观察 Green
  6. 确认无问题后销毁 Blue
  7. 出问题：切回 Blue（秒级）

优点：切换快、回滚快
缺点：需要双倍资源
```

```yaml
# K8s 蓝绿（用 Service selector 切换）
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  selector:
    app: my-app
    version: green  # 切换时改为 blue
```

## 金丝雀（Canary）

```text
流程：
  1. 部署新版本到 1 个 Pod（5% 流量）
  2. 监控 5 分钟（错误率 / P99）
  3. 指标正常 → 扩到 50%
  4. 监控 10 分钟
  5. 指标正常 → 100%
  6. 指标异常 → 自动回滚到 0%

工具：
  - Argo Rollouts
  - Flagger
  - Istio + 流量分配
```

```yaml
# Argo Rollouts 金丝雀
apiVersion: argoproj.io/v1alpha1
kind: Rollout
spec:
  strategy:
    canary:
      steps:
        - setWeight: 5
        - pause: { duration: 5m }
        - setWeight: 50
        - pause: { duration: 10m }
        - setWeight: 100
      analysis:
        templates:
          - templateName: success-rate
        startingStep: 1
```

## Feature Flag

```text
用途：
  - 功能开关（不发版就能开关功能）
  - 灰度（按用户 / 租户 / 百分比）
  - A/B 测试
  - Kill Switch（紧急关闭）

工具：
  - LaunchDarkly（SaaS）
  - Unleash（开源）
  - Flagsmith（开源）
  - GrowthBook（开源 + A/B）
  - 自建（Redis + 配置）

代码示例：
  if (featureFlags.isEnabled('new-checkout', { userId })) {
    return <NewCheckout />;
  }
  return <OldCheckout />;
```

## 回滚方案

### 三层回滚

```text
1. 代码回滚（最快，< 1 min）
   - K8s: kubectl rollout undo
   - Vercel: 一键回滚
   - Docker: 切回旧镜像 tag

2. 配置回滚（< 5 min）
   - Feature Flag 关闭
   - 环境变量回退
   - ConfigMap 回退

3. 数据回滚（最慢，分钟~小时）
   - 数据库 PITR
   - 备份恢复
   - 补偿脚本
```

### 回滚触发条件

```text
自动回滚（推荐）：
  - 错误率 > 5% 持续 2 分钟
  - P99 > 2x 基线持续 5 分钟
  - 健康检查失败 > 3 次

手动回滚：
  - 业务指标异常（订单数骤降）
  - 用户投诉激增
  - 安全漏洞发现
```

### K8s 回滚

```bash
# 查看历史
kubectl rollout history deployment/my-app

# 回滚到上一版本
kubectl rollout undo deployment/my-app

# 回滚到指定版本
kubectl rollout undo deployment/my-app --to-revision=3

# 查看状态
kubectl rollout status deployment/my-app
```

## 发布流程模板

```text
1. 代码合并到 main
   ↓
2. CI 跑通（lint + test + build + scan）
   ↓
3. 构建镜像（tag = git sha）
   ↓
4. 部署到 staging
   ↓
5. staging 验证（自动 + 手动）
   ↓
6. 审批（如需）
   ↓
7. 部署到 production（金丝雀 5%）
   ↓
8. 监控 5 分钟
   ↓
9. 扩到 50% → 监控 10 分钟
   ↓
10. 扩到 100%
    ↓
11. 观察 1 小时
    ↓
12. 完成（或回滚）
```

## 数据库与代码协调

```text
原则：Schema 变更先于代码变更

发布顺序：
  1. 数据库兼容变更（Expand）
  2. 部署新代码（读写新字段）
  3. 回填数据
  4. 数据库清理变更（Contract）

详见 database-engineer/migration-rollout skill
```

## 配套模板

- `templates/release-plan-template.md` — 发布计划 + 策略 + 回滚 + 监控

## 质量自检

```text
□ 发布策略选定（滚动 / 蓝绿 / 金丝雀）
□ 回滚方案可执行（< 5 min）
□ 回滚触发条件明确
□ 监控指标覆盖
□ staging 验证通过
□ 数据库变更先于代码
□ Feature Flag（如需）
□ 审批流程（如需）
□ 发布后观察期
□ 文档化（发布手册）
```

## 常见坑

1. **没有回滚方案**——故障时慌
2. **全量发布**——一次性影响所有用户
3. **不监控就放量**——问题扩散
4. **代码先于数据库**——新代码读不到新字段
5. **回滚太慢**——> 30 分钟
6. **Feature Flag 不清理**——代码里一堆 if/else
7. **staging 跳过**——生产才发现
8. **镜像 tag 用 latest**——不知道回滚到哪个版本
9. **不自动化**——手动部署出错
10. **告警不配**——发布后出问题不知道

## 与其他 skill 的协作

```text
上游：
  ci-cd-pipeline → 构建产物
  containerization → 镜像
  kubernetes-orchestration → 部署目标

下游：
  monitoring-alerting → 发布后监控
  sre-operations 工作流 → 事故响应
  database-engineer → 迁移协调
```
