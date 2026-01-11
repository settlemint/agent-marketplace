---
name: tdd-enforcement
description: Universal TDD enforcement for all code changes. Wraps devtools:tdd-typescript with crew-specific enforcement patterns.
triggers:
  - "implement"
  - "add"
  - "create"
  - "build"
  - "make"
  - "write"
  - "develop"
  - "fix"
  - "change"
  - "update"
  - "modify"
  - "refactor"
  - "new.*feature"
  - "new.*function"
  - "new.*component"
  - "new.*endpoint"
alwaysApply: true
---

<objective>
Enforce Test-Driven Development (TDD) for ALL code changes in the crew workflow. This skill wraps `devtools:tdd-typescript` and ensures no implementation code is written without failing tests first. Applies universally - whether from commands, direct requests, or any other context.
</objective>

<essential_principles>

**TDD is Non-Negotiable**

Every code change follows this sequence:

1. **TEST FIRST** - Write the test before ANY implementation
2. **FAIL FIRST** - Run tests, confirm they FAIL (RED phase)
3. **PASS MINIMAL** - Write minimum code to pass (GREEN phase)
4. **REFACTOR SAFELY** - Improve while keeping tests green

**The Three Laws of TDD**

1. Write NO production code until a failing test exists
2. Write ONLY enough test to demonstrate failure
3. Write ONLY enough code to pass the test

**Coverage Requirements (Non-Negotiable)**

| Metric            | Minimum | Critical Paths |
| ----------------- | ------- | -------------- |
| Line coverage     | 80%     | 100%           |
| Branch coverage   | 75%     | 100%           |
| Function coverage | 90%     | 100%           |

Critical paths include: authentication, authorization, payments, data persistence.

</essential_principles>

<quick_start>

**For ANY code change, immediately load the full TDD workflow:**

```javascript
Skill({ skill: "devtools:tdd-typescript" });
```

Then follow the complete RED-GREEN-REFACTOR cycle defined there.

**Enforcement Points in Crew**

1. **UserPromptSubmit Hook** - Fires on any code-related request
2. **PreToolUse Hook** - Fires before Edit/MultiEdit/Write
3. **crew:work Command** - Mandates TDD skill at Step 0
4. **Ralph Loop** - Requires TDD skill at each iteration

**No Escape Routes**

- Direct code requests → TDD enforced via hooks
- Commands → TDD enforced in workflow
- Agent tasks → TDD enforced via skill requirements
- Manual edits → TDD enforced via PreToolUse hook

</quick_start>

<workflow>

## Universal TDD Workflow

### 1. Understand Before Testing

Read existing code to understand:

- Current behavior
- API contracts
- Edge cases to cover

### 2. Write Failing Test (RED)

```bash
# Create test file if needed
touch src/__tests__/feature.test.ts

# Write test for desired behavior
# Test should describe WHAT, not HOW
```

### 3. Verify Test Fails

```bash
bun run test
# OR
vitest run
```

**The test MUST fail.** If it passes:

- Feature already exists, or
- Test is wrong

### 4. Write Minimal Implementation (GREEN)

Only enough code to make the test pass. No more.

```bash
# After implementation
bun run test
# Must pass
```

### 5. Refactor (REFACTOR)

Improve code quality while keeping tests green:

- Extract methods
- Rename for clarity
- Remove duplication
- Improve performance

```bash
# After refactoring
bun run test
# Must still pass
```

### 6. Check Coverage

```bash
bun run test --coverage
```

Verify coverage requirements are met.

</workflow>

<integration>

**Works With:**

- `devtools:tdd-typescript` - Full TDD workflow and phase gates
- `devtools:vitest` - Test syntax and assertions
- `crew:work` - Execution workflow with TDD mandatory
- `crew:work:ci` - CI checks for test failures
- `crew:work:review` - Quality review includes test coverage

**Command Integration:**

All crew commands that touch code reference this skill or `devtools:tdd-typescript`:

| Command          | TDD Integration                |
| ---------------- | ------------------------------ |
| crew:work        | Step 0: Mandatory skill load   |
| crew:plan        | No code allowed, TDD N/A       |
| crew:work:review | Coverage in quality criteria   |
| crew:work:ci     | Test failures block completion |

</integration>

<success_criteria>

TDD enforcement is successful when:

- [ ] Test written BEFORE any implementation code
- [ ] Test verified to FAIL before implementation
- [ ] Minimal code written to pass test
- [ ] Tests pass after implementation
- [ ] Refactoring keeps tests green
- [ ] Coverage meets requirements (80%+ lines, 75%+ branches, 90%+ functions)
- [ ] Critical paths have 100% coverage
- [ ] No untested code in production

</success_criteria>
