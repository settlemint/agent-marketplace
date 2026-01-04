---
name: crew:handoff
description: Create a handoff document to preserve context for future sessions
argument-hint: "[type: task|triage|session] [brief description]"
---

# Handoff Command

Create a structured handoff document to preserve work context.

## Arguments

<arguments>$ARGUMENTS</arguments>

## Workflow

**IMPORTANT:** Execute directly in main thread for native UI access.

### Phase 1: Determine Handoff Type

Parse arguments or ask:

```
AskUserQuestion({
  questions: [{
    question: "What type of handoff is this?",
    header: "Type",
    options: [
      {label: "Task completion", description: "Finished implementing a task from a plan"},
      {label: "Triage resolution", description: "Fixed issues from code review/todos"},
      {label: "Session end", description: "Capturing context before ending session"},
      {label: "Blocked/Paused", description: "Work paused - need to resume later"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Gather Context

Collect information based on type:

**For Task Completion:**
```bash
# Get current branch and recent changes
git branch --show-current
git diff --stat HEAD~1
git log -1 --format="%s%n%n%b"
```

**For Triage Resolution:**
```bash
# List completed todos
ls .claude/todos/*-complete-*.md 2>/dev/null | tail -5
```

**For Session End:**
```bash
# Get session activity
git log --oneline --since="4 hours ago"
ls -t .claude/branches/*/handoffs/*.md 2>/dev/null | head -5
```

### Phase 3: Create Handoff Directory

```bash
BRANCH=$(git branch --show-current | tr '/' '-')
mkdir -p .claude/branches/$BRANCH/handoffs
```

### Phase 4: Generate Handoff Content

Write to `.claude/branches/${BRANCH}/handoffs/${type}-${timestamp}.md`:

```markdown
---
type: [task|triage|session|blocked]
timestamp: [ISO_DATE]
branch: [branch-name]
status: [completed|blocked|paused]
---

# [Brief Title]

## What Was Done
[Summary of changes made]

## Files Changed
- `path/to/file.ts:123` - [what changed and why]

## Decisions Made
- **[Decision]**: [rationale]
  - Alternatives considered: [options]
  - Why this choice: [reasoning]

## Tests
- [x] Unit tests passing
- [x] Integration tests passing
- [ ] E2E tests (if applicable)

## Learnings (REQUIRED)

### What Worked Well
- [Approach/tool/pattern that succeeded and why]

### What Didn't Work
- Tried: [approach] → Failed because: [reason]
- [Dead ends worth remembering]

### Key Insights
- [Insight that would help future similar work]
- [Non-obvious behavior discovered]
- [Gotcha to remember]

### Patterns to Compound
[Reusable patterns worth extracting into skills/rules - feed into /crew:compound]

## Open Questions
[Unresolved questions for future sessions]

## Next Steps
[What needs to happen next - critical for session recovery]

## Context for Resume
[Essential context if this work is resumed after compaction]
```

### Phase 5: Confirm and Suggest Compound

```
AskUserQuestion({
  questions: [{
    question: "Handoff created. Compound learnings now?",
    header: "Compound",
    options: [
      {label: "Compound now (Recommended)", description: "Extract patterns into permanent knowledge"},
      {label: "Skip compounding", description: "Just save the handoff"},
      {label: "View handoff first", description: "Review before deciding"}
    ],
    multiSelect: false
  }]
})
```

If "Compound now" selected:
```javascript
Skill({ skill: "crew:compound", args: "from handoff" });
```

## Handoff Types

| Type | When to Use | Key Sections |
|------|-------------|--------------|
| `task` | After completing a plan task | Files Changed, Tests, Decisions |
| `triage` | After resolving review comments/todos | Patterns, Prevention |
| `session` | Before ending a work session | Next Steps, Context for Resume |
| `blocked` | When stuck and need to pause | Open Questions, What Was Tried |

## Why Handoffs Matter

1. **Survives compaction** - Context persists on disk
2. **Enables recovery** - Can resume work after context loss
3. **Feeds compounding** - Patterns extracted into permanent knowledge
4. **Team visibility** - Others can understand what was done

## Usage

```bash
/crew:handoff task "Implemented user auth flow"
/crew:handoff triage "Fixed N+1 queries from review"
/crew:handoff session "Ending work on feature X"
/crew:handoff blocked "Stuck on API integration"
```
