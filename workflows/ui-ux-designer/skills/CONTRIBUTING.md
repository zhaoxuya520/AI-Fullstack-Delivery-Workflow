# 新增 Skill 指南（UI/UX 设计工作流）

## 何时新增 skill

- 现有 routing 找不到合适入口
- 任务类型有独立方法论
- 多次出现同类任务
- 来自外部权威源的成熟方法（Apple HIG、Material、WCAG、大厂设计系统）

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
✅ user-flow / atomic-design / design-tokens
❌ User_Flow / atomicDesign / 用户流程
```

## 新增后必须更新

1. `routing.md`
2. `WORKFLOW.md`（Skills 总览）
3. `skills/SKILL.md`

## 内容质量要求

```text
✅ 必须有：
  - 适用场景和不适用场景的明确区分
  - 至少 1 个完整示例
  - 工作流程
  - 质量自检清单
  - 常见坑
  - 与其他 skill 的协作说明

❌ 避免：
  - 把所有内容塞进 SKILL.md
  - 复制其他 skill 的内容
  - 没有来源标注的"业界方法"
  - 模糊空话
```
