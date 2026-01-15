---
name: flow:enhance:pr-awareness
description: Adds PR context awareness during regular work. Shows unresolved comments, guides resolution after fixes.
license: MIT
triggers:
  - "pr.*open"
  - "review.*comment"
  - "address.*feedback"
  - "fix.*comment"
---

<objective>

During regular work on a branch with an open PR, maintain awareness of unresolved review comments and CI status. When making changes that address feedback, resolve the corresponding threads.

</objective>

<quick_start>

1. **Check for PR** - Run `gh pr view` at session start
2. **Note unresolved threads** - Use `pr-threads.sh` to see pending feedback
3. **Work normally** - Do not interrupt flow for comments
4. **Resolve opportunistically** - When your change addresses feedback, resolve that thread
5. **Run QA if stale** - Check timestamp before push

</quick_start>

<pr_context>

**Check PR status at the start of work:**

```bash
# Get PR info (if exists for current branch)
gh pr view --json number,url,title,state 2>/dev/null || echo "No PR"

# Get unresolved review threads
gh api graphql -f query='
query { repository(owner:"OWNER", name:"REPO") {
  pullRequest(number:N) { reviewThreads(first:50) { nodes {
    id isResolved path line
    comments(first:1) { nodes { body author { login } } }
  }}}
}}' | jq '.data...nodes[] | select(.isResolved==false)'

# Get CI status
gh pr checks 2>/dev/null | head -20
```

**Scripts available (from devtools:git):**

- `pr-info.sh` - PR metadata
- `pr-threads.sh` - Unresolved review threads with THREAD_IDs
- `pr-checks.sh` - CI check status

</pr_context>

<awareness_protocol>

**During Regular Work**

1. **Check for PR at session start** (or when working on a branch)
2. **If PR exists with unresolved comments:**
   - Note which files/lines have feedback
   - Consider whether current work addresses any comments
3. **If modifying a file with comments:**
   - Check if your change addresses the feedback
   - If yes, plan to resolve the thread after pushing

**Don't Interrupt Flow**

- Awareness is passive - don't stop work to address comments
- Only resolve threads when you're naturally making related changes
- The user can explicitly request `/devtools:git:pr:fix-reviews` for dedicated fixing

</awareness_protocol>

<thread_resolution>

**When Your Change Addresses Feedback**

After committing and pushing changes that address a review comment:

```bash
# 1. Get the thread ID from the comment
# (Thread IDs look like PRRT_xxx and come from pr-threads.sh output)

# 2. Resolve the thread with a brief explanation
gh api graphql -f query='
mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
    comment { id }
  }
}' -F threadId="PRRT_xxx" -F body="Fixed: [brief description]"

gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { isResolved }
  }
}' -F threadId="PRRT_xxx"
```

**Or use the devtools script:**

```bash
devtools/skills/git/scripts/pr-resolve.sh "PRRT_xxx" "Fixed: description"
```

</thread_resolution>

<common_sense_qa>

**Smart QA Before Push**

Before pushing (especially if addressing feedback):

1. **Check if CI was run recently:**

   ```bash
   [[ -f .claude/state/qa-timestamp ]] && \
     [[ $(($(date +%s) - $(cat .claude/state/qa-timestamp))) -lt 300 ]] && \
     echo "QA fresh - skip" || echo "QA stale - run bun run ci"
   ```

2. **If substantial changes:** Run `bun run ci`
3. **If minor/typo fix:** Skip (common sense)
4. **Update timestamp after running CI:**
   ```bash
   mkdir -p .claude/state && date +%s > .claude/state/qa-timestamp
   ```

</common_sense_qa>

<integration>

This skill works with:

- `devtools:git` - For git operations, scripts, and workflows
- `flow:enhance:review` - For dedicated code review tasks
- `/devtools:git:pr:fix-reviews` - For bulk fixing all comments (manual trigger)

The pr-awareness skill is for **passive context** during regular work.
Use `/devtools:git:pr:fix-reviews` when you want to **actively fix all comments**.

</integration>

<constraints>

- Do NOT interrupt flow to address comments unless explicitly asked
- Do NOT refetch PR data if already loaded in context
- Do NOT resolve threads without pushing the fix first
- Limit to 3 CI iterations max before escalating

</constraints>

<anti_patterns>

- **Interrupt-driven work** - Stopping current task to fix every comment immediately
- **Redundant fetches** - Re-running gh commands when data is already in context
- **Silent failures** - Resolving threads without actually fixing the issue
- **QA spam** - Running CI after every tiny change

</anti_patterns>

<success_criteria>

- [ ] Aware of open PR and unresolved comments
- [ ] Changes that address feedback get threads resolved
- [ ] QA run when appropriate (not redundantly)
- [ ] Flow of regular work not interrupted

</success_criteria>

<evolution>

**Extension Points:**

- Add webhook integration for real-time PR updates
- Support for multi-PR awareness (stacked PRs)
- Integration with IDE for inline comment display
- Automated conflict detection with base branch

</evolution>
