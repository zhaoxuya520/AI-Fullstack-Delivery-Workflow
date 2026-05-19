param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$workflowRoot = Join-Path $Root 'workflows'

$workflows = @(
    [pscustomobject]@{ Slug='product-manager'; Title='Product Manager Workflow'; Keywords='requirements, PRD, MVP, user story, acceptance criteria'; Tools='PRD template, user story template, Mermaid, competitor analysis table'; Pitfalls='missing acceptance criteria; solution written as requirement; MVP scope too large; non-goals not defined' },
    [pscustomobject]@{ Slug='project-manager'; Title='Project Manager Workflow'; Keywords='schedule, milestone, task breakdown, risk management, sprint plan'; Tools='kanban, gantt chart, Mermaid, risk matrix'; Pitfalls='tasks without dependencies; no integration buffer; risks not tracked; release gate missing' },
    [pscustomobject]@{ Slug='ui-ux-designer'; Title='UI/UX Designer Workflow'; Keywords='UI, UX, interaction, prototype, page structure, user flow'; Tools='Figma, Pixso, Mermaid, screenshot annotation'; Pitfalls='static screens only; empty/error/loading states missing; component boundary unclear; UI data mismatches API' },
    [pscustomobject]@{ Slug='frontend-engineer'; Title='Frontend Engineer Workflow'; Keywords='React, Vue, CSS, HTML, JavaScript, TypeScript, page, component, browser'; Tools='Node.js, npm/pnpm/yarn, Vite, React/Vue, Chrome DevTools, Playwright'; Pitfalls='not verified in browser; success state only; API field mismatch; responsive layout missing; console errors ignored' },
    [pscustomobject]@{ Slug='backend-engineer'; Title='Backend Engineer Workflow'; Keywords='API, server, auth, authorization, business logic, data processing, cache, queue'; Tools='Node.js/Python/Go/Java, FastAPI/Express/Spring Boot, curl, OpenAPI, Redis'; Pitfalls='authorization only in frontend; controller contains complex business logic; transaction/idempotency missing; sensitive data in logs' },
    [pscustomobject]@{ Slug='fullstack-engineer'; Title='Full-stack Engineer Workflow'; Keywords='full-stack, MVP, admin panel, frontend-backend integration, end-to-end feature'; Tools='frontend framework, backend framework, migration tool, Docker, curl'; Pitfalls='API contract skipped; temporary database design; missing test data; deployment differences ignored' },
    [pscustomobject]@{ Slug='api-designer'; Title='API Designer Workflow'; Keywords='OpenAPI, Swagger, API design, Mock, error code, API contract'; Tools='OpenAPI, Swagger, Postman, Apifox, JSON Schema, Mermaid'; Pitfalls='unstable response structure; inconsistent error codes; internal implementation exposed; mock differs from backend' },
    [pscustomobject]@{ Slug='database-engineer'; Title='Database Engineer Workflow'; Keywords='database, SQL, schema, ERD, index, migration, PostgreSQL, MySQL, Redis'; Tools='PostgreSQL, MySQL, SQLite, Redis, Prisma, Flyway, DBeaver'; Pitfalls='schema copied from page fields; unique constraints missing; over-indexing; production migration without backup/rollback' },
    [pscustomobject]@{ Slug='qa-engineer'; Title='QA Engineer Workflow'; Keywords='test case, functional test, regression test, acceptance test, bug reproduction'; Tools='test case template, Postman, Apifox, browser DevTools, issue tracker'; Pitfalls='positive path only; test data not recorded; bug lacks reproduction steps; regression scope too narrow' },
    [pscustomobject]@{ Slug='automation-qa'; Title='Automation QA Workflow'; Keywords='unit test, integration test, E2E, Playwright, Cypress, Jest, Pytest, coverage'; Tools='Jest, Vitest, Pytest, JUnit, Playwright, Cypress, GitHub Actions'; Pitfalls='too many flaky E2E tests; test data pollutes environment; weak assertions; CI failure hard to diagnose' },
    [pscustomobject]@{ Slug='devops-engineer'; Title='DevOps Engineer Workflow'; Keywords='Docker, CI/CD, GitHub Actions, GitLab CI, Nginx, deploy, rollback'; Tools='Docker, Docker Compose, GitHub Actions, GitLab CI, Nginx, Kubernetes'; Pitfalls='missing env vars; no health check; no rollback plan; wrong CI trigger; secret leakage' },
    [pscustomobject]@{ Slug='sre-operations'; Title='SRE Operations Workflow'; Keywords='monitoring, log, alert, incident, production issue, performance, postmortem'; Tools='Prometheus, Grafana, Loki, ELK, OpenSearch, Sentry, Kubernetes'; Pitfalls='root cause before mitigation; app logs only; unactionable alerts; postmortem without action items' },
    [pscustomobject]@{ Slug='security-engineer'; Title='Security Engineer Workflow'; Keywords='security review, vulnerability, permission risk, dependency security, XSS, SQL injection, SSRF, IDOR'; Tools='SAST, DAST, Burp Suite, ZAP, Nmap, Nuclei, security checklist'; Pitfalls='authorization not confirmed; scan without business validation; IDOR ignored; remediation not actionable' },
    [pscustomobject]@{ Slug='reverse-pentest'; Title='Reverse Pentest Workflow'; Keywords='reverse, pentest, CTF, packet capture, APK, IDA, Frida, JS signature, binary'; Tools='embedded reverse-skill-private project, jadx, apktool, Frida, IDA, radare2, Nmap'; Pitfalls='authorization not confirmed; tool-index not checked; screenshots without reproduction steps; field-journal not updated' },
    [pscustomobject]@{ Slug='data-analyst'; Title='Data Analyst Workflow'; Keywords='metrics, report, data analysis, funnel, retention, conversion, SQL report, AB test'; Tools='SQL, Python, Pandas, BI tool, Jupyter, Mermaid'; Pitfalls='metric definition inconsistent; sample bias ignored; correlation treated as causation; conclusion not actionable' },
    [pscustomobject]@{ Slug='ai-ml-engineer'; Title='AI ML Engineer Workflow'; Keywords='AI, machine learning, LLM, RAG, recommendation, classification, prediction, embedding'; Tools='Python, PyTorch, scikit-learn, vector database, LLM API, evaluation script'; Pitfalls='no baseline; offline metric only; RAG recall not evaluated; prompt not versioned' },
    [pscustomobject]@{ Slug='technical-writer'; Title='Technical Writer Workflow'; Keywords='README, documentation, report, architecture doc, API doc, deployment doc, postmortem'; Tools='Markdown, Mermaid, MkDocs, Docusaurus, VitePress, screenshot tool'; Pitfalls='reproduction steps missing; commands/paths not portable; risks/limits missing; sensitive data leaked in security report' }
)

function Write-IfMissing {
    param([string]$Path, [string]$Content)
    if (-not (Test-Path $Path)) {
        $parent = Split-Path -Parent $Path
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        Set-Content -Path $Path -Value $Content -Encoding utf8
        Write-Host "created $Path"
    }
}

foreach ($workflow in $workflows) {
    $dir = Join-Path $workflowRoot $workflow.Slug
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    foreach ($sub in @('templates','references','scripts','field-journal')) {
        $subdir = Join-Path $dir $sub
        if (-not (Test-Path $subdir)) { New-Item -ItemType Directory -Force -Path $subdir | Out-Null }
    }

    $toolLines = (($workflow.Tools -split ', ') | ForEach-Object { "- $_" }) -join "`n"
    $pitfallLines = (($workflow.Pitfalls -split '; ') | ForEach-Object { "- $_" }) -join "`n"

    $routing = @'
# {TITLE} Routing

## Keywords

{KEYWORDS}

## Route Contract

```yaml
workflow: {SLUG}
name: {TITLE}
keywords: [{KEYWORDS}]
entry: WORKFLOW.md
required_files:
  - WORKFLOW.md
  - routing.md
  - tool-index.md
  - pitfalls.md
  - field-journal/_index.md
outputs:
  - deliverable
  - verification result
  - document or report when needed
```

## Before Entering

```text
goal is clear
required input exists
expected output is clear
cross-workflow collaboration is identified
security/data/deployment/production risk is identified
```

## Missed Route

If the task does not belong here, return to the root `routing.md` and choose another workflow.
'@
    $routing = $routing -replace '\{TITLE\}', $workflow.Title
    $routing = $routing -replace '\{SLUG\}', $workflow.Slug
    $routing = $routing -replace '\{KEYWORDS\}', $workflow.Keywords

    $tools = @'
# {TITLE} Tool Index

## Common Tools

{TOOLLINES}

## Tool Rules

1. Prefer the current project's existing toolchain.
2. Do not add dependencies for one-off convenience.
3. Confirm blast radius before using tools that affect security, deployment, database, or production.
4. If a tool is missing, check this file and the root `tool-index.md` before installing or replacing it.

## Tool Entry Template

```text
name:
purpose:
install:
verify:
related scripts:
```
'@
    $tools = $tools -replace '\{TITLE\}', $workflow.Title
    $tools = $tools -replace '\{TOOLLINES\}', $toolLines

    $pitfalls = @'
# {TITLE} Pitfalls

## Frequent Pitfalls

{PITFALLLINES}

## Handling Rules

1. Confirm input and acceptance criteria first.
2. Reproduce before designing a fix.
3. Verify the core path before edge cases.
4. Record reusable lessons in `field-journal/` after completion.

## New Pitfall Template

```text
date:
scenario:
problem:
root cause:
prevention:
```
'@
    $pitfalls = $pitfalls -replace '\{TITLE\}', $workflow.Title
    $pitfalls = $pitfalls -replace '\{PITFALLLINES\}', $pitfallLines

    $journalIndex = @'
# {TITLE} Field Journal

> Record reusable lessons from real tasks in this workflow. After a task produces a reusable pattern, pitfall, or template, add an entry using `_template.md` and update this index.

## Entries

<!-- - [YYYY-MM-DD] project — keywords: keyword1, keyword2 -->

## High-frequency Lessons

<!-- Add only lessons from real work, not generic rules. -->

## Stats

- Total entries: 0
- Last updated: 2026-05-18
'@
    $journalIndex = $journalIndex -replace '\{TITLE\}', $workflow.Title

    $journalTemplate = @"
# Journal Entry

## Date

YYYY-MM-DD

## Workflow

$($workflow.Slug)

## Task Background

## Inputs

## Problem

## Solution

## Verification

## Reusable Lesson

## Follow-up Improvements

## Tags

#$($workflow.Slug)
"@

    $evolution = @'
# {SLUG} Evolution Protocol

## Purpose

This file defines how this workflow improves itself after real tasks.

Each completed task should produce not only a deliverable, but also a decision on whether this workflow learned something reusable.

## Evolution Targets

Update these files when the task produces reusable knowledge:

```text
field-journal/      # Real task lessons
pitfalls.md         # Common failures and prevention
routing.md          # Keywords, triggers, required inputs, outputs
tool-index.md       # Tools, commands, setup, script references
templates/          # Reusable deliverable templates
references/         # Methodology, standards, cheatsheets
scripts/            # Repeatable automation
WORKFLOW.md         # Workflow steps, inputs, outputs, quality checks
```

## Completion Checklist

```text
1. New reusable lesson? -> Add field-journal entry.
2. New pitfall or repeated mistake? -> Update pitfalls.md.
3. New keyword, task type, or routing condition? -> Update routing.md and root routing.md if needed.
4. New tool, command, framework, or service? -> Update tool-index.md and root tool-index.md if needed.
5. New reusable deliverable format? -> Add a template under templates/.
6. New long-term reference or method? -> Add it under references/.
7. Repeatable manual steps? -> Add automation under scripts/.
8. Changed standard process or quality gate? -> Update WORKFLOW.md.
9. Affects another workflow? -> Update workflow-map.md or the related workflow docs.
```

## Root-level Escalation

Update root-level docs only when the lesson affects multiple workflows.
'@
    $evolution = $evolution -replace '\{SLUG\}', $workflow.Slug

    Write-IfMissing -Path (Join-Path $dir 'EVOLUTION.md') -Content $evolution
    Write-IfMissing -Path (Join-Path $dir 'routing.md') -Content $routing
    Write-IfMissing -Path (Join-Path $dir 'tool-index.md') -Content $tools
    Write-IfMissing -Path (Join-Path $dir 'pitfalls.md') -Content $pitfalls
    Write-IfMissing -Path (Join-Path $dir 'field-journal\_index.md') -Content $journalIndex
    Write-IfMissing -Path (Join-Path $dir 'field-journal\_template.md') -Content $journalTemplate
    Write-IfMissing -Path (Join-Path $dir 'templates\README.md') -Content "# $($workflow.Title) Templates`n`nThis directory stores deliverable templates for this workflow.`n"
    Write-IfMissing -Path (Join-Path $dir 'references\README.md') -Content "# $($workflow.Title) References`n`nThis directory stores methodology, conventions, cheatsheets, and references for this workflow.`n"
    Write-IfMissing -Path (Join-Path $dir 'scripts\README.md') -Content "# $($workflow.Title) Scripts`n`nThis directory stores automation scripts for this workflow.`n"
}

Write-Host 'workflow standardization completed'
