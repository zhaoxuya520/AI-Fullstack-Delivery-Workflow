# 新增 Skill 指南（API 设计工作流）

## 何时新增 skill

- 现有 routing 找不到合适入口
- 任务类型有独立方法论（如 GraphQL 设计、gRPC、HATEOAS）
- 来自外部权威源的成熟方法（RFC、Stripe/GitHub/Google API Design）

## Skill 目录结构

```text
skills/
└── <skill-name>/
    ├── SKILL.md          # 必需
    ├── templates/        # 可选
    └── references/       # 可选
```

## SKILL.md 必需结构

```markdown
---
name: <skill-name>
description: <一句话说明何时使用>
---

# <Skill 标题>

参考来源：[链接]

## 适用场景
## 不适用场景
## 核心原则
## 核心方法
## 工作流程
## 输出格式 / 模板
## 质量自检
## 常见坑
## 配套模板（如有）
## 与其他 skill 的协作
```

## 命名规范

- 全小写英文，连字符分隔

```text
✅ resource-modeling / error-handling / webhook-async
❌ ResourceModeling / errorHandling / 资源建模
```

## 新增后必须更新

1. `routing.md`
2. `WORKFLOW.md`（Skills 总览）
3. `skills/SKILL.md`
4. 在 [openapi-mock](openapi-mock/SKILL.md) 中加上对应 skill 的输出引用（如适用）
