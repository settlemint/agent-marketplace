---
description: Codebase assessment before following existing patterns
globs: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py,**/*.go,**/*.rs,**/*.sol"
alwaysApply: false
---

# Codebase Assessment

## Before Following Patterns

Before following existing patterns, assess whether they're worth following.

### Quick Assessment

1. Check config files: linter, formatter, type config
2. Sample 2-3 similar files for consistency
3. Note project age signals (dependencies, patterns)

### State Classification

| State | Signals | Your Behavior |
| --- | --- | --- |
| **Disciplined** | Consistent patterns, configs present, tests exist | Follow existing style strictly |
| **Transitional** | Mixed patterns, some structure | Ask: "I see X and Y patterns. Which to follow?" |
| **Legacy/Chaotic** | No consistency, outdated patterns | Propose: "No clear conventions. I suggest [X]. OK?" |
| **Greenfield** | New/empty project | Apply modern best practices |

### Important Verification

If codebase appears undisciplined, verify before assuming:

- Different patterns may serve different purposes (intentional)
- Migration might be in progress
- You might be looking at the wrong reference files

## Implementation Behavior

### Code Changes

- Match existing patterns (if codebase is disciplined)
- Propose approach first (if codebase is chaotic)
- Never suppress type errors with `as any`, `@ts-ignore`, `@ts-expect-error`
- Never commit unless explicitly requested

### Verification

Run `lsp_diagnostics` (or equivalent) on changed files at:

- End of a logical task unit
- Before marking a todo item complete
- Before reporting completion to user

If project has build/test commands, run them at task completion.

### Evidence Requirements

Task is NOT complete without these:

| Action | Required Evidence |
| --- | --- |
| File edit | Diagnostics clean on changed files |
| Build command | Exit code 0 |
| Test run | Pass (or explicit note of pre-existing failures) |
| Delegation | Agent result received and verified |

**NO EVIDENCE = NOT COMPLETE.**
