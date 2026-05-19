# E2E 测试模板

## 关键旅程清单

| # | 旅程 | 优先级 | 状态 |
|---|------|--------|------|
| 1 | 注册 → 登录 → 退出 | P0 | ✅ |
| 2 | 创建订单 → 支付 → 确认 | P0 | ✅ |
| 3 | 搜索 → 筛选 → 详情 | P1 | ⏳ |

## Page Object 结构

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}
  
  async goto() { await this.page.goto('/login'); }
  
  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Login' }).click();
  }
}
```

## 测试数据

```text
测试账号：
  - user: test@example.com / password123
  - admin: admin@example.com / admin123

测试数据：
  - 已存在订单 ID：[ID]
  - 测试商品 ID：[ID]
```

## 自检

```text
□ 关键旅程覆盖
□ Page Object
□ 稳定 selector
□ 不用 sleep
□ 并行
□ CI 集成
□ Flaky < 1%
```
