---
name: tdd-typescript
description: "[DEPRECATED] Use superpowers:test-driven-development instead. This wrapper will be removed in v1.56.0."
deprecated: true
license: MIT
triggers:
  - "tdd"
  - "test[- ]?driven"
  - "test[- ]?first"
  - "red[- ]?green"
---

<redirect>
## This Skill Has Been Deprecated

This skill has been replaced by `superpowers:test-driven-development`, which provides:
- Rationalization prevention tables
- More comprehensive anti-pattern detection
- Better workflow enforcement

**Load the replacement:**
```javascript
Skill({ skill: "superpowers:test-driven-development" })
```

**For TypeScript-specific test patterns, see:**
```javascript
Skill({ skill: "devtools:vitest" })
```

The Vitest skill includes comprehensive reference documentation copied from this skill:
- `references/test-coverage-patterns.md` - Coverage targets, test categories
- `references/test-naming-conventions.md` - Naming patterns and anti-patterns
- `references/test-data-strategies.md` - Factories, fixtures, mocks
- `references/test-strategy-checklist.md` - Phase gates, test pyramid
- `references/project-setup.md` - CLAUDE.md instructions for TDD enforcement
</redirect>

<migration_notice>
**Why this changed:**
The superpowers plugin provides a more comprehensive TDD workflow that includes:
1. Rationalization prevention with explicit tables showing common excuses
2. Phase gate enforcement with evidence requirements
3. Integration with plan mode and code review workflows

**What to do:**
1. Replace `Skill({ skill: "devtools:tdd-typescript" })` with `Skill({ skill: "superpowers:test-driven-development" })`
2. For Vitest-specific syntax and assertions, use `Skill({ skill: "devtools:vitest" })`
3. Coverage targets and patterns are now in `devtools:vitest` references

**Removal timeline:**
This wrapper will be removed in devtools v1.56.0. Update your workflows now.
</migration_notice>
