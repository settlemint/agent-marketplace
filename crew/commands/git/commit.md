---
name: crew:git:commit
description: Create a conventional commit
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
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh`
</commit_context>

<notes>
Format and protected files per @rules/git-safety.md
</notes>

<process>
1. If sensitive files flagged → `git reset HEAD <file>`
2. `git add <files>`
3. `git commit -m "type(scope): description"`
</process>
