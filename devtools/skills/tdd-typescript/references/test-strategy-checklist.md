# Reference: Test Strategy Checklist

<overview>
Quality cannot be negotiated away. This checklist ensures test strategy is planned upfront, coverage targets are enforced, and phase gates block transitions when criteria aren't met.
</overview>

<philosophy>
**Core principles:**
- Tests are planned and budgeted from day one, not added later
- Coverage targets are minimum requirements, not aspirational goals
- Flaky tests are fixed immediately, not skipped
- Test automation enables continuous delivery
- Every feature has tests BEFORE reaching main branch
</philosophy>

<test_pyramid>
**Test distribution follows the pyramid:**

```
          /‾‾‾‾‾‾‾\
         /   E2E   \        ~10% — Slow, expensive, catch integration issues
        /‾‾‾‾‾‾‾‾‾‾‾\
       / Integration \      ~20% — API contracts, component boundaries
      /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
     /      Unit       \    ~70% — Fast, isolated, high coverage
    /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
```

| Level           | Target            | Speed  | Isolation          | Focus                 |
| --------------- | ----------------- | ------ | ------------------ | --------------------- |
| **Unit**        | 80%+ coverage     | <10ms  | Full (mocked deps) | Business logic, utils |
| **Integration** | All API endpoints | <500ms | Partial (real DB)  | Contracts, boundaries |
| **E2E**         | Critical paths    | <5s    | None (full stack)  | User journeys         |

</test_pyramid>

<coverage_matrix>
**Test coverage by level:**

| Test Level  | Coverage Target         | Blocking | Owner        | Automation  |
| ----------- | ----------------------- | -------- | ------------ | ----------- |
| Unit        | 80% lines, 75% branches | PR merge | Developer    | CI-required |
| Integration | 100% API endpoints      | PR merge | Developer    | CI-required |
| E2E         | 100% critical paths     | Release  | QA/Developer | CI-required |
| Performance | Baseline established    | Release  | Developer    | Scheduled   |
| Security    | OWASP Top 10            | Release  | Security     | Scheduled   |

**What counts as "critical path":**

- Authentication and authorization flows
- Payment and checkout processes
- Data mutation operations (create, update, delete)
- Core business workflows
  </coverage_matrix>

<phase_gates>
**Quality gates block phase transitions when criteria aren't met.**

<gate name="pre_implementation">
**Before Writing Code:**
- [ ] Requirements have acceptance criteria
- [ ] Test cases identified for each acceptance criterion
- [ ] Edge cases and error scenarios documented
- [ ] Test data strategy chosen (factories vs fixtures)
</gate>

<gate name="pr_merge">
**Before PR Can Merge:**
- [ ] All new code has tests (no untested additions)
- [ ] Coverage does not decrease below threshold
- [ ] All tests pass (no skipped tests)
- [ ] No flaky tests (100% pass rate over 3 runs)
- [ ] Integration tests pass
- [ ] Lint and type checks pass
</gate>

<gate name="release">
**Before Release:**
- [ ] All coverage targets met
- [ ] E2E tests pass for all critical paths
- [ ] No critical/high severity bugs open
- [ ] Performance baseline validated
- [ ] Security scan passed
- [ ] Regression suite 100% passing
</gate>
</phase_gates>

<test_scenarios_checklist>
**For every feature, verify these scenarios are tested:**

<category name="functional">
**Functional Tests:**
- [ ] Normal/happy path operation
- [ ] Multiple valid input variations
- [ ] Expected output format and structure
</category>

<category name="validation">
**Input Validation:**
- [ ] Required fields missing
- [ ] Invalid data types
- [ ] Out-of-range values
- [ ] Malformed input (XSS, injection attempts)
- [ ] Empty/null/undefined handling
</category>

<category name="boundaries">
**Boundary Tests:**
- [ ] Minimum values
- [ ] Maximum values
- [ ] Off-by-one (n-1, n, n+1)
- [ ] Empty collections
- [ ] Single-item collections
- [ ] Maximum-size collections
</category>

<category name="errors">
**Error Handling:**
- [ ] Expected errors thrown with correct type
- [ ] Error messages are informative
- [ ] Resources cleaned up on failure
- [ ] Partial failures handled gracefully
- [ ] Timeout scenarios
</category>

<category name="state">
**State Management:**
- [ ] Initial state correct
- [ ] Valid state transitions work
- [ ] Invalid state transitions blocked
- [ ] Concurrent modifications handled
- [ ] State persists across sessions (if applicable)
</category>

<category name="integration">
**Integration Points:**
- [ ] API contracts honored
- [ ] External service failures handled
- [ ] Retry logic works correctly
- [ ] Circuit breakers trigger appropriately
</category>

<category name="security">
**Security (where applicable):**
- [ ] Authentication required for protected resources
- [ ] Authorization checked for operations
- [ ] Sensitive data not logged
- [ ] Input sanitized
</category>
</test_scenarios_checklist>

<anti_patterns>
**Red flags that indicate test strategy problems:**

| Anti-Pattern                        | Problem                     | Solution                                     |
| ----------------------------------- | --------------------------- | -------------------------------------------- |
| "We'll add tests later"             | Tests never get added       | Tests are part of the feature, not optional  |
| "Coverage targets are aspirational" | Coverage declines over time | Targets are minimum requirements             |
| "Skip tests for this sprint"        | Technical debt accumulates  | Track as explicit debt with remediation plan |
| "Manual testing is sufficient"      | Cannot deliver continuously | Automate what can be automated               |
| "Integration tests are expensive"   | Bugs escape to production   | Integration bugs cost more in production     |
| Skipping flaky tests                | Test suite loses trust      | Fix flaky tests immediately                  |

</anti_patterns>

<blocking_conditions>
**Escalate immediately if:**

- Coverage targets proposed below 80% without documented justification
- Tests marked as "nice to have" instead of required
- Phase transitions happen without test gates
- Flaky tests skipped instead of fixed
- Test automation deprioritized or deferred
- Critical path lacks 100% coverage
  </blocking_conditions>

<success_metrics>
**Test strategy succeeds when:**

- [ ] Every feature has tests before merging
- [ ] Coverage never decreases sprint over sprint
- [ ] No critical bugs escape to production
- [ ] Test execution time enables rapid feedback (<5 min for unit, <15 min for full suite)
- [ ] Developers write tests naturally as part of development
- [ ] Flaky test rate < 1%
      </success_metrics>
