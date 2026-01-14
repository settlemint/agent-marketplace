# Review Prompts by Pass Level

Escalating prompts for the 5-pass convergence pattern. Each pass broadens scope from code-level to strategic.

## Pass 1: Standard Review

```
Review this code for:
1. Syntax errors and typos
2. Obvious bugs or logic errors
3. Missing null/undefined checks
4. Uncovered edge cases
5. Basic error handling gaps
6. Test coverage for happy path

List each finding with severity (P1=critical, P2=high, P3=medium).
```

## Pass 2: Deep Review

```
Look more carefully. A senior engineer reviewing this would find:
1. Subtle logic errors that only appear in specific conditions
2. Race conditions or timing issues
3. Resource leaks (memory, file handles, connections)
4. Incomplete input validation
5. Inconsistent naming or code style
6. Duplicated logic that should be extracted
7. Missing tests for error paths

What did the first review miss?
```

## Pass 3: Architecture Review

```
Step back from the code and evaluate the design:
1. Does this follow established patterns in the codebase?
2. Are dependencies appropriate? Any circular dependencies?
3. Is coupling appropriate? Could components be more independent?
4. Is there unnecessary complexity? YAGNI violations?
5. Are there missing abstractions that would simplify the code?
6. Is anything over-engineered for the current requirements?
7. Does the module structure make sense?

Focus on structural and design concerns, not code-level issues.
```

## Pass 4: Strategic Review

```
Question the fundamental approach:
1. Are we solving the right problem?
2. Is this the best approach, or are there simpler alternatives?
3. Will this be maintainable in 6 months? 1 year?
4. What edge cases haven't we considered?
5. How does this integrate with the broader system?
6. Are there security implications we haven't addressed?
7. What could go wrong in production?

Think like a tech lead reviewing before a major release.
```

## Pass 5: Existential Review

```
Final check - be creative and think outside the box:
1. Is there a completely different approach that would be better?
2. What assumptions are we making that might be wrong?
3. What would break if requirements change slightly?
4. Are we building technical debt that will hurt later?
5. Would a new team member understand this code?
6. Is this something we'd be proud to show in a code walkthrough?

Declare convergence if this pass finds nothing significant.
```

## Convergence Declaration Prompts

When an agent has truly converged:

```
After reviewing this [N] times, I believe this is as good as it can get because:
- [Specific reasons]
- [What was improved across passes]
- [Any remaining minor items that don't warrant changes]
```

When NOT converged:

```
This needs another pass because:
- [Significant issue found]
- [Area not yet reviewed deeply]
- [Uncertainty about approach]
```

## Quick Reference

| Pass | Focus            | Key Question              |
| ---- | ---------------- | ------------------------- |
| 1    | Code correctness | Does it work?             |
| 2    | Code quality     | Is it well-written?       |
| 3    | Architecture     | Is it well-designed?      |
| 4    | Strategy         | Is it the right solution? |
| 5    | Meta             | Should we ship this?      |
