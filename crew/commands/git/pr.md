---
name: crew:git:pr
description: Commit, push, and open a PR
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git fetch:*), Bash(gh pr create:*), Bash(git machete:*), AskUserQuestion
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/pr-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<template>

```markdown
## Summary

<2-3 bullets>

## Test plan

- [ ] <verification>
```

</template>

<process>

1. Check state: `git branch --show-current && git status --short`
2. If on main → create feature branch
3. Stage & commit: `git add . && git commit -m "type(scope): msg"`
4. Ask PR type:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "PR type?",
      header: "Type",
      options: [
        { label: "Ready for review", description: "Ready to merge" },
        { label: "Draft", description: "Work in progress" },
      ],
    },
  ],
});
```

5. **If machete-managed:**

```bash
git machete github create-pr [--draft]
git machete github anno-prs
```

**If traditional:**

```bash
git push -u origin $(git branch --show-current)
gh pr create --title "..." --body "$(cat <<'EOF'
## Summary
...
EOF
)" [--draft]
```

Return PR URL.

</process>
