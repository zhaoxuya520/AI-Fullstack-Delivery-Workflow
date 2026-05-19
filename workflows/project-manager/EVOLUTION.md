# project-manager Evolution Protocol

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

## What to Record

Record verified fixes, reusable task patterns, validated checklists, useful tool usage, failure modes that caused rework, and cross-workflow collaboration lessons.

Do not record temporary state, unverified guesses, plain code structure derivable from files, secrets, tokens, accounts, customer data, or one-off noise without future value.

## Journal Entry Flow

```text
copy field-journal/_template.md
-> create dated entry
-> summarize task background
-> record problem and solution
-> record verification
-> extract reusable lesson
-> update field-journal/_index.md
```

## Root-level Escalation

Update root-level docs only when the lesson affects multiple workflows:

```text
../../RULES.md
../../routing.md
../../workflow-map.md
../../tool-index.md
../../EVOLUTION.md
../../field-journal/_index.md
```
