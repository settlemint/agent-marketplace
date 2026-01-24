---
name: crew-codex
description: Complete development workflow for Codex. Defines philosophy, task classification, hard requirements, anti-patterns, and 8-phase development process with spawn_agent.
---

# Crew Codex Skill

## MANDATORY LOADING — NO EXCEPTIONS

**⚠️ STOP. You MUST read ALL files below BEFORE any implementation work.**

This skill defines the complete development workflow. Skipping ANY file = workflow violation.

### Required Files (READ ALL — IN ORDER)

```
1. read_file .agents/skills-local/crew-codex/philosophy.md
2. read_file .agents/skills-local/crew-codex/task-classification.md
3. read_file .agents/skills-local/crew-codex/hard-requirements.md
4. read_file .agents/skills-local/crew-codex/anti-patterns.md
5. read_file .agents/skills-local/crew-codex/workflows.md
6. read_file .agents/skills-local/crew-codex/skill-routing-table.md
```

### Loading Verification

After reading all files, confirm by outputting:

```
CREW-CODEX LOADED:
- [x] philosophy.md — Development philosophy, non-negotiables, coding style, security
- [x] task-classification.md — Classification rules and checklists
- [x] hard-requirements.md — Gates, skill activation, verification requirements
- [x] anti-patterns.md — What NEVER to do
- [x] workflows.md — 8-phase development process with spawn_agent
- [x] skill-routing-table.md — Trigger → skill/tool mapping
```

**If you cannot check all boxes, STOP and read the missing files.**

### Why This Matters

These files contain:
- **Philosophy** — Development mindset, non-negotiables, coding style, security guards
- **Task Classification** — Trivial/Simple/Standard/Complex with minimum steps
- **Hard Requirements** — Gates that BLOCK progress if not met
- **Anti-Patterns** — Failure modes that result in rejected work
- **Workflows** — The 8-phase process with spawn_agent collaboration
- **Skill Routing** — Which skills/tools to use for which triggers

**Ignoring these = rework, failed reviews, broken builds.**

### Self-Check

Before ANY implementation:
1. Did I read all 6 files? If no → STOP, read them
2. Did I output the loading verification? If no → output it now
3. Did I classify the task? If no → classify before proceeding
