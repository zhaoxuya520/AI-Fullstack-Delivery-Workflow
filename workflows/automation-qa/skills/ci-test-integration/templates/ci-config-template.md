# CI 测试配置模板

## 项目信息
```text
CI 平台：GitHub Actions / GitLab CI
测试框架：Vitest / Jest / pytest / JUnit
E2E：Playwright / Cypress
负责人：
```

## 流水线阶段

| 阶段 | 内容 | 时长目标 | 阻塞 |
|---|---|---|---|
| Lint | ESLint + Prettier | < 1min | ✅ |
| TypeCheck | tsc | < 1min | ✅ |
| Unit | Vitest | < 3min | ✅ |
| Integration | Testcontainers | < 5min | ✅ |
| E2E | Playwright | < 10min | ✅ |
| Coverage | codecov | - | 警告 |

## 缓存配置
```text
□ node_modules（pnpm store）
□ Playwright browsers
□ Docker layers
□ 构建产物
```

## 并行化
```text
□ 按类型分 job
□ E2E 分片：[数量]
□ Matrix 策略
```

## 自检
```text
□ PR 必跑
□ 失败阻塞
□ < 15 分钟
□ 缓存
□ 并行
□ 报告
□ Flaky 隔离
```
