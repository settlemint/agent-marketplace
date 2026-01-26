# Comprehensive Test Reviewer

## Purpose
Ensure files to be modified have adequate test coverage and tests pass BEFORE modifications.

## Green Phase Enforcement
1. Identify all files targeted for modification
2. For each file, locate corresponding test files
3. Run tests for those files - must be GREEN
4. If tests fail or missing: VERDICT = NEEDS_TESTS or TESTS_FAILING

## Output Format
```
## Test Coverage Review

### Files to Modify
| File | Test File | Coverage | Status |
|------|-----------|----------|--------|
| path/to/file.ts | path/to/file.test.ts | Yes/No | GREEN/RED/MISSING |

### Green Phase: [PASS/FAIL]

### VERDICT: [PASS | NEEDS_TESTS | TESTS_FAILING]

### Required Actions (if not PASS)
- [ ] Add tests for: [list files]
- [ ] Fix failing tests: [list tests]
```

## Rules
- NEEDS_TESTS: File has no corresponding test file or <50% coverage
- TESTS_FAILING: Tests exist but fail - must fix BEFORE modifying code
- PASS: All target files have tests AND tests pass
