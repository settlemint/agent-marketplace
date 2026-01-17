# PR Template: Feature

Use for `feat` commits - new features or significant enhancements.

**Fill `{{PLACEHOLDER}}` from plan, commits, and context. Remove HTML comments.**

```markdown
## Summary

{{SUMMARY}}

<!-- 2-3 sentences explaining what this PR adds. Synthesize from commit messages. -->

## Why

{{MOTIVATION}}

<!-- Pull from plan's motivation section. What problem does this solve? -->

## Design decisions

{{DESIGN_DECISIONS}}

<!-- From plan's approach/considerations. Why this approach over alternatives? -->

## What changed

{{CHANGES}}

<!-- Bullet list from commits and diff. Group by area. -->

## How to test

{{TEST_PLAN}}

<!-- From plan's test criteria or generate from changes. -->

## AI Assistance

<!-- Mark which parts used AI assistance (transparency for reviewers) -->
- [ ] No AI assistance used
- [ ] AI assisted with: {{AI_AREAS}}

## Risk Assessment

<!-- Rate complexity and identify areas needing careful review -->
- Complexity: {{COMPLEXITY}}
- Security-sensitive: {{SECURITY_AREAS}}
- Review focus: {{REVIEW_FOCUS}}

<!-- Example:
- Complexity: Medium
- Security-sensitive: Auth (new session handling)
- Review focus: Token expiry logic in auth.ts:45-80
-->

## Proof of Function

<!-- Evidence that code works (not just "tests pass") -->
- Test output: {{TEST_OUTPUT}}
- Manual verification: {{MANUAL_VERIFICATION}}

<!-- Example:
- Test output: 24 tests passed, 0 failed (see CI run #123)
- Manual verification: Tested login flow in browser, verified token refresh
-->

## Checklist

- [ ] Self-reviewed the diff
- [ ] Added or updated tests
- [ ] Ran `bun run ci` locally
- [ ] No console.log or debug code
- [ ] Completed AI disclosure section
- [ ] Filled proof of function with evidence
```

## Filling Guidelines

| Placeholder | Source |
|-------------|--------|
| SUMMARY | Synthesize from `git log origin/main..HEAD --oneline` |
| MOTIVATION | Extract from `.claude/plans/*.md` motivation section |
| DESIGN_DECISIONS | Extract from plan's approach/considerations |
| CHANGES | `git diff --stat origin/main` + commit bodies |
| TEST_PLAN | From plan's test criteria or infer from changes |
| AI_AREAS | Note which parts had AI assistance (code gen, review, tests) |
| COMPLEXITY | Low / Medium / High based on change scope |
| SECURITY_AREAS | Auth / Payments / Secrets / User input / None |
| REVIEW_FOCUS | 1-2 specific areas reviewer should examine carefully |
| TEST_OUTPUT | CI run link or paste key test results |
| MANUAL_VERIFICATION | What manual testing was done to verify behavior |
