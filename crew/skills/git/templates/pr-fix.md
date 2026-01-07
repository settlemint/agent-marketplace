# PR Template: Bug Fix

Use this template for `fix` commits - bug fixes and corrections.

**Writing style:** Active voice, sentence case headings, no banned words. Focus on clarity about what broke, why, and how you fixed it.

**Placeholders:** Fill `{{PLACEHOLDER}}` from investigation, commits, and context. Remove HTML comments after filling.

```markdown
## Summary

{{SUMMARY}}

<!-- One sentence: what bug does this fix? -->

## Root cause

{{ROOT_CAUSE}}

<!-- What caused the bug? Be specific about the code path or condition. -->

## The fix

{{FIX_DESCRIPTION}}

<!-- How does this PR fix it? What approach did you take? -->

## Why this approach

{{APPROACH_RATIONALE}}

<!-- If there were multiple ways to fix this, why this one? -->

## How to reproduce (before this fix)

{{REPRODUCTION_STEPS}}

<!-- Steps to trigger the bug. -->

## How to verify (after this fix)

{{VERIFICATION_STEPS}}

<!-- Steps to confirm the fix works. -->

## Risk assessment

{{RISK_LEVEL}}

<!-- Low/Medium/High risk and why -->

## Checklist

- [ ] Identified the root cause (not just symptoms)
- [ ] Added test to prevent regression
- [ ] Ran `bun run ci` locally
- [ ] Checked for similar bugs elsewhere in the codebase
```
