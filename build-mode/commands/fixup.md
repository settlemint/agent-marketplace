---
name: fixup
description: Fix all unresolved PR review comments and CI failures with educational feedback
argument-hint: [PR number, defaults to current branch PR]
---

Fix all unresolved PR review comments and CI failures.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`

## PR Info
!`${CLAUDE_PLUGIN_ROOT}/scripts/pr-info.sh $ARGUMENTS`

## Unresolved Threads
!`${CLAUDE_PLUGIN_ROOT}/scripts/pr-threads.sh $ARGUMENTS`

## CI Status
!`${CLAUDE_PLUGIN_ROOT}/scripts/pr-checks.sh $ARGUMENTS`

## Workflow

### 1. Parse Context

Extract from the data above:
- Unresolved review threads (with THREAD_ID)
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

```bash
git add -A && git commit -m "fix: address PR review comments" && git push --force-with-lease
```

### 5. Resolve Threads with Educational Feedback

For EACH unresolved thread, provide feedback using symbols:

- **✓** Reviewer was correct - Acknowledge and explain what you learned
- **◐** Reviewer was partially correct - Explain the nuance
- **✗** Reviewer was incorrect - Teach respectfully why

**Examples:**

```bash
# Reviewer was correct
${CLAUDE_PLUGIN_ROOT}/scripts/pr-resolve.sh "THREAD_ID" "✓ Good catch! The null check was missing. Learning: Always validate optional props. Fixed in abc123."

# Reviewer was partially correct
${CLAUDE_PLUGIN_ROOT}/scripts/pr-resolve.sh "THREAD_ID" "◐ Valid concern but useMemo is premature here since component rarely re-renders. Added comment explaining tradeoff. Fixed in def456."

# Reviewer was incorrect (teach respectfully)
${CLAUDE_PLUGIN_ROOT}/scripts/pr-resolve.sh "THREAD_ID" "✗ This pattern is intentional for TypeScript discriminated unions. The 'redundant' check enables type narrowing. Learning: Discriminated unions need explicit guards. Added clarifying comment."
```

### 6. Verify All Threads Resolved

```bash
gh api graphql -f query='query { repository(owner:"OWNER",name:"REPO") { pullRequest(number:N) { reviewThreads(first:50) { nodes { isResolved } } } } }' | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)] | length'
```

Should return 0.

### 7. Wait for CI and Retry if Needed

If CI fails after push:
1. Read the failure logs
2. Fix the issue
3. Commit with descriptive message
4. Push again

Max 3 CI retry iterations before escalating.

## Success Criteria

- [ ] All review comments addressed with code fixes
- [ ] All threads resolved on GitHub with educational feedback
- [ ] All CI checks passing
- [ ] No new issues introduced

## Related Skills

| Skill | Purpose | Invocation |
|-------|---------|------------|
| build | Implement with TDD workflow | `Skill({ skill: "build-mode:build" })` |
| implementing-code | TDD guidance | `Skill({ skill: "build-mode:implementing-code" })` |
