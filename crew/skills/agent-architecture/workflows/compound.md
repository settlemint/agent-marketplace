---
name: crew:compound
description: Document a recently solved problem to compound your team's knowledge
argument-hint: "[optional: brief context about the fix]"
---

# Compound Command

Transform ephemeral session learnings into permanent, compounding capabilities.

## Context

<context>$ARGUMENTS</context>

## Workflow

**IMPORTANT:** Execute this workflow directly in the main thread. Do NOT delegate to an orchestrator agent - this preserves native UI components.

### Phase 1: Gather Learnings

First, check for existing learnings from recent sessions:

```bash
# List recent handoffs (PRIMARY SOURCE - most recent first)
ls -t .claude/handoffs/**/*.md 2>/dev/null | head -10

# List recent solutions
ls -t .claude/solutions/**/*.md 2>/dev/null | head -10

# Check git for recent changes
git log --oneline -20 --all
```

**Read handoffs first** - they contain:
- What was done and why
- Decisions made during implementation
- Key patterns discovered
- Context that would otherwise be lost

### Phase 2: Identify What to Compound

```
AskUserQuestion({
  questions: [{
    question: "What should we compound from this session?",
    header: "Source",
    options: [
      {label: "Recent handoffs (Recommended)", description: "Extract patterns from task handoffs"},
      {label: "Problem I solved", description: "Document a fix from this conversation"},
      {label: "Pattern I learned", description: "Capture a reusable technique"},
      {label: "Session learnings", description: "Extract from full session context"}
    ],
    multiSelect: false
  }]
})
```

**If "Recent handoffs" selected:**

1. Read all handoffs from current branch: `.claude/handoffs/$(git branch --show-current | tr '/' '-')/*.md`
2. Extract patterns from "Decisions Made" and "Key Patterns" sections
3. Look for repeated patterns across multiple handoffs

### Phase 3: Extract & Consolidate Patterns

**3a. Build Frequency Table**

For each learning source, extract entries from these sections:

| Section Header  | What to Extract    |
| --------------- | ------------------ |
| `## Root Cause` | Problem patterns   |
| `## Solution`   | Fix patterns       |
| `## Prevention` | Rule candidates    |
| `## Symptoms`   | Detection patterns |

Build a frequency table:

| Pattern                          | Sources | Category    |
| -------------------------------- | ------- | ----------- |
| "Check artifacts before editing" | 3       | debugging   |
| "Pass IDs explicitly"            | 4       | reliability |

**3b. Consolidate Similar Patterns**

Before counting, merge patterns expressing the same principle:

- "Artifact-first debugging" + "Verify hook output" + "Filesystem-first debugging"
- → **"Observe outputs before editing code"**

Use the most general formulation. Update the frequency table.

**3c. Detect Meta-Patterns (Critical Step)**

Look at what the learnings cluster around:

```
If >50% of patterns relate to ONE topic (e.g., "hooks", "testing", "auth"):
  → That topic needs a DEDICATED SKILL rather than multiple rules
  → One skill compounds better than five rules
```

Ask: _"Is there a skill that would make all these rules unnecessary?"_

Examples:

- 5 patterns about hook debugging → Create `debug-hooks` skill
- 4 patterns about test setup → Enhance `*-test` skills
- 3 patterns about API errors → Enhance `api-errors` skill

### Phase 4: Apply Signal Thresholds

| Occurrences | Action                                  |
| ----------- | --------------------------------------- |
| 1           | Note but skip (unless critical failure) |
| 2           | Consider - present to user              |
| 3+          | Strong signal - recommend creation      |
| 4+          | Definitely create                       |

### Phase 5: Categorize via Decision Tree

For each pattern, determine artifact type:

```
Is it a sequence of commands/steps?
  → YES → SKILL (executable > declarative)
  → NO ↓

Should it run automatically on an event?
  → YES → HOOK (automatic > manual)
  → NO ↓

Is it "when X, do Y" or "never do X"?
  → YES → RULE (add to CLAUDE.md or .claude/rules/)
  → NO ↓

Does it enhance an existing agent workflow?
  → YES → AGENT UPDATE
  → NO → SOLUTION (document in .claude/solutions/)
```

**Examples:**

| Pattern                            | Type              | Why               |
| ---------------------------------- | ----------------- | ----------------- |
| "Run linting before commit"        | Hook (PreToolUse) | Automatic gate    |
| "Extract learnings on session end" | Hook (SessionEnd) | Automatic trigger |
| "Debug hooks step by step"         | Skill             | Manual sequence   |
| "Always pass IDs explicitly"       | Rule              | Heuristic         |

### Phase 6: Propose Artifacts (Main Thread - Native UI)

Present each proposal for approval:

```
AskUserQuestion({
  questions: [{
    question: "Create this artifact?",
    header: "Proposal",
    options: [
      {label: "Create it", description: "Add to permanent capabilities"},
      {label: "Skip", description: "Not worth capturing"},
      {label: "Modify first", description: "I want to adjust the content"}
    ],
    multiSelect: false
  }]
})
```

**Proposal Format:**

```markdown
## Pattern: [Generalized Name]

**Signal:** [N] occurrences
**Category:** [debugging / reliability / workflow / etc.]
**Artifact Type:** Rule / Skill / Hook / Agent Update / Solution
**Rationale:** [Why this artifact type, why worth creating]

**Draft Content:**
[Actual content that would be written]

**File:** `.claude/solutions/[cat]/[name].md` or `.claude/skills/[name]/SKILL.md`
```

### Phase 7: Create Approved Artifacts

#### For Solutions (most common):

Create at `.claude/solutions/[category]/[slug].md`:

```markdown
# [Problem Title]

## Symptoms

[What you observed that indicated the problem]

## Root Cause

[The underlying issue]

## Solution

[How it was fixed - include code snippets]

## Post-Mortem

### What Worked

- [Approach that succeeded and why]
- [Tool/pattern that helped]

### What Failed

- Tried: [approach] → Failed because: [reason]
- [Dead ends worth documenting]

### Key Decisions

- Decision: [choice made]
  - Alternatives: [other options considered]
  - Reason: [why this choice]

## Prevention

[How to avoid this in the future]

## Related

- [Links to docs, issues, or other solutions]

## Metadata

- Date: [YYYY-MM-DD]
- Component: [affected area]
```

#### For Rules:

Create `.claude/rules/[name].md` (preferred) or add to `CLAUDE.md`:

```markdown
# Rule Name

[Context: why this rule exists]

## DO

- [Concrete action]

## DON'T

- [Anti-pattern]

## Why

[Rationale - helps future readers understand the rule]

## Source Sessions

- [session-id]: [what happened that led to this rule]
```

#### For Skills:

**IMPORTANT:** Use the heal-skill command to update or create skills:

```javascript
Skill({ skill: "context:heal-skill", args: "[skill-name] [what to add/fix]" });
```

This ensures skills are properly structured and follow conventions.

#### For Hooks:

Create shell script in `.claude/skills/crew/scripts/hooks/[event]/` and register in `.claude/settings.json`.

### Phase 8: Summary & Next Actions

```
AskUserQuestion({
  questions: [{
    question: "Compounding complete. What next?",
    header: "Done",
    options: [
      {label: "View created files", description: "Open the new artifacts"},
      {label: "Commit changes", description: "Stage and commit to git"},
      {label: "Compound more", description: "Extract additional patterns"},
      {label: "Done", description: "All set!"}
    ],
    multiSelect: false
  }]
})
```

**Summary Format:**

```markdown
## Compounding Complete

**Patterns Found:** [M]
**Artifacts Created:** [K]

### Created:

- Solution: `database-issues/n-plus-one-fix.md`
- Rule: Added to CLAUDE.md - "Always check query count"

### Skipped (insufficient signal):

- "Pattern X" (1 occurrence)

**Your setup is now permanently improved.**
```

## Quality Checks

Before creating any artifact:

1. **Is it general enough?** Would it apply in other contexts?
2. **Is it specific enough?** Does it give concrete guidance?
3. **Does it already exist?** Check `.claude/solutions/` and `.claude/` first
4. **Is it the right type?** Sequences → skills, heuristics → rules, fixes → solutions

## Why "Compound"?

Each documented learning compounds team knowledge:

1. First time solving "N+1 query" → Research (30 min)
2. Document the solution → 5 min
3. Next occurrence → Quick lookup (2 min)
4. Pattern becomes rule → Never happens again

## Categories

Solutions are organized into:

- `build-errors/` - Compilation, bundling, dependencies
- `test-failures/` - Test setup, mocking, assertions
- `runtime-errors/` - Exceptions, crashes
- `performance-issues/` - Slow queries, memory leaks
- `database-issues/` - Migrations, queries
- `security-issues/` - Auth, permissions, vulnerabilities
- `ui-bugs/` - Frontend, styling, interactions
- `integration-issues/` - APIs, third-party services
- `contract-issues/` - Solidity, deployment, upgrades
- `workflow-issues/` - CI/CD, hooks, automation

## Usage

```bash
/crew:compound                           # Document most recent learning
/crew:compound Fixed N+1 in briefs      # With context hint
/crew:compound session                  # Extract from full session
```
