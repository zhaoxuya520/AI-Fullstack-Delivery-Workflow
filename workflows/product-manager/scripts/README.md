# 产品经理工作流脚本

## check-prd.ps1

检查 PRD 是否包含产品经理工作流要求的核心章节。

用法：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "workflows/product-manager/scripts/check-prd.ps1" -Path "path/to/prd.md"
```

检查项包括：

```text
背景、目标、目标用户、范围、本版本不做、用户流程、功能需求、业务规则、角色和权限、异常、验收标准、风险、未决问题、下游交付
```
