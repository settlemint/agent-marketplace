# PR Body Template

Fill sections based on commit type. Remove unused sections.

```markdown
## Summary

<!-- 2-3 sentences. What does this PR do? -->

## Why

<!-- What problem does this solve? Pull from plan if exists. -->

## Root cause (fix only)

<!-- What caused the bug? -->

## Design decisions (feat only)

<!-- Why this approach over alternatives? -->

## What changed

<!-- Bullet list from commits/diff. Group by area. -->

## How to test

<!-- Steps to verify. From plan or infer from changes. -->

## Checklist

- [ ] Ran `bun run ci` locally
- [ ] Self-reviewed the diff
- [ ] No console.log or debug code
```

## Section Selection

| Commit Type | Include Sections                              |
| ----------- | --------------------------------------------- |
| feat        | Summary, Why, Design decisions, Changed, Test |
| fix         | Summary, Root cause, Changed, Test            |
| refactor    | Summary, Why, Changed, Test                   |
| chore/docs  | Summary, Changed                              |

## Context Sources

- **Summary:** Synthesize from commit messages
- **Why:** Extract from `.claude/plans/*.md` motivation section
- **Design decisions:** From plan's approach/considerations
- **Changed:** `git diff --stat` + commit bodies
- **Test:** From plan's test criteria or infer from changes
