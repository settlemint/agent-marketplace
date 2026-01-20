---
name: implementing-code
description: This skill should be used when the user asks to "implement a feature", "build this", "write code", "execute the plan", or when starting implementation tasks. TDD-driven development with subagent orchestration.
version: 1.0.0
---

# Implementation Methodology

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

Code before test? Delete it. Start over.

## TDD Cycle

**RED:** Write failing test → verify fails for right reason
**GREEN:** Write minimum code to pass → no over-engineering
**REFACTOR:** Improve while green → tests pass after every change

## Execution Loop

```
For each task:
  1. TodoWrite: in_progress
  2. Spawn task-implementer (fresh context)
  3. Spawn spec-reviewer → if fails, fix
  4. Spawn quality-reviewer → address P1s
  5. Spawn silent-failure-hunter
  6. If UI → spawn visual-tester
  7. TodoWrite: completed
```

## Build-Mode Agents

| Task | subagent_type |
|------|---------------|
| Implementation | `build-mode:task-implementer` |
| Spec check | `build-mode:spec-reviewer` |
| Quality | `build-mode:quality-reviewer` |
| Security | `build-mode:security-reviewer` |
| Error handling | `build-mode:silent-failure-hunter` |
| UI verify | `build-mode:visual-tester` |
| Final gate | `build-mode:completion-validator` |

## Two-Stage Review

**Stage 1 - Spec:** Literal, intent, edge cases
**Stage 2 - Quality:** Style, patterns, maintainability (only after spec passes)

## Systematic Debugging

1. **Root Cause** - Error msgs, reproduce, trace data flow
2. **Pattern Analysis** - Find working examples, compare
3. **Hypothesis** - Single hypothesis, one variable
4. **Implementation** - Failing test first, then fix

Red flags: "Just try X", "don't understand but...", 3+ fix attempts

## Visual Testing (UI changes)

Chrome MCP for dev, Playwright for E2E test generation.

## Verification

**5-Step Gate:** Identify → Run → Read → Verify → Claim with evidence

| Work Type | Required Evidence |
|-----------|-------------------|
| Tests | Output showing 0 failures |
| Bug fix | Symptom + passing test |
| Feature | Tests + CI green |

**CI Gate:** `bun run ci` must pass before completion.

## Completion Checklist

- [ ] TDD followed
- [ ] Two-stage review passed
- [ ] Silent failure hunter clear
- [ ] Visual tests (if UI)
- [ ] `bun run ci` exits 0
- [ ] Evidence documented

See `references/` for detailed patterns.
