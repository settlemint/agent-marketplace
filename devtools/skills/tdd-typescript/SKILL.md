---
name: tdd-typescript
description: TDD TypeScript workflow. Use when asked to "write tests first", "test-driven development", or "red-green-refactor". RED-GREEN-REFACTOR cycle for all new TypeScript code.
license: MIT
triggers:
  - "tdd"
  - "test[- ]?driven"
  - "test[- ]?first"
  - "red[- ]?green"
  - "red.*green.*refactor"
  - "write.*test.*first"
  - "test.*before.*code"
  - "failing.*test.*first"
  - "coverage.*target"
  - "coverage.*80"
  - "coverage.*percent"
  - "increase.*coverage"
  - "improve.*coverage"
  - "test.*coverage"
  - "branch.*coverage"
  - "line.*coverage"
  - "function.*coverage"
  - "three.*laws"
  - "kent.*beck"
  - "refactor.*test"
  - "test.*refactor"
  - "test.*cycle"
  - "test.*workflow"
  - "how.*should.*test"
  - "testing.*strateg"
  - "test.*pattern"
  - "test.*approach"
  - "test.*methodolog"
  - "when.*write.*test"
  - "test.*practice"
  - "best.*practice.*test"
---

<objective>
Enforce strict TDD for TypeScript changes: tests first, code second, refactor last.
</objective>

<essential_principles>

- Three laws: no production code without a failing test; write only enough test to fail; write only enough code to pass.
- Phase gates: RED must fail, GREEN must pass, REFACTOR must stay green.
- Coverage targets: 80% lines, 75% branches, 90% functions; 100% critical paths (see `references/test-coverage-patterns.md`).
  </essential_principles>

<constraints>
**Banned:**
- Writing implementation before a failing test exists
- Tests that pass on first run (proves nothing)
- Skipping RED phase verification
- Over-implementing in GREEN phase
- Refactoring without running tests after each change

**Required:**

- Run test suite and see failure before writing implementation
- Commit after each complete RED-GREEN-REFACTOR cycle
- Coverage gates must pass before PR merge
  </constraints>

<anti_patterns>

- **Test After Development (TAD):** Writing tests after implementation defeats the design benefits of TDD
- **Testing Implementation Details:** Tests coupled to internal structure break on refactoring
- **God Tests:** Single test covering multiple behaviors; split into focused units
- **Flaky Tests:** Non-deterministic tests (time, network, random) erode trust in the suite
- **Coverage Theater:** High coverage with weak assertions; tests that never fail are worthless
  </anti_patterns>

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

<research>
**Find TDD patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find TDD and testing patterns",
      researchGoal: "Search for test-first development patterns",
      reasoning: "Need real-world examples of TDD practices",
      keywordsToSearch: ["describe", "it", "expect", "beforeEach"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Test structure: `keywordsToSearch: ["describe", "it", "test", "vitest"]`
- Coverage: `keywordsToSearch: ["coverage", "c8", "vitest", "threshold"]`
- Mocking: `keywordsToSearch: ["vi.mock", "vi.spyOn", "mockImplementation"]`
  </research>

<enforcement_patterns>

**Hook Integration**

PreToolUse hooks validate TDD on Edit/Write operations:

- Check for test file when editing implementation
- Verify test exists and fails before implementation
- Suggest TDD skill when test-first pattern not followed

**Coverage Gates (Non-Negotiable)**

| Metric            | Minimum | Blocking |
| ----------------- | ------- | -------- |
| Line coverage     | 80%     | Yes      |
| Branch coverage   | 75%     | Yes      |
| Function coverage | 90%     | Yes      |
| Critical paths    | 100%    | Yes      |

**Blocking criteria:**

- PRs MUST NOT merge with coverage below thresholds
- CI fails if coverage decreases
- New code without tests = blocked

**Worker Preamble TDD Block**

Include in every implementation worker:

```
TDD REQUIRED:
1. RED: Write failing test FIRST - run test, MUST see failure
2. GREEN: Write minimal code to pass - no more than needed
3. REFACTOR: Clean while tests pass - run tests after each change

Load: Skill({ skill: "devtools:tdd-typescript" })

CRITICAL:
- You MUST run the test and see it FAIL before writing implementation
- Screenshot/output of failing test is REQUIRED evidence
- "Should work" is NOT acceptable - prove it with test output
```

**Phase Gate Verification**

After each phase, verify:

| Phase    | Verification                   | Required Output         |
| -------- | ------------------------------ | ----------------------- |
| RED      | Test exists and fails          | Error message from test |
| GREEN    | Test passes with minimal code  | "N tests passed"        |
| REFACTOR | Tests still pass after cleanup | "N tests passed"        |

**Common TDD Violations (Anti-patterns)**

| Violation                     | Why It's Wrong                     |
| ----------------------------- | ---------------------------------- |
| Writing implementation first  | Defeats purpose - test fits code   |
| Writing test that passes      | No proof the test catches failures |
| Skipping RED phase            | Can't trust the test               |
| Over-implementing in GREEN    | Adds untested code                 |
| Not running tests in REFACTOR | May break during cleanup           |

</enforcement_patterns>

<plan_mode_integration>

## Plan Mode Integration (ENFORCED)

When creating implementation plans, TDD requirements are **ENFORCED** by the `plan-quality-gate.sh` PreToolUse hook.

### Every Implementation Step Needs TDD

Plans will be blocked from exiting plan mode if implementation steps don't include test requirements:

```markdown
3. [serial] Implement user service
   - File: src/services/user.ts
   - TDD: Write failing test in src/services/user.test.ts FIRST
   - Evidence: Test fails → implementation passes → coverage ≥80%
```

### Touching Untested Files?

If modifying files without existing tests, plan MUST include a test baseline step:

```markdown
0. [serial] Add test coverage for existing code
   - File: src/services/user.test.ts (NEW)
   - TDD: Write tests for existing untested functions
   - Evidence: Coverage baseline established before changes
```

### Delegation Pattern for TDD Analysis

Spawn a TDD Analyzer agent to identify coverage gaps before planning:

```javascript
Task({
  subagent_type: "Explore",
  prompt: "Find untested files in [paths we'll modify]. Return list with current coverage percentages."
})
```

### Plan Validation (Automatic)

The `plan-quality-gate.sh` hook checks:
- Plan has `[serial]` or `[parallel]` markers (implementation steps)
- Plan mentions `test`, `TDD`, `coverage`, `vitest`, or `spec`
- If implementation steps exist without test mentions → **BLOCKED**

### Worker Preambles

When spawning implementation workers from a plan, include:

```
REQUIRED: Load TDD skill first
Skill({ skill: "devtools:tdd-typescript" })

TDD REQUIRED: Write failing test FIRST
- RED: Test exists and FAILS (show error output)
- GREEN: Minimal code to pass (no more than needed)
- REFACTOR: Clean while tests pass

Evidence: Test output showing failure → pass → coverage
```

</plan_mode_integration>

<lsp_for_tdd>
**Use LSP to link tests with implementations:**

LSP tools help navigate between tests and the code they cover:

- `lspGotoDefinition(lineHint)` - Jump from test to implementation under test
- `lspFindReferences(lineHint)` - Find all tests covering a function
- `lspCallHierarchy(incoming, lineHint)` - Trace test coverage paths

**Workflow:**

1. Grep for function name → get lineHint
2. `lspFindReferences` → find test files that import/call it
3. Verify coverage before refactoring

**CRITICAL:** Always search first to get `lineHint` (1-indexed line number). Never call LSP tools without a lineHint from search results.

**When to use:**

- Finding which tests cover a function → `lspFindReferences`
- Navigating from test to implementation → `lspGotoDefinition`
- Understanding test coverage gaps → `lspCallHierarchy`

Load LSP skill for detailed patterns: `Skill({ skill: "devtools:typescript-lsp" })`
</lsp_for_tdd>

<related_skills>

**Vitest syntax:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Writing test assertions
- Setting up mocks

**E2E testing:** Load via `Skill({ skill: "devtools:playwright" })` when:

- Testing user flows
- Integration testing
  </related_skills>

<success_criteria>

1. [ ] RED test fails before implementation
2. [ ] GREEN minimal code passes
3. [ ] REFACTOR keeps tests green
4. [ ] Coverage targets met (see `test-coverage-patterns.md`)
5. [ ] Naming and data strategy follow references
</success_criteria>

<evolution>
**Extension Points:**
- Add domain-specific test patterns via references (e.g., API testing, React components)
- Integrate with CI/CD hooks for automated coverage enforcement
- Extend coverage targets per project requirements

**Timelessness:** TDD's RED-GREEN-REFACTOR cycle is a fundamental software engineering practice that predates and will outlast any specific testing framework.
</evolution>
