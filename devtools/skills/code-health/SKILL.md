---
name: code-health
description: Systematic code health audit for YAGNI, dead code, duplication, and technical debt
license: MIT
triggers:
  - health
  - audit
  - code smell
  - dead code
  - YAGNI
  - duplication
  - tech debt
  - technical debt
  - cleanup
  - refactor.*opportunit
  - find.*issues
  - what.*wrong.*codebase
  - quality.*check
---

<objective>
Conduct a systematic code health audit across 8 dimensions. Identify technical debt, code smells, YAGNI violations, and improvement opportunities. Triage findings by severity (P1/P2/P3) and produce actionable cleanup recommendations.
</objective>

<quick_start>

**Three-phase audit workflow:**

1. **Discover** - Spawn parallel agents to scan each dimension
2. **Triage** - Classify findings by severity (P1/P2/P3)
3. **Report** - Generate actionable cleanup plan

</quick_start>

<constraints>
**Banned:**
- Deleting code without LSP verification (may have dynamic imports)
- Reporting false positives in P1 category (erodes trust)
- Skipping LSP verification for dead code candidates

**Required:**

- Verify dead code with lspFindReferences before removal
- Triage all findings by severity (P1/P2/P3)
- Include actionable fix suggestions for each finding
  </constraints>

<anti_patterns>

- **Text Search Only:** Relying solely on grep to find dead code; misses dynamic imports
- **Over-Abstraction Blindness:** Not recognizing single-use abstractions as YAGNI
- **Coverage Theater:** High line coverage with weak assertions masking real issues
- **Premature Optimization:** Flagging slow code before profiling proves it's a bottleneck
- **Stale Findings:** Reporting issues that were already fixed; re-scan before reporting
  </anti_patterns>

<quick_start_continued>

```bash
# Quick file size check
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20

# Find console.log statements
grep -rn "console\.\(log\|warn\|error\)" --include="*.ts" --include="*.tsx" src/

# Find TODO/FIXME comments
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" src/
```

</quick_start>

<audit_dimensions>

| Dimension            | Detection Pattern                      | Default Severity |
| -------------------- | -------------------------------------- | ---------------- |
| **Large Files**      | >500 lines = P2, >1000 lines = P1      | P1/P2            |
| **Low Coverage**     | Untested code paths, no test file      | P1/P2            |
| **Duplication**      | Redundant systems, copy-pasted code    | P2               |
| **Dead Code**        | Unused exports, unreachable branches   | P2               |
| **YAGNI Violations** | Abstractions used only once            | P3               |
| **Library Gaps**     | Hand-rolled code that libraries solve  | P3               |
| **Misplaced Files**  | Files in wrong directories or misnamed | P3               |
| **Debug Cruft**      | console.log, TODO comments, temp files | P3               |

</audit_dimensions>

<severity_triage>

| Severity | Criteria                                      | Action                |
| -------- | --------------------------------------------- | --------------------- |
| **P1**   | Blocks agents, causes bugs, security risk     | Fix immediately       |
| **P2**   | Slows agents, makes code harder to understand | Fix this sprint       |
| **P3**   | Code smell, minor improvement                 | Fix opportunistically |

**Severity escalation rules:**

- File >1000 lines: P1 (blocks understanding)
- No test coverage on business logic: P1 (risk of regressions)
- Duplicate systems (not just code): P1 (divergence bugs)
- Security-related dead code: P1 (attack surface)
- Everything else follows default severity above

</severity_triage>

<parallel_discovery>

**Launch up to 3 discovery agents to scan different dimensions:**

```javascript
// Agent 1: File structure issues
Task({
  subagent_type: "Explore",
  description: "Find large/misplaced files",
  prompt: `Scan for file structure issues:

    1. LARGE FILES (>500 lines)
       - Count lines per file
       - Identify split points (multiple responsibilities)
       - Severity: >500=P2, >1000=P1

    2. MISPLACED FILES
       - Components outside /components
       - Utilities with side effects
       - Tests not co-located
       - Severity: P3

    Output JSON array: [{file, issue, severity, suggestion}]`,
  run_in_background: true,
});

// Agent 2: Code quality issues
Task({
  subagent_type: "Explore",
  description: "Find dead code and cruft",
  prompt: `Scan for code quality issues:

    1. DEAD CODE
       - Exported functions never imported elsewhere
       - Unreachable switch cases
       - Commented-out code blocks (>5 lines)
       - Severity: P2

    2. DEBUG CRUFT
       - console.log/warn/error (not in logger)
       - TODO/FIXME/HACK comments
       - Disabled tests (.skip, .only)
       - Severity: P3

    Output JSON array: [{file, line, issue, severity, suggestion}]`,
  run_in_background: true,
});

// Agent 3: Architectural issues
Task({
  subagent_type: "Explore",
  description: "Find YAGNI and duplication",
  prompt: `Scan for architectural issues:

    1. YAGNI VIOLATIONS
       - Abstractions with single implementation
       - Config options never varied
       - Generic handlers used once
       - Severity: P3

    2. DUPLICATION
       - Multiple implementations of same concept
       - Copy-pasted code (>10 similar lines)
       - Parallel class hierarchies
       - Severity: P2

    Output JSON array: [{files, issue, severity, consolidation}]`,
  run_in_background: true,
});
```

</parallel_discovery>

<codex_integration>

**Use Codex MCP for deep analysis of complex findings:**

```javascript
// Load Codex for architecture review
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });

// Analyze complex duplication
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze these potentially duplicate systems:

    System A: [file paths and descriptions]
    System B: [file paths and descriptions]

    Questions:
    1. Are these truly duplicates or intentionally separate?
    2. If duplicate, which should be the canonical version?
    3. What's the migration path to consolidate?
    4. What's the risk of consolidation?`,
});

// Analyze YAGNI candidates
mcp__plugin_devtools_codex__codex({
  prompt: `Evaluate if this abstraction is YAGNI:

    [abstraction code]

    Current usages: [list of call sites]

    Questions:
    1. Is this abstraction earning its complexity?
    2. Would inlining improve or hurt readability?
    3. Is there a simpler pattern that achieves the same goal?`,
});
```

</codex_integration>

<detection_patterns>

**Large Files:**

```bash
# Find files over 500 lines
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | awk '$1 > 500' | sort -rn
```

**Dead Exports:**

```bash
# Find exports and check if they're imported
grep -rh "^export " --include="*.ts" src/ | while read export; do
  name=$(echo "$export" | grep -oP '(?<=export (const|function|class|type|interface) )\w+')
  count=$(grep -r "import.*$name" --include="*.ts" src/ | wc -l)
  if [ "$count" -eq 0 ]; then echo "Unused: $name"; fi
done
```

**Debug Cruft:**

```bash
# Console statements
grep -rn "console\.\(log\|warn\|error\|debug\)" --include="*.ts" --include="*.tsx" src/

# TODO comments
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" src/

# Disabled tests
grep -rn "\.skip\|\.only" --include="*.test.ts" --include="*.spec.ts" src/
```

**Duplication (conceptual):**

- Search for similar function names across files
- Look for parallel folder structures
- Check for multiple error handling patterns

**YAGNI Signals:**

- Interface with single implementor
- Config type with only default values used
- Factory function called from one place
- Abstract class with single concrete child

</detection_patterns>

<lsp_for_verification>
**Use LSP to verify dead code before removal:**

Text search can miss dynamic imports, computed references, and re-exports. LSP provides semantic accuracy:

- `lspFindReferences(lineHint)` - Confirm zero usages (not just text search misses)
- `lspCallHierarchy(incoming, lineHint)` - Verify no callers for functions

**Workflow:**

1. Grep to identify candidate dead code → get lineHint
2. `lspFindReferences` → verify truly unused
3. Only then remove code

**CRITICAL:** Always search first to get `lineHint` (1-indexed line number). Never call LSP tools without a lineHint from search results.

**When to use:**

- Before deleting exports → verify no dynamic imports
- Verifying YAGNI candidates → confirm single usage
- Audit confirms dead code → LSP validates before removal

Load LSP skill for detailed patterns: `Skill({ skill: "devtools:typescript-lsp" })`
</lsp_for_verification>

<output_format>

After audit, produce a structured report:

```markdown
# Code Health Report

## Summary

| Severity | Count | Estimated Effort |
| -------- | ----- | ---------------- |
| P1       | N     | X hours          |
| P2       | N     | X hours          |
| P3       | N     | X hours          |

## Critical (P1) - Fix Immediately

1. **[file:line]** - [Issue description]
   - Impact: [Why this blocks work]
   - Fix: [Specific action to take]

## High Priority (P2) - Fix This Sprint

1. **[file:line]** - [Issue description]
   - Impact: [Why this slows work]
   - Fix: [Specific action to take]

## Medium Priority (P3) - Fix Opportunistically

1. **[file:line]** - [Issue description]
   - Fix: [Specific action to take]

## Recommendations

1. Schedule dedicated cleanup session for P1/P2 items
2. Address P3 items when touching related code
3. Re-run audit after cleanup to measure improvement
```

</output_format>

<reference_index>

| Reference               | Content                                    |
| ----------------------- | ------------------------------------------ |
| `detection-patterns.md` | Detailed patterns for each audit dimension |
| `audit-report.md`       | Template for structured audit output       |

</reference_index>

<related_skills>

**Iterative improvement:** Load via `Skill({ skill: "devtools:rule-of-five" })` when:

- Audit finds many issues requiring multiple passes
- Need convergence on complex refactoring

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Low coverage findings need test additions
- Dead code removal needs regression protection

**Git workflow:** Load via `Skill({ skill: "devtools:git" })` when:

- Committing cleanup changes
- Multi-agent environment needs coordination

**Security auditing (Trail of Bits):** Load these for security-focused code health:

- `Skill({ skill: "trailofbits:sharp-edges" })` — Error-prone APIs and dangerous configs
- `Skill({ skill: "trailofbits:static-analysis" })` — CodeQL, Semgrep, SARIF for security scans

</related_skills>

<success_criteria>

- [ ] All 8 audit dimensions scanned
- [ ] Findings triaged by severity (P1/P2/P3)
- [ ] Zero false positives in P1 category
- [ ] Each finding has actionable fix suggestion
- [ ] Report generated with effort estimates
- [ ] TodoWrite populated for tracking fixes
      </success_criteria>

<evolution>
**Extension Points:**
- Add codebase-specific detection patterns via references
- Extend with custom severity rules per project requirements
- Integrate with CI/CD for automated health checks on PRs

**Timelessness:** Code health auditing is essential for maintainable software; the 8-dimension framework applies regardless of language or framework.
</evolution>
