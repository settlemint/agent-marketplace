---
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git fetch:*), Bash(git log:*), Bash(git diff:*), Bash(gh pr create:*)
description: Commit, push, and open a PR
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Diff stats: !`git diff --stat HEAD`
- Commits ahead of origin/main: !`git log origin/main..HEAD --oneline 2>/dev/null || echo "N/A"`
- Remote tracking: !`git status -sb | head -1`

## PR Body Template

```markdown
## Summary
<2-3 bullet points describing the changes>

## Test plan
- [ ] <verification steps>
```

## Your Task

1. **If on main**: Create a new branch with a descriptive name based on the changes
2. **Stage and commit**: Create a conventional commit (see /crew:git:commit for format)
3. **Push**: Push the branch to origin with `-u` flag
4. **Create PR**: Use `gh pr create` with:
   - Clear, descriptive title
   - Body following the template above
   - Use HEREDOC for the body to preserve formatting

Execute all commands in a single response. Return the PR URL when complete.
