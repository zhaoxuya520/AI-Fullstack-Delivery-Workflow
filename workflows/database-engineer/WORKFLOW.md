# 数据库工程师工作流

## 定位

数据库工程师工作流负责把产品需求、API 契约和业务实体转化为**可迁移、可验证、可扩展、可回滚**的数据设计方案。

本工作流采用 **skills 模块化架构**：总控负责路由和通用规则，具体方法论拆分成独立 skills，按需加载。

## 适用场景

- 新业务实体建模、ER 图、表结构设计
- 字段类型、主键、外键、唯一约束、检查约束设计
- 索引设计、访问模式分析、SQL 审查、慢查询优化
- 数据库迁移、存量回填、灰度切换、回滚方案
- 事务边界、一致性、多租户隔离、数据生命周期设计
- 生产数据变更、备份恢复、数据修复和操作安全检查

## 不适用场景

- 业务需求未定义：先转 `product-manager`
- API 契约未定且影响实体边界：先转 `api-designer`
- 只涉及业务代码实现：转 `backend-engineer` 或 `fullstack-engineer`
- 只涉及发布流水线、实例扩容、监控告警：转 `devops-engineer` 或 `sre-ops`
- 涉及漏洞验证、未授权访问、数据泄露取证：转 `security-engineer` 或 `reverse-pentest`

## 必需输入

```text
业务目标 / PRD
核心实体和实体关系
主要读写场景
数据量级和增长预估
一致性要求
性能目标
数据库类型和现有技术栈
上线/迁移约束
```

## 输入不足时补问

优先补齐会影响设计不可逆决策的问题：

1. 数据库类型和版本是什么？
2. 这是新库新表，还是已有表变更？
3. 预计数据量、读写比例和高频查询是什么？
4. 是否有多租户、权限隔离、审计、软删、归档要求？
5. 是否允许停机迁移？是否需要灰度、回滚、备份窗口？

## Skills 模块

| Skill | 适用场景 | 核心方法 |
|-------|---------|---------|
| [schema-design](skills/schema-design/SKILL.md) | 实体建模和表结构设计 | 实体关系 + 字段类型 + 约束 |
| [index-access-pattern](skills/index-access-pattern/SKILL.md) | 索引和访问模式设计 | 查询路径 + 读写权衡 |
| [migration-rollout](skills/migration-rollout/SKILL.md) | 数据迁移和上线切换 | 兼容迁移 + 回填 + 回滚 |
| [query-review](skills/query-review/SKILL.md) | SQL 审查和慢查询优化 | 执行路径 + 查询重写 |
| [consistency-multitenancy](skills/consistency-multitenancy/SKILL.md) | 一致性和多租户隔离 | 事务边界 + 租户边界 |
| [data-operations-safety](skills/data-operations-safety/SKILL.md) | 生产数据操作安全 | 备份恢复 + 操作门禁 |

## 硬行为链

```text
1. 读取输入（PRD/API 契约/业务实体/查询场景/迁移约束）
   ↓
2. 检查 field-journal/_index.md → 是否有同类数据建模或迁移经验可复用
   ↓
3. 读取 skills/routing.md → 路由到需要的 skills
   ↓
4. 判断数据库任务复杂度（S/M/L/XL）→ 选择设计粒度
   ↓
5. 加载命中的 skills → 按方法执行
   ↓
6. 输出 ER/DDL/索引/迁移/回滚/风险说明
   ↓
7. 转交后端 / QA / DevOps / SRE / 安全 / 文档工作流
   ↓
8. 按 EVOLUTION.md 检查是否需要沉淀经验 → 回写 field-journal
```

## 复杂度分级

| 复杂度 | 场景 | 输出粒度 |
|--------|------|---------|
| S | 单表新增、少量字段调整、简单索引 | 表结构说明 + DDL + 验证点 |
| M | 多表关系、常规迁移、明确查询路径 | ER 说明 + 约束 + 索引 + 迁移/回滚 |
| L | 存量大表、在线迁移、多租户、复杂查询 | 分阶段迁移 + 回填 + 灰度 + 风险评估 |
| XL | 跨库拆分、分区分片、高并发核心链路 | 专项方案 + 压测计划 + 多工作流门禁 |

## 输出物

```text
数据库设计说明
ER 图或实体关系表
DDL / migration 草案
约束设计说明
索引方案
查询-索引映射
迁移和回滚计划
数据风险说明
验证清单
待确认问题
```

## 通用质量检查

```text
□ 表结构是否表达真实业务约束，而不是只复制页面字段
□ 主键、外键、唯一约束、检查约束是否明确
□ 索引是否来自真实查询路径，而不是凭字段名猜测
□ 迁移是否考虑存量数据、锁表、回填、兼容窗口
□ 是否有备份、回滚和恢复验证
□ 多租户、权限、审计、软删/归档边界是否明确
□ DDL、迁移脚本、后端模型、API 字段语义是否一致
□ 输出是否能被后端、QA、DevOps/SRE 直接接手
```

## 禁止行为

- 不在未确认数据库类型和现有技术栈时给出最终 DDL。
- 不把生产 DDL 当作普通代码变更处理。
- 不为了性能猜测随意加索引。
- 不在缺少备份和回滚方案时建议执行生产数据变更。
- 不把租户隔离、权限、审计字段作为可选细节忽略。
- 不硬编码密钥、Token、密码、私有地址等敏感信息。

## 与其他工作流协作

| 上下游 | 协作内容 |
|--------|---------|
| product-manager | 业务实体、生命周期、验收口径 |
| api-designer | API 字段语义、分页筛选排序、幂等要求 |
| backend-engineer | ORM 模型、事务边界、查询实现 |
| qa-engineer | 测试数据、迁移验证、回归范围 |
| devops-engineer / sre-ops | 迁移窗口、备份恢复、监控告警、容量风险 |
| security-engineer | 数据权限、脱敏、审计、敏感数据边界 |
| technical-writer | 数据设计说明、变更说明、运维手册 |

## 工具与自举

### 工具索引

工具状态以 `tool-index.md` 和 `tool-index.json` 为准。不要猜测版本号。

### 工具自举

缺少工具时调用（路径相对于项目根）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/bootstrap-project.ps1" -Workflow database-engineer
```

### 工具失败处理

| 情况 | 处理方式 |
|------|---------|
| bootstrap 成功 | 继续任务 |
| bootstrap 失败，原因明确 | 输出结构化引导（问题/原因/步骤/验证命令），等用户确认 |
| 同一工具失败 2 次 | 停止重试，给完整手动步骤 |

## 自进化

任务结束后按 `EVOLUTION.md` 判断是否更新：

- `field-journal/`：真实任务经验
- `pitfalls.md`：新高频坑
- `skills/routing.md`：新路由场景
- `tool-index.md`：新工具或检查命令
- `skills/*/templates/`：可复用交付模板
- `skills/*/references/`：长期方法参考
