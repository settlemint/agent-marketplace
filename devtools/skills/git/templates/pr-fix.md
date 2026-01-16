# PR Template: Bug Fix

Use for `fix` commits - bug fixes and corrections.

**Fill `{{PLACEHOLDER}}` from investigation, commits, and context. Remove HTML comments.**

```markdown
## Summary

{{SUMMARY}}

<!-- One sentence: what bug does this fix? -->

## Root cause

{{ROOT_CAUSE}}

<!-- What caused the bug? Be specific about the code path or condition. -->

## The fix

{{FIX_DESCRIPTION}}

<!-- How does this PR fix it? What approach? -->

## How to reproduce (before)

{{REPRODUCTION_STEPS}}

<!-- Steps to trigger the bug. -->

## How to verify (after)

{{VERIFICATION_STEPS}}

<!-- Steps to confirm the fix works. -->

## Risk assessment

{{RISK_LEVEL}}

<!-- Low/Medium/High and why -->

## Checklist

- [ ] Identified root cause (not just symptoms)
- [ ] Added test to prevent regression
- [ ] Ran `bun run ci` locally
- [ ] Checked for similar bugs elsewhere
```

## Filling Guidelines

| Placeholder | Source |
|-------------|--------|
| SUMMARY | From commit message or issue description |
| ROOT_CAUSE | From investigation/debugging notes |
| FIX_DESCRIPTION | Synthesize from commit messages |
| REPRODUCTION_STEPS | From issue or manual testing |
| VERIFICATION_STEPS | Inverse of reproduction steps |
| RISK_LEVEL | Assess based on code area affected |
