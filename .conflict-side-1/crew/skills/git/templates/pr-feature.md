# PR Template: Feature

Use this template for `feat` commits - new features or significant enhancements.

**Writing style:** Active voice, sentence case headings, no banned words (seamless, leverage, utilize, dive into, game-changing). Be direct and specific.

**Placeholders:** Fill `{{PLACEHOLDER}}` from plan, commits, and context. Remove HTML comments after filling.

```markdown
## Summary

{{SUMMARY}}

<!-- 2-3 sentences explaining what this PR adds. Synthesize from commit messages. -->

## Why

{{MOTIVATION}}

<!-- Pull from plan's motivation section. What problem does this solve? What user need? -->

## Design decisions

{{DESIGN_DECISIONS}}

<!-- Pull from plan's approach/considerations. Why this approach over alternatives? -->

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
- [ ] Updated documentation (if applicable)
- [ ] No console.log or debug code left behind
```
