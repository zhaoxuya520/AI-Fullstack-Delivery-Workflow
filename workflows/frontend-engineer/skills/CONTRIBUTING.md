# 新增 Skill 流程（前端工程师工作流）

## 1. 何时需要新增 skill

- 出现新的前端范式（如 Server Components 深度方案、WebGPU、AI 集成）
- 路由表多次未命中
- 现有 skill 内容超过 600 行需要拆分
- 出现独立的工程维度（如微前端、移动端跨端、PWA 离线优先、低代码集成）

## 2. 新增步骤

```text
1. 在 skills/ 下新建 <skill-name>/ 目录
2. 创建 SKILL.md（必需 frontmatter）
3. 必备章节：
   - 适用场景
   - 核心原则
   - 工作流程
   - 质量自检
   - 常见坑
   - 配套模板
   - 与其他 skill 的协作
4. 创建 templates/ + 至少 1 个模板
5. 如有理论参考，创建 references/
6. 更新 skills/SKILL.md
7. 更新 skills/routing.md
8. 更新工作流根 WORKFLOW.md 的 Skills 总览
9. 跑 `python scripts/audit-workflows.py` 验证
```

## 3. 命名规范

- 目录名：kebab-case，3 个词以内
- frontmatter name 字段：与目录名一致
- description：一句话说明何时用
