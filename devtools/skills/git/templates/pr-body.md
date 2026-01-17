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

## Risk assessment

<!-- Evaluate potential risks. Remove categories that don't apply. -->

| Category | Risk Level | Notes |
|----------|------------|-------|
| Breaking changes | None/Low/Medium/High | <!-- API changes, schema migrations --> |
| Security | None/Low/Medium/High | <!-- Auth, data exposure, injection --> |
| Performance | None/Low/Medium/High | <!-- N+1 queries, memory, latency --> |
| Data integrity | None/Low/Medium/High | <!-- Migrations, data loss potential --> |

<!-- For High risk items, explain mitigation strategy -->

## Checklist

- [ ] Ran `bun run ci` locally
- [ ] Self-reviewed the diff
- [ ] No console.log or debug code
```

## Section Selection

| Commit Type | Include Sections                              |
| ----------- | --------------------------------------------- |
| feat        | Summary, Why, Design decisions, Changed, Test, Risk |
| fix         | Summary, Root cause, Changed, Test, Risk      |
| refactor    | Summary, Why, Changed, Test, Risk             |
| chore/docs  | Summary, Changed                              |

## Context Sources

- **Summary:** Synthesize from commit messages
- **Why:** Extract from `.claude/plans/*.md` motivation section
- **Design decisions:** From plan's approach/considerations
- **Changed:** `git diff --stat` + commit bodies
- **Test:** From plan's test criteria or infer from changes
