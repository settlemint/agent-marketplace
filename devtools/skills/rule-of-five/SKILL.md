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
| **Specs and requirements** | 3-5 |
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

<evidence_based_passes>

## Evidence-Based Review (Proof Over Vibes)

Each pass MUST include **evidence**, not just claims. The bottleneck has shifted from writing code to **proving it works**.

Source: https://addyosmani.com/blog/code-review-ai/

| Pass | Required Evidence |
|------|-------------------|
| Pass 1: Generation | Compilation output, basic test run |
| Pass 2: Standard | Test output (X tests, Y failures), edge case identification |
| Pass 3: Deep | Code trace showing error paths handled |
| Pass 4: Architecture | Comparison with existing patterns, security tool output |
| Pass 5: Convergence | Summary of all findings addressed, final test results |

### Evidence Markers

When documenting passes, include these evidence markers:

```markdown
## Pass 2: Standard Review - EVIDENCE
- ✓ Tests pass: `24 tests, 0 failures`
- ✓ Edge case: Empty input handled at line 42
- Finding: Missing null check at line 67 - FIXED
- Citation: `src/auth.ts:67` - added `if (!user) throw`

## Pass 3: Deep Review - EVIDENCE
- ✓ Error path traced: validateInput() → throws → caught at line 89
- ✓ Code trace: login → validateToken → [success: return user, failure: redirect]
- No new findings - converged
```

### What Counts as Evidence

**Good evidence:**
- Test output with counts: "24 tests, 0 failures"
- Code citations with line numbers: `auth.ts:45-52`
- Execution traces: "A calls B which validates C"
- Tool output: "Codex found no security issues"
- Screenshots of UI behavior
- CI run links

**Not evidence (just claims):**
- "Tests pass" (without output)
- "I reviewed the code" (without findings)
- "Looks good" (without specifics)
- "No issues found" (without what was checked)

### AI-First Review Integration

For code with AI assistance or security-sensitive areas, use the AI-First Review workflow:

```
Skill({ skill: "flow:enhance" })
# Then navigate to workflows/ai-first-review.md
```

This workflow structures AI tools as a first pass, with human verification and accountability.

</evidence_based_passes>

<spec_convergence>

## Spec-Specific Review Passes

Apply Rule of Five to specifications with these focus areas:

| Pass | Focus | Key Questions |
|------|-------|---------------|
| 1. Completeness | Coverage | All six core areas? Goal-oriented framing? |
| 2. Clarity | Precision | Can agent implement with zero questions? |
| 3. Testability | Verification | All success criteria measurable? |
| 4. Boundaries | Safety | Always/Ask/Never defined? No vague language? |
| 5. Strategic | Alignment | Right problem? Right scope? |

## Spec Convergence Signals

**STOP iterating when:**
- All six core areas have specific, actionable content
- An agent could implement without clarifying questions
- Boundaries cover known risks and decisions
- Success criteria are all testable

**CONTINUE iterating when:**
- Any core area is vague or missing
- Success criteria contain subjective language ("works well", "is fast")
- Boundaries don't cover obvious risk areas
- You find yourself saying "they'll figure it out"

## Banned Vague Language

Specs must NEVER contain these terms without definition:
- "appropriate" → specify exact criteria
- "best practices" → name the practice or link standard
- "as needed" → define trigger condition
- "properly" → list specific validations
- "handle errors" → specify: catch X, log Y, return Z

**Load spec-writing skill for detailed guidance:** `Skill({ skill: "devtools:spec-writing" })`

</spec_convergence>

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
| spec-review-prompts.md | Spec-specific review prompts for each pass |
</reference_index>

<constraints>
**Banned:** Single-pass outputs for complex work, skipping review phases, declaring convergence before 3 passes

**Required for code changes (ENFORCED):**

- Minimum 3 documented passes before committing
- Each pass must include **evidence** (not just claims)
- Each pass must broaden scope (code → architecture → existential)
- Document findings from each pass with citations (even if "No findings")
- Commits will be BLOCKED without documented review passes with evidence

**Evidence scoring (used by commit gate):**

- Pass with evidence: 2 points
- Pass without evidence: 0 points (doesn't count)
- Minimum: 3 passes, 3 evidence markers, 6 points total

Note: Passes without evidence markers don't count toward the score.

**Required for all work:**

- Each pass must broaden scope (code → architecture → existential)
- Declare convergence only when new findings approach zero
- Include proof of testing, not just "tests pass"
- Exploration tasks are exempt from commit gates
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

**Stack review checklists:** Load via `Skill({ skill: "devtools:stack-review" })` when:

- Reviewing code in the full-stack blockchain platform
- Need domain-specific checklists (contracts, frontend, subgraph, auth)
- Want access to 353 curated review patterns from top OSS projects

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
