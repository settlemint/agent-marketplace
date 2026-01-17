# PR Template: Refactor / Docs / Chore

Use for `refactor`, `docs`, `chore`, `test` commits - changes without new features or bug fixes.

**Fill `{{PLACEHOLDER}}` from context. Remove HTML comments.**

```markdown
## Summary

{{SUMMARY}}

<!-- What does this PR change? 2-3 sentences. -->

## Why

{{MOTIVATION}}

<!-- Why is this change needed now? What triggered it? -->

## What changed

{{CHANGES}}

<!-- List the key changes. -->

## Impact

{{IMPACT}}

<!-- What's affected? No behavior change, build change, test change, etc. -->

## Verification

{{VERIFICATION}}

<!-- How to verify nothing broke. -->

## AI Assistance

<!-- Mark which parts used AI assistance -->
- [ ] No AI assistance used
- [ ] AI assisted with: {{AI_AREAS}}

## Proof of No Regression

<!-- Evidence that existing behavior unchanged -->
- Tests: {{TEST_STATUS}}
- Build: {{BUILD_STATUS}}

<!-- Example:
- Tests: All 156 tests pass, no changes to test files
- Build: Clean build, bundle size unchanged (+0.1kb)
-->

## Checklist

- [ ] No unintended behavior changes
- [ ] Self-reviewed the diff
- [ ] Ran `bun run ci` locally
- [ ] Completed AI disclosure section
```

## Filling Guidelines

| Placeholder | Source |
|-------------|--------|
| SUMMARY | Synthesize from commit messages |
| MOTIVATION | From plan or task description |
| CHANGES | `git diff --stat origin/main` + commit bodies |
| IMPACT | List affected systems/components |
| VERIFICATION | Run tests, verify build, manual check |
| AI_AREAS | Note which parts had AI assistance (refactoring, review) |
| TEST_STATUS | Test results (e.g., "156 tests pass, 0 fail") |
| BUILD_STATUS | Build outcome (e.g., "Clean build, no warnings") |
