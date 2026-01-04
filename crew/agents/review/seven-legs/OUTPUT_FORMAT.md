# Seven-Leg Review Output Format

All seven canonical reviewers use this consistent output format.

## Severity Levels

| Level | Code | Meaning | Merge Impact |
|-------|------|---------|--------------|
| Critical | P0 | Will cause failures, data loss, security breach | Blocks merge |
| High | P1 | Significant issue affecting quality/reliability | Should fix before merge |
| Medium | P2 | Notable issue, lower urgency | Address soon |
| Observation | Obs | Note for consideration | Not blocking |

## Finding Format

Each finding MUST follow this format:

```
[P0|P1|P2|Observation] file:line - Brief title

  Context: What the code does / What was reviewed
  Issue: Specific problem identified
  Impact: Consequence if not addressed
  Fix: Recommended solution
```

### Example Findings

```
[P0] src/auth/login.ts:47 - SQL injection via username

  Context: User login endpoint accepting username/password
  Issue: Username concatenated directly into SQL query
  Impact: Attacker can extract/modify all database data
  Fix: Use parameterized query: db.query('SELECT * FROM users WHERE username = ?', [username])
```

```
[P1] src/api/orders.ts:123 - N+1 query in order listing

  Context: GET /orders endpoint fetching customer orders
  Issue: Each order triggers separate query for customer data
  Impact: 100 orders = 101 queries, O(n) database load
  Fix: Use JOIN or include customer in initial query
```

```
[P2] src/utils/format.ts:56 - Memoization opportunity

  Context: formatCurrency called repeatedly with same values
  Issue: Pure function recalculates on every call
  Impact: Minor CPU overhead, noticeable in tight loops
  Fix: Wrap with useMemo or implement LRU cache
```

```
[Observation] src/components/Button.tsx:12 - Consider semantic naming

  Context: Button component with "handleClick" prop
  Issue: Generic name doesn't convey business intent
  Impact: Reduced code clarity
  Fix: Consider "onSubmit", "onCancel", etc. based on context
```

## Summary Format

Each reviewer ends with a summary:

```markdown
## [Leg Name] Review Summary

### Critical (P0)
- [count] issues requiring immediate fix
- [brief list if any]

### High Priority (P1)
- [count] significant issues
- [brief list if any]

### Medium Priority (P2)
- [count] notable issues

### Observations
- [count] notes for consideration

### Files Reviewed
- file1.ts: [P0: n, P1: n, P2: n, Obs: n]
- file2.ts: [P0: n, P1: n, P2: n, Obs: n]

### [Leg-Specific Metrics]
[Include metrics relevant to this review dimension]
```

## Leg-Specific Metrics

Each leg should include relevant summary metrics:

| Leg | Key Metrics |
|-----|-------------|
| Correctness | Edge cases covered, null safety score |
| Performance | Worst complexity, N+1 count, cache opportunities |
| Security | OWASP coverage, attack surface area |
| Elegance | SOLID compliance, cohesion assessment |
| Resilience | Error handling coverage, cleanup verification |
| Style | Naming consistency, formatter compliance |
| Smells | Duplication %, complexity hotspots, dead code |

## Cross-Reference Format

When a finding relates to another leg, note it:

```
[P1] src/api/users.ts:89 - Missing authorization check

  Context: User update endpoint
  Issue: No ownership verification before update
  Impact: Any authenticated user can modify any user's data
  Fix: Add ownership check: if (user.id !== targetUser.id) throw Forbidden

  Cross-reference: Also flagged by Correctness for edge case handling
```

## Deduplication Rules

When synthesizing findings across legs:

1. Same file:line with different perspectives → merge into highest severity
2. Same root cause across files → create single finding with all locations
3. Cross-leg patterns → escalate to meta-analysis for systemic review
