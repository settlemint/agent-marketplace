---
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git fetch:*), Bash(gh pr create:*)
description: Commit, push, and open a PR
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/pr-context.sh`

## PR Template

```markdown
## Summary
<2-3 bullets>

## Test plan
- [ ] <verification>
```

## Task

1. **If on main**: `git checkout -b feat/<name>`
2. **Stage & commit**: `git add . && git commit -m "type(scope): msg"`
3. **Push**: `git push -u origin $(git branch --show-current)`
4. **Create PR**: Use HEREDOC for body:
   ```bash
   gh pr create --title "..." --body "$(cat <<'EOF'
   ## Summary
   ...
   EOF
   )"
   ```

Execute all in a single response. Return the PR URL.
