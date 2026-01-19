---
name: review-checklist
description: Interactive code review guidance using the hybrid 3-stage model. Use when reviewing code changes or preparing for commit.
license: MIT
triggers:
  - "review my code"
  - "code review"
  - "review checklist"
  - "prepare for commit"
  - "review before commit"
---

<objective>
Guide through the hybrid 3-stage code review process combining superpowers workflow with specialized review agents. Ensure evidence-based review documentation.
</objective>

<quick_start>
**3-Stage Review Process:**

1. **Stage 1: Spec Compliance** (superpowers)
   - Does implementation match requirements?
   - Are design decisions documented?

2. **Stage 2: Quality Review** (6 specialized agents)
   - Bugs, errors, security, tests, types, comments

3. **Stage 3: Feedback Receiving** (superpowers)
   - Evaluate feedback quality before implementing
</quick_start>

<stage_1>
## Stage 1: Spec Compliance

Load the superpowers skill:
```javascript
Skill({ skill: "superpowers:requesting-code-review" })
```

**Checklist:**
```
□ Implementation matches stated requirements
□ Design decisions are documented
□ Trade-offs are explained
□ Edge cases are addressed
```

**Document:**
```markdown
## Pass 1: Spec Compliance - EVIDENCE
- Requirements met: [list which requirements]
- Design documented: [location of design notes]
- Trade-offs: [what was chosen and why]
```
</stage_1>

<stage_2>
## Stage 2: Quality Review (6 Agents)

Spawn specialized reviewers in parallel:

```javascript
// Always run
Task({
  subagent_type: "pr-review-toolkit:code-reviewer",
  description: "Review for bugs and CLAUDE.md compliance",
  prompt: "Review changes for bugs, logic errors, and CLAUDE.md violations"
})

Task({
  subagent_type: "pr-review-toolkit:silent-failure-hunter",
  description: "Check error handling",
  prompt: "Check for silent failures, inadequate error handling, inappropriate fallbacks"
})

// If tests changed
Task({
  subagent_type: "pr-review-toolkit:pr-test-analyzer",
  description: "Analyze test coverage",
  prompt: "Review test coverage quality and completeness"
})

// If types changed
Task({
  subagent_type: "pr-review-toolkit:type-design-analyzer",
  description: "Review type design",
  prompt: "Analyze type design for encapsulation and invariant expression"
})
```

**Confidence threshold:** Only act on findings with ≥80% confidence.

**Document:**
```markdown
## Pass 2: Quality Review - EVIDENCE
- code-reviewer: [findings or "No issues"]
- silent-failure-hunter: [findings or "No issues"]
- pr-test-analyzer: [findings or "N/A"]
- type-design-analyzer: [findings or "N/A"]
- Fixed: [list of FIXED items with citations]
```
</stage_2>

<stage_3>
## Stage 3: Feedback Receiving

Load the superpowers skill:
```javascript
Skill({ skill: "superpowers:receiving-code-review" })
```

**Evaluate feedback before implementing:**
```
□ Is feedback technically correct?
□ Does it apply to this codebase?
□ Is it high-priority (security, correctness)?
□ Or is it stylistic/preference?
```

**Push back on incorrect suggestions with evidence:**
- Show code citations proving the suggestion is wrong
- Reference documentation or tests
- Explain why current approach is correct

**Timebox:** 5 minutes max per feedback item.

**Document:**
```markdown
## Pass 3: Feedback Evaluation - EVIDENCE
- Feedback received: [count] items
- Implemented: [list]
- Rejected with reason: [list with evidence]
- Converged: [yes/no]
```
</stage_3>

<evidence_markers>
## Evidence Markers (Required)

Your review documentation MUST include evidence markers:

| Marker Type | Example |
|-------------|---------|
| Test output | "✓ Tests pass: 24 tests, 0 failures" |
| Code citation | "src/auth.ts:67" |
| FIXED marker | "FIXED: Missing null check" |
| Tool output | "Codex found: [finding]" |
| Convergence | "Converged: All issues addressed" |

**Minimum requirements:**
- 3 review passes
- 3 evidence markers
- Score ≥6 (passes × evidence)
</evidence_markers>

<quick_review>
## Quick Review (Minimal Changes)

For small changes (<3 files, no critical paths):

```markdown
## Quick Review - EVIDENCE
- Scope: [files changed]
- Tests: ✓ [X] tests pass
- Lint: ✓ No errors
- Type check: ✓ No errors
- Visual check: [what you verified]
```

This satisfies the review requirement for minor changes.
</quick_review>

<integration>
**Related skills:**
- `superpowers:requesting-code-review` - Stage 1 workflow
- `superpowers:receiving-code-review` - Stage 3 workflow
- `devtools:rule-of-five` - Detailed multi-pass review scoring
- `flow:exit-readiness` - Pre-exit checklist
</integration>

<success_criteria>
1. [ ] Stage 1: Spec compliance verified
2. [ ] Stage 2: Quality agents run (or quick review for small changes)
3. [ ] Stage 3: Feedback evaluated
4. [ ] Evidence documented for each pass
5. [ ] Score ≥6 achieved
</success_criteria>
