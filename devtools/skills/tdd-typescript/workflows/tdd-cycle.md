# Workflow: TDD Cycle

<required_reading>
**Read these reference files NOW:**

1. references/test-coverage-patterns.md
2. references/test-naming-conventions.md
   </required_reading>

<overview>
The TDD cycle consists of three phases executed sequentially with strict gates. Each feature increment goes through the complete cycle before the next increment begins.
</overview>

<critical_rule>
**ALWAYS use root scripts for test execution.**

- **NEVER** run `vitest`, `bunx vitest`, or `bun test` directly
- **NEVER** `cd` into a package directory to run tests
- **ALWAYS** run `bun run test` from the repository root

This ensures correct Turborepo dependency ordering, environment setup, and caching.
</critical_rule>

<process>

<phase name="red" color="RED">
**Goal:** Write a failing test that defines expected behavior

<steps>
1. **Understand the requirement** — What behavior needs to exist?
2. **Define the public API** — What will the caller see? (function signature, return type, error conditions)
3. **Write ONE test** — Start with the simplest case (happy path or most basic input)
4. **Run the test** — Confirm it FAILS (compilation error or assertion failure)
</steps>

<test_selection>
For the FIRST test of a feature, choose:

- The simplest valid input case (happy path baseline)
- A single responsibility (one assertion focus)

Subsequent tests add complexity:

- Edge cases (empty, null, boundary values)
- Error conditions (invalid input, failure states)
- State transitions (if applicable)
  </test_selection>

<verification>
```bash
# ALWAYS run from repository root using root scripts
bun run test -- --run -t "test name pattern"
```

**Gate:** Test MUST fail. If it passes, either:

- The feature already exists (no work needed)
- The test is wrong (fix the test)

Do NOT proceed until you see a FAILING test.
</verification>
</phase>

<phase name="green" color="GREEN">
**Goal:** Write MINIMAL code to make the test pass

<steps>
1. **Implement the simplest solution** — Even if it looks naive or hardcoded
2. **Focus on THIS test only** — Ignore future requirements
3. **Run the test** — Confirm it PASSES
</steps>

<constraints>
- Write the LEAST code possible
- Hardcoding is acceptable if it passes the test
- No optimization, no "cleanup", no "while I'm here"
- Do NOT anticipate future tests
</constraints>

<verification>
```bash
# ALWAYS run from repository root using root scripts
bun run test -- --run -t "test name pattern"
```

**Gate:** Test MUST pass. If it fails:

- Debug the implementation (not the test—the test is the spec)
- Add minimal code until it passes

Do NOT proceed until test is GREEN.
</verification>
</phase>

<phase name="refactor" color="REFACTOR">
**Goal:** Improve code quality while keeping tests green

<steps>
1. **Assess the code** — Look for duplication, unclear naming, complex logic
2. **Apply ONE improvement** — Extract function, rename variable, simplify conditional
3. **Run tests** — Confirm they STILL pass
4. **Repeat** — Continue improving until code is clean
</steps>

<refactoring_opportunities>
**Extract when:**

- Logic is duplicated
- Function exceeds single responsibility
- Complex conditionals hide intent

**Rename when:**

- Names don't reveal intent
- Abbreviations obscure meaning

**Simplify when:**

- Nested conditionals exist
- Early returns could flatten logic
  </refactoring_opportunities>

<verification>
```bash
# ALWAYS run from repository root using root scripts
bun run test  # Run all tests via Turborepo
```

**Gate:** ALL tests MUST still pass. If any fail:

- Revert the refactoring
- Try a smaller change

Do NOT proceed to next feature until tests are GREEN and code is clean.
</verification>
</phase>

<cycle_completion>
**After completing one RED-GREEN-REFACTOR cycle:**

1. **Check coverage** — Are there untested edge cases?
2. **Add next test** — Go back to RED phase for next behavior
3. **Repeat** — Continue until feature is complete

Use `references/test-coverage-patterns.md` to ensure comprehensive coverage:

- Happy path
- Negative/failure cases
- Edge/boundary cases
- Error handling
- State transitions (if applicable)
  </cycle_completion>

</process>

<agent_isolation>
**For complex features, spawn isolated agents:**

```
Test Writer Agent (RED phase):
- Tools: Read, Glob, Grep, Write, Edit, Bash
- Skills: devtools:vitest, devtools:tdd-typescript
- Return: Test file path + failure output

Implementer Agent (GREEN phase):
- Tools: Read, Glob, Grep, Write, Edit, Bash
- Return: Modified files + test success output

Refactorer Agent (REFACTOR phase):
- Tools: Read, Glob, Grep, Write, Edit, Bash
- Return: Refactored files + test success output
```

**Why isolation?** The test writer cannot see implementation plans. This prevents designing tests around anticipated code—tests should define behavior independently.
</agent_isolation>

<common_mistakes>
<mistake name="writing_implementation_first">
**Wrong:** "I'll just write this helper function first, then test it"
**Right:** Write the test that needs the helper, then implement
</mistake>

<mistake name="testing_internals">
**Wrong:** Testing private methods or implementation details
**Right:** Test the public contract—inputs and outputs
</mistake>

<mistake name="over_testing">
**Wrong:** Multiple assertions testing the same behavior
**Right:** One test per behavior, one primary assertion
</mistake>

<mistake name="skipping_red">
**Wrong:** Writing tests after implementation "to be safe"
**Right:** Tests MUST fail first—this proves they test something real
</mistake>

<mistake name="big_steps">
**Wrong:** Writing 10 tests, then implementing everything
**Right:** One test → implement → refactor → next test
</mistake>
</common_mistakes>

<success_criteria>
TDD cycle complete for a feature when:

- [ ] Each increment went through RED-GREEN-REFACTOR
- [ ] No implementation code written without failing test first
- [ ] Tests cover happy path, edges, and errors
- [ ] All tests pass
- [ ] Code is clean (no TODOs, no duplication, clear names)
      </success_criteria>
