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

## Checklist

- [ ] No unintended behavior changes
- [ ] Self-reviewed the diff
- [ ] Ran `bun run ci` locally
```

## Filling Guidelines

| Placeholder | Source |
|-------------|--------|
| SUMMARY | Synthesize from commit messages |
| MOTIVATION | From plan or task description |
| CHANGES | `git diff --stat origin/main` + commit bodies |
| IMPACT | List affected systems/components |
| VERIFICATION | Run tests, verify build, manual check |
