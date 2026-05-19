# 新增 Skill 流程（数据分析师工作流）

## 1. 何时需要新增 skill

- 出现新的分析范式（如因果推断 / 时间序列 / 用户画像）
- 路由表多次未命中
- 现有 skill 超过 600 行需要拆分

## 2. 新增步骤

```text
1. 在 skills/ 下新建 <skill-name>/ 目录
2. 创建 SKILL.md（必需 frontmatter：name + description）
3. 必备章节：适用场景 / 核心原则 / 流程 / 自检 / 常见坑 / 配套模板 / 协作
4. 创建 templates/ + 至少 1 个模板
5. 更新 skills/SKILL.md + skills/routing.md + WORKFLOW.md
6. 跑 `python scripts/audit-workflows.py` 验证
```

## 3. 命名规范

- 目录名：小写 + 连字符（如 `cohort-analysis`）
- SKILL.md frontmatter 的 name 与目录名一致
- 模板文件：`<用途>-template.md`

## 4. 质量要求

- 每个 skill 必须有至少 1 个可直接使用的模板
- 常见坑至少列 5 条
- 自检清单至少 8 条
- 协作关系写清上下游
