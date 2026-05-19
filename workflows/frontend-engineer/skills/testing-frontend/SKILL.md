---
name: testing-frontend
description: 实现前端测试时使用。覆盖 Vitest / Jest / React Testing Library / Vue Test Utils / Playwright / Cypress / Storybook / MSW / 视觉回归。融合测试金字塔 + a11y 测试 + 视觉测试。
---

# 前端测试（Frontend Testing）

参考来源：Kent C. Dodds《Testing Trophy》、Testing Library 官方、Playwright / Cypress 官方、Storybook 测试文档、deque axe-core。

## 适用场景

- 单元测试（工具函数、Hook、Composable）
- 组件测试（行为 + 可访问性）
- 集成测试（页面 + Mock API）
- E2E 测试（关键用户旅程）
- 视觉回归测试
- 可访问性自动化测试

## 核心原则

```text
1. Testing Trophy（Kent C. Dodds 模型）
   - 静态（TS + ESLint）：基础
   - 单元：工具函数 / Hook
   - 集成（最有价值）：组件 + 页面
   - E2E：关键流程
   
2. 测行为不测实现
   - 用户视角：能看到 / 能点 / 能输入
   - 不测：state 内部值 / 私有方法

3. Testing Library 哲学
   - getByRole / getByLabelText（用户找元素的方式）
   - 不用 getByTestId（除非别无选择）

4. Mock 越少越好
   - Mock：网络请求（MSW）/ 时间 / 随机
   - 不 Mock：内部组件 / 业务逻辑

5. 测试金字塔
   - 单元 70%（多）
   - 集成 25%
   - E2E 5%（少）

6. CI 集成
   - 单元 / 集成必跑
   - E2E 关键路径
   - Lighthouse Accessibility
```

## 测试工具速查

| 类型 | 工具 | 适合 |
|---|---|---|
| **单元 / 集成** | Vitest（推荐）/ Jest | 业务逻辑 |
| **组件渲染** | React Testing Library / Vue Test Utils | 行为测试 |
| **API Mock** | MSW（推荐） | 网络层 |
| **E2E** | Playwright（推荐）/ Cypress | 关键流程 |
| **视觉回归** | Chromatic / Percy / Playwright screenshots | UI 一致 |
| **可访问性** | jest-axe / @axe-core/playwright | a11y |
| **Storybook** | Storybook | 组件展示 + 测试 |
| **性能** | Lighthouse CI | Web Vitals |

## Vitest（推荐）

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
      },
    },
  },
});

// src/test/setup.ts
import '@testing-library/jest-dom/vitest';
import { afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';

afterEach(() => cleanup());
```

## React Testing Library 实战

### 组件行为测试

```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });
  
  it('calls onClick when clicked', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    
    render(<Button onClick={onClick}>Submit</Button>);
    await user.click(screen.getByRole('button'));
    
    expect(onClick).toHaveBeenCalledTimes(1);
  });
  
  it('does not call onClick when disabled', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    
    render(<Button onClick={onClick} disabled>Submit</Button>);
    await user.click(screen.getByRole('button'));
    
    expect(onClick).not.toHaveBeenCalled();
  });
  
  it('shows loading state', () => {
    render(<Button isLoading>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });
});
```

### 表单测试

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('shows validation errors on empty submit', async () => {
    const user = userEvent.setup();
    render(<LoginForm />);
    
    await user.click(screen.getByRole('button', { name: /login/i }));
    
    expect(await screen.findByText(/email required/i)).toBeInTheDocument();
    expect(await screen.findByText(/password required/i)).toBeInTheDocument();
  });
  
  it('submits with valid data', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    
    render(<LoginForm onSubmit={onSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /login/i }));
    
    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

### Hook 测试

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';
import { useUserList } from './useUserList';

describe('useUserList', () => {
  it('fetches users', async () => {
    const { result } = renderHook(() => useUserList(), {
      wrapper: TestWrapper,  // 含 QueryClientProvider
    });
    
    expect(result.current.isLoading).toBe(true);
    
    await waitFor(() => {
      expect(result.current.users).toHaveLength(3);
    });
  });
});
```

## MSW（API Mock）

```typescript
// mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'Alice' },
      { id: 2, name: 'Bob' },
    ]);
  }),
  
  http.post('/api/users', async ({ request }) => {
    const newUser = await request.json();
    return HttpResponse.json({ id: 3, ...newUser }, { status: 201 });
  }),
  
  http.get('/api/users/:id', ({ params }) => {
    if (params.id === '999') {
      return new HttpResponse(null, { status: 404 });
    }
    return HttpResponse.json({ id: Number(params.id), name: 'Alice' });
  }),
];

// mocks/node.ts (test 环境)
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// vitest setup
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// 单测中覆盖 handler
it('handles error', async () => {
  server.use(
    http.get('/api/users', () => HttpResponse.error())
  );
  // 测试错误状态
});
```

## Vue Test Utils

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import Counter from './Counter.vue';

describe('Counter', () => {
  it('increments on click', async () => {
    const wrapper = mount(Counter, {
      props: { initial: 0 },
    });
    
    expect(wrapper.text()).toContain('0');
    
    await wrapper.find('button').trigger('click');
    
    expect(wrapper.text()).toContain('1');
  });
  
  it('emits update event', async () => {
    const wrapper = mount(Counter);
    
    await wrapper.find('button').trigger('click');
    
    expect(wrapper.emitted('update')).toBeTruthy();
    expect(wrapper.emitted('update')?.[0]).toEqual([1]);
  });
});
```

## Playwright（E2E 推荐）

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});

// e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('user can log in successfully', async ({ page }) => {
    await page.goto('/login');
    
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Login' }).click();
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome')).toBeVisible();
  });
  
  test('shows error on invalid credentials', async ({ page }) => {
    await page.goto('/login');
    
    await page.getByLabel('Email').fill('wrong@example.com');
    await page.getByLabel('Password').fill('wrong');
    await page.getByRole('button', { name: 'Login' }).click();
    
    await expect(page.getByText('Invalid credentials')).toBeVisible();
  });
});

// 截图对比（视觉回归）
test('home page visual', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('home.png');
});
```

### Page Object Model（推荐）

```typescript
// e2e/pages/LoginPage.ts
import { Page, expect } from '@playwright/test';

export class LoginPage {
  constructor(private page: Page) {}
  
  async goto() {
    await this.page.goto('/login');
  }
  
  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Login' }).click();
  }
  
  async expectError(message: string) {
    await expect(this.page.getByRole('alert')).toContainText(message);
  }
}

// 使用
test('login flow', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('test@example.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

## Cypress

```typescript
// cypress/e2e/login.cy.ts
describe('Login', () => {
  beforeEach(() => {
    cy.visit('/login');
  });
  
  it('logs in successfully', () => {
    cy.findByLabelText(/email/i).type('test@example.com');
    cy.findByLabelText(/password/i).type('password123');
    cy.findByRole('button', { name: /login/i }).click();
    
    cy.url().should('include', '/dashboard');
    cy.findByText(/welcome/i).should('be.visible');
  });
  
  it('shows error on invalid credentials', () => {
    cy.findByLabelText(/email/i).type('wrong@example.com');
    cy.findByLabelText(/password/i).type('wrong');
    cy.findByRole('button', { name: /login/i }).click();
    
    cy.findByText(/invalid credentials/i).should('be.visible');
  });
});
```

## Storybook（组件文档 + 测试）

```typescript
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  parameters: {
    a11y: { config: {} },  // 自动 a11y 测试
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger'],
    },
  },
};
export default meta;

type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: { variant: 'primary', children: 'Click me' },
};

export const Loading: Story = {
  args: { isLoading: true, children: 'Submitting' },
};

// 交互测试
import { within, userEvent, expect } from '@storybook/test';

export const InteractTest: Story = {
  args: { children: 'Click' },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    const button = canvas.getByRole('button');
    
    await userEvent.click(button);
    
    expect(button).toHaveAttribute('aria-pressed', 'true');
  },
};
```

## 视觉回归（Chromatic）

```yaml
# .github/workflows/chromatic.yml
name: Chromatic
on: push
jobs:
  chromatic:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-node@v4
      - run: npm ci
      - uses: chromaui/action@v1
        with:
          projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
          autoAcceptChanges: main
```

## 可访问性测试

```typescript
// jest-axe / vitest-axe
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

it('has no a11y violations', async () => {
  const { container } = render(<MyComponent />);
  expect(await axe(container)).toHaveNoViolations();
});

// Playwright + axe
import { test } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('home page is accessible', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## 测试数据工厂

```typescript
// test/factories.ts
import { faker } from '@faker-js/faker';
import { Factory } from 'fishery';
import type { User, Order } from '@/types';

export const userFactory = Factory.define<User>(() => ({
  id: faker.number.int({ min: 1 }),
  email: faker.internet.email(),
  name: faker.person.fullName(),
  createdAt: faker.date.recent(),
}));

export const orderFactory = Factory.define<Order>(({ associations }) => ({
  id: faker.string.uuid(),
  status: 'PAID',
  total: faker.number.int({ min: 100, max: 10000 }),
  user: associations.user ?? userFactory.build(),
  items: [],
}));

// 用法
const user = userFactory.build();
const admin = userFactory.build({ role: 'admin' });
const orders = orderFactory.buildList(10);
```

## CI 集成

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run test:unit
      - run: npm run test:coverage
      - uses: codecov/codecov-action@v4

  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run build
      - run: npm run test:e2e
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/

  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build
      - run: npx @lhci/cli@latest autorun
```

## 测试金字塔分布

```text
对一个中等项目（5 万行代码）：

单元测试（70%）：
  - 工具函数 / Hook / Composable
  - 业务逻辑（pure function）
  - 数量：500~2000 个
  - 时长：< 30s

集成测试（25%）：
  - 组件 + Mock API
  - 表单提交流程
  - 数量：100~300 个
  - 时长：< 5min

E2E 测试（5%）：
  - 关键用户旅程（5~15 条）
  - 登录 / 下单 / 支付 / 注销
  - 时长：< 10min
```

## 工作流程

```text
1. 选工具栈
   - Vitest + RTL + MSW + Playwright

2. 配置 CI
   - 单元 + 集成必跑
   - E2E 关键路径
   - 失败阻塞合并

3. 写测试（TDD 或 之后）
   - 工具函数 → 单元
   - 组件 → 组件测试 + Storybook
   - 页面 → 集成
   - 关键流程 → E2E

4. Mock 层（MSW）
   - 不依赖真后端

5. 测试数据（factories）

6. 视觉回归（Storybook + Chromatic）

7. 可访问性（axe-core）

8. 持续维护
   - 失败用例修
   - Flaky 隔离
```

## 配套模板

- `templates/test-strategy-template.md` — 测试金字塔 + 工具选型 + Mock + CI

## 质量自检

```text
□ 测试金字塔分布合理
□ 单元覆盖业务逻辑 ≥ 80%
□ 集成覆盖主路径
□ E2E 关键 5~15 条
□ 用 Testing Library 哲学（角色 / 标签）
□ MSW Mock API
□ Storybook 覆盖组件
□ 视觉回归（关键 UI）
□ a11y 自动测试
□ CI 集成（PR 阻塞）
□ Page Object Model（E2E）
□ 测试数据用工厂
□ 不测实现细节
□ 失败信息清晰
```

## 常见坑

1. **测实现细节**——重构挂大量
2. **getByTestId 滥用**——应该用 role / label
3. **过度 Mock**——Mock 自己代码
4. **不测可访问性**——后期返工大
5. **E2E 太多**——慢且脆弱
6. **没 Page Object**——E2E 重复代码
7. **不用 MSW**——每个测试自己写 Mock
8. **测试不独立**——共享状态
9. **flaky 测试不修**——干扰真问题
10. **测试不快**——5min 跑完没人跑
11. **不用 factory**——测试数据散乱
12. **CI 不阻塞合并**——形同虚设
13. **不视觉回归**——UI 改坏不知道
14. **不 sleep 用 waitFor**——异步处理

## 与其他 skill 的协作

```text
上游：
  api-designer → API 契约 → MSW handler
  component-architecture → 组件 + Storybook

下游：
  qa-engineer 工作流 → QA 用例
  automation-qa 工作流 → CI 自动化
  build-deploy → 构建产物测试
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 测试工具
- backend-engineer testing-implementation skill
