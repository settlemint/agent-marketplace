---
name: crew:git:stack-status
description: Show git-machete branch stack status
allowed-tools: Bash(git machete:*), Bash(git branch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

## Purpose

Display the current state of the branch stack, showing parent-child relationships and sync status.

## Status Indicators

- **Green edge**: Branch is in sync with parent
- **Red edge**: Branch is out of sync (needs rebase)
- **Gray edge**: Branch is merged into parent

## Task

1. **If no machete layout**, inform user and offer setup options

2. **Show status with commits**:

   ```bash
   git machete status --list-commits
   ```

3. **Annotate with PR numbers** (if GitHub):

   ```bash
   git machete github anno-prs
   git machete status --list-commits
   ```

4. **Highlight issues**:
   - Branches needing rebase (red edges)
   - Merged branches that can be slid out (gray edges)
   - Branches without PRs

## Quick Commands

```bash
# Basic status
git machete status

# With commit list
git machete status --list-commits
git machete status -l

# Add PR annotations
git machete github anno-prs
```
