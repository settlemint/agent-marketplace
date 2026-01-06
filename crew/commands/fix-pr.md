---
name: fix-pr
description: Resolve all unresolved PR review comments and CI failures on the current branch
argument-hint: "[PR number, defaults to current branch PR]"
---

# Fix PR Command

Resolve all unresolved PR review comments and fix CI failures.

## Context

Check for PR:
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`

**Unresolved comments are fetched via gh CLI scripts in Phase 3.**

## Workflow

**IMPORTANT:** Execute this workflow directly in the main thread. Do NOT delegate to an orchestrator agent - this preserves native UI components.

### Phase 1: Validate PR

1. Check if there's a PR for current branch
2. If not found, use AskUserQuestion:

```
AskUserQuestion({
  questions: [{
    question: "No PR found for current branch. What would you like to do?",
    header: "PR",
    options: [
      {label: "Create PR first", description: "Create a new pull request"},
      {label: "Specify PR number", description: "I'll tell you which PR to fix"},
      {label: "Cancel", description: "Exit without action"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Create Progress Tracking

```
TodoWrite([
  {content: "Fetch unresolved comments", status: "in_progress", activeForm: "Fetching comments"},
  {content: "Check CI status", status: "pending", activeForm: "Checking CI"},
  {content: "Group issues by file", status: "pending", activeForm: "Grouping issues"},
  {content: "Fix comments and CI failures", status: "pending", activeForm: "Fixing issues"},
  {content: "Run CI verification", status: "pending", activeForm: "Verifying CI"},
  {content: "Reply and resolve", status: "pending", activeForm: "Resolving threads"}
])
```

### Phase 3: Analyze Comments

1. **Fetch unresolved review threads:**

Get repo and PR info:
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-repo-info.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh`

Fetch unresolved threads via gh CLI:
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-threads.sh`

2. Group comments by file for efficient fixing

### Phase 3.5: Check CI Status

1. **Fetch CI check status:**

```bash
gh pr checks --json name,state,conclusion --jq '.[] | select(.conclusion == "failure" or .conclusion == "cancelled" or .state == "pending")'
```

2. **For failed checks, fetch logs:**

```bash
# Get the run ID for failed checks
gh run list --branch $(git branch --show-current) --status failure --json databaseId --jq '.[0].databaseId'

# Fetch failed job logs
gh run view <run_id> --log-failed
```

3. **Parse failure types:**
   - **Lint errors**: Extract file:line:message from eslint/qlty output
   - **Type errors**: Extract TypeScript errors with file locations
   - **Test failures**: Extract failing test names and assertion messages
   - **Build errors**: Extract compilation errors

4. **Present combined summary:**

```markdown
## Issues Summary

### Unresolved Comments: X threads

- `src/components/Auth.tsx` (3 comments)
- `src/api/routes.ts` (2 comments)

### CI Failures: Y issues

- **lint**: 5 eslint errors in 2 files
- **typecheck**: 3 type errors in 1 file
- **test**: 2 failing tests
```

### Phase 4: Confirm Before Fixing (Main Thread - Native UI)

```
AskUserQuestion({
  questions: [{
    question: "Found X unresolved comments and Y CI failures. How should I proceed?",
    header: "Fix",
    options: [
      {label: "Fix all (Recommended)", description: "Resolve all comments and CI failures"},
      {label: "Comments only", description: "Fix PR comments, skip CI failures"},
      {label: "CI only", description: "Fix CI failures, skip PR comments"},
      {label: "Show details first", description: "Show each issue before fixing"},
      {label: "Cancel", description: "Don't fix anything"}
    ],
    multiSelect: false
  }]
})
```

### Phase 5: Fix Comments and CI Failures

Launch fixes in parallel:

```javascript
// 1. PR Comment resolvers (grouped by file)
Task({
  subagent_type: "pr-comment-resolver",
  prompt: "Fix these review comments in [file]: [comments list]",
  run_in_background: true,
});

// 2. CI failure fixers (by error type)
// For lint errors:
Task({
  subagent_type: "general-purpose",
  prompt: "Fix these lint errors:\n[parsed lint errors with file:line:message]",
  run_in_background: true,
});

// For type errors:
Task({
  subagent_type: "general-purpose",
  prompt:
    "Fix these TypeScript errors:\n[parsed type errors with file:line:message]",
  run_in_background: true,
});

// For test failures:
Task({
  subagent_type: "general-purpose",
  prompt: "Fix these failing tests:\n[test name, file, assertion failure]",
  run_in_background: true,
});
```

Update TodoWrite as each issue group is fixed.

### Phase 6: Verify and Commit (Main Thread - Native UI)

After fixes complete:

1. Run full CI locally: `bun run ci`
2. If CI still fails, loop back to Phase 3.5 and repeat
   - **Maximum 3 iterations** before escalating to user
   - After 3 attempts, present remaining failures:

```
AskUserQuestion({
  questions: [{
    question: "CI is still failing after 3 fix attempts. How should I proceed?",
    header: "CI Loop",
    options: [
      {label: "Try again", description: "One more fix attempt"},
      {label: "Show failures", description: "Display remaining issues for manual review"},
      {label: "Skip CI", description: "Commit without passing CI (not recommended)"}
    ],
    multiSelect: false
  }]
})
```

```
AskUserQuestion({
  questions: [{
    question: "All issues fixed. Local CI: [PASS/FAIL]. Ready to commit?",
    header: "Commit",
    options: [
      {label: "Commit and push", description: "Commit fixes and push to PR"},
      {label: "Review changes", description: "Show me the diff first"},
      {label: "Re-run fixes", description: "CI still failing, try again"},
      {label: "Cancel", description: "Don't commit yet"}
    ],
    multiSelect: false
  }]
})
```

### Phase 7: Reply and Resolve Threads

After pushing, resolve each thread on GitHub:

1. **Get thread IDs from Phase 3 output** (THREAD_ID= lines)
2. **For each thread, run:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "THREAD_ID" "Fixed in commit [hash]"
```

3. **Verify all resolved:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-threads.sh
# Should output: "No unresolved threads found"
```

**Example resolution loop:**

```bash
# Resolve all threads from the saved IDs
for THREAD_ID in $THREAD_IDS; do
  ${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-resolve-thread.sh "$THREAD_ID" "Fixed."
done
```

## Key Principles

1. **Keep UI in main thread** - User approves before fixing, before committing
2. **Agents for fixes only** - pr-comment-resolver and general-purpose agents do the actual code changes
3. **Batch by type** - Group PR comments by file, CI failures by error type
4. **Full CI before commit** - Always run `bun run ci` after fixes
5. **Iterate until green** - Loop back if CI still fails after fixes

## Usage

```bash
/crew:fix-pr           # Fix current branch's PR comments and CI failures
/crew:fix-pr 123       # Fix specific PR number
```
