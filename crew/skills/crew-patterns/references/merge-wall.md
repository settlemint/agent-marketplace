# The Merge Wall

When swarming agents, the hardest part is merging their work back together. Understanding the "merge wall" helps plan effective parallel work.

## Core Problem

Swarm workers start from the same baseline (git commit). Each worker can dramatically change that baseline. When workers finish at different times, merging becomes increasingly difficult.

```
Timeline:
                    baseline
                       |
        Worker A ------+----> changes to logging
        Worker B ------+----> changes to database
        Worker C ------+----> changes to API
        Worker D ------+----> changes to logging (conflicts!)
                       |
                    merge point (THE WALL)
```

## The MapReduce Analogy

Agent swarming is like MapReduce, but with a critical difference:

| Phase      | MapReduce                       | Agent Swarming             |
| ---------- | ------------------------------- | -------------------------- |
| **Map**    | Unlimited parallel workers      | Unlimited parallel workers |
| **Reduce** | Simple aggregation (sum, count) | Complex code merging       |

In MapReduce, reduce is trivial (monoidal). In agent swarming, reduce is arbitrarily complex.

## When to Serialize

Some work MUST be serialized despite the desire for parallelism:

| Situation                    | Why Serialize                           |
| ---------------------------- | --------------------------------------- |
| **Directory restructuring**  | Changes all imports, affects every file |
| **Package reorganization**   | Cascading changes to module references  |
| **Cross-cutting concerns**   | Logging, telemetry, database schema     |
| **Configuration changes**    | Affects all workers' assumptions        |
| **Core abstraction changes** | Ripples through entire codebase         |

## When to Parallelize

Safe candidates for parallel work:

| Situation                        | Why Safe                          |
| -------------------------------- | --------------------------------- |
| **Independent features**         | Touch different files/modules     |
| **Tests for different features** | No overlap                        |
| **Documentation**                | Rarely conflicts with code        |
| **Isolated bug fixes**           | Contained scope                   |
| **New files**                    | No existing code to conflict with |

## Merge Queue Pattern

When merging parallel work:

```
1. Worker A completes → merge immediately
2. Worker B completes → rebase on A's changes, then merge
3. Worker C completes → rebase on A+B's changes, then merge
4. Worker D completes → rebase on A+B+C's changes, then merge
```

Each subsequent merge requires more context because the baseline has evolved.

## Conflict Severity Scale

| Severity      | Description                         | Resolution          |
| ------------- | ----------------------------------- | ------------------- |
| **Trivial**   | Same file, different sections       | Auto-mergeable      |
| **Moderate**  | Same file, adjacent sections        | Manual but clear    |
| **Difficult** | Same code block, different changes  | Requires judgment   |
| **Critical**  | Conflicting architectural decisions | May require re-work |

## Signs You've Hit the Wall

| Signal                          | What It Means                              |
| ------------------------------- | ------------------------------------------ |
| **Repeated rebase failures**    | Too many conflicts to auto-resolve         |
| **Context exhaustion**          | Agent can't reason about all changes       |
| **Oscillating fixes**           | Fixing one conflict breaks another         |
| **Worker D's work is obsolete** | Baseline changed so much it needs redesign |

## Strategies

### 1. Plan for Serial Phases

Alternate between swarmable and serial phases:

```
Phase 1: Swarm (parallel feature work)
    ↓
Phase 2: Serial (architectural changes)
    ↓
Phase 3: Swarm (parallel refinements)
    ↓
Phase 4: Serial (integration testing)
```

### 2. Minimize Overlap

When planning parallel work, explicitly identify potential conflicts:

```markdown
## Worker A: Logging System

- Files: src/logging/\*.ts
- Impact: None outside logging/

## Worker B: Database Layer

- Files: src/db/\*.ts
- Impact: None outside db/

## Worker C: API Routes

- Files: src/api/\*.ts
- Impact: Uses logging, uses db (READ ONLY)
- Conflict risk: LOW - only imports, doesn't modify
```

### 3. Deferred Integration

For high-conflict work, defer integration:

1. Worker completes in isolation
2. Document all changes and rationale
3. Human reviews before merge attempt
4. If baseline changed significantly, regenerate instead of merge

### 4. Feature Flags

Use feature flags to merge incomplete work:

```typescript
if (FEATURE_NEW_LOGGING) {
  newLoggingSystem.log(message);
} else {
  oldLoggingSystem.log(message);
}
```

Allows merging without full integration, reducing conflict window.

## The Critical Question

Before launching parallel workers, ask:

> "If worker A finishes and changes X, will workers B, C, D be able to rebase cleanly?"

If the answer is "probably not," either:

- Serialize the work
- Reduce scope of parallel tasks
- Accept that some workers may need regeneration

## Key Insight

The power of swarming comes from the map phase. The merge wall is the tax you pay. Plan work to maximize map time and minimize merge complexity. Sometimes the fastest path is serial.
