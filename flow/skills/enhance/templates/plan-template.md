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

## Goal-Oriented Framing

| Question | Answer |
|----------|--------|
| **Who is the user?** | <target user/persona> |
| **What do they need?** | <core requirement> |
| **Why does this matter?** | <value proposition> |
| **What does success look like?** | <measurable outcome> |

## Boundaries

### Always Do (without asking)
- <specific action>
- <specific action>

### Ask First (high-impact decisions)
- <decision needing approval>
- <decision needing approval>

### Never Do (categorically off-limits)
- <prohibited action>
- <prohibited action>

## User Stories

- As a <user type>, I want <goal>, so that <benefit>
- As a <user type>, I want <goal>, so that <benefit>

## Acceptance Criteria

- Given <context>, when <action>, then <expected outcome>
- Given <context>, when <action>, then <expected outcome>
- Given <context>, when <action>, then <expected outcome>

## Kill Criteria

Define conditions that should halt work immediately:

- [ ] Scope expands beyond original brief
- [ ] Blocked by missing dependency for >10 minutes
- [ ] Approach requires architectural changes not in brief
- [ ] Security concern discovered that needs human judgment
- [ ] Tests reveal fundamental design flaw
- [ ] <Add project-specific criteria>

**If any kill criterion triggers:** Stop work, report findings, and request guidance before continuing.

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

## Commands

| Command | Purpose | When to Run |
|---------|---------|-------------|
| `bun run test` | Run test suite | Before every commit |
| `bun run typecheck` | Check TypeScript types | Before commit |
| `bun run lint` | Run linter | Before commit |

## Verification

1. Run tests: `bun run test`
2. Run typecheck: `bun run typecheck`
3. Run lint: `bun run lint`
4. Verify evidence for each step

## Self-Verification Checklist

Before finalizing plan:
- [ ] Goal-oriented framing complete (Who/What/Why/Success)
- [ ] Boundaries defined (Always/Ask/Never)
- [ ] No vague language ("appropriate", "best practices", "as needed")
- [ ] Success criteria are measurable
- [ ] All steps have evidence criteria
- [ ] TDD requirement included for code changes

After implementation, audit:
- [ ] All plan requirements addressed
- [ ] All boundaries respected
- [ ] All success criteria verified

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

### Goal-Oriented Framing

| Question | Purpose |
|----------|---------|
| Who is the user? | Target audience |
| What do they need? | Core requirement |
| Why does this matter? | Value proposition |
| What does success look like? | Measurable criteria |

### Three-Tier Boundary System

| Tier | Symbol | Examples |
|------|--------|----------|
| Always | ✅ | Run tests, follow style guide |
| Ask First | ⚠️ | New deps, schema changes |
| Never | 🚫 | Commit secrets, edit vendor |

### Banned Vague Language

Never use without specific definition:
- "appropriate"
- "best practices"
- "as needed"
- "properly"
- "handle errors"
