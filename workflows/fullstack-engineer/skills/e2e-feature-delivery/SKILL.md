---
name: e2e-feature-delivery
description: 端到端功能交付时使用。适用于从 PRD 到部署的一人闭环：Schema → API → UI → 联调 → 测试 → 部署。融合全栈交付清单 + 垂直切片 + 增量交付。
---

# 端到端功能交付（E2E Feature Delivery）

参考来源：Vertical Slice Architecture、Shape Up（Basecamp）、Kent Beck Incremental Design、全栈 MVP 实践。

## 适用场景

- 一人完成从数据库到页面的完整功能
- MVP / POC / 内部工具快速交付
- 小团队端到端功能模块

## 核心原则

```text
1. 垂直切片（Vertical Slice）
   不是先做完所有后端再做前端
   而是一个功能从 DB → API → UI 一次做完

2. 增量交付
   先做最小可用版本（happy path）
   再补错误处理 / 边界 / 权限

3. 边写边调
   不要前后端分别写完再联调
   写一个端点就联调一个

4. Schema First
   先设计数据模型，再写代码

5. 部署优先
   第一天就部署空项目到 Preview
   后续每个功能都能在线看

6. 测试跟着走
   不是最后补测试
   每个功能完成就写测试
```

## 垂直切片交付流程

```text
功能：用户创建订单

切片 1（最小可用）：
  □ Schema：orders 表（id, user_id, status, total, created_at）
  □ API：POST /orders（创建）+ GET /orders（列表）
  □ UI：订单列表页 + 创建按钮 + 简单表单
  □ 联调：前端调真实 API
  □ 部署：Preview 可访问
  → 验收：能创建订单并看到列表

切片 2（补充）：
  □ Schema：order_items 表
  □ API：GET /orders/:id（详情）
  □ UI：订单详情页
  □ 联调 + 部署
  → 验收：能看到订单详情

切片 3（完善）：
  □ API：PATCH /orders/:id（状态流转）
  □ UI：状态操作按钮
  □ 错误处理（库存不足 / 权限不足）
  □ 测试
  → 验收：完整业务流程
```

## 标准流程

```text
1. 理解需求
   - 核心用户流程是什么？
   - 涉及哪些数据实体？
   - 权限边界？
   ↓
2. 选技术栈（如未定）
   → fullstack-architecture skill
   ↓
3. 设计数据模型
   → database-schema-impl skill
   ↓
4. 部署空项目
   → deploy-preview skill
   ↓
5. 按垂直切片实现
   每个切片：
   a. 写 Schema / Migration
   b. 写 API 端点
   c. 写前端页面
   d. 联调验证
   e. 部署到 Preview
   ↓
6. 认证（如需）
   → auth-e2e skill
   ↓
7. 测试
   - 单元：核心业务逻辑
   - E2E：关键用户旅程（1~3 条）
   ↓
8. 验收
   - 对照验收标准逐条检查
   ↓
9. 正式部署
   → deploy-preview skill（Production）
   ↓
10. 沉淀经验
```

## 全栈交付清单（每个功能必查）

```text
数据层：
  □ Schema 设计完成
  □ Migration 可执行
  □ 种子数据（如需）
  □ 索引覆盖核心查询

后端层：
  □ API 端点实现
  □ 入参校验
  □ 错误码统一
  □ 权限检查
  □ 幂等（写操作）

前端层：
  □ 页面实现
  □ Loading / Error / Empty 状态
  □ 表单校验
  □ 响应式
  □ 基本 a11y

联调层：
  □ 前后端字段一致
  □ 错误处理对接
  □ Token 传递正确
  □ 分页 / 筛选对接

测试层：
  □ 核心逻辑单元测试
  □ 关键路径 E2E（至少 1 条）

部署层：
  □ Preview 可访问
  □ 环境变量配置
  □ 数据库连接正常
```

## 时间分配（M 级功能，8 小时）

```text
需求理解 + 设计：     1h（12%）
数据模型 + Migration：1h（12%）
后端实现：            2h（25%）
前端实现：            2h（25%）
联调 + 错误处理：     1h（12%）
测试：                0.5h（6%）
部署 + 验收：         0.5h（6%）
```

## 增量交付策略

```text
Day 1：
  - 空项目部署到 Preview ✓
  - Schema 设计 ✓
  - 核心 CRUD API ✓
  - 列表页 ✓

Day 2：
  - 详情页 + 创建表单 ✓
  - 联调 ✓
  - 认证 ✓

Day 3：
  - 错误处理 + 边界 ✓
  - 测试 ✓
  - 正式部署 ✓
  - 验收 ✓
```

## 配套模板

- `templates/e2e-delivery-checklist.md` — 垂直切片清单 + 全栈交付检查 + 时间分配

## 质量自检

```text
□ 垂直切片（不是先全后端再全前端）
□ Schema First
□ 第一天就部署
□ 边写边调
□ 4 种状态（loading/error/empty/success）
□ 错误处理端到端
□ 认证端到端
□ 至少 1 条 E2E 测试
□ Preview 可访问
□ 验收标准全部满足
```

## 常见坑

1. **先写完后端再写前端**——联调时字段不一致
2. **不部署就开发**——最后部署时各种环境问题
3. **不写 Schema 就写代码**——数据模型反复改
4. **不处理错误状态**——用户看到白屏
5. **不增量交付**——3 天后才能看到东西
6. **复杂度超出硬撑**——质量崩溃，应该拆分
7. **不写测试**——改一处坏三处
8. **不用 TypeScript**——联调时类型错误
9. **认证最后做**——前面全是裸奔
10. **不用全栈框架**——自己拼装浪费时间

## 与其他 skill 的协作

```text
下游：
  database-schema-impl → 建表
  api-frontend-integration → 联调
  auth-e2e → 认证
  deploy-preview → 部署
  fullstack-architecture → 选型
```
