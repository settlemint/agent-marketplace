# Reference: Project Setup for TDD Enforcement

<overview>
This reference documents how to configure your project to enforce TDD workflow. The devtools plugin includes a hook that automatically reminds about TDD when implementation requests are detected.
</overview>

<automatic_enforcement>
**The devtools plugin automatically enforces TDD.**

When you install the devtools plugin, a `UserPromptSubmit` hook activates on prompts containing:

- "implement"
- "add feature"
- "build feature"
- "create functionality"
- "new feature"
- "develop"

The hook injects a reminder about the RED-GREEN-REFACTOR cycle before Claude proceeds.

**No additional configuration needed** — just install the plugin.
</automatic_enforcement>

<claude_md_instructions>
**Recommended: Add to your project's CLAUDE.md for explicit enforcement:**

````markdown
## Test-Driven Development (Required)

All TypeScript code changes MUST follow Test-Driven Development (TDD):

### TDD Workflow (Mandatory)

**For ANY implementation task:**

1. **RED Phase** — Write a failing test FIRST
   - Define expected behavior in test
   - Run `bun run test` to confirm it FAILS
   - Do NOT proceed until test fails

2. **GREEN Phase** — Write minimal code to pass
   - Implement ONLY what's needed to pass
   - No optimization, no "while I'm here"
   - Run `bun run test` to confirm it PASSES

3. **REFACTOR Phase** — Improve while green
   - Clean up code (extract, rename, simplify)
   - Run `bun run test` after EACH change
   - All tests must stay GREEN

### Coverage Requirements

Every implementation must include tests for:

- [ ] Happy path (valid input, expected behavior)
- [ ] Edge cases (empty, null, boundary values)
- [ ] Error handling (invalid input, failure states)
- [ ] State transitions (if applicable)

### Test Execution

**ALWAYS use root scripts:**

- `bun run test` — Run all tests
- `bun run test -- --run -t "pattern"` — Run specific tests
- `bun run ci` — Full CI pipeline (run before completing tasks)

**NEVER** run `vitest`, `bunx vitest`, or `bun test` directly.

### Test Naming Convention

Use `should_<expected>_when_<condition>` pattern:

```typescript
it("should_return_user_when_valid_id_provided");
it("should_throw_NotFound_when_user_does_not_exist");
```
````

### Enforcement

- **NEVER write implementation code without a failing test first**
- **NEVER skip the RED phase** — tests must fail before implementation
- **ALWAYS run tests** after each phase to verify gates

```
</claude_md_instructions>

<verification>
**To verify TDD is being followed:**

1. Check test file timestamps vs implementation timestamps
2. Look for test commits before implementation commits
3. Ensure test coverage metrics don't drop
4. Review that tests cover edge cases, not just happy path

**Signs TDD is NOT being followed:**
- Implementation commits without test commits
- Tests written after implementation (tests that "just work" on first run)
- Tests that mirror implementation instead of specifying behavior
- No edge case coverage
</verification>

<hook_details>
**Hook location:** `devtools/hooks/hooks.json`

**Hook script:** `devtools/scripts/hooks/enforce-tdd.sh`

The hook outputs a `CONTEXT:` message (guidance, not blocking) that reminds Claude to:
1. Load the `superpowers:test-driven-development` skill
2. Follow the RED-GREEN-REFACTOR cycle
3. Never write implementation without a failing test first
</hook_details>
```
