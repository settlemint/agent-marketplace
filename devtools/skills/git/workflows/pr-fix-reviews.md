---
name: pr-fix-reviews
description: Fix PR review comments and CI failures
---

<context>
!`${SKILL_ROOT}/scripts/pr-info.sh`
!`${SKILL_ROOT}/scripts/pr-threads.sh`
!`${SKILL_ROOT}/scripts/pr-checks.sh`
</context>

<objective>
Fix PR comments and CI failures. Resolve threads. Max 3 CI iterations.
</objective>

<data_usage>
The context above contains ALREADY-FETCHED data. Parse it directly.
DO NOT run `gh pr view`, `gh api graphql`, or refetch.
Thread IDs (PRRT_xxx) are in the unresolved threads section.
</data_usage>

<workflow>

1. **Parse context:** Extract comments and CI failures from above
2. **Fix issues:** Make code changes for each comment/failure
3. **Commit and push:**
   ```bash
   git add -A && git commit -m "fix: address PR review comments" && git push --force-with-lease
   ```
4. **Resolve threads:** For EACH thread fixed:
   ```bash
   ${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_xxx" "Fixed: brief description"
   ```
5. **Verify:** Check all threads resolved:
   ```bash
   gh api graphql -f query='query { repository(owner:"OWNER",name:"REPO") { pullRequest(number:N) { reviewThreads(first:50) { nodes { isResolved } } } } }' | jq '[.data...nodes[] | select(.isResolved==false)] | length'
   # Should be 0
   ```

If CI fails after push: fix and retry (max 3 times), then escalate.

</workflow>

<thread_resolution>

**MANDATORY:** Resolve each thread after pushing fix.

```bash
# Get thread IDs from context
# For each PRRT_xxx:
${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_abc123" "Fixed: added null check"
${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_def456" "Fixed: renamed variable"
```

</thread_resolution>

<success_criteria>

- [ ] All comments addressed (code fixes made)
- [ ] All CI checks passing
- [ ] All threads resolved on GitHub (verified with query)

</success_criteria>
