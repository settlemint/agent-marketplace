# Boundary Complexity

AI cognition degrades every time it crosses a system boundary. Understanding this helps diagnose when projects are too hard for current models.

## Core Principle

Every boundary crossing (RPC, IPC, FFI, database, client/server, eval) makes agents cognitively "dumber." The more boundaries, the harder the task.

## Boundary Types

| Boundary          | Example                                   | Cognitive Cost |
| ----------------- | ----------------------------------------- | -------------- |
| **Process**       | Agent → separate process (emacs, browser) | High           |
| **Network**       | API calls, RPC, client/server             | Medium-High    |
| **Database**      | SQL queries, ORM translations             | Medium         |
| **FFI**           | Calling code in another language          | High           |
| **Eval**          | Dynamic code execution                    | High           |
| **IPC**           | Inter-process communication               | Medium-High    |
| **Serialization** | JSON/protobuf boundaries                  | Low-Medium     |

## Symptoms of Boundary Overload

When an agent is struggling with too many boundaries:

| Symptom                 | Description                                                       |
| ----------------------- | ----------------------------------------------------------------- |
| **Diminishing returns** | Each attempt produces slightly better results, but never succeeds |
| **Context exhaustion**  | Agent runs out of context reasoning about all the layers          |
| **Repeated failures**   | Same failure mode despite different approaches                    |
| **Confusion**           | Agent conflates which system is responsible for what              |
| **Partial solutions**   | Works on one side of boundary but not the other                   |

## Strategies

### 1. Wait for Smarter Models

Some projects are ahead of their time. If current models can't handle the boundary complexity:

- Pause the project
- Keep it in a "too hard for AI" backlog
- Revisit after 1-2 model releases
- Use as a benchmark to measure model progress

### 2. Reduce Boundaries

Restructure to minimize boundary crossings:

```
BEFORE (3 boundaries):
Agent → Bridge → External Process → API → Response

AFTER (1 boundary):
Agent → Direct API call → Response
```

### 3. Build Better Bridges

When boundaries are necessary, invest in agent-friendly bridges:

- Clear error messages
- Simple request/response format
- Minimal state management
- Comprehensive logging

### 4. Plan for Future Models

Build tools that work better with smarter agents:

- Document what the tool SHOULD do, even if current models can't use it
- Design clean interfaces that future models will handle easily
- Accept that current integration may be clunky

## The "Too Hard" Backlog

Maintain a list of projects that are currently too hard for AI:

```markdown
## Too Hard for AI (Current Models)

### Project: Efrit (Native Elisp Agent)

- Boundaries: Agent → Emacs process → API → elisp eval
- Last attempted: August 2025
- Model at time: Sonnet 3.5
- Reason: Too many boundaries, context exhaustion

### Project: Browser Automation

- Boundaries: Agent → Browser extension → DOM → Network
- Last attempted: October 2025
- Model at time: Sonnet 4
- Reason: Async complexity across boundaries
```

When new models release, revisit these projects. Track which ones "fall" to measure model progress.

## Decision Framework

When agent struggles with a boundary-heavy task:

1. **Count boundaries**: How many system boundaries does this task cross?
   - 0-1: Should be straightforward
   - 2-3: Expect some difficulty
   - 4+: May be too hard for current models

2. **Assess complexity at each boundary**:
   - Simple data passing: Low cost
   - State management: Medium cost
   - Bidirectional communication: High cost
   - Async operations: Very high cost

3. **Calculate total cognitive load**:
   - Low: Proceed normally
   - Medium: Simplify where possible
   - High: Consider pausing or restructuring
   - Very High: Add to "too hard" backlog

## Signs a Project is Ready

When to revisit a paused project:

- New model release (especially major versions)
- New tools that reduce boundary complexity
- Architectural insight that eliminates boundaries
- Similar project succeeded with current models

## Key Insight

AI models improve exponentially. What's impossible today may be trivial in 3 months. Don't force a solution - sometimes the right answer is patience.
