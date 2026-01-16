---
name: rule-of-five
description: Use when iterating on designs, plans, or implementations until quality converges. Covers the 5-pass multi-review pattern from code to architecture.
license: MIT
triggers:
  # Intent triggers
  - "rule of five"
  - "multi-pass review"
  - "iterate until good"
  - "review again"
  - "deeper review"
  - "thorough review"
  - "make it better"
  - "improve quality"

  # Artifact triggers
  - "convergence"
  - "iterative refinement"
  - "architecture review"
  - "self-review"
---

<objective>
Achieve higher quality through iterative refinement. Have agents review their own work 4-5 times until it converges to "as good as it can get."
</objective>

<essential_principles>

- Generating is easy, reviewing deeply is hard. First outputs are drafts, not finals.
- 4-5 iterations before convergence. Less for trivial tasks (2-3), more for complex ones (5+).
- Each pass broadens scope: code → architecture → existential questions.
- Mix narrow (in-the-small) and broad (in-the-large) reviews.
- Converged = agent declares "this is as good as it can get."
  </essential_principles>

<quick_start>

1. Generate initial output (design, plan, code, tests).
2. First review: standard code review (syntax, bugs, edge cases).
3. Second review: deeper issues (missed tests, error handling, naming).
4. Third review: architectural concerns (patterns, dependencies, coupling).
5. Fourth+ review: existential questions ("Are we solving the right problem?").
6. Stop when agent converges or 5 passes complete.
   </quick_start>

<when_to_apply>
| Context | Recommended Passes |
|---------|-------------------|
| Trivial changes (typos, small fixes) | 1-2 |
| Standard features | 3 |
| Complex features, unfamiliar stack | 4-5 |
| Critical systems, security-sensitive | 5+ |
</when_to_apply>

<five_pass_phases>
| Pass | Focus | Key Questions |
|------|-------|---------------|
| 1. Generation | Create initial output | Does it compile/run? Basic correctness? |
| 2. Standard Review | Usual code review concerns | Bugs? Edge cases? Test coverage? |
| 3. Deep Review | Non-obvious issues | Error handling? Naming? Duplication? |
| 4. Architecture Review | System-level concerns | Patterns? Dependencies? YAGNI violations? |
| 5. Existential Review | Strategic alignment | Right problem? Right approach? Future-proof? |
</five_pass_phases>

<workflow_index>
| Workflow | Purpose |
|----------|---------|
| convergence-cycle.md | Complete 5-pass review cycle for any artifact |
| design-convergence.md | Apply to design documents and plans |
| code-convergence.md | Apply to implementations |
</workflow_index>

<reference_index>
| Reference | Content |
|-----------|---------|
| review-prompts.md | Escalating prompts for each pass level |
| convergence-signals.md | How to detect when work has converged |
</reference_index>

<constraints>
**Banned:** Single-pass outputs for complex work, skipping review phases, declaring convergence before 3 passes

**Required:**

- Minimum 3 passes for non-trivial work
- Each pass must broaden scope (code → architecture → existential)
- Document findings from each pass
- Declare convergence only when new findings approach zero
  </constraints>

<anti_patterns>
**Common mistakes to avoid:**

- Stopping after first output looks good (premature convergence)
- All passes reviewing at same depth level (no escalation)
- Skipping existential questions ("Are we solving the right problem?")
- Rubber-stamping passes without genuine critique
- Not documenting findings between passes
  </anti_patterns>

<integration>
- Use after `devtools:tdd-typescript` for test quality convergence.
- Apply to design documents and implementation plans.
- Combine with code health audits for systematic quality improvement.
</integration>

<research>
**Find code review patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find code review and quality patterns",
      researchGoal: "Search for review checklist and quality gate patterns",
      reasoning: "Need real-world examples of review workflows",
      keywordsToSearch: ["review", "checklist", "quality-gate"],
      extension: "md",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Review checklists: `keywordsToSearch: ["code-review", "checklist", "guidelines"]`
- Quality gates: `keywordsToSearch: ["quality-gate", "ci", "pre-commit"]`
- Architecture review: `keywordsToSearch: ["ADR", "architecture", "decision"]`
  </research>

<related_skills>

**TDD workflow:** Load via `Skill({ skill: "devtools:tdd-typescript" })` when:

- Applying convergence to test quality
- Iterating on test coverage

**Debugging:** Load via `Skill({ skill: "devtools:troubleshooting" })` when:

- Convergence reveals bugs to investigate
- Root cause analysis needed
  </related_skills>

<success_criteria>

- [ ] Multiple review passes executed (not just generation)
- [ ] Each pass finds progressively fewer issues
- [ ] Final pass produces minimal or no new findings
- [ ] Agent declares convergence or 5 passes complete
- [ ] Output quality measurably higher than single-pass
      </success_criteria>

<evolution>
**Extension Points:**

- Add domain-specific review checklists per pass level
- Create automated convergence detection heuristics
- Integrate with CI for mandatory multi-pass reviews

**Timelessness:** Iterative refinement and self-review are fundamental quality assurance patterns across all engineering disciplines.
</evolution>
