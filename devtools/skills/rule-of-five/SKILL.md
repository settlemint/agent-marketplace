---
name: rule-of-five
description: Multi-pass convergence pattern for designs, plans, implementations, and reviews. 5 iterations until quality converges.
triggers:
  - "rule of five"
  - "5[- ]pass"
  - "convergence"
  - "iterative review"
  - "multi[- ]pass"
  - "review.*again"
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

<integration>
- Use after `devtools:tdd-typescript` for test quality convergence.
- Integrate with `/crew:plan` for design convergence.
- Integrate with `/crew:work` for implementation convergence.
- Combine with `/crew:health` for code health audits.
</integration>

<success_criteria>

- [ ] Multiple review passes executed (not just generation)
- [ ] Each pass finds progressively fewer issues
- [ ] Final pass produces minimal or no new findings
- [ ] Agent declares convergence or 5 passes complete
- [ ] Output quality measurably higher than single-pass
      </success_criteria>
