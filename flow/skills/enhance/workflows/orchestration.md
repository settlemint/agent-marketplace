# Orchestration Workflow

Patterns for orchestrating multiple agents to complete complex tasks. Based on the principle that managing AI agents mirrors managing distributed engineering teams: front-load clarity, delegate bounded work, maintain feedback loops.

## Quick Start

1. **Classify the task** - Determine delegation tier
2. **Brief the agent** - Include kill criteria and checkpoints
3. **Execute** - Spawn workers with appropriate pattern
4. **Review** - Use two-agent pattern for non-trivial work
5. **Integrate** - Collect results and merge

## Delegation Tiers

Before delegating any task, classify it:

| Tier | Delegate To | Examples |
|------|-------------|----------|
| **Fully Delegate** | Agent runs autonomously | Mechanical implementation with clear specs, boilerplate refactors, low-risk maintenance, test generation, documentation |
| **Delegate with Checkpoints** | Agent pauses at decision points | Shared interfaces, potential merge conflicts, product edge cases, multiple valid approaches |
| **Retain Ownership** | Human decides, agent assists | System architecture, cross-cutting refactors, product decisions, security-sensitive design, API contracts |

**Key insight:** Fully-delegated tasks should have acceptance criteria so clear that success is binary. If you're unsure, add checkpoints.

## Two-Agent Review Pattern

For non-trivial implementations, spawn a dedicated reviewer after the implementer completes:

```javascript
// Step 1: Implementation
const implementTask = await Task({
  subagent_type: "general-purpose",
  description: "Implement feature X",
  prompt: `[WORKER PREAMBLE]
You are an IMPLEMENTER agent. Focus on correctness and completion.

TASK: [detailed task description]

EVIDENCE REQUIRED:
- Tests pass
- Typecheck passes
- Feature works when triggered`,
  run_in_background: true,
});

// Step 2: Wait for implementation
const implementation = await TaskOutput({ task_id: implementTask.id });

// Step 3: Review (separate agent, fresh perspective)
const reviewTask = await Task({
  subagent_type: "general-purpose",
  description: "Review feature X implementation",
  prompt: `REQUIRED: Load skills first.
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })

Read your workflow from workflows/review.md

[REVIEWER PREAMBLE]
You are a REVIEWER agent. The implementation is complete. Your job is to:

1. CORRECTNESS: Does it actually work? Run the code, verify behavior.
2. STYLE: Does it match codebase patterns? Check naming, structure.
3. MISSED TESTS: Are edge cases covered? Suggest additional tests.
4. RISK ASSESSMENT: What could go wrong? Breaking changes, security, performance.

IMPLEMENTATION SUMMARY:
${implementation}

FILES TO REVIEW:
[list of modified files]

OUTPUT FORMAT:
- Severity (P0/P1/P2/Observation) for each finding
- Specific file:line citations
- Concrete fix suggestions (not just "improve this")

If no issues found, state: "Review complete. No blocking issues."`,
  run_in_background: true,
});

const review = await TaskOutput({ task_id: reviewTask.id });
```

**When to use two-agent review:**
- Feature spans >3 files
- Contains business logic or state management
- Touches security-sensitive areas
- Has potential for subtle bugs (async, race conditions)

**When to skip (self-review sufficient):**
- Single-file mechanical changes
- Test additions without implementation changes
- Documentation-only changes
- Strictly additive changes with no side effects

## Progress Reporting

Set expectations for stalled work:

```javascript
Task({
  prompt: `...
PROGRESS RULES:
- If no significant progress in 15 minutes, STOP and report:
  1. What you attempted
  2. What's blocking you
  3. What you need to proceed
- Use predictable format for check-ins:
  - What changed?
  - What's next?
  - What are risks/blockers?
  - What do you need?

Do NOT spin on the same problem. Report blockers early.`
});
```

## Kill Criteria

Define stop conditions BEFORE starting work:

```javascript
Task({
  prompt: `...
KILL CRITERIA (stop immediately if any occur):
- [ ] Scope expands beyond original brief
- [ ] Blocked by missing dependency for >10 minutes
- [ ] Approach requires architectural changes not in brief
- [ ] Security concern discovered that needs human judgment
- [ ] Tests reveal fundamental design flaw

If any kill criterion triggers, report back with findings instead of continuing.`
});
```

## Review Bandwidth Management

**WIP Limits for Reviews:**

| Orchestrator Context | Max Concurrent Reviews |
|---------------------|----------------------|
| Single feature | 1-2 |
| Multi-file refactor | 2-3 |
| Large migration | 3-4 (with careful coordination) |

**Why limits matter:**
- Each review requires orchestrator attention to process findings
- Too many parallel reviews = drowning in context switches
- Better to complete reviews sequentially than batch-process poorly

**Pattern: Review Queue**

```javascript
// Process reviews sequentially to maintain quality
for (const taskId of implementationTaskIds) {
  const impl = await TaskOutput({ task_id: taskId });

  const review = await Task({
    subagent_type: "general-purpose",
    description: `Review ${taskId}`,
    prompt: `[REVIEWER PREAMBLE]...`,
    // NOT run_in_background - process one at a time
  });

  // Process review findings before moving to next
  await processFindings(review);
}
```

## Orchestration Patterns Summary

| Pattern | Use When | Key Characteristic |
|---------|----------|-------------------|
| **Fan-Out** | Independent parallel work | Multiple `Task()` calls, `run_in_background: true` |
| **Pipeline** | Sequential dependencies | `await TaskOutput()` between stages |
| **Two-Agent Review** | Quality-critical implementation | Implementer then Reviewer |
| **Map-Reduce** | Same transform across many files | Map tasks, collect results |
| **Checkpoint** | Uncertain scope or approach | Agent pauses for approval at defined points |

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Mega-delegation** | One agent touches 20+ files | Break into bounded tasks |
| **Review avalanche** | 10 parallel implementations | Cap concurrent reviews |
| **Scope creep** | Agent adds "improvements" beyond brief | Include "Never Do" in brief |
| **Missing kill criteria** | Agent spins on blocked task | Define stop conditions upfront |
| **No checkpoints** | Discover problems only at end | Add intermediate validation |

## Constraints

- One agent owns one PR - no mega-PRs from multiple agents
- Agents must work in isolated paths (git worktrees or separate files)
- Define explicit boundaries so agents don't touch adjacent code
- Kill criteria must be defined before task starts

## Success Criteria

- [ ] Delegation tier identified for task
- [ ] Kill criteria defined in brief
- [ ] Progress reporting expectations set
- [ ] Two-agent review used for quality-critical work
- [ ] Review bandwidth not exceeded
- [ ] No scope creep beyond original brief
