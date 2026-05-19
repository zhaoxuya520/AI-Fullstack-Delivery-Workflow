# Scripts 目录说明

本目录存放 QA 工程师工作流可重复执行的本地检查脚本。

## 脚本列表

| 脚本 | 用途 |
|------|------|
| `check-test-report.ps1` | 检查测试报告是否包含一页纸总结、关键风险、用例执行、缺陷分析、覆盖度、风险评估、改进建议和经验沉淀等核心章节 |
| `check-quality-gate.ps1` | 检查质量门禁定义是否包含项目信息、三层门禁、紧急修复通道、DORA、触发记录、复盘、演进路线和自检 |

## 使用方式

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "F:\AI Full-stack Delivery Workflow\workflows\qa-engineer\scripts\check-test-report.ps1" -Path "F:\AI Full-stack Delivery Workflow\workflows\qa-engineer\skills\test-report\templates\test-report-template.md"

powershell -NoProfile -ExecutionPolicy Bypass -File "F:\AI Full-stack Delivery Workflow\workflows\qa-engineer\scripts\check-quality-gate.ps1" -Path "F:\AI Full-stack Delivery Workflow\workflows\qa-engineer\skills\quality-gate\templates\quality-gate-template.md"
```

## 编写原则

- Windows PowerShell 5.1 兼容。
- 脚本源码保持 ASCII-safe。
- 中文检查项通过 Unicode code point 构造，避免编码问题。
- 只做只读检查，不修改目标文档。
