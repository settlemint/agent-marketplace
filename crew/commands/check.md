---
name: crew:check
description: Multi-agent code review with automatic triage
argument-hint: "[PR number, GitHub URL, branch name, or latest]"
---

!`../scripts/workflow/check-context.sh`

## Input

<review_target>$ARGUMENTS</review_target>

## Process

### Phase 1: Determine Review Target

If unclear, ask:

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like me to check?",
    header: "Target",
    options: [
      {label: "Current branch", description: "Review changes on this branch vs main"},
      {label: "Latest PR", description: "Review the most recent pull request"},
      {label: "Specify PR number", description: "I'll tell you which PR"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Launch Parallel Review Agents

Based on recommended reviewers above:

```javascript
// CORE AGENTS - Always launch
Task({ subagent_type: "kieran-typescript-reviewer", prompt: "Review TypeScript: [files]", run_in_background: true });
Task({ subagent_type: "security-sentinel", prompt: "Security audit: [files]", run_in_background: true });
Task({ subagent_type: "code-simplicity-reviewer", prompt: "Simplicity review: [files]", run_in_background: true });
Task({ subagent_type: "architecture-strategist", prompt: "Architecture review: [files]", run_in_background: true });

// CONDITIONAL - Based on file types shown above
```

### Phase 3: Collect and Synthesize

1. Use `TaskOutput` to collect results from each agent
2. **Deduplicate** - merge similar findings
3. Categorize by priority:
   - **P1 (Critical)** - Blocks merge
   - **P2 (Important)** - Should fix
   - **P3 (Nice-to-have)** - Improvements

### Phase 4: Create Todo Files

For each finding, create in `.claude/todos/`:

```markdown
# [NNN]-pending-[priority]-[brief-slug].md
```

## Success Criteria

- [ ] All relevant agents launched
- [ ] Findings deduplicated and prioritized
- [ ] Todo files created for each finding
