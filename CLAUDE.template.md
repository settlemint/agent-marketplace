# Claude Code Guidelines

Global configuration for Claude Code agents. These rules are enforced across all sessions and projects.

## Core Principles

1. **TDD is Mandatory** - No production code without a failing test first
2. **Plan Before Build** - Complex tasks require explicit planning
3. **Evidence Over Claims** - Verify all work with observable proof
4. **Use Specialized Agents** - Delegate to build-mode agents, not generic agents
5. **Atomic Commits** - One task = one commit opportunity

## Workflow Selection

### When to Plan

Use planning for tasks that:
- Add new features or significant functionality
- Affect multiple files or modules
- Require architectural decisions
- Have unclear requirements
- Need user approval before implementation

**Invoke planning:** `Skill({ skill: "plan-mode:plan" })` or `/plan`

**Planning produces a written specification with 2-5 minute tasks.**

### When to Build Directly

Build directly when:
- Plan already exists and is approved
- Task is a single-file bug fix
- User explicitly says "just fix it"
- Requirements are completely clear

**Invoke build:** `Skill({ skill: "build-mode:build" })` or `/build`

## TDD Workflow (Mandatory)

### The Iron Law

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

This is not optional. This is not negotiable. If you write implementation code before a test:
1. DELETE the code
2. Write the test
3. Verify the test FAILS
4. THEN write the implementation

### Red-Green-Refactor Cycle

1. **RED**: Write a failing test that demonstrates the desired behavior
2. **GREEN**: Write the minimum code to make the test pass
3. **REFACTOR**: Improve code while keeping tests green

### Verification Commands

Always run these commands and cite their output:
```bash
bun run test      # Tests pass
bun run lint      # No lint errors
bun run ci        # Full CI pipeline (if available)
```

**Never claim "tests pass" without running and showing the output.**

## Agent Orchestration

### Mandatory: Use Build-Mode Agents

**NEVER use "Explore" or "general-purpose" for implementation tasks.**

| Task | Invocation |
|------|------------|
| Implementation | `Task({ subagent_type: "build-mode:task-implementer", prompt: "..." })` |
| Requirements check | `Task({ subagent_type: "build-mode:spec-reviewer", prompt: "..." })` |
| Code quality | `Task({ subagent_type: "build-mode:quality-reviewer", prompt: "..." })` |
| Security audit | `Task({ subagent_type: "build-mode:security-reviewer", prompt: "..." })` |
| Error handling | `Task({ subagent_type: "build-mode:silent-failure-hunter", prompt: "..." })` |
| UI verification | `Task({ subagent_type: "build-mode:visual-tester", prompt: "..." })` |
| Final gate | `Task({ subagent_type: "build-mode:completion-validator", prompt: "..." })` |

### Execution Pattern

```
For each task:
  1. Mark task in_progress (TodoWrite)
  2. Task({ subagent_type: "build-mode:task-implementer", prompt: "..." })
  3. Task({ subagent_type: "build-mode:spec-reviewer", prompt: "..." })
  4. Task({ subagent_type: "build-mode:quality-reviewer", prompt: "..." })
  5. Task({ subagent_type: "build-mode:silent-failure-hunter", prompt: "..." })
  6. If UI: Task({ subagent_type: "build-mode:visual-tester", prompt: "..." })
  7. Mark task completed with evidence (TodoWrite)
```

### Fresh Context Per Task

Context pollution degrades quality. Spawn a NEW agent for each task:

```
Task 1 -> Task({ subagent_type: "build-mode:task-implementer" }) -> DONE
Task 2 -> Task({ subagent_type: "build-mode:task-implementer" }) -> DONE
```

### Iterative Retrieval Protocol

When agent results are incomplete:
1. Evaluate: Can I proceed confidently with ONLY this information?
2. Identify gaps: What was mentioned but not detailed?
3. Resume if needed: `Task({ resume: agentId, prompt: "Follow-up: ..." })`
4. Maximum 3 refinement cycles

**Load iterative-retrieval skill:** `Skill({ skill: "build-mode:iterative-retrieval" })`

## Planning Methodology

**Load planning skill:** `Skill({ skill: "plan-mode:planning-methodology" })`

### 7-Phase Planning

1. **Context Gathering** - Launch parallel Explore agents
2. **Clarifying Questions** - One question at a time, multiple choice preferred
3. **Specification** - Six Core Areas, exact file paths, no vague language
4. **Architecture Decision** - 2-3 options with trade-offs, recommend one
5. **Task Decomposition** - 2-5 minute tasks with `[parallel]`/`[serial]` markers
6. **Validation** - Rule of Five convergence
7. **Documentation** - Write plan, ask about Linear integration

### Task Requirements

- **2-5 minute granularity** - Break down larger tasks
- **Exact file paths** - `src/services/auth.ts`, not "auth file"
- **Code snippets** - For non-trivial changes
- **Evidence criteria** - Observable completion proof
- **TDD requirement** - Write failing test FIRST

### Parallelization Markers

| Marker | Meaning |
|--------|---------|
| `[parallel]` | Can run simultaneously (no shared files) |
| `[serial]` | Must wait for prior steps |
| `[MERGE-WALL]` | Blocks all parallel work |

**Front-load merge walls, then parallelize remaining work.**

## Banned Practices

### Vague Language

| Banned | Replace With |
|--------|--------------|
| "appropriate" | Exact criteria or threshold |
| "best practices" | Name the specific practice |
| "as needed" | Specific trigger condition |
| "properly" | List specific validations |
| "should work" | Test output showing it works |

### Anti-Patterns

- Writing implementation before tests
- Using generic agents for specialized tasks
- Claiming completion without verification
- Skipping two-stage review
- Making architectural decisions without planning

## Evidence Requirements

### Before Claiming Completion

1. **Identify** the verification command
2. **Run** the command fresh (not cached)
3. **Read** full output and exit codes
4. **Verify** output confirms the claim
5. **Only then** make the claim with evidence

### Required Evidence by Work Type

| Work Type | Required Evidence |
|-----------|-------------------|
| Tests | Test output showing 0 failures |
| Lint | Lint output showing 0 errors |
| Build | Build exit code 0 |
| Bug fix | Original symptom + passing test |
| Feature | Demo + tests + CI green |

## Systematic Debugging

### When Encountering Bugs

1. **Root Cause Investigation** - NO FIXES WITHOUT THIS
   - Read error messages completely
   - Reproduce consistently
   - Trace data flow
   - Gather evidence

2. **Pattern Analysis**
   - Find working examples in codebase
   - Compare against broken code
   - Document differences

3. **Hypothesis Testing**
   - Form single, specific hypothesis
   - Test with minimal changes
   - Verify before proceeding

4. **Implementation**
   - Write failing test reproducing bug
   - Implement single fix for root cause

### Red Flags (Return to Step 1)

- "Just try X and see"
- "I don't fully understand but..."
- "One more fix attempt"
- Proposing solutions before data flow analysis

## Code Health

### Avoid Over-Engineering

- Don't add features beyond what was asked
- Don't refactor code that doesn't need it
- Don't add error handling for impossible scenarios
- Don't create abstractions for one-time operations

### Clean Implementation

- Favor full rewrites over backwards-compatibility hacks for internal code
- Delete unused code completely (no `_unused` variables)
- No comments for removed code

## Git Workflow

### Commit Strategy

- One atomic commit per 2-5 minute task
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Commit after each task completion, not in batches

### Before Committing

1. Run `bun run ci` (or equivalent)
2. Verify all tests pass
3. Verify lint is clean
4. Show the evidence

## Quick Reference

### Implementation Checklist

- [ ] Plan approved (for complex tasks)
- [ ] TodoWrite updated with tasks
- [ ] Failing test written FIRST
- [ ] Test verified to fail
- [ ] Minimal implementation written
- [ ] Test passes
- [ ] Refactor complete (tests still green)
- [ ] Two-stage review passed
- [ ] Silent failure hunter passed
- [ ] Visual tests passed (if UI)
- [ ] CI green with fresh evidence
- [ ] Atomic commit made

### Available Skills and Commands

| Command/Skill | Purpose | Invocation |
|---------------|---------|------------|
| /plan | Start 7-phase planning workflow | `Skill({ skill: "plan-mode:plan" })` |
| /build | Execute plan with TDD and agents | `Skill({ skill: "build-mode:build" })` |
| /review | Run comprehensive code review | `Skill({ skill: "build-mode:review" })` |
| /commit | Create conventional commit | `Skill({ skill: "git:commit" })` |
| /pr | Create pull request | `Skill({ skill: "git:pr" })` |
| /push | Push commits safely | `Skill({ skill: "git:push" })` |
| /sync | Sync with main branch | `Skill({ skill: "git:sync" })` |
