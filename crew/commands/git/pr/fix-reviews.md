---
name: crew:git:pr:fix-reviews
description: Resolve all unresolved PR review comments and CI failures
argument-hint: "[PR number, defaults to current branch PR]"
allowed-tools:
  - Bash
  - Read
  - Edit
  - Task
  - AskUserQuestion
  - TodoWrite
  - Skill
---

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

<objective>

Sync stack, fix PR comments and CI failures, resolve threads, update PR. Max 3 CI iterations.

</objective>

<workflow>

## Step 1: Sync Stack (if machete-managed)

```bash
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git fetch origin
  git machete update
fi
```

## Step 2: Validate PR

If no PR found → ask user to create or specify PR number.

## Step 3: Create Todo List

```javascript
TodoWrite({
  todos: [
    // For each comment from <unresolved_threads>:
    {
      content: "Fix: src/file.ts:42 - description (THREAD_ID=PRRT_xxx)",
      status: "pending",
      activeForm: "Fixing...",
    },
    // For each CI failure:
    {
      content: "Fix CI: lint errors",
      status: "pending",
      activeForm: "Fixing lint",
    },
    // Resolution tasks:
    {
      content: "Resolve thread PRRT_xxx",
      status: "pending",
      activeForm: "Resolving thread",
    },
    // Final tasks:
    { content: "Commit and push", status: "pending", activeForm: "Committing" },
    { content: "Update PR", status: "pending", activeForm: "Updating PR" },
  ],
});
```

## Step 4: Confirm Scope

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
      multiSelect: false,
    },
  ],
});
```

## Step 5: Fix Issues

Mark todos as `in_progress` → make fix → `completed`.

For complex multi-file fixes:

```javascript
Task({
  subagent_type: "crew:workflow:pr-comment-resolver",
  prompt: "Fix: [details]",
  run_in_background: true,
});
```

## Step 6: Verify CI

```bash
bun run ci
```

If fails after 3 iterations → escalate to user.

## Step 7: Code Quality Review

```javascript
Task({
  subagent_type: "crew:review:smells-reviewer",
  prompt:
    "Review code modified while fixing PR comments for: duplication, complexity, dead code, YAGNI violations. Report issues to fix.",
  description: "code-quality-review",
});
```

## Step 8: Commit and Push

```bash
git add -A
git commit -m "fix: address PR review comments"
git push --force-with-lease
```

## Step 9: Resolve Threads

For each fixed thread:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "THREAD_ID" "Fixed: description"
```

## Step 10: Update PR

```javascript
Skill({ skill: "crew:git:pr:update" });
```

</workflow>

<success_criteria>

- [ ] Stack synced (if machete-managed)
- [ ] All PR comments addressed
- [ ] All CI failures fixed
- [ ] `bun run ci` passes locally
- [ ] Changes committed and pushed
- [ ] Threads resolved on GitHub
- [ ] PR updated

</success_criteria>
