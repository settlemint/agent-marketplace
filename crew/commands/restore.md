---
name: crew:restore
description: Show compacted session state details for the current branch
allowed-tools:
  - Read
  - Bash
---

<objective>
Load and summarize the compacted session state on demand (plan, todos, tasks).
</objective>

<workflow>
1. Resolve current branch and state file:

```bash
BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD)
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
STATE_FILE=".claude/branches/$SAFE_BRANCH/state.json"
```

2. If `STATE_FILE` is missing, report and stop.
3. Read the JSON and summarize:

- Active workflow (if any)
- Plan file path
- Todos (include a TodoWrite array if present)
- Pending tasks and next task
</workflow>

<success_criteria>
- [ ] State file read
- [ ] Summary provided with actionable next step
</success_criteria>
