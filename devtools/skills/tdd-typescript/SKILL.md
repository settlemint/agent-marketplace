---
name: tdd-typescript
description: Default test workflow. RED-GREEN-REFACTOR cycle for all new TypeScript code.
triggers:
  - "tdd"
  - "test[- ]first"
  - "red[- ]green"
  - "write.*test"
  - "vitest"
  - "jest"
---

<objective>
Enforce strict TDD for TypeScript changes: tests first, code second, refactor last.
</objective>

<essential_principles>
- Three laws: no production code without a failing test; write only enough test to fail; write only enough code to pass.
- Phase gates: RED must fail, GREEN must pass, REFACTOR must stay green.
- Coverage targets: 80% lines, 75% branches, 90% functions; 100% critical paths (see `references/test-coverage-patterns.md`).
</essential_principles>

<quick_start>
1. Read `workflows/tdd-cycle.md`.
2. RED: write failing test; run `bun run test`.
3. GREEN: minimal implementation to pass.
4. REFACTOR: improve design; keep tests green.
5. Use references for coverage, naming, and test data.
</quick_start>

<workflow_index>
| Workflow | Purpose |
|----------|---------|
| tdd-cycle.md | Complete RED-GREEN-REFACTOR cycle for feature implementation |
</workflow_index>

<reference_index>
| Reference | Content |
|-----------|---------|
| test-coverage-patterns.md | Coverage targets, blocking criteria, priority analysis, test categories |
| test-naming-conventions.md | Naming conventions, test structure patterns |
| test-data-strategies.md | Factories, fixtures, mocks, determinism patterns |
| test-strategy-checklist.md | Phase gates, test pyramid, coverage matrix, anti-patterns |
| project-setup.md | CLAUDE.md instructions and hook configuration for enforcement |
</reference_index>

<integration>
Works with `devtools:vitest` for test syntax and assertions.
</integration>

<success_criteria>
- [ ] RED test fails before implementation
- [ ] GREEN minimal code passes
- [ ] REFACTOR keeps tests green
- [ ] Coverage targets met (see `test-coverage-patterns.md`)
- [ ] Naming and data strategy follow references
</success_criteria>
