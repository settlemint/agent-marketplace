---
name: troubleshooting
description: "[DEPRECATED] Use superpowers:systematic-debugging instead. This wrapper will be removed in v1.56.0."
deprecated: true
license: MIT
triggers:
  - "help debug"
  - "fix this"
  - "troubleshoot"
  - "not working"
---

<redirect>
## This Skill Has Been Deprecated

This skill has been replaced by `superpowers:systematic-debugging`, which provides:
- 4-phase root cause investigation workflow
- Defense-in-depth approach to fixes
- Condition-based waiting patterns
- Better integration with verification workflows

**Load the replacement:**
```javascript
Skill({ skill: "superpowers:systematic-debugging" })
```

**Reference documentation preserved:**
The unique reference materials from this skill have been moved to `devtools/docs/`:
- `devtools/docs/boundary-complexity.md` - AI cognition at system boundaries
- `devtools/docs/regenerate-vs-repair.md` - When to delete vs fix code
</redirect>

<migration_notice>
**Why this changed:**
The superpowers plugin provides a more structured debugging approach with:
1. 4-phase investigation (Observe → Hypothesize → Test → Fix)
2. Root cause tracing with evidence requirements
3. Defense-in-depth: fix root cause AND add protection
4. Condition-based waiting instead of arbitrary timeouts

**What to do:**
1. Replace `Skill({ skill: "devtools:troubleshooting" })` with `Skill({ skill: "superpowers:systematic-debugging" })`
2. Reference docs are now in `devtools/docs/` directory
3. For verification before claiming done, use `Skill({ skill: "superpowers:verification-before-completion" })`

**Key workflow differences:**

| Old (troubleshooting) | New (systematic-debugging) |
|-----------------------|---------------------------|
| Observe-reproduce-isolate-fix | Observe-hypothesize-test-fix |
| Quality gate at end | Defense-in-depth throughout |
| "Simplest change" | "Root cause + protection" |

**Removal timeline:**
This wrapper will be removed in devtools v1.56.0. Update your workflows now.
</migration_notice>
