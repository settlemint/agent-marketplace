<objective>

Complete reference for the GitButler CLI (`but` command). All commands for branch management, committing, pushing, and recovery.

</objective>

<initialization>

```bash
but init                    # Initialize GitButler in repo
but init --target-branch origin/main  # Specify target branch
```

Sets up GitButler tracking and establishes the target branch (production code baseline).

</initialization>

<branch_commands>

**Create and manage virtual branches:**

| Command                   | Description                           |
| ------------------------- | ------------------------------------- |
| `but branch new [NAME]`   | Create branch (auto-named if omitted) |
| `but branch delete NAME`  | Remove branch                         |
| `but branch unapply NAME` | Hide branch without deleting          |
| `but branch list`         | List all virtual branches             |

</branch_commands>

<commit_commands>

**Create commits:**

| Command                   | Description                           |
| ------------------------- | ------------------------------------- |
| `but commit -m "message"` | Commit assigned changes               |
| `but commit --only`       | Commit only explicitly assigned files |
| `but commit`              | AI-generates commit message           |

GitButler auto-generates semantic prefixes (feat:, fix:, refactor:) when using AI message generation.

**Edit commits:**

| Command                     | Description                          |
| --------------------------- | ------------------------------------ |
| `but describe [SHA/BRANCH]` | Edit commit message or rename branch |
| `but new [TARGET]`          | Insert blank commit for splitting    |

</commit_commands>

<rub_command>

The `rub` command combines entities for versatile operations:

| Operation        | Command                   | Result                                   |
| ---------------- | ------------------------- | ---------------------------------------- |
| Amend commit     | `but rub FILE COMMIT`     | Add file to existing commit              |
| Squash           | `but rub COMMIT1 COMMIT2` | Combine commits                          |
| Assign to branch | `but rub FILE BRANCH`     | Move file to branch                      |
| Move commit      | `but rub COMMIT BRANCH`   | Move commit to branch                    |
| Unassign         | `but rub FILE 00`         | Remove assignment (ID `00` = unassigned) |

<examples>

```bash
# Assign file to branch
but rub app/models/user.rb add-user-feature

# Amend last commit with file
but rub config/routes.rb HEAD

# Squash commit into previous
but rub abc123 def456

# Unassign file
but rub app/temp.rb 00
```

</examples>

</rub_command>

<base_commands>

**Manage relationship with upstream:**

| Command           | Description                             |
| ----------------- | --------------------------------------- |
| `but base check`  | View upstream status, integration state |
| `but base update` | Rebase active branches on upstream      |

`but base update` automatically:

- Rebases all virtual branches on latest upstream
- Detects conflicts
- Removes integrated branches

</base_commands>

<push_commands>

**Push to remote:**

| Command                | Description           |
| ---------------------- | --------------------- |
| `but push [BRANCH_ID]` | Push branch to remote |
| `but push --all`       | Push all branches     |

**Gerrit-specific flags:**

| Flag            | Description              |
| --------------- | ------------------------ |
| `--wip`         | Push as work-in-progress |
| `--ready`       | Mark ready for review    |
| `--hashtag TAG` | Add hashtag              |
| `--topic TOPIC` | Set topic                |

</push_commands>

<forge_commands>

**GitHub/GitLab integration:**

| Command                 | Description              |
| ----------------------- | ------------------------ |
| `but forge auth`        | Authenticate with GitHub |
| `but publish [OPTIONS]` | Create PRs for branches  |

</forge_commands>

<recovery_commands>

**Operations log and undo:**

| Command                 | Description                  |
| ----------------------- | ---------------------------- |
| `but oplog`             | Display operation history    |
| `but undo`              | Revert last operation        |
| `but restore SHA`       | Restore to specific snapshot |
| `but snapshot -m "msg"` | Create manual checkpoint     |

<recovery_example>

```bash
# View recent operations
but oplog

# Output shows:
# [abc123] 5 min ago - committed to feature-branch
# [def456] 10 min ago - created branch feature-branch

# Undo last operation
but undo

# Or restore to specific snapshot
but restore def456
```

</recovery_example>

</recovery_commands>

<data_locations>

GitButler stores data in platform-specific locations:

| Platform | Path                                                    |
| -------- | ------------------------------------------------------- |
| macOS    | `~/Library/Application Support/com.gitbutler.app/`      |
| Windows  | `C:\Users\[username]\AppData\Roaming\com.gitbutler.app` |
| Linux    | `~/.local/share/gitbutler-tauri/`                       |

**Git references:**
Virtual branches stored as `refs/gitbutler/[branch-name]`

```bash
# View virtual branch directly
git show refs/gitbutler/feature-branch

# Push virtual branch manually (escape hatch)
git push origin refs/gitbutler/feature:refs/heads/feature
```

</data_locations>

<success_criteria>

- Commands executed without errors
- Virtual branches created and managed
- Changes committed and pushed
- Recovery operations restore expected state

</success_criteria>
