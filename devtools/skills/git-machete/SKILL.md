---
name: git-machete
description: Git branch management with stacked PRs using git-machete. Simplifies rebase workflows, branch synchronization, and GitHub/GitLab integration. Triggers on stacked, machete, branch stack, dependent branches.
triggers:
  [
    "stacked",
    "machete",
    "branch stack",
    "dependent branches",
    "stacked pr",
    "stacked branch",
  ]
---

<objective>
Manage complex branch hierarchies with git-machete for stacked PR workflows. Provides bird's-eye view of branches, automated rebasing, and GitHub/GitLab integration for maintaining small, focused, easy-to-review pull requests.
</objective>

<essential_principles>
**Branch Layout is the Source of Truth**

The `.git/machete` file defines parent-child relationships between branches. Indentation represents hierarchy:

```text
main
    feature-base
        feature-part-1
        feature-part-2
    another-feature
```

**Status Colors Indicate Sync State**

- **Green edge**: Branch is in sync with parent
- **Red edge**: Branch is out of sync (needs rebase)
- **Gray edge**: Branch is merged into parent

**Rebase Over Merge for Stacks**

Always use rebase (not merge) when syncing stacked branches. Merging creates tangled history that's hard to untangle.

**Merge Order: Top to Bottom**

Merge PRs from top-most (closest to main) first. This prevents big-ball-of-code PRs at the end of the stack.
</essential_principles>

<quick_start>
**Setup a new stack:**

```bash
# Discover existing branches
git machete discover

# Or manually edit layout
git machete edit

# Check current state
git machete status --list-commits
```

**Daily workflow:**

```bash
# Sync all branches with parents and remotes
git machete traverse -W -y

# Create PR using parent from layout as base
git machete github create-pr

# After PR merged, remove branch and rebase children
git machete slide-out --delete
```

**Navigation:**

```bash
git machete go down    # Child branch
git machete go up      # Parent branch
git machete go         # Interactive selection
```

</quick_start>

<intake>
Use the **AskUserQuestion tool** to determine the task:

```
AskUserQuestion:
  header: "Task"
  question: "What do you need help with?"
  options:
    - label: "Setup stacked branches"
      description: "Initialize git-machete and define branch layout"
    - label: "Sync branches"
      description: "Rebase and push branches to sync with parents"
    - label: "Create stacked PRs"
      description: "Create GitHub/GitLab PRs for branch stack"
    - label: "Clean up merged branches"
      description: "Remove merged branches and reconnect children"
    - label: "Install git-machete"
      description: "Install and configure shell completions"
  multiSelect: false
```

</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "setup", "initialize", "layout" | `workflows/setup-stack.md` |
| 2, "sync", "rebase", "update" | `workflows/sync-branches.md` |
| 3, "pr", "pull request", "create" | `workflows/stacked-prs.md` |
| 4, "clean", "merged", "slide-out" | `workflows/cleanup.md` |
| 5, "install", "setup tool" | Execute `scripts/install.sh` |
| other | Clarify, then select |

**After reading the workflow, follow it exactly.**
</routing>

<commands_reference>
**Layout Management:**

- `git machete discover` — Auto-detect branch layout from commit history
- `git machete edit` — Open `.git/machete` in editor
- `git machete add [branch] [--onto parent]` — Add branch to layout
- `git machete status [-l]` — Show branch tree with sync status

**Synchronization:**

- `git machete update` — Rebase current branch onto parent
- `git machete traverse` — Walk through branches, syncing each
- `git machete traverse -W -y` — Fetch, sync all, auto-confirm

**Navigation:**

- `git machete go up/down/prev/next` — Move between branches
- `git machete go` — Interactive branch selection

**GitHub/GitLab:**

- `git machete github create-pr [--draft]` — Create PR with parent as base
- `git machete github checkout-prs --mine` — Checkout your PRs
- `git machete github retarget-pr` — Update PR base to match layout
- `git machete github anno-prs` — Add PR numbers to status

**Cleanup:**

- `git machete slide-out [branch]` — Remove branch, reconnect children
- `git machete advance` — Fast-forward merge child into current
  </commands_reference>

<fork_point>
**Understanding Fork Point**

Git-machete tracks where each branch diverged from its parent. This ensures only unique commits are rebased, avoiding duplicate commits.

```bash
# Check fork point
git machete fork-point [branch]

# Override if detection fails
git machete update --fork-point <commit>
```

**Best Practice:** Don't immediately delete merged branches — their reflogs help determine fork points for other branches.
</fork_point>

<workflows_index>
| Workflow | Purpose |
|----------|---------|
| setup-stack.md | Initialize git-machete and define branch hierarchy |
| sync-branches.md | Rebase and push all branches in stack |
| stacked-prs.md | Create and manage GitHub/GitLab PRs for stack |
| cleanup.md | Remove merged branches and slide out from stack |
</workflows_index>

<success_criteria>

- [ ] git-machete installed and shell completions configured
- [ ] `.git/machete` file defines correct branch hierarchy
- [ ] `git machete status` shows expected branch relationships
- [ ] All branches sync cleanly with `traverse`
- [ ] PRs created with correct base branches
      </success_criteria>
