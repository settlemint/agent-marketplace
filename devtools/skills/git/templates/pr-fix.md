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

## AI Assistance

<!-- Mark which parts used AI assistance -->
- [ ] No AI assistance used
- [ ] AI assisted with: {{AI_AREAS}}

## Proof of Function

<!-- Evidence the fix works -->
- Before: {{BEFORE_EVIDENCE}}
- After: {{AFTER_EVIDENCE}}
- Regression test: {{REGRESSION_TEST}}

<!-- Example:
- Before: Error "undefined is not a function" on login
- After: Login completes successfully, token stored
- Regression test: Added test in auth.test.ts:45 that covers this case
-->

## Checklist

- [ ] Identified root cause (not just symptoms)
- [ ] Added test to prevent regression
- [ ] Ran `bun run ci` locally
- [ ] Checked for similar bugs elsewhere
- [ ] Completed AI disclosure section
- [ ] Filled proof of function with before/after evidence
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
| AI_AREAS | Note which parts had AI assistance (debugging, fix, tests) |
| BEFORE_EVIDENCE | How bug manifested (error message, screenshot, log) |
| AFTER_EVIDENCE | Proof fix works (output, screenshot, passing test) |
| REGRESSION_TEST | Test file:line that prevents recurrence |
