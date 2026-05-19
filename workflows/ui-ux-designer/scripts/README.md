# UI/UX 设计工作流脚本

## check-design-spec.ps1

检查页面设计说明是否包含 UI/UX 工作流要求的核心章节。

用法：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "workflows/ui-ux-designer/scripts/check-design-spec.ps1" -Path "path/to/page-spec.md"
```

检查项包括：

```text
页面基本信息、页面结构、核心信息、操作设计、状态说明、响应式要求、可访问性要求、前端验收标准、待确认问题
```
