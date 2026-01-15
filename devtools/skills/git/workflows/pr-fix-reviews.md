---
name: pr-fix-reviews
description: Fix PR review comments and CI failures with educational feedback
---

<context>
!`${SKILL_ROOT}/scripts/pr-info.sh`
!`${SKILL_ROOT}/scripts/pr-threads.sh`
!`${SKILL_ROOT}/scripts/pr-checks.sh`
</context>

<objective>
Fix PR comments and CI failures. Resolve threads with **educational feedback** to teach reviewers. Max 3 CI iterations.
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
4. **Resolve threads with educational feedback:** For EACH thread, explain whether reviewer was correct:
   ```bash
   # Format: "[symbol] Assessment. Explanation. Learning: insight. Fixed in [hash]."
   ${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_xxx" "✓ Correct! [why they were right]. Learning: [insight]. Fixed in abc123."
   ```
5. **Verify:** Check all threads resolved:
   ```bash
   gh api graphql -f query='query { repository(owner:"OWNER",name:"REPO") { pullRequest(number:N) { reviewThreads(first:50) { nodes { isResolved } } } } }' | jq '[.data...nodes[] | select(.isResolved==false)] | length'
   # Should be 0
   ```

If CI fails after push: fix and retry (max 3 times), then escalate.

</workflow>

<thread_resolution>

**MANDATORY:** Resolve each thread with **educational feedback**.

**Symbols:**

- ✓ Reviewer was correct
- ◐ Reviewer was partially correct
- ✗ Reviewer was incorrect (teach respectfully)

**Examples:**

```bash
# Reviewer was correct
${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_abc" "✓ Good catch! The null check was missing. Learning: Always validate optional props. Fixed in abc123."

# Reviewer was partially correct
${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_def" "◐ Valid concern but useMemo is premature here since component rarely re-renders. Added comment explaining tradeoff. Learning: Consider render frequency before memoization. Fixed in def456."

# Reviewer was incorrect (explain respectfully)
${SKILL_ROOT}/scripts/pr-resolve.sh "PRRT_ghi" "✗ This pattern is intentional for TypeScript discriminated unions. The 'redundant' check enables type narrowing. Learning: Discriminated unions need explicit guards. Added clarifying comment."
```

</thread_resolution>

<success_criteria>

- [ ] All comments addressed (code fixes made)
- [ ] All CI checks passing
- [ ] All threads resolved on GitHub (verified with query)

</success_criteria>
