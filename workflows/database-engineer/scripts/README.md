# Scripts 目录说明

本目录存放数据库工程师工作流可重复执行的本地检查脚本。

## 脚本列表

| 脚本 | 用途 |
|------|------|
| `check-database-deliverable.ps1` | 检查数据库交付文档是否包含核心章节 |

## 使用方式

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "F:\AI Full-stack Delivery Workflow\workflows\database-engineer\scripts\check-database-deliverable.ps1" -Path "F:\AI Full-stack Delivery Workflow\workflows\database-engineer\skills\schema-design\templates\schema-design-template.md"
```

## 检查范围

脚本检查以下章节是否存在：背景/目标、输入依据、实体与关系、表结构、约束设计、索引方案、查询场景、迁移方案、回滚方案、风险说明、验证清单、待确认问题。

## 编写原则

- Windows PowerShell 5.1 兼容。
- 脚本源码保持 ASCII-safe。
- 中文检查项通过 Unicode code point 构造，避免编码问题。
- 只做只读检查，不修改目标文档。
