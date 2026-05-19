---
name: versioning
description: 设计 API 版本管理和兼容变更策略时使用。适用于公开 API、SDK、长期维护项目。优先使用 Stripe 版本策略 + 兼容/不兼容变更分类 + 弃用流程。
---

# API 版本管理

参考来源：[Stripe API Versioning](https://stripe.com/blog/api-versioning)、Semver 思想

## 适用场景

- 公开 API / 开放平台
- 第三方 SDK 维护
- 长期演进的 API
- 需要平滑升级的产品

## 不适用场景

- 内部 API（前后端紧耦合，可同步升级）
- 短期项目
- 早期 MVP

## 核心原则

```text
1. 兼容变更优先
   能不升版本就不升

2. 不兼容变更必须升版本
   不能悄悄改

3. 老版本要有弃用期
   不能立即下线

4. 版本策略全 API 统一
   不要不同模块用不同方式
```

## 兼容变更（Compatible / Additive）

不需要升版本的变更：

```text
✅ 新增可选字段（请求和响应）
✅ 新增端点
✅ 新增可选参数
✅ 新增错误码
✅ 新增枚举值（响应中，调用方应忽略未知值）
✅ 放宽校验（如：原 max=10 改为 max=20）
✅ 新增 HTTP 方法（如原只支持 GET，新增 POST）
```

## 不兼容变更（Breaking）

必须升版本的变更：

```text
❌ 删除字段
❌ 删除端点
❌ 重命名字段
❌ 改字段类型（string → integer）
❌ 改字段语义（同名字段含义变了）
❌ 改必填规则（可选 → 必填）
❌ 改默认值
❌ 改枚举值含义（仅添加是兼容的，删除/重命名不兼容）
❌ 改错误响应结构
❌ 改 HTTP 状态码（200 → 201）
❌ 改鉴权方式
❌ 收紧校验（max=20 改为 max=10）
❌ 改分页风格（offset → cursor）
```

## 版本表达方式

### 1. URL 版本（最常见）

```text
/api/v1/users
/api/v2/users

优点：
  ✅ 直观
  ✅ 缓存友好
  ✅ 易于路由

缺点：
  ❌ 升级时所有 URL 都变
  ❌ 一个端点的小变更也要全升
```

### 2. Header 版本

```text
Accept: application/vnd.example.v2+json
或自定义：
X-API-Version: 2

优点：
  ✅ URL 干净
  ✅ 可按端点细粒度版本

缺点：
  ❌ 不直观
  ❌ 缓存配置复杂
  ❌ 浏览器测试不方便
```

### 3. 日期版本（Stripe 风格）

```text
Stripe-Version: 2024-01-15

优点：
  ✅ 精确到日期
  ✅ 客户端可固定版本
  ✅ 升级路径清晰

缺点：
  ❌ 维护成本高（每个变更都是新版本）
```

### 4. 媒体类型版本

```text
Accept: application/json; version=2

优点：
  ✅ 符合 REST 原则

缺点：
  ❌ 复杂
  ❌ 多数客户端不熟悉
```

## 选择建议

```text
内部 API → 不需要版本（前后端同步）
公开 API（普通） → URL 版本 (/v1, /v2)
公开 API（精细） → 日期版本（Stripe 风格）
开放平台（成熟） → URL 版本 + 日期细化
```

## 弃用流程

```text
1. 公告（Announce）
   - 提前 6~12 个月通告
   - 邮件 / 文档 / Changelog
   - 提供迁移指南

2. 标注（Deprecate）
   - 响应 Header：Sunset: <date>
   - 文档明确标注 deprecated
   - 提供新端点 / 新字段

3. 警告（Warn）
   - 响应 Header：Deprecation: <date>
   - 日志记录使用情况
   - 联系大客户

4. 下线（Sunset）
   - 到期下线
   - 老调用返回 410 Gone
   - 错误信息指向新版本

时间表示例：
  Day 0：发布 v2，v1 标 deprecated
  Day 90：v1 警告（响应 header）
  Day 180：v1 错误（部分非关键端点）
  Day 365：v1 完全下线
```

## 版本变更示例

### 示例 1：兼容变更（不升版）

```text
旧 v1：
GET /users/{id}
{
  "id": "usr_001",
  "name": "张三"
}

新 v1（新增字段，兼容）：
GET /users/{id}
{
  "id": "usr_001",
  "name": "张三",
  "email": "user@example.com",  ← 新增
  "phone": "+86138..."           ← 新增
}

老客户端忽略未知字段，不影响
```

### 示例 2：不兼容变更（必须升版）

```text
旧 v1：
{
  "user_id": "usr_001",          ← 旧字段名
  "user_name": "张三"
}

新 v2：
{
  "id": "usr_001",               ← 重命名
  "name": "张三"
}

必须 /v2/users/{id}
v1 保留过渡期
```

## 版本变更评估模板

```markdown
## 版本变更评估：[变更内容]

### 变更描述

[具体改了什么]

### 兼容性评估

- 变更类型：兼容 / 不兼容
- 受影响的字段/端点：
- 受影响的客户端：

### 兼容判断

- [ ] 是否新增字段（兼容）
- [ ] 是否新增端点（兼容）
- [ ] 是否删除字段（不兼容）
- [ ] 是否改字段类型（不兼容）
- [ ] 是否改语义（不兼容）
- [ ] 是否改必填（不兼容）

### 决策

- ✅ 兼容变更，无需升版
- ❌ 不兼容变更，需要 v2

### 如果升版

- 新版本号：v2
- 老版本弃用期：6 个月
- 迁移指南：[链接]
- 通知方式：邮件 + Changelog
```

## OpenAPI 中的弃用标注

```yaml
paths:
  /v1/users:
    get:
      summary: List users (deprecated)
      deprecated: true
      description: |
        This endpoint is deprecated and will be removed on 2026-12-31.
        Please use /v2/users instead.
        Migration guide: https://docs.example.com/migration/v2
```

## 工作流程

```text
1. 评估变更是否兼容（用上方评估模板）
2. 如果兼容 → 直接修改，更新文档
3. 如果不兼容 → 决定升版策略
4. 创建新版本，老版本保留
5. 写迁移指南
6. 发布弃用公告
7. 监控老版本使用率
8. 到期下线
```

## 质量自检

```text
□ 是否区分了兼容和不兼容变更
□ 兼容变更是否真的兼容（不要侥幸）
□ 不兼容变更是否升了版本
□ 弃用是否有充足时间（≥ 6 个月）
□ 是否有迁移指南
□ 是否在 OpenAPI 标注 deprecated
□ 是否监控老版本使用率
```

## 常见坑

1. **侥幸不升版**——"用户应该不会注意" → 客户端崩溃
2. **删字段当兼容**——以为没人用结果有人用
3. **弃用期太短**——3 周就下线 → 客户来不及升级
4. **没有迁移指南**——客户不知道怎么升
5. **版本数量爆炸**——每个变更都升版 → v1 v2 v3 ... v15
6. **新老版本逻辑分叉太多**——维护成本爆炸
7. **不监控老版本**——以为没人用其实大量调用

## 配套模板

- `templates/api-version-change-template.md` — 变更评估 + 迁移指南 + 弃用公告模板

## 与其他 skill 的协作

```text
上游：
  product-manager 的需求变更

平行：
  endpoint-design → 新版本端点设计
  request-response → 字段变更评估
  error-handling → 错误码版本兼容

下游：
  openapi-mock → 多版本 OpenAPI
  转交技术文档 → 迁移指南
```
