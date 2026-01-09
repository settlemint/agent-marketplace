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

The machete file defines parent-child relationships between branches. Indentation represents hierarchy:

```text
main
    feature-base
        feature-part-1
        feature-part-2
    another-feature
```

**Worktree Support**

In worktrees, the machete file is in the main repo's `.git` directory, not the worktree:

```bash
# Get the correct machete file path (works in worktrees too)
machete_file="$(git rev-parse --git-common-dir)/machete"
```

**Status Indicates Sync State**

Visual colors (for humans):

- **Green edge**: Branch is in sync with parent
- **Red edge**: Branch is out of sync (needs rebase)
- **Gray edge**: Branch is merged into parent

Agent-parseable indicators (from `git machete status` output):

- `o-` prefix: in sync with parent (green)
- `x-` prefix: out of sync, needs rebase (red)
- `?-` prefix: untracked/unknown status
- `m-` prefix: branch is merged into parent (gray)

**Rebase Over Merge for Stacks**

Always use rebase (not merge) when syncing stacked branches. Merging creates tangled history that's hard to untangle.

**Merge Order: Top to Bottom**

Merge PRs from top-most (closest to main) first. This prevents big-ball-of-code PRs at the end of the stack.
</essential_principles>

<constraints>

**NEVER use shell redirects to edit the machete file.** The following patterns WILL FAIL:

```bash
# WRONG - these will fail in various shells
cat > .git/machete << 'EOF'
echo "..." > .git/machete
printf '...' >| /path/machete
```

**ALWAYS use the Write tool or git machete edit:**

```bash
# Correct: Use git machete commands
git machete discover           # Auto-detect layout
git machete edit               # Opens in editor
git machete add --onto main    # Add branch to layout

# Or use the Write tool with the correct path
machete_file="$(git rev-parse --git-common-dir)/machete"
# Then use Write tool, not shell redirects
```

</constraints>

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
**Auto-detection heuristics (try before asking):**

```bash
# Check if machete is installed
which git-machete || echo "TASK: install"

# Check if machete file exists
[ -f "$(git rev-parse --git-common-dir)/machete" ] || echo "TASK: setup"

# Check sync status (parse for out-of-sync branches)
git machete status 2>/dev/null | grep -E "^\s+x-" && echo "TASK: sync"

# Check for merged branches
git machete status 2>/dev/null | grep -E "^\s+m-" && echo "TASK: cleanup"

# Check if PRs exist
git machete github anno-prs 2>/dev/null | grep -q "PR #" || echo "TASK: create-prs"
```

**If auto-detection is ambiguous**, use the **AskUserQuestion tool**:

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

<parsing_status_output>
**Parsing `git machete status` output programmatically:**

The status output uses a tree structure with prefixes indicating sync state:

```
  main
  |
  o-feature-base *   # 'o-' = in sync, '*' = current branch
  | |
  | x-feature-part-1 # 'x-' = out of sync (needs rebase)
  | |
  | o-feature-part-2 # 'o-' = in sync
  |
  m-old-feature      # 'm-' = merged into parent
```

**Extract branches needing rebase:**

```bash
git machete status | grep -E "^\s+x-" | sed 's/.*x-//' | cut -d' ' -f1
```

**Extract merged branches (candidates for cleanup):**

```bash
git machete status | grep -E "^\s+m-" | sed 's/.*m-//' | cut -d' ' -f1
```

**Get current branch in stack:**

```bash
git machete status | grep '\*' | sed 's/.*[oxm]-//' | cut -d' ' -f1
```

**Check if any branch needs action:**

```bash
# Returns exit code 0 if all synced, 1 if any need rebase
git machete status | grep -qE "^\s+x-" && echo "Branches need sync" || echo "All synced"
```

**JSON-like structured output:**

```bash
# Get branch relationships as parseable format
git machete show up    # Parent of current branch
git machete show down  # First child of current branch
git machete list-branches # All branches in layout
```

</parsing_status_output>

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

<gotchas>
**Rebase Can Silently Drop Commits**

When rebasing onto a branch that doesn't contain your commits, git may silently drop them if it considers them "already applied" based on patch content. This happens especially when:

- Cherry-picks were made between branches
- Similar changes exist in different commits
- The target branch has commits with overlapping changes

**Recovery Pattern:**

```bash
# Check reflog for the lost commit
git reflog | grep "your commit message"

# Cherry-pick the lost commit back
git cherry-pick <commit-sha>

# Or reset to the pre-rebase state
git reset --hard HEAD@{n}  # n from reflog
```

**Prevention:**

```bash
# Before rebase, note your current commit count
git rev-list --count parent-branch..HEAD

# After rebase, verify same count
git rev-list --count parent-branch..HEAD

# If counts differ, check what was lost
git log --oneline HEAD@{1} --not HEAD
```

**Worktree Safety**

In worktrees, avoid branch-switching commands (`traverse`, `go up/down`) as they defeat the worktree purpose. Safe commands:

- `git machete update` — Rebase current branch only
- `git machete status` — View without switching
- `git machete show up/down` — View parent/child without switching
  </gotchas>

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
