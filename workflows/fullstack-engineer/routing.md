# 全栈工程师工作流路由

## 触发关键词

```text
fullstack-engineer, 全栈工程师工作流, 跨前端、后端、API、数据库的端到端功能交付
```

## 机器可读路由

```yaml
workflow: fullstack-engineer
name: 全栈工程师工作流
entry: WORKFLOW.md
skills_routing: skills/routing.md
status: ready
keywords:
  - fullstack-engineer
  - 全栈工程师工作流
required_files:
  - WORKFLOW.md
  - routing.md
  - tool-index.md
  - pitfalls.md
  - skills/routing.md
  - field-journal/_index.md
outputs:
  - 端到端实现 / 联调记录 / 测试结果 / 交接说明
  - 验证结果
  - 交接说明
```

## 进入条件

```text
□ 任务目标属于本工作流职责范围
□ 上游输入或补问路径明确
□ 预期输出格式明确
□ 需要与其他工作流协作的边界已识别
□ 安全、数据、部署、生产风险已识别
```

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 需求范围不清 | `product-manager` |
| 排期、依赖或风险编排不清 | `project-manager` |
| API 契约不清 | `api-designer` |
| 数据模型或迁移不清 | `database-engineer` |
| 测试策略或质量门禁不清 | `qa-engineer` |
| 部署、监控、回滚不清 | `devops-engineer` / `sre-operations` |
| 涉及授权安全测试或敏感数据风险 | `security-engineer` |

## 未命中处理

如果任务不属于本工作流，不要硬塞进当前工作流；返回根 `routing.md` 选择更合适的工作流。
