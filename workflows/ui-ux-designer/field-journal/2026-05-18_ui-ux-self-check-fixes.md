# UI/UX 工作流扩展自检修复记录

## Date

2026-05-18

## Workflow

ui-ux-designer

## Task Background

用户要求对最近扩展的 UI/UX 工作流开始自检。自检范围覆盖视觉风格库、反 AI 化、反同质化、GitHub UI 项目参考、索引接入、链接和检查脚本。

## Checks

执行检查：

```text
UI/UX 设计说明模板检查
Markdown 本地链接检查
新增参考资料和模板存在性检查
Workflow / Skill 术语检查
完整行为链编号检查
产品经理 PRD 模板检查
项目经理项目计划模板检查
```

## Findings

发现问题：

```text
1. WORKFLOW.md 完整行为链中出现重复编号 6。
2. github-ui-projects-reference.md 中有一处“技能管理”术语，不符合本项目 Workflow 术语偏好。
```

## Fixes

修复内容：

```text
1. 修正 WORKFLOW.md 完整行为链编号为 1-17 连续编号。
2. 将 “技能管理” 改为 “能力管理”。
```

## Verification

验证结果：

```text
Markdown local link check passed.
Registered UI/UX extension files exist.
PRD check passed: required sections found.
Project plan check passed: required sections found.
Design spec check passed: required sections found.
```

## Reusable Lesson

扩展工作流时，除了新增资料和模板，还要检查硬性流程编号、索引引用、术语一致性和跨章节检查脚本。特别是连续追加步骤后，行为链编号容易重复，应作为自检固定项。

## Tags

#ui-ux-designer #self-check #workflow-consistency #anti-ai-design #github-ui #self-evolution
