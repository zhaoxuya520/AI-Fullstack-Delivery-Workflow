---
name: ci-test-integration
description: 把自动化测试集成到 CI/CD 流水线时使用。适用于 GitHub Actions / GitLab CI 测试阶段配置、并行化、缓存、失败阻塞。
---

# CI 测试集成（CI Test Integration）

## 适用场景

- 测试集成到 CI 流水线
- 测试并行化加速
- 缓存优化（依赖 / 构建）
- 失败阻塞合并
- 测试报告自动化
- Flaky 测试隔离

## 核心原则

```text
1. 每次 PR 必跑测试
2. 失败必须阻塞合并
3. 测试要快（< 15 分钟）
4. 并行化（多 worker）
5. 缓存依赖（不每次装）
6. 报告可视化（PR 评论）
```

## GitHub Actions 模板

```yaml
name: Test
on: [push, pull_request]

jobs:
  unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: 'pnpm' }
      - run: pnpm install --frozen-lockfile
      - run: pnpm test:unit
      - run: pnpm test:coverage
      - uses: codecov/codecov-action@v4

  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: pnpm install
      - run: npx playwright install --with-deps
      - run: pnpm build
      - run: pnpm test:e2e
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

## 并行化策略

```text
方案 A：按类型分 job
  unit → 1 job（快）
  integration → 1 job
  e2e → 1 job（慢）

方案 B：分片（Sharding）
  e2e 拆 4 个 shard 并行
  matrix: { shard: [1, 2, 3, 4] }

方案 C：按变更范围
  只跑受影响模块的测试
```

## 配套模板

- `templates/ci-config-template.md` — CI 测试配置模板

## 质量自检

```text
□ PR 必跑测试
□ 失败阻塞合并
□ 总时长 < 15 分钟
□ 缓存依赖
□ 并行化
□ 报告可视化
□ Flaky 隔离
□ 覆盖率上报
```

## 常见坑

1. **CI 太慢**——开发跳过
2. **不阻塞合并**——形同虚设
3. **不缓存**——每次装依赖 5 分钟
4. **Flaky 不处理**——干扰真问题
5. **不并行**——串行跑 30 分钟

## 与其他 skill 的协作

```text
上游：
  unit/integration/e2e/contract → 测试代码

下游：
  devops-engineer ci-cd-pipeline → 流水线配置
  coverage-reporting → 覆盖率
```
