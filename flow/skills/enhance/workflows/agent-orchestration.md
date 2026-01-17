# Agent Orchestration Workflow

Patterns for running multiple Claude agents in parallel for complex tasks. Covers git worktrees for isolated work, dependency mapping, and pipeline orchestration.

## Quick Start

When a task can be parallelized:

1. **Analyze dependencies** - Map which tasks can run independently
2. **Choose isolation strategy** - Worktrees for file conflicts, branches for independent work
3. **Spawn agents in parallel** - Single message with multiple Task tool calls
4. **Monitor and merge** - Track progress, resolve conflicts at merge points

## When to Use Multiple Agents

| Scenario | Agent Strategy |
|----------|----------------|
| Independent features | Parallel agents, separate branches |
| Shared file modifications | Sequential OR worktrees |
| Research tasks | Parallel Explore agents |
| Large refactoring | Split by module, parallel execution |
| Review + implementation | Pipeline (review agent → implementation agent) |

**Don't parallelize when:**
- Tasks modify same files
- Strong sequential dependencies exist
- Coordination overhead exceeds benefit

## Git Worktrees for Parallel Work

Worktrees allow multiple agents to work on different branches simultaneously without file conflicts.

### Setup Worktrees

```bash
# Create worktree for feature A
git worktree add ../worktree-feature-a feature-a

# Create worktree for feature B
git worktree add ../worktree-feature-b feature-b

# List active worktrees
git worktree list
```

### Agent Assignment

```javascript
// Agent 1 - works in worktree A
Task({
  subagent_type: "general-purpose",
  prompt: `Working directory: /path/to/worktree-feature-a

  TASK: Implement user authentication

  Branch: feature-a
  Files: src/auth/*`
});

// Agent 2 - works in worktree B (parallel)
Task({
  subagent_type: "general-purpose",
  prompt: `Working directory: /path/to/worktree-feature-b

  TASK: Implement payment processing

  Branch: feature-b
  Files: src/payments/*`
});
```

### Cleanup After Merge

```bash
# After merging features
git worktree remove ../worktree-feature-a
git worktree remove ../worktree-feature-b
```

## Dependency Mapping

Before parallelizing, map task dependencies:

### Dependency Matrix

| Task | Depends On | Can Parallel With | Touches Files |
|------|------------|-------------------|---------------|
| Add auth service | None | B, C | src/auth/* |
| Add payment service | None | A, C | src/payments/* |
| Add dashboard UI | A, B | None | src/components/* |
| Write integration tests | A, B, C | None | tests/* |

### Dependency Graph

```
[A: Auth] ──────────┐
                    ├──→ [C: Dashboard] ──→ [D: Tests]
[B: Payments] ──────┘
```

**Parallel opportunities:**
- A and B run simultaneously
- C waits for A and B
- D waits for C

## Spawning Parallel Agents

**CRITICAL: Send multiple Task calls in a SINGLE message for true parallelism.**

```javascript
// ✅ CORRECT - Single message, multiple agents
Task({
  subagent_type: "Explore",
  prompt: "Find all authentication-related code..."
});
Task({
  subagent_type: "Explore",
  prompt: "Find all database schema definitions..."
});
Task({
  subagent_type: "Explore",
  prompt: "Find all API endpoint handlers..."
});

// ❌ WRONG - Sequential calls (defeats parallelism)
// Message 1: Task({ ... })
// Wait for result
// Message 2: Task({ ... })
```

## Pipeline Orchestration

For tasks with sequential dependencies, use pipeline patterns:

### Review → Implement Pipeline

```javascript
// Stage 1: Review agent analyzes current code
const reviewResult = await Task({
  subagent_type: "Explore",
  prompt: `Analyze the current authentication implementation.

  Report:
  1. Current patterns used
  2. Security concerns
  3. Recommended improvements`
});

// Stage 2: Implementation agent uses review output
Task({
  subagent_type: "general-purpose",
  prompt: `Based on review findings:
  ${reviewResult.summary}

  Implement the recommended improvements.`
});
```

### Build → Test → Deploy Pipeline

```
[Build Agent] → [Test Agent] → [Deploy Agent]
     ↓              ↓              ↓
  Build output   Test results   Deployment URL
```

## Merge Strategies

### For Worktree-Based Parallel Work

```bash
# From main worktree
git checkout main
git merge feature-a --no-ff -m "feat: add authentication"
git merge feature-b --no-ff -m "feat: add payments"
```

### Conflict Resolution

If agents modified same files unexpectedly:

1. Identify conflicting changes
2. Spawn conflict resolution agent:

```javascript
Task({
  subagent_type: "general-purpose",
  prompt: `Resolve merge conflict in src/shared/types.ts

  Branch A changes: [describe]
  Branch B changes: [describe]

  Merge intent: Combine both changes preserving functionality.`
});
```

## Monitoring Parallel Agents

### Background Agents

```javascript
// Run agents in background
Task({
  subagent_type: "general-purpose",
  prompt: "...",
  run_in_background: true
});

// Check status with TaskOutput
TaskOutput({ task_id: "agent-id", block: false });

// Or read output file
Read({ file_path: "/path/to/output/file" });
```

### Progress Tracking

Use TodoWrite to track parallel work:

```
1. [x] Agent A: Authentication service
2. [x] Agent B: Payment service
3. [ ] Agent C: Dashboard (waiting for A, B)
4. [ ] Agent D: Integration tests (waiting for C)
```

## Best Practices

### Do
- Map dependencies before parallelizing
- Use worktrees for file-level isolation
- Spawn parallel agents in single message
- Track progress with TodoWrite
- Plan merge strategy upfront

### Don't
- Parallelize tightly coupled tasks
- Ignore merge conflicts until the end
- Create more agents than necessary
- Forget to clean up worktrees

## Success Criteria

- [ ] Dependencies mapped before parallelization
- [ ] Isolation strategy chosen (worktrees vs branches)
- [ ] Parallel agents spawned in single message
- [ ] Progress tracked via TodoWrite
- [ ] Merge strategy defined
- [ ] Worktrees cleaned up after merge
