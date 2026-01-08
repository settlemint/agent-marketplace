---
name: agent-architecture
description: Patterns for building autonomous agent workflows. Sub-agent orchestration, loops, state.
triggers:
  - "build.*agent"
  - "agent.*workflow"
  - "orchestrat.*agent"
  - "sub.*agent"
  - "agent.*loop"
agent: Plan
context: fork
---

<objective>

Provide architectural guidance for prompt-native agent systems. This skill covers orchestration patterns, iteration loops, state management, and agent handoffs.

</objective>

<essential_principles>

## The Crew Philosophy

**Agents work, you orchestrate.** Spawn agents for heavy lifting, keep main thread light for decisions.

**State survives compaction.** All branch state lives in `.claude/branches/{branch}/state.json`.

**Handoffs are mandatory.** Every task completion creates a handoff. Knowledge persists.

**Iteration until done.** Use loops for tasks with verifiable completion criteria.

</essential_principles>

<routing>

## Task Routing

| Task                  | Resource                         |
| --------------------- | -------------------------------- |
| Agent orchestration   | `references/orchestration.md`    |
| Iteration loops       | `references/iteration-loop.md`   |
| State persistence     | `references/state-management.md` |
| Architecture patterns | `references/architecture/`       |

## Agent Definitions (`agents/`)

| Category | Agents                                                                                                                                                                |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Research | `repo-research-analyst`, `best-practices-researcher`, `git-history-analyzer`, `framework-docs-researcher`                                                             |
| Design   | `api-interface-analyst`, `data-model-architect`, `ux-workflow-analyst`, `scale-performance-analyst`, `security-threat-analyst`, `integration-dependency-analyst`      |
| Review   | `correctness-reviewer`, `performance-reviewer`, `security-reviewer`, `elegance-reviewer`, `resilience-reviewer`, `style-reviewer`, `smells-reviewer`, `meta-reviewer` |
| Workflow | `spec-flow-analyzer`, `work-orchestrator`, `pr-comment-resolver`, `bug-reproduction-validator`, `design-iterator`, `content-style-editor`                             |

## Workflows

| Workflow         | Purpose                                    |
| ---------------- | ------------------------------------------ |
| `loop.md`        | Iteration loop for autonomous completion   |
| `cancel-loop.md` | Graceful loop termination                  |
| `handoff.md`     | Create context preservation documents      |
| `compound.md`    | Extract learnings into permanent knowledge |
| `triage.md`      | Categorize and prioritize findings         |

</routing>

<references>

## Domain Knowledge

### Core Patterns

- `orchestration.md` - Agent spawning patterns
- `iteration-loop.md` - Loop mechanics, completion promises
- `state-management.md` - Unified state format

### Architecture (`references/architecture/`)

- `architecture-patterns.md` - Prompt-native design
- `system-prompt-design.md` - System prompts
- `mcp-tool-design.md` - MCP tool patterns
- `self-modification.md` - Self-modifying systems
- `refactoring-to-prompt-native.md` - Migration patterns
- `infrastructure.md` - Infrastructure patterns
- `architecture-checklist.md` - Review checklist

</references>

<success_criteria>

- Agent spawned for heavy lifting, main thread reserved for orchestration decisions
- State persisted to `.claude/branches/{branch}/state.json` when modified
- Handoff document created on task completion with context preserved
- Iteration loop has verifiable completion criteria before starting
- Parallel agents launched in single message block, not sequential calls

</success_criteria>
