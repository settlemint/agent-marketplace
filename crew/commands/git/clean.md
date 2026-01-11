---
name: crew:git:clean
description: Clean up stale branches (deleted on remote)
allowed-tools:
  - Bash
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<clean_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/clean-context.sh`
</clean_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Branch cleanup is not applicable with GitButler virtual branches.

GitButler manages virtual branches differently - they don't correspond
to traditional git branches that can become stale.

Use GitButler's UI or `but branch delete <name>` to remove virtual branches.
```

Exit immediately. Do not proceed with cleanup commands.

</gitbutler_incompatible>

<objective>

Delete local branches that no longer exist on remote. Execute cleanup commands if shown above.

</objective>

<workflow>

## Step 1: Execute Cleanup

If `<clean_context>` shows cleanup commands → execute them.
If "No Stale Branches" → report no cleanup needed.

</workflow>

<success_criteria>

- [ ] Stale branches deleted (if any)

</success_criteria>
