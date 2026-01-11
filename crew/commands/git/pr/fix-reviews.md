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

Fix PR comments and CI failures, resolve threads, update PR. Max 3 CI iterations.

</objective>

<workflow>

## Step 1: Validate PR

If no PR found → ask user to create or specify PR number.

## Step 2: Create Todo List

**CRITICAL: Include a "Resolve thread" task for EACH thread. Do NOT skip thread resolution.**

```javascript
TodoWrite({
  todos: [
    // For EACH comment from <unresolved_threads>, create TWO todos:
    // 1. A "Fix" todo for making the code change
    {
      content: "Fix: src/file.ts:42 - description (THREAD_ID=PRRT_xxx)",
      status: "pending",
      activeForm: "Fixing...",
    },
    // 2. A "Resolve thread" todo - ONE PER THREAD, must be completed after pushing
    {
      content: "Resolve thread PRRT_xxx on GitHub",
      status: "pending",
      activeForm: "Resolving thread",
    },
    // Repeat for each thread...

    // For each CI failure:
    {
      content: "Fix CI: lint errors",
      status: "pending",
      activeForm: "Fixing lint",
    },

    // Final tasks:
    { content: "Commit and push", status: "pending", activeForm: "Committing" },
    {
      content: "Resolve ALL threads on GitHub",
      status: "pending",
      activeForm: "Resolving threads",
    },
    {
      content: "Verify all threads resolved",
      status: "pending",
      activeForm: "Verifying",
    },
    { content: "Update PR", status: "pending", activeForm: "Updating PR" },
  ],
});
```

## Step 3: Confirm Scope

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

## Step 4: Fix Issues

Mark todos as `in_progress` → make fix → `completed`.

For complex multi-file fixes:

```javascript
Task({
  subagent_type: "crew:workflow:pr-comment-resolver",
  prompt: "Fix: [details]",
  run_in_background: true,
});
```

## Step 5: Verify CI

```bash
bun run ci
```

If fails after 3 iterations → escalate to user.

## Step 6: Code Quality Review

```javascript
Task({
  subagent_type: "crew:review:smells-reviewer",
  prompt:
    "Review code modified while fixing PR comments for: duplication, complexity, dead code, YAGNI violations. Report issues to fix.",
  description: "code-quality-review",
});
```

## Step 7: Commit and Push

```bash
git add -A
git commit -m "fix: address PR review comments"
git push --force-with-lease
```

## Step 8: Resolve Threads (MANDATORY)

**DO NOT SKIP THIS STEP. Unresolved threads leave PR in incomplete state.**

For EACH thread that was fixed, resolve it on GitHub:

```bash
# Run this for EVERY thread ID from <unresolved_threads>
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "PRRT_xxx" "Fixed: brief description of fix"
```

Example for multiple threads:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "PRRT_abc123" "Fixed: Added null check"
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "PRRT_def456" "Fixed: Updated variable name"
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "PRRT_ghi789" "Fixed: Removed deprecated call"
```

## Step 9: Verify All Threads Resolved

**Confirm zero unresolved threads remain:**

```bash
gh api graphql -f query='
query {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      reviewThreads(first: 50) {
        nodes { isResolved }
      }
    }
  }
}' --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length'
# Should output: 0
```

If any threads remain unresolved, go back to Step 8 and resolve them.

## Step 10: Update PR

```javascript
Skill({ skill: "crew:git:pr:update" });
```

</workflow>

<success_criteria>

- [ ] All PR comments addressed (code fixes made)
- [ ] All CI failures fixed
- [ ] `bun run ci` passes locally
- [ ] Changes committed and pushed
- [ ] **ALL threads resolved on GitHub** (verified with query showing 0 unresolved)
- [ ] PR updated

**INCOMPLETE if any threads remain unresolved. Always verify with Step 9 query.**

</success_criteria>
