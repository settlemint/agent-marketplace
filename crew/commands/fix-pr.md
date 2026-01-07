---
name: crew:fix-pr
description: Resolve all unresolved PR review comments and CI failures
argument-hint: "[PR number, defaults to current branch PR]"
---

## PR Information

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`

## Unresolved Review Threads

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-threads.sh 2>&1`

## CI Check Status

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-checks.sh 2>&1`

## Stack Context

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`

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
- **Stack awareness** - If machete-managed, warn user that child branches may need rebasing after fixes

</constraints>

<process>

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

</process>

<success_criteria>

- [ ] All PR comments addressed
- [ ] All CI failures fixed
- [ ] `bun run ci` passes
- [ ] Threads resolved on GitHub
- [ ] If machete-managed: suggest `/crew:git:traverse` to sync child branches

</success_criteria>
