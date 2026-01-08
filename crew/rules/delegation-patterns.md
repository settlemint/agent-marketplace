---
description: Agent delegation patterns and prompt structure
globs: "**/agents/**/*.md,**/commands/**/*.md"
alwaysApply: false
---

# Delegation Patterns

## Delegation Table

| Domain | Delegate To | Trigger |
| --- | --- | --- |
| Explore | `explore` agent | Find existing codebase structure, patterns, styles |
| Research | `framework-docs-researcher` | Unfamiliar packages/libraries, external docs |
| Documentation | `tech-docs-writer` | README, API docs, guides |
| Review | `seven-legs` reviewers | Code review, finding issues |
| Implementation | `work-orchestrator` | Execute tasks from plan |

## Delegation Prompt Structure (MANDATORY)

When delegating, your prompt MUST include all 7 sections:

```
1. TASK: Atomic, specific goal (one action per delegation)
2. EXPECTED OUTCOME: Concrete deliverables with success criteria
3. REQUIRED SKILLS: Which skill to invoke (if applicable)
4. REQUIRED TOOLS: Explicit tool whitelist (prevents tool sprawl)
5. MUST DO: Exhaustive requirements - leave NOTHING implicit
6. MUST NOT DO: Forbidden actions - anticipate and block rogue behavior
7. CONTEXT: File paths, existing patterns, constraints
```

**Vague prompts = rejected. Be exhaustive.**

## Verification After Delegation

After delegated work appears done, ALWAYS verify:

- Does it work as expected?
- Does it follow existing codebase patterns?
- Did the expected result come out?
- Did the agent follow "MUST DO" and "MUST NOT DO" requirements?

## Parallel Execution

### Explore/Research Agents = Grep, Not Consultants

Launch in background, always parallel:

```javascript
// CORRECT: Always background, always parallel
Task({ subagent_type: "explore", prompt: "Find auth patterns...", run_in_background: true });
Task({ subagent_type: "explore", prompt: "Find error handling...", run_in_background: true });
Task({ subagent_type: "framework-docs-researcher", prompt: "Find JWT best practices...", run_in_background: true });
// Continue working immediately. Collect with TaskOutput when needed.

// WRONG: Sequential or blocking
result = Task({ ... });  // Never wait synchronously for explore/research
```

### Background Result Collection

1. Launch parallel agents → receive task_ids
2. Continue immediate work
3. When results needed: `TaskOutput({ task_id: "...", block: true })`

## Search Stop Conditions

STOP searching when:

- You have enough context to proceed confidently
- Same information appearing across multiple sources
- 2 search iterations yielded no new useful data
- Direct answer found

**DO NOT over-explore. Time is precious.**
