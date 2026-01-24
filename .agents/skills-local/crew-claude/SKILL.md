---
name: crew-claude
description: Complete development workflow for Claude Code. Defines philosophy, task classification, hard requirements, anti-patterns, and 8-phase development process.
---

# Crew Claude Skill

## MANDATORY LOADING — NO EXCEPTIONS

**⚠️ STOP. You MUST read ALL files below BEFORE any implementation work.**

This skill defines the complete development workflow. Skipping ANY file = workflow violation.

### Required Files (READ ALL — IN ORDER)

```
1. Read .agents/skills-local/crew-claude/philosophy.md
2. Read .agents/skills-local/crew-claude/task-classification.md
3. Read .agents/skills-local/crew-claude/hard-requirements.md
4. Read .agents/skills-local/crew-claude/anti-patterns.md
5. Read .agents/skills-local/crew-claude/workflows.md
6. Read .agents/skills-local/crew-claude/skill-routing-table.md
```

### Loading Verification

After reading all files, confirm by outputting:

```
CREW-CLAUDE LOADED:
- [x] philosophy.md — Development philosophy, non-negotiables, coding style, security
- [x] task-classification.md — Classification rules and checklists
- [x] hard-requirements.md — Gates, skill loading, verification requirements
- [x] anti-patterns.md — What NEVER to do
- [x] workflows.md — 8-phase development process
- [x] skill-routing-table.md — Trigger → skill/tool mapping
```

**If you cannot check all boxes, STOP and read the missing files.**

### Why This Matters

These files contain:
- **Philosophy** — Development mindset, non-negotiables, coding style, security guards
- **Task Classification** — Trivial/Simple/Standard with minimum steps
- **Hard Requirements** — Gates that BLOCK progress if not met
- **Anti-Patterns** — Failure modes that result in rejected work
- **Workflows** — The 8-phase process with gates
- **Skill Routing** — Which skills/tools to use for which triggers

**Ignoring these = rework, failed reviews, broken builds.**

### Self-Check

Before ANY implementation:
1. Did I read all 6 files? If no → STOP, read them
2. Did I output the loading verification? If no → output it now
3. Did I classify the task? If no → classify before proceeding
