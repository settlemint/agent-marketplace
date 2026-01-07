# Workflow: Clean Up Merged Branches

<objective>
Remove merged branches from the stack and reconnect child branches to their new parents.
</objective>

<process>
## Step 1: Identify Merged Branches

Check status for gray edges (merged branches):

```bash
git machete status
```

**Gray edge** indicates the branch is merged into its parent.

## Step 2: Slide Out Merged Branch

Remove a merged branch and reconnect its children:

```bash
git machete slide-out <branch-name>
```

**What happens:**

1. Removes branch from `.git/machete`
2. Children are attached to the parent of the removed branch
3. By default, rebases children onto their new parent

**Options:**

```bash
# Don't rebase children (useful for remote merges)
git machete slide-out --no-rebase <branch>

# Also delete the local branch
git machete slide-out --delete <branch>

# Slide out multiple branches
git machete slide-out branch1 branch2 branch3
```

## Step 3: Handle Remote Merges (Squash/Merge Queue)

When PRs are merged remotely via squash or merge queue:

```bash
# 1. Slide out without rebasing
git machete slide-out --no-rebase <merged-branch>

# 2. Sync remaining branches
git machete traverse -W -y -H
```

The traverse will:

- Pull fresh main/master
- Rebase children onto new parent
- Retarget remaining PRs (`-H` flag)

## Step 4: Automatic Merge Detection

Enable squash merge detection:

```bash
# Simple detection (faster)
git config machete.squashMergeDetection simple

# Exact detection (slower but more precise)
git config machete.squashMergeDetection exact
```

With detection enabled, traverse suggests slide-out for merged branches.

## Step 5: Fast-Forward Merge with Advance

To merge a child into the current branch (fast-forward):

```bash
git machete advance
```

This is useful when:

- You're on a parent branch
- Child is ready to merge
- You want a linear history

**After advance:**

- Child branch is merged into current
- Child is slid out of layout
- Next child (if any) becomes the new child

## Step 6: Delete Stale Branches

After sliding out, delete local branches:

```bash
# Delete specific branch
git branch -d <branch-name>

# Or use slide-out with --delete
git machete slide-out --delete <branch>

# Prune remote tracking branches
git fetch --prune
```

## Step 7: Verify Clean State

Check the layout is correct:

```bash
git machete status --list-commits
```

Ensure:

- No orphaned branches
- All remaining branches have correct parents
- No gray edges (unless intentional)
  </process>

<slide_out_examples>
**Before slide-out:**

```text
main
    feature-base (merged)
        feature-part-1
        feature-part-2
```

**After `git machete slide-out feature-base`:**

```text
main
    feature-part-1
    feature-part-2
```

Children `feature-part-1` and `feature-part-2` are now direct children of `main`.
</slide_out_examples>

<common_scenarios>
**Scenario: PR merged via GitHub squash:**

```bash
git machete slide-out --no-rebase feature-x
git machete traverse -W -y
```

Or using crew commands:

```javascript
Skill({ skill: "crew:git:slide-out" });
Skill({ skill: "crew:git:traverse" });
```

**Scenario: Multiple branches merged:**

```bash
git machete slide-out branch1 branch2 branch3 --no-rebase
git machete traverse -W -y
```

**Scenario: Want to delete local branch too:**

```bash
git machete slide-out --delete feature-x
```

**Scenario: Delete all unmanaged branches:**

```javascript
Skill({ skill: "crew:git:cleanup-unmanaged" });
```

</common_scenarios>

<related_commands>

| Task                      | Crew Command                                     |
| ------------------------- | ------------------------------------------------ |
| View stack status         | `Skill({ skill: "crew:git:stack-status" })`      |
| Slide out merged branches | `Skill({ skill: "crew:git:slide-out" })`         |
| Sync all branches         | `Skill({ skill: "crew:git:traverse" })`          |
| Delete unmanaged branches | `Skill({ skill: "crew:git:cleanup-unmanaged" })` |
| Clean stale remote refs   | `Skill({ skill: "crew:git:clean" })`             |
| Fast-forward merge child  | `Skill({ skill: "crew:git:advance" })`           |

</related_commands>

<success_criteria>

- [ ] Merged branches removed from layout
- [ ] Children reconnected to correct parents
- [ ] Children rebased onto new parents (or manually synced)
- [ ] Local branches deleted (optional)
- [ ] Remote branches pruned
- [ ] `status` shows clean tree
      </success_criteria>
