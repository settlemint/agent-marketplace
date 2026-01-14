# Convergence Signals

How to detect when iterative review has converged and no more passes are needed.

## Strong Convergence Signals

These indicate the work is ready:

| Signal                | Description                                             |
| --------------------- | ------------------------------------------------------- |
| **Zero findings**     | A full pass produces no new issues                      |
| **Only cosmetic**     | Findings are style preferences, not substance           |
| **Circular fixes**    | Fixes from one pass get reverted in another             |
| **Agent declaration** | Agent explicitly states "this is as good as it can get" |
| **Scope exhaustion**  | All review dimensions (code, arch, strategy) covered    |

## Weak Convergence Signals

These suggest approaching convergence but more review may help:

| Signal                      | Description                              |
| --------------------------- | ---------------------------------------- |
| **Diminishing severity**    | P1s → P2s → P3s across passes            |
| **Smaller diffs**           | Each pass makes fewer/smaller changes    |
| **Faster completion**       | Review pass completes more quickly       |
| **Uncertainty expressions** | "I'm not sure if...", "This might be..." |

## Anti-Convergence Signals

These indicate more passes are needed:

| Signal                  | Description                                |
| ----------------------- | ------------------------------------------ |
| **New P1/P2 findings**  | Serious issues still being discovered      |
| **Scope expansion**     | Review reveals areas not yet examined      |
| **Conflicting advice**  | Different passes suggest opposite changes  |
| **Agent hedging**       | "We should probably..." without confidence |
| **Untested dimensions** | Architecture or strategy not yet reviewed  |

## Convergence by Context

| Context          | Typical Passes | Convergence Indicator      |
| ---------------- | -------------- | -------------------------- |
| Trivial fix      | 1-2            | First review finds nothing |
| Standard feature | 3              | Architecture pass clean    |
| Complex feature  | 4-5            | Strategy pass confident    |
| Critical system  | 5+             | Multiple reviewers agree   |

## Forced Convergence

Sometimes you must stop despite weak signals:

- **Time constraints**: Ship what you have
- **Diminishing returns**: Cost exceeds benefit
- **Context limits**: Agent context exhausted
- **Circular changes**: Oscillating between alternatives

In forced convergence, document:

1. What passes were completed
2. What signals triggered stop
3. Known remaining concerns
4. Recommended follow-up

## Agent Self-Assessment Prompt

Ask the agent to evaluate convergence:

```
Assess your confidence in this work:
1. Have you reviewed code correctness thoroughly? (Pass 1-2)
2. Have you evaluated architecture and design? (Pass 3)
3. Have you questioned the strategic approach? (Pass 4-5)
4. What concerns remain?
5. On a scale of 1-10, how confident are you this is production-ready?

If confidence < 8, what would increase it?
```

## Metrics for Tracking

Track across sessions to calibrate:

- Passes until convergence (by task complexity)
- P1/P2 findings per pass
- Time per pass
- Post-deployment issues (did we miss something?)

Over time, this data helps predict when convergence is likely.
