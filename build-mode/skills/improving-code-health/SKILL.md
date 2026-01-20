---
name: improving-code-health
description: This skill should be used when the user asks to "audit code health", "find dead code", "clean up code", "find duplication", or when seeking cleanup opportunities. Identifies dead code, debug cruft, YAGNI violations, duplication.
version: 1.0.0
---

# Code Health

Leave it better than you found it. Clean nearby issues during implementation.

## Detection

**High Priority (fix now):**
- Dead code → `grep -rh "^export " src/` then LSP verify
- Console.log → `grep -rn "console\." src/`
- Large files → `find src -name "*.ts" | xargs wc -l | awk '$1 > 500'`

**Medium Priority (note for later):**
- YAGNI: single-use interfaces, factories, config defaults
- Duplication: >10 line copy-paste, parallel hierarchies

## Cleanup Rules

| Action | Items |
|--------|-------|
| ALWAYS fix | Empty catch, console.log, commented code >5 lines, dead imports |
| Fix if touching | Magic numbers, unclear names, missing error handling, stale TODOs |
| Note only | Large refactors, architecture, coverage gaps |

## Severity

| Level | Criteria | Action |
|-------|----------|--------|
| P0 | Security, data corruption | Fix immediately |
| P1 | Blocks understanding, causes bugs | Fix in task |
| P2 | Maintainability | Fix this sprint |
| P3 | Minor smell | Opportunistically |

Escalate to P1: >1000 lines, no tests on business logic, duplicate systems.

## Safe Removal

1. Grep finds candidate
2. LSP confirms zero references
3. Remove code
4. Run tests

## Output

```
### Cleaned
| File | Issue | Fix |
|------|-------|-----|
| `file:line` | [issue] | [fix] |

### Noted (out of scope)
| File | Issue | Priority |
```

## References

- `references/detection-patterns.md` - Full patterns
