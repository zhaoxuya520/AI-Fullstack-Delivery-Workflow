# 新增 Skill 流程（全栈工程师工作流）

## 1. 何时需要新增 skill

- 出现新的全栈框架范式（如 Server Components 全栈模式）
- 路由表多次未命中
- 现有 skill 超过 600 行需要拆分
- 出现独立的全栈维度（如实时协作 / 离线优先 / AI 集成）

## 2. 新增步骤

```text
1. 在 skills/ 下新建 <skill-name>/ 目录
2. 创建 SKILL.md（必需 frontmatter）
3. 必备章节：适用 / 原则 / 流程 / 自检 / 坑 / 模板 / 协作
4. 创建 templates/ + 至少 1 个模板
5. 更新 skills/SKILL.md + skills/routing.md + WORKFLOW.md
6. 跑 `python scripts/audit-workflows.py` 验证
```

## 3. 命名规范

- 目录名：kebab-case，3 个词以内
- frontmatter name 字段：与目录名一致
