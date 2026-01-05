---
name: tdd-typescript
description: Enforces Test-Driven Development workflow for TypeScript code. RED-GREEN-REFACTOR cycle with mandatory test-first approach. Triggers on implement, add feature, build, create functionality.
triggers:
  [
    "implement",
    "add feature",
    "build feature",
    "create functionality",
    "new feature",
    "develop",
  ]
---

<objective>
Enforce strict Test-Driven Development (TDD) workflow for TypeScript implementations. Every code change follows the RED-GREEN-REFACTOR cycle where tests are written BEFORE implementation code. This skill orchestrates the TDD phases and ensures test-first discipline.
</objective>

<essential_principles>
**The TDD Discipline**

TDD is not about testing—it's about design. Writing tests first forces you to think about the API, edge cases, and behavior BEFORE writing implementation code.

**Three Laws of TDD:**

1. Write NO production code until a failing test exists
2. Write ONLY enough test to demonstrate failure
3. Write ONLY enough production code to pass the test

**Context Isolation:**
Each phase (RED, GREEN, REFACTOR) runs with isolated context. The test writer cannot see implementation plans—this ensures genuinely test-first thinking rather than tests designed around anticipated code.

**Phase Gates:**
Do NOT proceed to the next phase until the current phase verification succeeds:

- RED → Test must FAIL before proceeding to GREEN
- GREEN → Test must PASS before proceeding to REFACTOR
- REFACTOR → Tests must STILL PASS after changes
  </essential_principles>

<quick_start>
**For any implementation task:**

1. Read `workflows/tdd-cycle.md` and follow it exactly
2. Use `references/test-coverage-patterns.md` for comprehensive coverage
3. Use `references/test-naming-conventions.md` for consistent naming

**Invoke with:** Any prompt containing "implement", "add feature", "build", or "create functionality"
</quick_start>

<workflow_index>
| Workflow | Purpose |
|----------|---------|
| tdd-cycle.md | Complete RED-GREEN-REFACTOR cycle for feature implementation |
</workflow_index>

<reference_index>
| Reference | Content |
|-----------|---------|
| test-coverage-patterns.md | Test categories, coverage strategies, property-based testing |
| test-naming-conventions.md | Naming conventions, test structure patterns |
| project-setup.md | CLAUDE.md instructions and hook configuration for enforcement |
</reference_index>

<integration>
**Works with:** `devtools:vitest` skill for test syntax and assertions

This skill handles the TDD WORKFLOW (when/what to test). The vitest skill handles TEST SYNTAX (how to write tests). Load both for full coverage.
</integration>

<success_criteria>
TDD workflow complete when:

- [ ] RED: Failing test written BEFORE any implementation
- [ ] GREEN: Minimal code written to pass test
- [ ] REFACTOR: Code improved while tests stay green
- [ ] Coverage: Happy path, edge cases, error handling tested
- [ ] Naming: Tests follow `should_<expected>_when_<condition>` pattern
      </success_criteria>
