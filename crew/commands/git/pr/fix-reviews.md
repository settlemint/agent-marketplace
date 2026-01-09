---
name: crew:git:pr:fix-reviews
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
**Check `<stack_context>` above. If it shows "is in machete layout", sync with parent FIRST:**

```bash
# Only run if machete-managed (check stack_context output)
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git fetch origin
  git machete update    # Rebase onto parent (safe in worktrees)
fi
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
Review the prefilled context above and **create a TodoWrite list** tracking each issue:

**Use TodoWrite to track all items:**

```javascript
TodoWrite({
  todos: [
    // For each comment from <unresolved_threads>:
    {
      content: "Fix: src/auth.ts:42 - add null check (THREAD_ID=PRRT_abc123)",
      status: "pending",
      activeForm: "Fixing null check in auth.ts",
    },
    {
      content: "Fix: src/api.ts:15 - rename variable (THREAD_ID=PRRT_def456)",
      status: "pending",
      activeForm: "Fixing variable name in api.ts",
    },
    // For each CI failure from <ci_status>:
    {
      content: "Fix CI: lint errors",
      status: "pending",
      activeForm: "Fixing lint errors",
    },
    {
      content: "Fix CI: type errors",
      status: "pending",
      activeForm: "Fixing type errors",
    },
    // Resolution tasks (add after fixing):
    {
      content: "Resolve thread PRRT_abc123",
      status: "pending",
      activeForm: "Resolving thread",
    },
    {
      content: "Resolve thread PRRT_def456",
      status: "pending",
      activeForm: "Resolving thread",
    },
    // Final tasks:
    {
      content: "Commit and push fixes",
      status: "pending",
      activeForm: "Committing and pushing",
    },
    { content: "Update PR", status: "pending", activeForm: "Updating PR" },
  ],
});
```

**Important:** Include the `THREAD_ID=...` in each comment todo - you'll need it to resolve threads later.

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
**Fix each issue, marking todos as in_progress → completed:**

For each fix todo in your list:

1. Mark todo as `in_progress`
2. Make the code fix
3. Mark todo as `completed`

You can fix issues directly or launch parallel agents for complex fixes:

```javascript
// For complex multi-file fixes, use agents
Task({
  subagent_type: "crew:workflow:pr-comment-resolver",
  prompt: "Fix: [specific comment details]",
  run_in_background: true,
});
```

**Keep the todo list updated** - this gives the user visibility into progress.

</phase>

<phase name="verify">

```bash
bun run ci
```

If fails after 3 iterations → escalate to user.
</phase>

<phase name="code-simplification">
**Run code-simplifier agent on modified files:**

```javascript
Task({
  subagent_type: "code-simplifier",
  prompt: `Simplify code modified while fixing PR comments.

Focus on:
- Files changed in this session
- Clarity and consistency
- Preserve ALL functionality

Output: List of simplifications made.`,
  description: "code-simplification",
  run_in_background: false,
});
```

</phase>

<phase name="commit-and-push">
**After fixes are complete, commit and push:**

```bash
git add -A
git commit -m "fix: address PR review comments"
git push
```

If push is rejected (rebased branch), use:

```bash
git push --force-with-lease
```

</phase>

<phase name="resolve">
**After push, resolve each thread you fixed (mark each "Resolve thread" todo as you go):**

For each "Resolve thread THREAD_ID" todo in your list:

1. Mark todo as `in_progress`
2. Run the resolve script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "THREAD_ID" "Fixed: brief description"
```

3. Mark todo as `completed`

**Example:**

```bash
# Resolving PRRT_abc123
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "PRRT_abc123" "Fixed: added null check"
# → mark "Resolve thread PRRT_abc123" as completed

# Resolving PRRT_def456
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "PRRT_def456" "Fixed: renamed variable"
# → mark "Resolve thread PRRT_def456" as completed
```

**Important:** Only resolve threads you actually fixed. Leave unaddressed threads unresolved.

</phase>

<phase name="update-pr">
**Update PR title and body to reflect fixes:**

```javascript
Skill({ skill: "crew:git:pr:update" });
```

</phase>

</process>

<success_criteria>

- [ ] Stack synced at start (if machete-managed)
- [ ] All PR comments addressed with code fixes
- [ ] All CI failures fixed
- [ ] `bun run ci` passes locally
- [ ] Changes committed and pushed
- [ ] Each fixed thread resolved on GitHub with `gh-pr-resolve-thread.sh`
- [ ] PR updated via `crew:git:pr:update`

**Worktree-safe completion message:**

- In worktree: "Done. Run `git machete update` in other worktrees to sync."
- In main checkout: "Done. Run `/crew:git:stacked:traverse` to sync child branches."

</success_criteria>
