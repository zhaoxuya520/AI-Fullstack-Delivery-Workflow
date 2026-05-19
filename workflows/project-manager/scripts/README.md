# 项目经理工作流脚本

## check-project-plan.ps1

检查项目执行计划是否包含项目经理工作流要求的核心章节。

用法：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "workflows/project-manager/scripts/check-project-plan.ps1" -Path "path/to/project-plan.md"
```

检查项包括：

```text
项目信息、输入依据、目标和范围、工作流参与、任务计划、里程碑、依赖和关键路径、风险摘要、交付门禁、沟通和状态更新
```
