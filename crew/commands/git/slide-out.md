---
name: crew:git:slide-out
description: Remove merged branches from stack and reconnect children
allowed-tools: Bash(git machete:*), Bash(git branch:*), Bash(git fetch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<what_happens>

1. Branch removed from `.git/machete`
2. Children attached to parent
3. Children rebased onto new parent (default)
4. Optionally delete local branch

</what_happens>

<process>

1. Check for merged (gray edges): `git machete status`
2. Slide out:

```bash
git machete slide-out <branch> --no-rebase  # For remote merges
git machete slide-out <branch> --delete     # Also delete local
```

3. Sync remaining: `git machete traverse -W -y -H`

</process>
