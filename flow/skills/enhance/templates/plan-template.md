# Plan Template

Use this template for all implementation plans. Copy to `.claude/plans/<slug>.md`.

## Template

```markdown
---
feature: <feature-name>
author: <branch-author>
created: <ISO-timestamp>
status: draft
files_to_modify:
  - path/to/file1.ts
  - path/to/file2.ts
estimated_complexity: low|medium|high
codex_verified: false
---

# <Feature Title>

## Summary

<1-2 sentence description of what this plan accomplishes>

## User Stories

- As a <user type>, I want <goal>, so that <benefit>
- As a <user type>, I want <goal>, so that <benefit>

## Acceptance Criteria

- Given <context>, when <action>, then <expected outcome>
- Given <context>, when <action>, then <expected outcome>
- Given <context>, when <action>, then <expected outcome>

## Implementation Steps

### Phase 1: <Phase Name>

1. [parallel] <Step description>
   - File: `path/to/file.ts`
   - Evidence: <observable completion criteria>
   - TDD: Write failing test for <behavior> first

2. [parallel] <Step description>
   - File: `path/to/file.ts`
   - Evidence: <observable completion criteria>
   - TDD: Write failing test for <behavior> first

3. [serial] [MERGE-WALL] <Step that requires prior steps>
   - File: `path/to/file.ts`
   - Reason: <why this is a merge wall>
   - Evidence: <observable completion criteria>
   - TDD: Write failing test for <behavior> first

### Phase 2: <Phase Name>

4. [parallel] <Step description>
   ...

## Codex Verification

**Required for plans with >5 files or architectural decisions.**

- [ ] Architecture trade-offs analyzed
- [ ] Security implications reviewed
- [ ] Complexity assessment completed

### Architecture Analysis

<Paste Codex output here after running:>

```javascript
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze this plan:
    [plan summary]

    Evaluate:
    1. Architecture trade-offs
    2. Security implications
    3. Complexity assessment
    4. Potential issues`
});
```

### Security Review

<Paste Codex security review output here>

## Verification

1. Run tests: `bun run test`
2. Run typecheck: `bun run typecheck`
3. Run lint: `bun run lint`
4. Verify evidence for each step

## Open Questions

- [ ] <Any unresolved questions>
```

## Quick Reference

### Parallelization Markers

| Marker | Meaning | Use When |
|--------|---------|----------|
| `[parallel]` | Can run simultaneously | No shared files or resources |
| `[serial]` | Must wait for prior steps | Depends on prior output |
| `[MERGE-WALL]` | Blocks all parallel work | Restructuring, config changes |

### Evidence Types

| Type | Example |
|------|---------|
| Command | `bun run test` exits with code 0 |
| Output | "All 47 tests pass" appears in stdout |
| File state | `src/file.ts` exists and exports `X` |
| Metric | Coverage >= 80% reported |

### Complexity Levels

| Level | Criteria |
|-------|----------|
| low | 1-3 files, single responsibility |
| medium | 4-10 files, cross-cutting concerns |
| high | >10 files, architectural changes |

### Codex Requirements

Plans MUST use Codex when:
- Touching >5 files
- Making architectural decisions
- Involving security-sensitive features
- Requiring complex trade-off analysis
