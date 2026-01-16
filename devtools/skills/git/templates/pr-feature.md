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

## Checklist

- [ ] Self-reviewed the diff
- [ ] Added or updated tests
- [ ] Ran `bun run ci` locally
- [ ] No console.log or debug code
```

## Filling Guidelines

| Placeholder | Source |
|-------------|--------|
| SUMMARY | Synthesize from `git log origin/main..HEAD --oneline` |
| MOTIVATION | Extract from `.claude/plans/*.md` motivation section |
| DESIGN_DECISIONS | Extract from plan's approach/considerations |
| CHANGES | `git diff --stat origin/main` + commit bodies |
| TEST_PLAN | From plan's test criteria or infer from changes |
