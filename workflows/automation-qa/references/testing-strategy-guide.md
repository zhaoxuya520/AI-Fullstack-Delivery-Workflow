# 自动化测试策略实战指南

> 面向 APP / 小程序 / 网页项目。覆盖测试金字塔、框架选型、CI 集成、覆盖率策略。

## 1. 测试金字塔

```text
         ╱╲
        ╱ E2E ╲        少量（5~10%）：关键用户流程
       ╱────────╲       Playwright / Cypress
      ╱ 集成测试  ╲     中量（20~30%）：API + 组件交互
     ╱──────────────╲   Supertest / Testing Library
    ╱   单元测试      ╲  大量（60~70%）：纯逻辑 + 工具函数
   ╱────────────────────╲ Vitest / Jest / JUnit / pytest
```

### 每层覆盖什么

| 层 | 覆盖 | 不覆盖 | 工具 |
|---|---|---|---|
| 单元 | 纯函数/工具/Hook/Service | UI渲染/网络 | Vitest/Jest |
| 集成 | 组件交互/API调用/DB操作 | 浏览器行为 | Testing Library/Supertest |
| E2E | 关键用户流程 | 所有分支 | Playwright |
| 视觉 | UI样式回归 | 功能逻辑 | Chromatic/Playwright |

---

## 2. 框架选型决策

### 前端测试

```text
单元/集成测试：
  Vitest（首选） — Vite 生态、快、ESM 原生
  Jest（备选）  — 老项目、React Native

组件测试：
  Testing Library（首选） — 用户视角、框架通用
  Storybook interaction tests — 视觉+交互

E2E 测试：
  Playwright（首选） — 多浏览器、自动等待、trace
  Cypress（备选）   — 开发体验好、社区大

Mock：
  MSW（首选） — 拦截网络层、浏览器+Node 通用
  vi.mock/jest.mock — 模块级 Mock
```

### 后端测试

```text
Java：
  JUnit 5 + Mockito + Testcontainers + REST Assured

Node.js：
  Vitest + Supertest + MSW + Testcontainers

Python：
  pytest + httpx + factory_boy + testcontainers

Go：
  testing + testify + httptest
```

---

## 3. 实操配置

### Vitest 配置（前端）

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.d.ts', 'src/test/**', 'src/**/*.stories.*'],
      thresholds: {
        statements: 70,
        branches: 60,
        functions: 70,
        lines: 70,
      },
    },
  },
});
```

### Playwright 配置（E2E）

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile', use: { ...devices['iPhone 14'] } },
  ],
  webServer: {
    command: 'pnpm dev',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E 测试示例

```typescript
// e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('用户登录', () => {
  test('正常登录流程', async ({ page }) => {
    await page.goto('/login');
    
    await page.getByLabel('邮箱').fill('user@example.com');
    await page.getByLabel('密码').fill('password123');
    await page.getByRole('button', { name: '登录' }).click();
    
    // 等待跳转到首页
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('欢迎回来')).toBeVisible();
  });

  test('密码错误提示', async ({ page }) => {
    await page.goto('/login');
    
    await page.getByLabel('邮箱').fill('user@example.com');
    await page.getByLabel('密码').fill('wrong');
    await page.getByRole('button', { name: '登录' }).click();
    
    await expect(page.getByText('邮箱或密码错误')).toBeVisible();
    await expect(page).toHaveURL('/login');  // 不跳转
  });
});
```

---

## 4. 覆盖率策略

```text
┌─ 覆盖率目标（务实版）───────────────────────────────────┐
│                                                          │
│  层次                │ 目标    │ 说明                    │
│  ────────────────────────────────────────────────────── │
│  核心业务逻辑        │ ≥ 90%  │ 计算/校验/状态转换      │
│  API 端点            │ ≥ 80%  │ 主路径 + 常见错误       │
│  UI 组件             │ ≥ 70%  │ 主要状态 + 交互         │
│  工具函数            │ ≥ 95%  │ 纯函数好测             │
│  配置/常量           │ 不要求  │ 没有逻辑               │
│                                                          │
│  原则：                                                  │
│  - 覆盖率是手段不是目的                                  │
│  - 高覆盖 ≠ 高质量（可能全是断言弱的测试）              │
│  - 关注边界条件和错误路径，不只是 happy path            │
│  - 新代码覆盖率 ≥ 80%（CI 门槛）                       │
└──────────────────────────────────────────────────────────┘
```

---

## 5. CI 中的测试流水线

```text
PR 提交：
  ┌─ Lint + Type Check ─────── 1min ──┐
  │                                     │
  ├─ 单元测试 + 覆盖率 ────── 2min ──┤  并行
  │                                     │
  ├─ 集成测试 ─────────────── 3min ──┤
  │                                     │
  └─ E2E 测试（关键路径）── 5min ────┘
  
  总计 ≤ 10 分钟（PR 反馈循环）

合入 main：
  全量 E2E + 视觉回归 + 性能测试

发布前：
  冒烟测试（核心流程 3~5 个 case）
```

---

## 6. 测试数据管理

```text
原则：
  - 测试数据与生产隔离
  - 每个测试用例自己准备数据（不依赖其他用例）
  - 测试后清理（或用事务回滚）
  - 敏感数据用 faker 生成

工具：
  - Testcontainers — 每次测试启动干净 DB
  - Factory 模式 — factory_boy(Python) / fishery(TS) / ObjectMother
  - Fixture — 固定数据集（JSON/SQL seed）
  - faker.js — 随机测试数据

反模式：
  ❌ 测试间共享数据 → 顺序依赖
  ❌ 用生产数据做测试 → 隐私风险
  ❌ 不清理测试数据 → DB 污染
```

---

## 7. 常见坑

```text
1. 测试太慢（>15min）→ 开发者跳过 → 形同虚设
2. E2E 不稳定（flaky）→ 信任崩塌 → 全部忽略
3. Mock 太多 → 不测真实行为 → 假安全感
4. 只测 happy path → 上线后边界崩溃
5. 覆盖率追数字 → 写无意义断言
6. 不在 CI 跑 → 本地跑过就合并
7. 测试与实现耦合 → 重构时全部重写
8. 不测异步/竞态 → 随机失败
9. 视觉回归不做 → CSS 改崩无感知
10. 不测移动端 → Safari/微信浏览器爆炸
```
