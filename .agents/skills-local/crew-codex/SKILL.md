---
name: crew-codex
description: Complete development workflow for Codex. Defines philosophy, task classification, hard requirements, anti-patterns, and 8-phase development process with spawn_agent.
---

# Crew Codex Skill

## Loading Guidance

This skill defines the development workflow. Load the depth appropriate to task risk.

### Minimum Load (Trivial/Simple or docs/config-only)

Read these before proceeding:

```
1. read_file .agents/skills-local/crew-codex/philosophy.md
2. read_file .agents/skills-local/crew-codex/task-classification.md
3. read_file .agents/skills-local/crew-codex/hard-requirements.md
```

### Full Load (Standard/Complex or multi-file code changes)

Read all files below, in order:

```
1. read_file .agents/skills-local/crew-codex/philosophy.md
2. read_file .agents/skills-local/crew-codex/task-classification.md
3. read_file .agents/skills-local/crew-codex/hard-requirements.md
4. read_file .agents/skills-local/crew-codex/anti-patterns.md
5. read_file .agents/skills-local/crew-codex/workflows.md
6. read_file .agents/skills-local/crew-codex/skill-routing-table.md
```

### Loading Verification

After reading all 6 files, confirm by outputting:

```
CREW-CODEX LOADED:
- [x] philosophy.md — Development philosophy, non-negotiables, coding style, security
- [x] task-classification.md — Classification rules and checklists
- [x] hard-requirements.md — Gates, skill activation, verification requirements
- [x] anti-patterns.md — What NEVER to do
- [x] workflows.md — 8-phase development process with spawn_agent
- [x] skill-routing-table.md — Trigger → skill/tool mapping
```

If you only completed the minimum load, confirm with:

```
CREW-CODEX PARTIAL:
- [x] philosophy.md
- [x] task-classification.md
- [x] hard-requirements.md
```

### Why This Matters

These files contain:
- **Philosophy** — Development mindset, non-negotiables, coding style, security guards
- **Task Classification** — Trivial/Simple/Standard/Complex with minimum steps
- **Hard Requirements** — Gates that BLOCK progress if not met
- **Anti-Patterns** — Failure modes that result in rejected work
- **Workflows** — The 8-phase process with spawn_agent collaboration
- **Skill Routing** — Which skills/tools to use for which triggers

**Ignoring these increases rework and review churn.**

### Self-Check

Before ANY implementation:
1. Did I read the minimum or full set appropriate to the task?
2. Did I output the matching loading verification?
3. Did I classify the task? If no → classify before proceeding
