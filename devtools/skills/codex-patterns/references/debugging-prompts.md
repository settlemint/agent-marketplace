# Debugging and Analysis Prompts

## Root Cause Analysis

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Debug this issue:

    Error: [error message]
    Stack trace: [stack trace]

    Relevant code:
    [code sections]

    Context:
    [what was happening when error occurred]

    Analyze:
    1. Immediate cause (what triggered the error?)
    2. Root cause (why did the trigger exist?)
    3. Contributing factors (what made this possible?)
    4. Fix (address root cause, not just symptom)
    5. Prevention (how to avoid in future?)`,
});
```

## Race Condition Detection

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze for race conditions:

    [concurrent code]

    Check for:
    1. Shared mutable state
    2. Non-atomic operations
    3. Missing synchronization
    4. Time-of-check-time-of-use (TOCTOU)
    5. Ordering assumptions

    For each race condition found:
    - Trigger scenario (sequence of events)
    - Consequence (data corruption, crash, etc.)
    - Fix (locks, atomics, redesign)`,
});
```

## Pattern Identification

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Identify design patterns in this code:

    [code to analyze]

    For each pattern found:
    1. Pattern name (GoF or other)
    2. Purpose (why was it used here?)
    3. Participants (which classes/functions)
    4. Consequences (benefits and drawbacks)
    5. Is it used correctly?`,
});
```

## Complexity Assessment

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Assess cognitive complexity:

    [code to analyze]

    Evaluate:
    1. Cyclomatic complexity (branches, loops)
    2. Cognitive complexity (nesting, control flow)
    3. Coupling complexity (dependencies)
    4. Temporal complexity (ordering requirements)

    Identify:
    - Functions that are too complex (>10 cyclomatic)
    - Deep nesting (>3 levels)
    - Long methods (>50 lines)

    Suggest simplification strategies.`,
});
```

## Edge Case Discovery

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Find edge cases in this function:

    [function code]

    Check boundary conditions:
    1. Null/undefined inputs
    2. Empty collections ([], {}, "")
    3. Single element collections
    4. Maximum values (MAX_INT, MAX_SAFE_INTEGER)
    5. Negative values where positive expected
    6. Unicode and special characters
    7. Concurrent calls
    8. Resource exhaustion (memory, file handles)

    For each edge case:
    - Input example
    - Expected behavior
    - Actual behavior (if different)
    - Test case to add`,
});
```
