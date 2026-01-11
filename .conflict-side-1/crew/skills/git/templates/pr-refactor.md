# PR Template: Refactor / Docs / Chore

Use this template for `refactor`, `docs`, `chore`, `test` commits - changes that don't add features or fix bugs.

**Writing style:** Active voice, sentence case headings. Be clear about what changed and why it matters.

**Placeholders:** Fill `{{PLACEHOLDER}}` from context. Remove HTML comments after filling.

```markdown
## Summary

{{SUMMARY}}

<!-- What does this PR change? 2-3 sentences. -->

## Why

{{MOTIVATION}}

<!-- Why is this refactor/update needed now? What triggered it? -->

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
