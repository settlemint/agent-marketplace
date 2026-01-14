# Convergence Cycle Workflow

Apply the 5-pass convergence pattern to any artifact (design, plan, code, tests).

## Phase 1: Generation

Create the initial artifact. This is a draft, not a final product.

```
GENERATE:
- Design document
- Implementation plan
- Code implementation
- Test suite
- Documentation
```

## Phase 2: Standard Review (Pass 1)

Find obvious issues a typical code review would catch.

```
REVIEW FOCUS:
- Syntax errors
- Obvious bugs
- Missing error handling
- Uncovered edge cases
- Basic test coverage
- Naming clarity

PROMPT: "Review this for obvious issues, bugs, and missing error handling."
```

## Phase 3: Deep Review (Pass 2)

Look for non-obvious issues requiring closer inspection.

```
REVIEW FOCUS:
- Subtle logic errors
- Race conditions
- Resource leaks
- Incomplete validation
- Inconsistent naming
- Code duplication

PROMPT: "Look deeper. What issues would a senior engineer find on careful inspection?"
```

## Phase 4: Architecture Review (Pass 3)

Evaluate system-level concerns and design decisions.

```
REVIEW FOCUS:
- Pattern consistency
- Dependency structure
- Coupling and cohesion
- YAGNI violations
- Missing abstractions
- Over-engineering

PROMPT: "Step back and evaluate the architecture. Are we following good patterns? Any unnecessary complexity?"
```

## Phase 5: Existential Review (Pass 4-5)

Question the fundamental approach and strategic alignment.

```
REVIEW FOCUS:
- Solving the right problem?
- Best approach for requirements?
- Future maintainability?
- Edge cases we haven't considered?
- Integration with broader system?
- Security implications?

PROMPT: "Are we doing the Right Thing? Is this the best approach to solve the underlying problem?"
```

## Convergence Detection

Stop when any of these occur:

1. **Agent declares convergence**: "This is as good as it can get given the requirements."
2. **No new findings**: Pass produces zero new issues.
3. **Diminishing returns**: Pass produces only minor suggestions.
4. **5 passes complete**: Maximum iterations reached.

## Output Format

After each pass, produce:

```markdown
## Pass N: [Focus Area]

### Findings

- [Issue 1]: [Description] - [Severity: P1/P2/P3]
- [Issue 2]: [Description] - [Severity]

### Fixes Applied

- [Fix 1]: [What was changed]

### Remaining Concerns

- [Items deferred or requiring human decision]

### Convergence Status

[ ] More passes needed
[x] Converged - [Reason]
```
