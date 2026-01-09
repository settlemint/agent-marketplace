# Git Machete Hooks Integration

<objective>
Document and provide templates for git-machete custom hooks that integrate with crew workflows.
</objective>

## Available Hooks

Git-machete supports custom hooks executed from the repository root:

| Hook                     | Trigger                           | Arguments                                                 |
| ------------------------ | --------------------------------- | --------------------------------------------------------- |
| `machete-post-slide-out` | After branch removal              | `<new-upstream> <lowest-slid-out> [<new-downstreams>...]` |
| `machete-pre-rebase`     | Before rebase operations          | `<new-base> <fork-point> <branch>`                        |
| `machete-status-branch`  | Per-branch during status/traverse | `<branch-name>`                                           |

## Hook Location

Hooks are placed in `.git/hooks/` with the name matching the hook type.

```bash
.git/hooks/
├── machete-post-slide-out   # Executable script
├── machete-pre-rebase       # Executable script
└── machete-status-branch    # Executable script
```

## Hook Templates

### machete-post-slide-out

Called after a branch is slid out. Use to update PR descriptions or notify team.

```bash
#!/usr/bin/env bash
# .git/hooks/machete-post-slide-out
#
# Arguments:
#   $1 - new upstream branch
#   $2 - lowest slid-out branch
#   $3+ - new downstream branches (children of slid-out)
#
set -euo pipefail

new_upstream="$1"
slid_out="$2"
shift 2
downstreams=("$@")

echo "Branch '$slid_out' was slid out"
echo "New upstream: $new_upstream"
echo "New downstreams: ${downstreams[*]:-none}"

# Update PR descriptions for all related PRs
git config machete.github.prDescriptionIntroStyle full
git machete github update-pr-descriptions --related 2>/dev/null || true

# Optional: Delete the remote branch
# git push origin --delete "$slid_out" 2>/dev/null || true

# Optional: Notify via webhook
# curl -X POST "$SLACK_WEBHOOK" -d "{\"text\": \"Branch $slid_out merged and cleaned up\"}"
```

### machete-pre-rebase

Called before rebase. Use to run checks or prevent rebases on certain branches.

```bash
#!/usr/bin/env bash
# .git/hooks/machete-pre-rebase
#
# Arguments:
#   $1 - new base commit
#   $2 - fork point commit
#   $3 - branch being rebased
#
# Exit non-zero to abort the rebase
#
set -euo pipefail

new_base="$1"
fork_point="$2"
branch="$3"

# Prevent rebase on protected branches
protected_branches=("main" "master" "develop" "release")
for protected in "${protected_branches[@]}"; do
    if [[ "$branch" == "$protected" ]]; then
        echo "ERROR: Cannot rebase protected branch '$branch'"
        exit 1
    fi
done

# Optional: Run linting before rebase
# if ! npm run lint --if-present 2>/dev/null; then
#     echo "WARNING: Lint issues found, but continuing with rebase"
# fi

# Optional: Check for work in progress
if git log --oneline "$fork_point..$branch" | grep -qi "wip\|fixup\|squash"; then
    echo "WARNING: Found WIP/fixup commits that should be cleaned up"
fi

exit 0
```

### machete-status-branch

Called per-branch during `status`, `discover`, and `traverse`. Output is appended to the branch line.

```bash
#!/usr/bin/env bash
# .git/hooks/machete-status-branch
#
# Arguments:
#   $1 - branch name
#
# Output is appended to the status line for this branch
#
set -euo pipefail

branch="$1"

# Show CI status for branches with PRs
pr_number=$(gh pr view "$branch" --json number -q '.number' 2>/dev/null || echo "")
if [[ -n "$pr_number" ]]; then
    # Get CI check status
    checks=$(gh pr checks "$pr_number" 2>/dev/null || echo "")

    if echo "$checks" | grep -q "fail"; then
        echo " ❌"
    elif echo "$checks" | grep -q "pending"; then
        echo " ⏳"
    elif echo "$checks" | grep -q "pass"; then
        echo " ✅"
    fi
fi

# Optional: Show last commit date
# last_commit=$(git log -1 --format="%cr" "$branch" 2>/dev/null || echo "")
# if [[ -n "$last_commit" ]]; then
#     echo " ($last_commit)"
# fi
```

## Installing Hooks

### Manual Installation

```bash
# Create hooks directory if needed
mkdir -p .git/hooks

# Create hook file
cat > .git/hooks/machete-status-branch << 'EOF'
#!/usr/bin/env bash
branch="$1"
pr_number=$(gh pr view "$branch" --json number -q '.number' 2>/dev/null || echo "")
if [[ -n "$pr_number" ]]; then
    checks=$(gh pr checks "$pr_number" 2>/dev/null || echo "")
    if echo "$checks" | grep -q "fail"; then echo " ❌"
    elif echo "$checks" | grep -q "pending"; then echo " ⏳"
    elif echo "$checks" | grep -q "pass"; then echo " ✅"
    fi
fi
EOF

# Make executable
chmod +x .git/hooks/machete-status-branch
```

### Via crew:git:stacked:setup

The `Skill({ skill: "crew:git:stacked:setup" })` command can optionally install these hooks during setup.

## Hook Behavior

- **Non-zero exit** from `machete-pre-rebase` aborts the rebase
- **Non-zero exit** from `machete-post-slide-out` aborts subsequent operations
- **Output** from `machete-status-branch` is appended to the status line
- Hooks run from the **repository root directory**

## Integration with Crew Workflows

### After slide-out, update PRs

The `machete-post-slide-out` hook can automatically trigger:

```bash
# In the hook:
git machete github update-pr-descriptions --related
```

This keeps all PR descriptions updated with the correct stack chain.

### CI status in stack-status

The `machete-status-branch` hook can show CI status:

```
  main
  │
  ├─ feature-auth  PR #45 ✅
  │  │
  │  └─ feature-auth-tests  PR #46 ⏳
  │
  └─ feature-api  PR #47 ❌
```

### Pre-rebase validation

Use `machete-pre-rebase` to:

- Prevent rebasing protected branches
- Run pre-commit checks
- Warn about WIP commits

## Troubleshooting

**Hook not running:**

```bash
# Check hook is executable
ls -la .git/hooks/machete-*

# Check hook syntax
bash -n .git/hooks/machete-status-branch
```

**Hook slowing down status:**

```bash
# Profile the hook
time .git/hooks/machete-status-branch main
```

Consider caching results or making GitHub API calls asynchronous.
