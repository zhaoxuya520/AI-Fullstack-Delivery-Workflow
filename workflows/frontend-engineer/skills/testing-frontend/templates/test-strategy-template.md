## 1. 项目信息

```text
项目：
框架：React / Vue / Angular / Svelte
单元测试：Vitest / Jest
组件测试：React Testing Library / Vue Test Utils
E2E：Playwright / Cypress
Mock：MSW
视觉：Storybook + Chromatic
负责人：
```

---

## 2. 金字塔分布

```text
单元（70%）：[数量] 个
集成（25%）：[数量] 个
E2E（5%）：[数量] 条
```

---

## 3. 单元测试范围

```text
□ 工具函数（utils/）
□ 自定义 Hook / Composable
□ 业务逻辑（services/）
□ 状态管理（store / slice）
□ 表单 schema（zod 校验）
```

---

## 4. 集成测试范围

```text
□ 关键页面（每个）
  - 加载状态
  - 错误状态
  - 空状态
  - 成功状态
□ 表单提交
□ 鉴权流程
□ 错误恢复
```

---

## 5. E2E 关键流程（5~15 条）

| 流程 | 优先级 | 时长 |
|---|---|---|
| 注册 → 登录 → 退出 | P0 | < 30s |
| 创建订单 → 支付 → 确认 | P0 | < 60s |
| 搜索 + 筛选 → 详情 | P1 | < 30s |
| 用户资料编辑 | P1 | < 30s |
| 密码重置 | P1 | < 30s |

---

## 6. Mock 策略

```text
□ MSW 配置 handlers
□ 每个端点：成功 + 失败 + 慢响应
□ 测试用 fixture 数据
□ 工厂函数（fishery / faker）
```

### Mock Handlers 清单

| 端点 | 成功 | 401 | 403 | 404 | 500 | 慢 |
|---|---|---|---|---|---|---|
| GET /users |  |  |  |  |  |  |
| POST /users |  |  |  |  |  |  |
| GET /users/:id |  |  |  |  |  |  |

---

## 7. 视觉回归

```text
□ Storybook 覆盖组件
□ Chromatic 集成
□ 关键页面截图（PR 比对）
□ 多视口（mobile / tablet / desktop）
□ 暗黑模式
```

---

## 8. 可访问性自动化

```text
□ jest-axe / vitest-axe（单元）
□ @axe-core/playwright（E2E）
□ Lighthouse CI Accessibility
□ 阻塞合并条件：a11y violations = 0
```

---

## 9. CI 配置

```text
□ 单元测试（PR 必跑）
□ 集成测试（PR 必跑）
□ E2E（PR 必跑或 nightly）
□ 视觉回归（PR）
□ Lighthouse（PR）
□ 覆盖率（≥ 80%）
□ 失败阻塞合并
```

---

## 10. 性能 / 时长

```text
单元测试：< 30s
集成测试：< 5min
E2E：< 10min
全部：< 15min（CI 并行）
```

---

## 11. 测试数据

```text
□ Factory 模式（fishery）
□ Faker 假数据
□ 不用真实 PII
□ 测试账号文档化
□ Fixture JSON
```

---

## 12. 自检

```text
□ 金字塔分布合理
□ 单元覆盖 ≥ 80%
□ 关键 E2E 覆盖
□ MSW Mock
□ 视觉回归
□ a11y 自动化
□ CI 集成
□ 失败阻塞
□ 测试快（< 15min）
□ Page Object（E2E）
□ Factory 数据
```
