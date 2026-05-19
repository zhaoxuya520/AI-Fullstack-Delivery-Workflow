# API 设计工作流

## 定位

API 设计工作流负责把 PRD、UI/UX 页面、业务规则、权限边界和数据约束，转化为 **稳定、可 Mock、可联调、可测试、可演进** 的 API 契约。

它不负责后端代码实现，也不替代数据库工程师设计物理表；它负责定义资源模型、端点、请求响应、错误码、认证鉴权、分页筛选排序、版本变更、幂等重试、Webhook/异步协议、OpenAPI/Swagger 文档和交接说明。

本工作流采用 **skills 模块化架构**：总控负责路由和通用规则，具体方法论拆分成独立 skills，按需加载。

---

## 适用场景

```text
API 设计 / 接口契约
OpenAPI / Swagger / REST 资源建模
端点清单 / 请求响应
错误码 / HTTP 状态码
认证鉴权 / 权限矩阵 / 租户隔离
分页 / 筛选 / 排序 / 搜索
API 版本管理 / 兼容变更
幂等 / 重试 / 限流 / 并发冲突
Webhook / 异步任务 / 回调协议
Mock 数据 / 前后端联调
```

---

## 不适用场景

| 任务 | 应转交工作流 |
|---|---|
| 需求目标、业务范围、验收标准不清 | 产品经理工作流 |
| 页面结构、表单字段、状态和交互不清 | UI/UX 设计工作流 |
| 数据库物理表、索引、迁移 | 数据库工程师工作流 |
| 后端业务逻辑、服务实现 | 后端工程师工作流 |
| 前端接口调用和状态管理 | 前端工程师工作流 |
| 自动化测试用例和测试执行 | QA 工作流 |
| 认证安全、敏感数据、攻击面 | 安全工程师工作流 |
| 发布、网关、监控、运行时配置 | DevOps / SRE 工作流 |

---

## 输入

### 必需输入

```text
PRD 或功能范围
调用方（前端 / 移动端 / 第三方 / 后台 / 内部服务）
业务资源（核心对象）
用户角色 / 权限边界
核心操作（CRUD + 特殊操作）
成功路径 / 失败路径
```

### 可选输入

```text
UI/UX 页面说明
数据模型草案
已有 API 风格 / 认证体系 / 租户模型
第三方 API 约束
性能 / SLA 要求
审计日志要求 / 敏感字段规则
网关或 Mock 工具限制
```

### 输入不足时先补问

```text
1. 这个 API 服务哪个页面或调用场景？
2. 核心业务资源是什么？资源之间有什么关系？
3. 哪些角色可以读、创建、修改、删除或审批？
4. 是否有租户、组织、所有者或字段级权限？
5. 是否需要分页、筛选、排序、搜索或导出？
6. 是否涉及提交、支付、扣减、审批等需要幂等的操作？
7. 是否有异步任务、Webhook、回调或轮询？
```

---

## 完整行为链（硬性流程）

```text
1. 读取 PRD / UI 流程 / 业务规则 / 权限约束
   ↓
2. 检查 field-journal/_index.md → 是否有同类 API 经验可复用
   ↓
3. 读取 skills/routing.md → 路由到需要的 skills
   ↓
4. 判断 API 复杂度（S/M/L/XL）→ 选择产出粒度
   ↓
5. 加载命中的 skills（一个或多个）→ 按 skill 内方法执行
   ↓
6. 输出 OpenAPI 契约 + Mock 数据 + 文档
   ↓
7. 转交前端 / 后端 / QA / 安全 / 文档工作流
   ↓
8. 按 EVOLUTION.md 检查是否需要沉淀经验 → 回写 field-journal
```

---

## Skills 模块总览

每个 skill 独立可用，按需组合。详细路由见 `skills/routing.md`。

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [resource-modeling](skills/resource-modeling/SKILL.md) | REST 资源建模 | 资源 + 集合 + 子资源 + 动作 |
| [endpoint-design](skills/endpoint-design/SKILL.md) | 端点设计 | 命名规范 + HTTP 语义 + 状态码 |
| [request-response](skills/request-response/SKILL.md) | 请求响应结构 | 字段稳定性 + 校验规则 |
| [error-handling](skills/error-handling/SKILL.md) | 错误码设计 | HTTP + 业务码 + 调用方处理 |
| [auth-permission](skills/auth-permission/SKILL.md) | 认证鉴权 | OAuth/JWT + 角色 + 字段权限 |
| [pagination-filtering](skills/pagination-filtering/SKILL.md) | 分页筛选排序 | offset/cursor + 统一规范 |
| [versioning](skills/versioning/SKILL.md) | API 版本管理 | 兼容变更 + 弃用策略 |
| [idempotency-retry](skills/idempotency-retry/SKILL.md) | 幂等和重试 | Idempotency-Key + 并发冲突 |
| [webhook-async](skills/webhook-async/SKILL.md) | Webhook 和异步 | 签名 + 重试 + 顺序 |
| [openapi-mock](skills/openapi-mock/SKILL.md) | OpenAPI 契约和 Mock | Schema + 示例 + 联调 |

---

## 禁止行为

```text
❌ 不要在业务对象和状态不清时直接列接口
❌ 不要把数据库表结构直接暴露成 API 契约
❌ 不要只设计成功路径，忽略失败、空结果、权限不足和并发冲突
❌ 不要让不同端点使用不同分页、筛选、排序风格
❌ 不要用 200 包装所有错误
❌ 不要只写错误文案，不写错误码和调用方处理建议
❌ 不要把认证和权限简化成"需登录"
❌ 不要对创建、提交、支付、扣减类接口省略幂等策略
❌ 不要让 Mock 数据和 OpenAPI Schema 不一致
❌ 不要在 OpenAPI 与 Markdown 说明之间出现字段不一致
❌ 不要设计无法测试、无法联调、无法验收的接口
❌ 不要跳过工作流交接和经验沉淀
```

---

## 任务复杂度分级

```text
S 级（10~30 分钟）：单端点 → 加载 endpoint-design + request-response

M 级（30~90 分钟）：功能模块 → 加载 resource-modeling + endpoint-design + request-response + error-handling + auth-permission + pagination-filtering + openapi-mock

L 级（1~3 小时）：多模块联动 → 加载所有 skills

XL 级（3 小时+）：产品级 API → 加载所有 skills + versioning 重点
```

---

## 通用质量检查

```text
□ 业务资源是否清楚？
□ 端点是否遵循统一命名和 HTTP 语义？
□ 请求字段是否有类型、必填、校验和示例？
□ 响应字段是否稳定、可解释、可 Mock？
□ 错误码是否可恢复、可测试、可定位？
□ 认证、鉴权、租户和字段权限是否明确？
□ 分页、筛选、排序是否统一？
□ 是否处理空结果、资源不存在、权限不足、冲突、限流？
□ 创建/提交/支付/扣减类接口是否有幂等策略？
□ Webhook 是否有签名、事件 ID 和重放防护？
□ OpenAPI 与 Markdown 说明是否一致？
□ Mock 数据是否覆盖主路径和失败路径？
□ 前端、后端、QA、安全、文档是否能根据交接包行动？
```

---

## 常见坑（跨 skill 通用）

```text
1. 把数据库表结构直接暴露成 API 契约
2. 不同端点用不同分页风格
3. 用 200 包装所有错误
4. 错误信息只有文案没有错误码
5. 创建/支付接口没有幂等设计
6. POST 创建后只返回 id，前端被迫再发一次 GET
7. 列表接口不返回 total
8. 时间字段格式不统一
9. 字段名风格不统一（snake_case 和 camelCase 混用）
10. 把权限简化为"需要登录"
11. 敏感字段默认返回
12. OpenAPI 文档和 Markdown 说明字段不一致
13. Mock 数据和 Schema 不一致
14. 删除接口直接物理删除，无审计
15. 改字段语义但不升版本
16. Webhook 没有签名和 event_id
17. 异步任务接口只返回"提交成功"
18. 限流返回 429 但不带 Retry-After
```

具体 skill 内的常见坑见各 skill 的 SKILL.md。

---

## 下游交接协议（核心）

API 契约是前端、后端、QA、安全四方共同的"合同"。详见 [openapi-mock](skills/openapi-mock/SKILL.md) 的交接章节。

---

## 与其他工作流的协作

### 上游

| 上游工作流 | API 设计需要的输入 |
|---|---|
| 产品经理工作流 | PRD、用户故事、验收标准、业务规则、权限范围 |
| UI/UX 设计工作流 | 页面字段、交互状态、表单校验、表格能力、错误/空/权限状态 |
| 数据库工程师工作流 | 实体关系、字段约束、唯一性、状态流转 |

### 下游

| 下游工作流 | API 设计交付内容 |
|---|---|
| 后端工程师工作流 | 契约、资源模型、端点、错误、权限、幂等和异步规则 |
| 前端工程师工作流 | OpenAPI、Mock、请求响应示例、错误处理、联调说明 |
| QA 工作流 | 成功/失败/边界/权限/并发/重试测试点 |
| 安全工程师工作流 | 认证鉴权、敏感字段、Webhook 签名、租户隔离、滥用风险 |
| 技术文档工作流 | 对外 API 文档、示例、错误码和迁移说明 |

---

## 多任务与中断处理

```text
1. 多个 API 模块并行：每个独立维护契约，标注资源引用关系
2. 中途中断：保存当前进度（已定义端点 + 待确认问题）
3. 契约变更：评估影响 → 兼容/不兼容 → 走版本策略 → 通知下游
```

---

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow api-designer
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

---

## 自进化要求

任务完成后按 `EVOLUTION.md` 检查：

```text
是否形成新的 API 模板？→ 加入对应 skill 的 templates/
是否发现新的错误码或权限坑？→ 更新对应 skill
是否需要新增 OpenAPI 风格规则？→ 更新 openapi-mock
是否需要补充 Webhook/异步经验？→ 更新 webhook-async
是否需要写入 field-journal？
是否需要新增 skill？→ 按 CONTRIBUTING.md 流程
```
