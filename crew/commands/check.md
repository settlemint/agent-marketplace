---
name: crew:check
description: Multi-agent code review with automatic triage
argument-hint: "[PR number, GitHub URL, branch name, or latest]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
context: fork
skills:
  - crew:crew-patterns
hooks:
  PostToolUse: false
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<prerequisite>

**Load patterns skill first:**

```javascript
Skill({ skill: "crew:crew-patterns" });
```

This provides: `<pattern name="quality-agents"/>`, `<pattern name="task-file"/>`.

</prerequisite>

<check_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/check-context.sh`
</check_context>

<input>
<review_target>$ARGUMENTS</review_target>
</input>

<seven_leg_system>

| Leg             | Focus            | Key Checks                             |
| --------------- | ---------------- | -------------------------------------- |
| **Correctness** | Logic accuracy   | Edge cases, null handling, type safety |
| **Performance** | Speed/efficiency | Complexity, caching, N+1 queries       |
| **Security**    | Vulnerabilities  | OWASP, injection, auth, secrets        |
| **Elegance**    | Design quality   | SOLID, clean architecture, cohesion    |
| **Resilience**  | Failure handling | Error recovery, cleanup, degradation   |
| **Style**       | Conventions      | Naming, formatting, idioms             |
| **Smells**      | Debt indicators  | Anti-patterns, duplication, complexity |

**Severity levels:**

- **P0**: Critical - Must fix, blocks deployment
- **P1**: High - Should fix, significant impact
- **P2**: Medium - Address soon
- **Observation**: Note for consideration

**Output format:** `[Severity] file:line - Description`

</seven_leg_system>

<notes>
- All 7 legs always, agents per `rules/agent-limits.md`
- Output format: `[P0|P1|P2|Obs] file:line - description`
</notes>

<process>

<phase name="determine-target">
If unclear from arguments:
```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like me to check?",
    header: "Target",
    options: [
      { label: "Current branch (Recommended)", description: "vs main" },
      { label: "Latest PR", description: "Most recent pull request" },
      { label: "Specific PR", description: "I'll tell you which" }
    ],
    multiSelect: false
  }]
});
```
</phase>

<phase name="gather-context">
```bash
git diff main...HEAD --name-only  # Changed files
git diff main...HEAD             # Full diff
```
</phase>

<phase name="launch-reviewers">
Launch ALL 7 using `<pattern name="quality-agents"/>` in SINGLE message:

```javascript
const legs = [
  "correctness",
  "performance",
  "security",
  "elegance",
  "resilience",
  "style",
  "smells",
];
for (const leg of legs) {
  Task({
    subagent_type: `${leg}-reviewer`,
    prompt: `CONTEXT: Review ${branch}\nSCOPE: ${files}\nFOCUS: ${legFocus[leg]}\nOUTPUT: [P0|P1|P2|Obs] file:line - description\n\nTools: Glob, Grep, Read (not bash)`,
    description: `${leg} review`,
    run_in_background: true,
  });
}

// Conditional domain agents (if applicable):
// - solidity-security-auditor (if .sol files)
// - data-migration-expert (if migrations)
// - agent-context-reviewer (if .claude/ files)
```

</phase>

<phase name="collect-synthesize">
```javascript
const findings = [];
for (const leg of legs) {
  const result = TaskOutput({ task_id: leg.id, block: true });
  findings.push(...parseFindings(result, leg));
}
// Deduplicate and sort by severity: P0 → P1 → P2 → Obs
```
</phase>

<phase name="meta-analysis">
Optional for complex reviews with many findings:
```javascript
Task({
  subagent_type: "meta-reviewer",
  prompt: `Synthesize findings from all 7 legs. Find: cross-leg patterns, priority escalations, systemic issues.\nMCP: Use Codex for deep reasoning.`,
  run_in_background: false
});
```
</phase>

<phase name="confirm-action">
```javascript
AskUserQuestion({
  questions: [{
    question: `Found ${p0} P0, ${p1} P1, ${p2} P2. How to proceed?`,
    header: "Action",
    options: [
      { label: "Create todo files (Recommended)", description: "Write to tasks/" },
      { label: "Fix P0 issues now", description: "Immediately address critical" },
      { label: "Show full report", description: "Display all findings" }
    ],
    multiSelect: false
  }]
});
```
</phase>

<phase name="create-task-files">
Add findings as task files using `<pattern name="task-file"/>`:

```javascript
const slugBranch = branch.replace(/\//g, "-");
// Findings start at order 050
// Naming: {order}-pending-{severity}-found-{slug}.md
// Example: 050-pending-p0-found-fix-null-deref.md
```

Each finding task includes:

- Leg dimension (correctness, security, etc.)
- Severity (P0/P1/P2/Obs)
- File:line location
- Recommended fix
  </phase>

</process>

<success_criteria>

- [ ] All 7 canonical reviewers launched in single message
- [ ] Conditional domain agents launched for relevant file types
- [ ] Findings deduplicated and prioritized
- [ ] AskUserQuestion confirms next steps
- [ ] Task files created with naming convention
- [ ] Each finding includes leg, severity, location, fix

</success_criteria>
