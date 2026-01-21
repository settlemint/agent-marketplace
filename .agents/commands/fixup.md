---
name: fixup
description: Fix all unresolved PR review comments and CI failures
argument-hint: [PR number, defaults to current branch PR]
---

Fix all unresolved PR review comments and CI failures with educational feedback.

## Context

```bash
! git branch --show-current
! git status --short
! gh pr view --json number,title,state,reviewDecision 2>/dev/null || echo "No PR found"
! gh pr checks 2>/dev/null | head -20 || echo "No checks"
! gh pr view --json reviewThreads --jq '.reviewThreads[] | select(.isResolved == false) | {path: .path, line: .line, body: .comments[0].body}' 2>/dev/null | head -30 || echo "No unresolved threads"
```

## Workflow

### 1. Parse Context

Extract from the data above:
- Unresolved review threads (file path, line, comment)
- Failed CI checks
- Current branch state

### 2. Fix Issues

For each unresolved thread or CI failure:
1. Read the file mentioned
2. Understand the reviewer's concern
3. Make the appropriate code fix
4. Consider if reviewer was correct, partially correct, or incorrect

### 3. Run Local Validation

Before pushing, verify locally:
```bash
bun run lint
bun run test
bun run ci  # if available
```

### 4. Commit and Push

Use single responsibility - delegate to commit-push:

```javascript
Skill({ skill: "commit-push", args: "fix: address PR review comments" })
```

Or manually:
```bash
git add -A
git commit -m "fix: address PR review comments"
git push --force-with-lease
```

### 5. Resolve Threads with Educational Feedback

For EACH unresolved thread, provide feedback using symbols:

- **✓** Reviewer was correct - Acknowledge and explain what you learned
- **◐** Reviewer was partially correct - Explain the nuance
- **✗** Reviewer was incorrect - Teach respectfully why

**Resolve thread via GraphQL:**

```bash
# Get thread ID
THREAD_ID=$(gh pr view --json reviewThreads --jq '.reviewThreads[] | select(.isResolved == false) | .id' | head -1)

# Resolve with comment
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "'"$THREAD_ID"'"}) {
      thread { isResolved }
    }
  }
'
```

**Example feedback patterns:**

```
✓ Good catch! The null check was missing. Fixed in abc123.

◐ Valid concern but useMemo is premature here since component rarely re-renders. Added comment explaining tradeoff.

✗ This pattern is intentional for TypeScript discriminated unions. The 'redundant' check enables type narrowing. Added clarifying comment.
```

### 6. Verify All Threads Resolved

```bash
gh pr view --json reviewThreads --jq '[.reviewThreads[] | select(.isResolved == false)] | length'
```

Should return 0.

### 7. Wait for CI and Retry if Needed

If CI fails after push:
1. Read the failure logs: `gh pr checks --watch`
2. Fix the issue
3. Commit with descriptive message
4. Push again

Max 3 CI retry iterations before escalating.

## Constraints

**Banned:**
- Dismissing reviewer comments without addressing them
- Pushing without running local validation
- Resolving threads without educational feedback

**Required:**
- Address ALL unresolved threads
- Run local validation before push
- Provide ✓/◐/✗ feedback when resolving

## Success Criteria

- [ ] All review comments addressed with code fixes
- [ ] All threads resolved on GitHub with educational feedback
- [ ] All CI checks passing
- [ ] No new issues introduced
