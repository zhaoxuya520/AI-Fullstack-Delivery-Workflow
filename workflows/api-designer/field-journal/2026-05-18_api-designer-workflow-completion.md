# API 设计工作流配套文件完善

## Date

2026-05-18

## Workflow

api-designer

## Task Background

用户要求继续完成全栈交付工作流的下一章节。按交付顺序，UI/UX 设计工作流之后进入 API 设计工作流。

## Inputs

- 已完成的 product-manager、project-manager、ui-ux-designer 章节结构
- 现有 `api-designer` 骨架
- API 设计主题：OpenAPI/Swagger、REST、端点、请求响应、错误码、认证鉴权、分页筛选排序、版本、幂等、Webhook、Mock 和交接

## Problem

`api-designer` 已有目录骨架，但内容未完成：

```text
WORKFLOW.md 只有简版说明。
routing.md 存在代码块和控制字符异常。
tool-index.md 混入 pitfalls 和 field-journal 内容。
pitfalls.md 为空。
templates、references、scripts 只有占位 README。
field-journal/_index.md 为空。
```

## Solution

重写核心文件：

```text
WORKFLOW.md
routing.md
tool-index.md
pitfalls.md
EVOLUTION.md
```

新增模板：

```text
api-design-brief-template.md
resource-model-template.md
endpoint-inventory-template.md
request-response-template.md
error-code-template.md
auth-permission-template.md
pagination-filter-sort-template.md
api-version-change-template.md
idempotency-retry-template.md
webhook-async-template.md
mock-contract-template.md
openapi-handoff-template.md
```

新增参考资料：

```text
public-source-index.md
api-methods.md
rest-resource-modeling-guide.md
openapi-style-guide.md
error-auth-guide.md
pagination-filter-sort-guide.md
versioning-compatibility-guide.md
idempotency-retry-guide.md
webhook-async-guide.md
mock-handoff-guide.md
```

新增脚本：

```text
scripts/check-api-spec.ps1
```

## Verification

验证目标：

```text
API 设计说明检查脚本通过。
产品经理、项目经理、UI/UX 已完成章节检查脚本仍通过。
Markdown 本地链接检查通过。
术语检查不出现非 Workflow 体系旧术语。
```

## Reusable Lesson

API 设计工作流必须以契约优先为核心：资源模型决定端点，端点必须同时定义请求、响应、错误、权限、分页、版本、幂等和 Mock。只列接口路径不足以支撑前端、后端、QA、安全和技术文档协作。

## Follow-up Improvements

- 后续后端工程师工作流应读取 `openapi-handoff-template.md` 和 `idempotency-retry-template.md`。
- 前端工程师工作流应读取 `mock-contract-template.md`。
- QA 工作流应把错误码、权限、分页、幂等和 Webhook 转成测试用例。
- 安全工程师工作流应关注认证鉴权、租户隔离、敏感字段和 Webhook 签名。

## Tags

#api-designer #openapi #rest #error-code #auth #pagination #idempotency #webhook #mock #self-evolution
