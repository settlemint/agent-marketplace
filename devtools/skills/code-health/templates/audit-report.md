# Code Health Report

**Project:** [Project Name]
**Date:** [YYYY-MM-DD]
**Auditor:** Claude Code

---

## Summary

| Severity | Count | Estimated Effort |
| -------- | ----- | ---------------- |
| P1       | 0     | 0 hours          |
| P2       | 0     | 0 hours          |
| P3       | 0     | 0 hours          |

**Overall Health Score:** [Good/Fair/Needs Attention]

---

## Critical (P1) - Fix Immediately

> These issues block agent comprehension, cause bugs, or pose security risks.

### 1. [Issue Title]

**File:** `path/to/file.ts:123`
**Category:** [Large File | Low Coverage | Duplication | Dead Code | ...]

**Impact:**

- [Why this blocks work or causes problems]

**Evidence:**

```
[Relevant code or output]
```

**Fix:**

1. [Specific step 1]
2. [Specific step 2]

**Effort:** ~X hours

---

## High Priority (P2) - Fix This Sprint

> These issues slow agent work and make code harder to understand.

### 1. [Issue Title]

**File:** `path/to/file.ts:123`
**Category:** [Category]

**Impact:**

- [Why this slows work]

**Fix:**

- [Action to take]

**Effort:** ~X hours

---

## Medium Priority (P3) - Fix Opportunistically

> These are code smells and minor improvements.

| File              | Category    | Issue                  | Suggested Fix |
| ----------------- | ----------- | ---------------------- | ------------- |
| `path/to/file.ts` | Debug Cruft | console.log on line 45 | Remove        |
| `path/to/file.ts` | YAGNI       | Single-use interface   | Inline        |
| ...               | ...         | ...                    | ...           |

---

## Dimension Summary

| Dimension             | Findings | Top Issue |
| --------------------- | -------- | --------- |
| Large Files           | 0        | -         |
| Low Coverage          | 0        | -         |
| Duplication           | 0        | -         |
| Dead Code             | 0        | -         |
| YAGNI Violations      | 0        | -         |
| Library Opportunities | 0        | -         |
| Misplaced Files       | 0        | -         |
| Debug Cruft           | 0        | -         |

---

## Recommendations

1. **Immediate Actions:**
   - [P1 issue that should be fixed now]

2. **Sprint Planning:**
   - Schedule X hours for P2 cleanup
   - [Specific P2 items to prioritize]

3. **Ongoing Maintenance:**
   - Address P3 items when touching related code
   - Consider adding linting rules to prevent future [issue type]

4. **Re-audit:**
   - Schedule follow-up audit after cleanup
   - Target: Zero P1, <5 P2

---

## Appendix: Raw Findings

<details>
<summary>Large Files (click to expand)</summary>

```
[Raw output from line count analysis]
```

</details>

<details>
<summary>Dead Code Candidates</summary>

```
[Raw output from dead code detection]
```

</details>

<details>
<summary>Debug Cruft</summary>

```
[Raw output from console.log/TODO search]
```

</details>
