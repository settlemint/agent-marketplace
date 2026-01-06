---
name: crew:git:traverse
description: Sync all stacked branches with parents and remotes
allowed-tools: Bash(git machete:*), Bash(git fetch:*), Bash(git rebase:*), Bash(git push:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

## Purpose

Sync all branches in the git-machete layout with their parents and remote tracking branches. This is the core command for keeping stacked branches in sync.

## Options

| Flag | Effect                                             |
| ---- | -------------------------------------------------- |
| `-W` | `--fetch --whole` - fetch and traverse entire tree |
| `-y` | Auto-confirm all actions                           |
| `-H` | Include GitHub PR retargeting                      |
| `-L` | Include GitLab MR retargeting                      |

## Task

1. **If no machete layout exists**, offer to set one up:

   ```javascript
   AskUserQuestion({
     questions: [
       {
         question: "No git-machete layout found. What would you like to do?",
         header: "Setup",
         options: [
           {
             label: "Discover layout",
             description: "Auto-detect from commit history",
           },
           {
             label: "Create manually",
             description: "Open editor to define layout",
           },
           { label: "Skip", description: "Continue without machete" },
         ],
         multiSelect: false,
       },
     ],
   });
   ```

2. **If machete layout exists**, run traverse:

   ```bash
   # Fetch and sync all branches, auto-confirm
   git machete traverse -W -y
   ```

3. **If GitHub PRs exist**, also retarget:

   ```bash
   git machete traverse -W -y -H
   ```

4. **Report results**:
   - List branches that were rebased
   - List branches that were pushed
   - Flag any that need manual intervention

## Common Workflows

```bash
# Quick sync (fetch + traverse all + auto-confirm)
git machete traverse -W -y

# Sync with GitHub PR retargeting
git machete traverse -W -y -H

# Interactive mode (confirms each action)
git machete traverse -W

# Just sync current branch subtree
git machete traverse
```
