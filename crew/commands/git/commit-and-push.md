---
name: crew:git:commit-and-push
description: Create a conventional commit and push to origin
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh 2>&1`
</commit_context>

<notes>
Commit format per @rules/git-safety.md
</notes>

<process>

<phase name="sync-stack">
**Check `<stack_context>` above. If it shows "is in machete layout", sync with parent FIRST:**

```bash
# Only run if machete-managed (check stack_context output)
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git fetch origin
  git machete update    # Rebase onto parent (safe in worktrees)
fi
```

</phase>

<phase name="commit">
1. If sensitive files flagged → `git reset HEAD <file>`
2. `git add <files>`
3. `git commit -m "type(scope): description"`

</phase>

<phase name="push">
```bash
git push -u origin $(git branch --show-current)
```

Never `--force` unless explicitly requested. If rejected:

- `git pull --rebase` first, then retry
- If machete-managed: `git push --force-with-lease`

</phase>

<phase name="update-pr">
**After successful push, update PR (if exists):**

```javascript
Skill({ skill: "crew:git:update-pr" });
```

</phase>

</process>
