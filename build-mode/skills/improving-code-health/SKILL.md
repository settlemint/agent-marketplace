---
name: improving-code-health
description: Identifies and fixes code health issues during implementation - dead code, debug cruft, YAGNI violations, and duplication. Applies the "leave it better than you found it" principle. Use when auditing code health, finding dead code, reviewing technical debt, or seeking cleanup opportunities.
version: 1.0.0
---

## Overview

Code health improvement follows the Boy Scout Rule: "Leave the campground cleaner than you found it." When modifying code, look for nearby opportunities to improve quality without scope creep.

## When to Apply

**During implementation:**
- When reading files for context, note nearby issues
- When modifying code, clean adjacent code smells
- After completing a task, quick scan touched files

**Standalone audit:**
- User requests code health review
- Before major refactoring
- Technical debt assessment

## Quick Detection Patterns

### High Priority (Fix During Implementation)

**Dead Code:**
```bash
# Unused exports
grep -rh "^export " --include="*.ts" src/ | head -20
# Then verify with LSP before removal
```

**Debug Cruft:**
```bash
# Console statements
grep -rn "console\.\(log\|warn\|error\)" --include="*.ts" src/

# TODO comments
grep -rn "TODO\|FIXME\|HACK" --include="*.ts" src/
```

**Large Files:**
```bash
# Files over 500 lines
find src -name "*.ts" | xargs wc -l | awk '$1 > 500' | sort -rn
```

### Medium Priority (Note for Later)

**YAGNI Violations:**
- Interface with single implementor
- Factory called from one place
- Config with only defaults used

**Duplication:**
- Similar functions across files
- Copy-pasted code blocks (>10 lines)
- Parallel class hierarchies

## Opportunistic Cleanup Rules

### ALWAYS Fix (During Any Implementation)
- Empty catch blocks (silent failures)
- Console.log in production code
- Commented-out code blocks (>5 lines)
- Obvious dead imports

### FIX IF TOUCHING THE FILE
- Magic numbers → named constants
- Unclear variable names
- Missing error handling in your path
- Stale TODO comments (completed tasks)

### NOTE BUT DON'T FIX (Scope Creep)
- Large refactors unrelated to task
- Architectural issues
- Test coverage gaps (unless your change needs them)
- Cross-cutting concerns

## Integration with TDD

When backfilling tests for legacy code:

1. **Check for code health issues first**
   ```bash
   # Console statements that should be logger calls
   grep -n "console\." path/to/file.ts
   ```

2. **Clean up before writing tests**
   - Remove dead code (fewer things to test)
   - Fix obvious bugs (test real behavior)
   - Clarify unclear code (easier to test)

3. **Document remaining issues**
   - Add TODO for P2/P3 items found
   - Note in PR description for visibility

## Severity Triage

| Severity | Criteria | Action |
|----------|----------|--------|
| **P0** | Security risk, data corruption | Fix immediately |
| **P1** | Blocks understanding, causes bugs | Fix in current task |
| **P2** | Makes code harder to maintain | Fix this sprint |
| **P3** | Minor smell, improvement | Fix opportunistically |

**Escalation rules:**
- File >1000 lines: P1
- No test coverage on business logic: P1
- Duplicate systems (not just code): P1
- Security-related dead code: P0

## Output Format

When doing opportunistic cleanup during implementation:

```markdown
### Code Health Improvements Made

While implementing [feature], cleaned up nearby code:

| File | Issue | Fix Applied |
|------|-------|-------------|
| `auth.ts:45` | console.log | Removed |
| `user.ts:120` | Magic number | Extracted to `MAX_RETRIES` |

### Issues Noted (Not Fixed - Out of Scope)

| File | Issue | Priority | Reason Not Fixed |
|------|-------|----------|------------------|
| `legacy.ts` | 800 lines | P2 | Would require major refactor |
```

## Verification Before Removal

**Critical:** Always verify dead code with LSP before removal.

Text search can miss:
- Dynamic imports
- Computed property access
- Re-exports
- Reflection usage

**Safe removal pattern:**
1. Grep identifies candidate
2. LSP confirms zero references
3. Remove code
4. Run tests to verify

## Anti-Patterns

- **Over-cleaning:** Don't refactor entire files when fixing one bug
- **Scope creep:** Don't let cleanup delay the actual task
- **False positives:** Don't remove "unused" code without LSP verification
- **Churn:** Don't make cosmetic changes unrelated to your work

## Additional Resources

### Reference Files

For detailed detection patterns by audit dimension:
- **`references/detection-patterns.md`** - Comprehensive patterns for each issue type

### Related Agents

- **silent-failure-hunter** - Deep analysis of error handling gaps
- **quality-reviewer** - Code quality assessment after implementation
