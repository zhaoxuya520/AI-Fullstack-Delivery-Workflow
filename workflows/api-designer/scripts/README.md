# API 设计工作流脚本

## 脚本清单

| 脚本 | 用途 | 示例 |
|---|---|---|
| `check-api-spec.ps1` | 检查 API 设计说明是否包含核心章节 | `powershell -ExecutionPolicy Bypass -File .\check-api-spec.ps1 -Path ..\templates\openapi-handoff-template.md` |

## 使用说明

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "F:\AI Full-stack Delivery Workflow\workflows\api-designer\scripts\check-api-spec.ps1" -Path "F:\AI Full-stack Delivery Workflow\workflows\api-designer\templates\openapi-handoff-template.md"
```

## 约束

```text
脚本只做章节完整性检查，不替代 OpenAPI lint。
OpenAPI 语法检查可使用项目已有 Swagger Editor、Spectral 或 CI 工具。
PowerShell 脚本保持 ASCII-safe，中文检查项使用 Unicode code point 构造。
```
