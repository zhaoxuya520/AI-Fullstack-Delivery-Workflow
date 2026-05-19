---
name: e2e-testing
description: E2E 测试实现时使用。适用于 Playwright / Cypress 关键用户旅程测试。融合 Page Object Model + 视觉回归 + 可访问性测试。
---

# E2E 测试（End-to-End Testing）

## 适用场景

- 关键用户旅程（5~15 条）
- 跨页面流程
- 视觉回归测试
- 可访问性自动化
- 多浏览器兼容

## 核心原则

```text
1. E2E 要少（金字塔顶层）
   5~15 条关键旅程，不是全覆盖

2. Page Object Model
   封装页面操作，不在测试里写 selector

3. 稳定 selector
   data-testid > role > text > CSS

4. 不依赖时间
   用 waitFor / expect，不用 sleep

5. 并行执行
   每个测试独立，可并行
```

## Playwright（推荐）

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'mobile', use: { ...devices['Pixel 5'] } },
  ],
});

// Page Object
class LoginPage {
  constructor(private page: Page) {}
  
  async goto() { await this.page.goto('/login'); }
  
  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Login' }).click();
  }
  
  async expectError(message: string) {
    await expect(this.page.getByRole('alert')).toContainText(message);
  }
}

// 测试
test('user can login and create order', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('test@example.com', 'password123');
  
  await expect(page).toHaveURL('/dashboard');
  
  await page.getByRole('button', { name: 'New Order' }).click();
  await page.getByLabel('Product').selectOption('100');
  await page.getByRole('button', { name: 'Submit' }).click();
  
  await expect(page.getByText('Order created')).toBeVisible();
});

// 可访问性测试
import AxeBuilder from '@axe-core/playwright';

test('home page is accessible', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## Cypress

```typescript
// cypress/e2e/login.cy.ts
describe('Login Flow', () => {
  it('logs in successfully', () => {
    cy.visit('/login');
    cy.findByLabelText(/email/i).type('test@example.com');
    cy.findByLabelText(/password/i).type('password123');
    cy.findByRole('button', { name: /login/i }).click();
    cy.url().should('include', '/dashboard');
  });
});
```

## 配套模板

- `templates/e2e-test-template.md` — E2E 测试模板（Page Object + 关键旅程）

## 质量自检

```text
□ 关键旅程覆盖（5~15 条）
□ Page Object Model
□ 稳定 selector（data-testid）
□ 不用 sleep
□ 并行执行
□ 多浏览器
□ 视觉回归（如需）
□ 可访问性测试
□ CI 集成
□ Flaky 率 < 1%
```

## 常见坑

1. **E2E 太多**——慢且脆弱
2. **不用 Page Object**——重复代码
3. **用 sleep**——Flaky
4. **CSS selector**——UI 改就挂
5. **不并行**——CI 慢
6. **不处理 Flaky**——干扰真问题

## 与其他 skill 的协作

```text
上游：
  integration-testing → 集成层

下游：
  ci-test-integration → CI 集成
```
