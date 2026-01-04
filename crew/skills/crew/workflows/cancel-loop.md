---
name: crew:cancel-loop
description: Cancel an active iteration loop gracefully
argument-hint: "[optional: reason for cancellation]"
---

# Cancel Loop Command

Gracefully stop an active iteration loop with proper handoff.

## Arguments

<arguments>$ARGUMENTS</arguments>

## Workflow

### Phase 1: Check Loop State

```bash
BRANCH=$(git branch --show-current | tr '/' '-')
STATE_FILE=".claude/branches/$BRANCH/state.json"

if [ -f "$STATE_FILE" ]; then
  jq '.loop // "No loop state"' "$STATE_FILE"
else
  echo "No state file found for branch: $BRANCH"
fi
```

### Phase 2: Document Progress

If loop was active, gather what was accomplished:

```bash
# Recent changes during loop
git log --oneline --since="$(jq -r '.loop.startedAt' "$STATE_FILE")"

# Current test status
bun run test 2>&1 | tail -20
```

### Phase 3: Create Partial Handoff

```javascript
Skill({
  skill: "crew:handoff",
  args: `blocked Loop cancelled at iteration ${iteration}/${maxIterations}: ${reason || "User requested stop"}`
});
```

### Phase 4: Clear Loop State

```bash
BRANCH=$(git branch --show-current | tr '/' '-')
STATE_FILE=".claude/branches/$BRANCH/state.json"
# Set loop.active to false instead of deleting
jq '.loop.active = false' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
```

### Phase 5: Confirm Cancellation

Output confirmation:

```
═══════════════════════════════════════════════════════════
LOOP CANCELLED
═══════════════════════════════════════════════════════════

Iteration: {iteration} of {maxIterations}
Reason: {reason}
Handoff: .claude/branches/{branch}/handoffs/blocked-{timestamp}.md
State: .claude/branches/{branch}/state.json (loop.active = false)

The loop has been stopped. You can:
- Resume with: /crew:loop "{original prompt}"
- Review handoff for progress made
- Continue manually from current state

═══════════════════════════════════════════════════════════
```

## When to Cancel

- **Blocked**: External dependency or decision needed
- **Wrong direction**: Approach isn't working after several iterations
- **Scope change**: Requirements changed mid-loop
- **Good enough**: Partial completion is acceptable

## What Gets Preserved

When you cancel:
1. All file changes remain (git tracked)
2. Handoff documents progress and blockers
3. Test results and CI status captured
4. Context for resuming later

## Usage

```bash
# Cancel with reason
/crew:cancel-loop "Need design decision on auth flow"

# Cancel without reason
/crew:cancel-loop

# Cancel and document blockers
/crew:cancel-loop "Blocked on API rate limits - need paid tier"
```
