---
name: planning-methodology
description: This skill should be used when the user asks to "plan a feature", "create a plan", "design an implementation", or enters plan mode. 7-phase methodology with specialized agents.
version: 2.4.0
context: fork
agent: Plan
---

# 7-Phase Planning Workflow

Execute phases in order: Context → Questions → Spec → Architecture → Tasks → Validation → Linear

## Core Principles

- **2-5 min tasks** with exact file paths, code snippets
- **Evidence** for every step
- **TDD** for all implementation
- **No vague language** ("appropriate", "best practices")
- **YAGNI** ruthlessly
- **One question at a time**, multiple choice preferred

---

## Phase 1: Context Gathering

```javascript
Task({
  subagent_type: "plan-mode:context-researcher",
  description: "Gather context for planning",
  prompt: "Research the codebase for [FEATURE]"
})
```

4-phase exploration:
1. **Feature Discovery** - Entry points, boundaries, configuration
2. **Execution Flow** - Call chains, data transformations, state changes
3. **Architectural Layers** - Presentation → business logic → data
4. **Deep-Dive** - Algorithms, error handling, performance

Use Octocode MCP (LSP, GitHub) + Context7 MCP (docs).

## Phase 2: Clarifying Questions

Use AskUserQuestion to clarify BEFORE designing:
- Edge cases and boundary conditions
- Error handling requirements
- Integration points and dependencies
- Scope boundaries (what's explicitly out)
- Design preferences
- Backward compatibility (external APIs only)
- Performance requirements

One question at a time, multiple choice with "(Recommended)" suffix.

## Phase 3: Specification

Apply Six Core Areas checklist:
1. **Commands** - build/test/lint commands
2. **Testing** - framework, coverage requirements
3. **Structure** - where code lives
4. **Style** - patterns to follow
5. **Git** - branch naming, commit format
6. **Boundaries** - Always/Ask/Never tiers

## Phase 4: Architecture Decision

```javascript
Task({
  subagent_type: "plan-mode:architecture-analyst",
  description: "Analyze architecture options",
  prompt: "Analyze architecture options for [FEATURE]"
})
```

The agent will:
- Present 2-3 options, lead with recommendation
- Compare across 6 dimensions
- Cross-check security/complex decisions
- Document in ADR format with trade-offs

## Phase 5: Task Decomposition

```javascript
Task({
  subagent_type: "plan-mode:task-decomposer",
  description: "Decompose into tasks",
  prompt: "Break down the work for [FEATURE]"
})
```

The agent will:
- Break into 2-5 minute tasks
- Add markers: `[parallel]`, `[serial]`, `[MERGE-WALL]`
- Front-load merge walls
- Define evidence criteria
- Specify TDD requirements
- Include exact file paths and code snippets

## Phase 6: Validation

```javascript
Task({
  subagent_type: "plan-mode:plan-validator",
  description: "Validate the plan",
  prompt: "Validate the plan for [FEATURE]"
})
```

The agent will:
- Apply confidence-based filtering (≥80%)
- Run self-verification audits
- Apply Rule of Five convergence
- Detect vague language (target: 0)
- Determine readiness with quality score

## Phase 7: Linear Integration (REQUIRED)

**MANDATORY: Do not complete without asking about Linear.**

1. Write the plan to the plan file

2. Use AskUserQuestion:
   - Create new Linear ticket with this plan
   - Update existing Linear ticket (user provides ID)
   - Skip Linear integration for now

3. If user chooses Linear, use Linear MCP tools.

---

## Quality Standards

| Criterion | Requirement |
|-----------|-------------|
| Granularity | 2-5 min |
| Paths | Exact |
| Evidence | Observable |
| Markers | [parallel]/[serial] |

## Banned Language

Replace: "appropriate" → exact criteria, "best practices" → name it, "handle errors" → catch/log/return.
