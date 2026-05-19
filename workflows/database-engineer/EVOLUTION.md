# database-engineer Evolution Protocol

## Purpose

This file defines how the database-engineer workflow improves itself after real tasks.

Each completed task should produce not only a database deliverable, but also a decision on whether this workflow learned something reusable.

## Evolution Targets

Update these files when the task produces reusable knowledge:

```text
field-journal/              # Real task lessons
pitfalls.md                 # Common failures and prevention
routing.md                  # Workflow-level keywords and transfer rules
skills/routing.md           # Skill-level routing rules
skills/*/SKILL.md           # Method changes for a specific skill
skills/*/templates/         # Reusable deliverable templates
skills/*/references/        # Long-term method references
tool-index.md               # Tools, commands, setup, script references
scripts/                    # Repeatable automation
WORKFLOW.md                 # Workflow steps, inputs, outputs, quality checks
```

## Database-specific Triggers

Consider updating this workflow when a task reveals:

1. A migration or rollback pattern that can be reused.
2. A repeated schema, constraint, index, or transaction pitfall.
3. A SQL review or query optimization pattern that applies to future work.
4. A multi-tenant isolation or data lifecycle decision that should become a checklist item.
5. A production data operation checklist that prevented risk.
6. A new database tool, migration framework, or verification command used successfully.
7. A new handoff requirement from API, backend, QA, DevOps/SRE, or security workflows.

## Completion Checklist

```text
1. New reusable lesson? -> Add field-journal entry.
2. New pitfall or repeated mistake? -> Update pitfalls.md.
3. New workflow keyword, task type, or transfer condition? -> Update routing.md.
4. New skill-level routing condition? -> Update skills/routing.md.
5. New tool, command, framework, or service? -> Update tool-index.md and root tool-index.md if cross-workflow.
6. New reusable deliverable format? -> Add a template under the relevant skills/*/templates/.
7. New long-term reference or method? -> Add it under the relevant skills/*/references/.
8. Repeatable manual checks? -> Add automation under scripts/.
9. Changed standard process or quality gate? -> Update WORKFLOW.md.
10. Affects another workflow? -> Update workflow-map.md or the related workflow docs.
```

## What to Record

Record verified fixes, reusable task patterns, validated migration checklists, useful tool usage, failure modes that caused rework, and cross-workflow collaboration lessons.

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
