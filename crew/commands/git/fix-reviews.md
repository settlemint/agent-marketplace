---
name: crew:git:fix-reviews
description: Resolve all unresolved PR review comments and CI failures
argument-hint: "[PR number, defaults to current branch PR]"
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

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<unresolved_threads>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-threads.sh 2>&1`
</unresolved_threads>

<ci_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-checks.sh 2>&1`
</ci_status>

<available_scripts>

These scripts are available in `${CLAUDE_PLUGIN_ROOT}/scripts/git/`:

- `gh-pr-info.sh [PR]` - Get PR metadata
- `gh-pr-threads.sh [PR]` - Get unresolved review threads
- `gh-pr-checks.sh [PR]` - Get CI check status
- `gh-pr-resolve-thread.sh THREAD_ID "message"` - Resolve a thread with comment

</available_scripts>

<constraints>

- **Main thread execution** - Do NOT delegate to orchestrator (preserves native UI)
- **Max 3 CI fix iterations** - Escalate to user after 3 attempts
- **Reply and resolve** - Mark threads resolved after fixing
- **Worktree safety** - NEVER suggest `git machete traverse` in worktrees (breaks checkout)
- **Stack awareness** - If machete-managed AND in main checkout, suggest update/sync options

</constraints>

<process>

<phase name="sync-stack">
**If machete-managed, sync with parent FIRST:**

Check worktree status from context above. Then:

**If in a worktree:**

```bash
git fetch origin
git machete update                # Safe: rebases current branch only
```

**If in main checkout:**

```bash
git fetch origin
git machete update                # Rebase onto parent
```

</phase>

<phase name="validate">
If no PR found in context above:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No PR found. What to do?",
      header: "PR",
      options: [
        { label: "Create PR first", description: "Create new PR" },
        { label: "Specify PR number", description: "Tell me which PR" },
      ],
    },
  ],
});
```

</phase>

<phase name="analyze">
Review the prefilled context above. Group issues by:
- **Comments**: by file path
- **CI failures**: by type (lint/type/test/build)

If context is stale, refresh with:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-threads.sh
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-checks.sh
```

</phase>

<phase name="confirm">

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Found ${comments} comments, ${failures} CI failures. Proceed?`,
      header: "Fix",
      options: [
        { label: "Fix all (Recommended)", description: "Comments + CI" },
        { label: "Comments only", description: "Skip CI" },
        { label: "CI only", description: "Skip comments" },
      ],
    },
  ],
});
```

</phase>

<phase name="fix">
Launch parallel agents:

```javascript
// PR comments by file
Task({
  subagent_type: "crew:workflow:pr-comment-resolver",
  prompt: "Fix: [comments]",
  run_in_background: true,
});

// CI failures by type
Task({
  subagent_type: "general-purpose",
  prompt: "Fix lint: [errors]",
  run_in_background: true,
});
Task({
  subagent_type: "general-purpose",
  prompt: "Fix types: [errors]",
  run_in_background: true,
});
```

</phase>

<phase name="verify">

```bash
bun run ci
```

If fails after 3 iterations → escalate to user.
</phase>

<phase name="resolve">
After push, resolve threads:

```bash
for THREAD_ID in $THREAD_IDS; do
  ${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "$THREAD_ID" "Fixed."
done
```

</phase>

<phase name="update-pr">
**Update PR title and body to reflect fixes:**

```javascript
Skill({ skill: "crew:git:update-pr" });
```

</phase>

</process>

<success_criteria>

- [ ] Stack synced at start (`git machete update`)
- [ ] All PR comments addressed
- [ ] All CI failures fixed
- [ ] `bun run ci` passes
- [ ] Threads resolved on GitHub
- [ ] PR updated via `/crew:git:update-pr`

**Worktree-safe completion message:**

- In worktree: "Done. Run `git machete update` in other worktrees to sync."
- In main checkout: "Done. Run `/crew:git:traverse` to sync child branches."

</success_criteria>
