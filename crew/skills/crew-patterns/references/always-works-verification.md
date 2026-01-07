<always_works_verification>

<overview>
Implementation verification ensures code actually works, not just appears correct. Pattern matching and logical reasoning are insufficient - only execution proves correctness.
</overview>

<core_philosophy>
<principle name="execution-proves-correctness">
"Should work" ≠ "does work"

Pattern matching isn't enough. You're not paid to write code, you're paid to solve problems. Untested code is just a guess, not a solution.
</principle>

<principle name="user-trust">
Time saved skipping tests: 30 seconds.
Time wasted when it doesn't work: 30 minutes.
User trust lost: Immeasurable.

A user describing a bug for the third time isn't thinking "this AI is trying hard" - they're thinking "why am I wasting time with this incompetent tool?"
</principle>
</core_philosophy>

<thirty_second_reality_check>
**Must answer YES to ALL before claiming completion:**

- [ ] Did I run/build the code?
- [ ] Did I trigger the exact feature I changed?
- [ ] Did I see the expected result with my own observation (including GUI)?
- [ ] Did I check for error messages?
- [ ] Would I bet $100 this works?

If ANY answer is NO, the work is not complete.
</thirty_second_reality_check>

<specific_test_requirements>
<requirement type="ui-changes">
Actually click the button/link/form. Visual inspection of code is not verification.
</requirement>

<requirement type="api-changes">
Make the actual API call. Reading the endpoint code is not verification.
</requirement>

<requirement type="data-changes">
Query the database. Reviewing migration files is not verification.
</requirement>

<requirement type="logic-changes">
Run the specific scenario. Tracing code paths mentally is not verification.
</requirement>

<requirement type="config-changes">
Restart and verify it loads. Checking syntax is not verification.
</requirement>
</specific_test_requirements>

<phrases_to_avoid>
These phrases indicate insufficient verification:

- "This should work now"
- "I've fixed the issue" (especially 2nd+ time)
- "Try it now" (without trying it yourself)
- "The logic is correct so..."
- "Based on the code, this will..."
- "I've updated the file to..."

Replace with:

- "I ran X and observed Y"
- "The test output shows..."
- "I verified by doing X and seeing Y"
- "Build/test passes with output: ..."
  </phrases_to_avoid>

<embarrassment_test>
Before claiming completion, ask:

> "If the user records trying this and it fails, will I feel embarrassed to see their face?"

If yes, do more verification.
</embarrassment_test>

<verification_workflow>
<step order="1">
**Implement the change**
Write the code, make the edit, update the config.
</step>

<step order="2">
**Run the relevant command**
Use `<pattern name="test-runner"/>` for tests, or appropriate verification command.
</step>

<step order="3">
**Observe the actual output**
Read the output. Don't assume success.
</step>

<step order="4">
**Check for errors and warnings**
Scan for ERROR, FAIL, warning, exception, stack traces.
</step>

<step order="5">
**Exercise the specific feature**
If you changed a button, click it. If you changed an API, call it. If you changed logic, trigger that code path.
</step>

<step order="6">
**Report what you observed**
Include actual output, not assumptions. Quote error messages. Reference test results.
</step>
</verification_workflow>

<common_failures>
<failure type="assuming-build-success">
Changed a file but didn't run the build. Syntax errors, import errors, type errors all undetected.

**Fix:** Always run build/typecheck after changes.
</failure>

<failure type="partial-test-run">
Ran tests but didn't notice one test file was skipped or excluded.

**Fix:** Verify all relevant test files executed. Check test count.
</failure>

<failure type="wrong-environment">
Code works locally but fails in CI due to environment differences.

**Fix:** Run CI checks, not just local tests.
</failure>

<failure type="cached-state">
Old build artifacts mask actual errors.

**Fix:** Clean build when uncertain. Verify fresh state.
</failure>

<failure type="visual-regression">
Logic correct but UI broken or misaligned.

**Fix:** For UI changes, actually render and inspect the result.
</failure>
</common_failures>

<integration_with_build>
When `/crew:build` executes tasks:

1. Agents implement changes
2. Test-runner verifies tests pass
3. **Final validation MUST run** - this catches what agents missed
4. Only `<promise>BUILD COMPLETE</promise>` after ALL verification passes

The final validation phase is NON-OPTIONAL. It catches:

- Cross-cutting issues agents couldn't see
- Integration problems between parallel changes
- Environment-specific failures
  </integration_with_build>

<success_criteria>
Verification is complete when:

- [ ] Build passes with zero errors
- [ ] All tests pass (not skipped, not errored)
- [ ] Changed feature exercised and working
- [ ] No new warnings introduced
- [ ] Output/behavior matches expectation
- [ ] User could try this immediately and it would work
      </success_criteria>

</always_works_verification>
