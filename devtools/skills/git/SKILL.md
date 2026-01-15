---
name: git
description: Git workflows - commits, branches, PRs. Routes to specialized skills based on task.
license: MIT
triggers:
  - "commit"
  - "branch"
  - "\\bpr\\b"
  - "pull request"
  - "push"
  - "sync"
  - "conventional commit"
---

<objective>
Route git tasks to the appropriate specialized skill.
</objective>

<quick_start>

1. **Identify task** — What git operation is needed?
2. **Route to skill** — Use the appropriate slash command or skill
3. **Execute** — The specialized skill handles the details

</quick_start>

<routing>

| Task | Skill | Command |
|------|-------|---------|
| Create commit | `Skill({ skill: "devtools:commit" })` | `/commit` |
| Create branch | `Skill({ skill: "devtools:branch" })` | `/branch` |
| Create PR | `Skill({ skill: "devtools:pr" })` | `/pr` |
| Push to remote | `Skill({ skill: "devtools:push" })` | `/push` |
| Sync with main | `Skill({ skill: "devtools:sync" })` | `/sync` |

</routing>

<quick_reference>

```bash
# Commit
git add <files> && git commit -m "type(scope): description"

# Branch
git checkout -b username/type/slug origin/main

# Push
git push -u origin $(git branch --show-current)

# Sync
git fetch origin main && git merge origin/main

# PR
gh pr create --title "type(scope): description" --body "..."
```

</quick_reference>

<decision_tree>

**What do you want to do?**

- "commit changes" / "save work" → `Skill({ skill: "devtools:commit" })`
- "create branch" / "new feature" → `Skill({ skill: "devtools:branch" })`
- "create PR" / "submit for review" → `Skill({ skill: "devtools:pr" })`
- "push" / "upload commits" → `Skill({ skill: "devtools:push" })`
- "sync" / "merge main" / "rebase" → `Skill({ skill: "devtools:sync" })`

</decision_tree>

<success_criteria>

1. [ ] Identified the correct specialized skill
2. [ ] Routed user to appropriate skill

</success_criteria>
