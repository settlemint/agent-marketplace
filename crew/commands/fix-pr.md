---
name: crew:fix-pr
description: Resolve all unresolved PR review comments and CI failures
argument-hint: "[PR number, defaults to current branch PR]"
---

<context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</context>

<constraints>

- **Main thread execution** - Do NOT delegate to orchestrator (preserves native UI)
- **Max 3 CI fix iterations** - Escalate to user after 3 attempts
- **Reply and resolve** - Mark threads resolved after fixing

</constraints>

<process>

<phase name="validate">
If no PR found:
```javascript
AskUserQuestion({ questions: [{
  question: "No PR found. What to do?",
  header: "PR",
  options: [
    { label: "Create PR first", description: "Create new PR" },
    { label: "Specify PR number", description: "Tell me which PR" }
  ]
}]});
```
</phase>

<phase name="analyze">
Fetch context:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-threads.sh  # Unresolved comments
gh pr checks --json name,state,conclusion --jq '.[] | select(.conclusion == "failure")'
```
Group by: file (comments), type (CI failures: lint/type/test/build)
</phase>

<phase name="confirm">
```javascript
AskUserQuestion({ questions: [{
  question: `Found ${comments} comments, ${failures} CI failures. Proceed?`,
  header: "Fix",
  options: [
    { label: "Fix all (Recommended)", description: "Comments + CI" },
    { label: "Comments only", description: "Skip CI" },
    { label: "CI only", description: "Skip comments" }
  ]
}]});
```
</phase>

<phase name="fix">
Launch parallel agents:
```javascript
// PR comments by file
Task({ subagent_type: "pr-comment-resolver", prompt: "Fix: [comments]", run_in_background: true });

// CI failures by type
Task({ subagent_type: "general-purpose", prompt: "Fix lint: [errors]", run_in_background: true });
Task({ subagent_type: "general-purpose", prompt: "Fix types: [errors]", run_in_background: true });

````
</phase>

<phase name="verify">
```bash
bun run ci
````

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

</success_criteria>
