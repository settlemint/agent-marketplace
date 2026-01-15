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

<routing>

| Task | Skill | Command |
|------|-------|---------|
| Create commit | `devtools:commit` | `/commit` |
| Create branch | `devtools:branch` | `/branch` |
| Create PR | `devtools:pr` | `/pr` |
| Push to remote | `devtools:push` | `/push` |
| Sync with main | `devtools:sync` | `/sync` |

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

- "commit changes" / "save work" → Load `devtools:commit`
- "create branch" / "new feature" → Load `devtools:branch`
- "create PR" / "submit for review" → Load `devtools:pr`
- "push" / "upload commits" → Load `devtools:push`
- "sync" / "merge main" / "rebase" → Load `devtools:sync`

</decision_tree>

<success_criteria>

1. [ ] Identified the correct specialized skill
2. [ ] Routed user to appropriate skill

</success_criteria>
