---
name: fix-pr-reviews
description: Fix all unresolved PR review comments and CI failures. Resolves threads after pushing fixes.
license: MIT
user_invocable: true
argument-hint: "[PR number, defaults to current branch PR]"
triggers:
  - "fix pr"
  - "fix review"
  - "address review"
  - "resolve comment"
  - "pr feedback"
---

<pr_info>
!`gh pr view --json number,url,title,state 2>/dev/null || echo "No PR found"`
</pr_info>

<unresolved_threads>
!`gh api graphql -f query='query { repository(owner:"'$(gh repo view --json owner -q '.owner.login')'", name:"'$(gh repo view --json name -q '.name')'") { pullRequest(number:'$(gh pr view --json number -q '.number' 2>/dev/null || echo 0)') { reviewThreads(first:100) { nodes { id isResolved path line comments(first:1) { nodes { body author { login } } } } } } } }' 2>/dev/null | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | "- \(.path):\(.line // "?") [@\(.comments.nodes[0].author.login)]: \(.comments.nodes[0].body | split("\n")[0])\n  THREAD_ID=\(.id)"' 2>/dev/null || echo "No unresolved threads"`
</unresolved_threads>

<ci_status>
!`gh pr checks 2>/dev/null | head -20 || echo "No CI checks"`
</ci_status>

<objective>

Fix all unresolved PR review comments and CI failures. Resolve each thread after pushing fixes with **educational feedback** to teach reviewers. Max 3 CI iterations.

</objective>

<quick_start>

1. **Parse context** - Extract PR info, threads, and CI status from sections above
2. **Fix each issue** - Read file, make code fix, move to next
3. **Commit and push** - Stage all, commit with message, push
4. **Resolve threads** - Reply with **educational feedback** explaining:
   - Whether reviewer was correct and why
   - What you learned or what the fix teaches
   - Mark thread as resolved
5. **Verify** - Query for 0 unresolved threads

</quick_start>

<data_usage>

**CRITICAL:** Use the inline-fetched data from sections above - it refreshes on each skill invocation.

- Thread IDs (PRRT_xxx) are in `<unresolved_threads>` - parse directly
- If "No PR found" → ask user to create or specify PR number
- **Never assume "already done"** - always process whatever threads are returned
- Keep invoking until 0 unresolved threads remain

**NEVER create report files** like `FIX_REVIEW_REPORT.md` - work directly in the conversation.

</data_usage>

<workflow>

**Step 1: Parse Context**

Extract from sections above:

- PR number and URL from `<pr_info>`
- Unresolved comments with THREAD_IDs from `<unresolved_threads>`
- Failed CI checks from `<ci_status>`

**Step 2: Fix Issues**

For each comment/failure:

1. Read the relevant file
2. Make the code fix
3. Move to next issue

**Step 3: Commit and Push**

```bash
git add -A
git commit -m "fix: address PR review comments"
git push --force-with-lease
```

**Step 4: Resolve Threads with Educational Feedback**

MANDATORY - For EACH fixed thread, provide **educational feedback** that teaches:

**Response Format:**

```
[ASSESSMENT]: Was the reviewer correct? (Yes/Partially/No)

[EXPLANATION]: Why they were right/wrong and what the fix addresses.

[LEARNING]: Key insight for future reviews.

Fixed in commit [hash].
```

**Examples:**

1. Reviewer was correct:

```
✓ Correct catch! This null check was missing and could cause runtime errors.
The defensive programming pattern you suggested is the right approach here.
Learning: Always validate optional props before accessing nested properties.
Fixed in abc123.
```

2. Reviewer was partially correct:

```
◐ Partially correct. The performance concern is valid, but useMemo here
would be premature optimization since this component rarely re-renders.
However, I've added a comment explaining the tradeoff.
Learning: Consider render frequency before adding memoization.
Fixed in def456.
```

3. Reviewer was incorrect (teach respectfully):

```
✗ Actually, this pattern is intentional. TypeScript's discriminated unions
require this structure for proper type narrowing. The "redundant" check
enables type inference in the subsequent block.
Learning: Discriminated unions need explicit type guards for narrowing.
No change needed, but added a clarifying comment.
```

**Execute:**

```bash
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')

# Reply with educational feedback
gh api graphql -f query='mutation($id: ID!, $body: String!) { addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $id, body: $body}) { comment { id } } }' -F id="PRRT_xxx" -F body="✓ Correct catch! [explanation]. Learning: [insight]. Fixed in [hash]."

# Resolve thread
gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }' -F id="PRRT_xxx"
```

**Step 5: Verify**

```bash
# Should output 0
gh api graphql -f query='query { repository(owner:"OWNER", name:"REPO") { pullRequest(number:N) { reviewThreads(first:50) { nodes { isResolved } } } } }' | jq '[.data...nodes[] | select(.isResolved==false)] | length'
```

If CI fails after push: fix and retry (max 3 times), then escalate.

</workflow>

<smart_qa>

Before pushing:

- Check if `bun run ci` was run in last 5 minutes
- If stale: run CI first
- If fresh: proceed with push

```bash
[[ -f .claude/state/qa-timestamp ]] && \
  [[ $(($(date +%s) - $(cat .claude/state/qa-timestamp))) -lt 300 ]] && \
  echo "QA fresh" || echo "Run: bun run ci"
```

</smart_qa>

<constraints>

- Do NOT refetch data that is already in context sections
- Do NOT resolve threads without pushing the fix first
- Limit to 3 CI iterations max before escalating to user
- Do NOT modify files unrelated to the review comments

</constraints>

<anti_patterns>

- **Premature resolution** - Resolving threads before pushing the fix
- **Data refetch** - Running gh commands when data is already in context
- **Scope creep** - Fixing unrelated issues while addressing review comments
- **Silent failures** - Not verifying thread resolution succeeded

</anti_patterns>

<success_criteria>

- [ ] All comments addressed (code fixes made)
- [ ] All CI checks passing
- [ ] All threads resolved on GitHub
- [ ] Verified with query (0 unresolved)

</success_criteria>

<evolution>

**Extension Points:**

- Batch thread resolution for efficiency
- AI-powered fix suggestions before manual implementation
- Integration with review automation tools
- Support for draft PR workflows

</evolution>
