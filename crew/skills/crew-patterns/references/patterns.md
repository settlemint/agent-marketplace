<patterns>

<pattern name="user-questions-constraint">
**MANDATORY: ALWAYS use AskUserQuestion tool for user choices.**

NEVER output plain text questions with bullet options. ALWAYS use the AskUserQuestion tool.

This applies to:

- End-of-workflow "what next?" prompts
- Decision points during execution
- Clarification requests
- All user-facing choices
  </pattern>

<pattern name="bash-subagent">
Use Bash subagent for commands with large output (tests, builds, CI).

```javascript
Task({
  subagent_type: "Bash",
  prompt: `Run tests and report:
1. Run: bun run test
2. Report: PASS or list failures with file:line`,
  description: "test-runner",
});
```

**When to use:**

- Test suites (vitest, jest, playwright)
- CI checks (eslint, tsc, biome)
- Builds (bun build, turbo build)
- Package installs (bun install)

**Why:** Separate context prevents main thread pollution.
</pattern>

<pattern name="task-file">
Task files in `.claude/branches/{slugified-branch}/tasks/`:

```markdown
---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/path/to/file.ts
depends_on: []
---

# TXXX: Task title

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

Naming: `{order}-{status}-{priority}-{story}-{slug}.md`
Example: `010-pending-p1-us1-create-model.md`
</pattern>

<pattern name="branch-state">
Branch state at `.claude/branches/{slugified-branch}/state.json`:

```json
{
  "branch": "feat/feature-name",
  "plan": { "exists": true, "file": ".claude/plans/feature.yaml" },
  "execution": { "pending_count": 5 }
}
```

</pattern>

</patterns>
