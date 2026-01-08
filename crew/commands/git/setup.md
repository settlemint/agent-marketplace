---
name: crew:git:setup
description: Configure optimal git-machete settings for stacked PRs
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

<objective>
Set up git-machete with optimal configuration for stacked PR workflows.
</objective>

<process>

## Step 1: Check Installation

```bash
if ! command -v git-machete &>/dev/null; then
    echo "git-machete is not installed"
    # Offer installation options
fi
git-machete version
```

If not installed, offer:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "git-machete is not installed. How to install?",
      header: "Install",
      options: [
        {
          label: "Homebrew (Recommended)",
          description: "brew install git-machete",
        },
        { label: "pip", description: "pip install --user git-machete" },
        { label: "Skip", description: "I'll install manually" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Configure Machete Settings

```bash
# PR description intro style - required for update-pr-descriptions --related
git config machete.github.prDescriptionIntroStyle full

# Squash merge detection - detect GitHub squash merges as merged
git config machete.squashMergeDetection simple

# Include full PR URLs in annotations
git config machete.github.annotateWithUrls true

# Extra space before branch name for easier terminal selection
git config machete.status.extraSpaceBeforeBranchName true
```

## Step 3: Configure Git Performance Settings

**Recommended by Git core developers (zero downsides):**

```bash
# Better diff algorithm (histogram vs myers from 1986)
git config --global diff.algorithm histogram

# Highlight moved code in diffs
git config --global diff.colorMoved plain

# Auto-setup remote tracking branches
git config --global push.autoSetupRemote true

# Clean stale remote references on fetch
git config --global fetch.prune true
git config --global fetch.pruneTags true

# Better branch/tag display
git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global tag.sort version:refname
```

**Performance settings for large repositories:**

```javascript
AskUserQuestion({
  questions: [
    {
      question:
        "Enable filesystem monitoring for faster git status? (Recommended for large repos)",
      header: "FSMonitor",
      options: [
        {
          label: "Yes (Recommended for large repos)",
          description: "Enable fsmonitor and untrackedCache",
        },
        {
          label: "No",
          description: "Skip filesystem monitoring",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Yes":

```bash
# Enable filesystem monitoring (runs a background process per repo)
git config core.fsmonitor true

# Cache untracked files for faster status
git config core.untrackedCache true
```

**Additional performance for very large repos:**

```bash
# Enable multi-pack index for faster pack access
git config --global core.multiPackIndex true

# Enable commit graph for faster log/blame
git config --global fetch.writeCommitGraph true

# Enable sparse checkout readiness
git config --global index.sparse true
```

## Step 4: Configure Shell Completions

```bash
SHELL_TYPE=$(basename "$SHELL")
case "$SHELL_TYPE" in
    bash)
        echo 'eval "$(git machete completion bash)"' >> ~/.bashrc
        ;;
    zsh)
        echo 'eval "$(git machete completion zsh)"' >> ~/.zshrc
        ;;
    fish)
        echo 'git machete completion fish | source' >> ~/.config/fish/config.fish
        ;;
esac
```

## Step 5: Initialize Layout (if none exists)

If no `.git/machete` file exists:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No machete layout found. How to initialize?",
      header: "Layout",
      options: [
        {
          label: "Auto-discover (Recommended)",
          description: "Detect branches from git reflog",
        },
        {
          label: "Start fresh",
          description: "Create empty layout, add branches manually",
        },
        { label: "Skip", description: "I'll set it up later" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Auto-discover":

```javascript
Skill({ skill: "crew:git:discover" });
```

## Step 6: Verify Setup

```bash
echo "=== Git Machete Configuration ==="
git config --get-regexp machete 2>/dev/null || echo "(no machete config set)"
echo
echo "=== Layout File ==="
cat .git/machete 2>/dev/null || echo "(no layout file)"
echo
echo "=== Current Status ==="
git machete status 2>/dev/null || echo "(unable to get status)"
```

</process>

<configuration_reference>

**Machete Settings:**

| Setting                                     | Value    | Purpose                               |
| ------------------------------------------- | -------- | ------------------------------------- |
| `machete.github.prDescriptionIntroStyle`    | `full`   | Full PR chain in descriptions         |
| `machete.squashMergeDetection`              | `simple` | Detect squash-merged PRs              |
| `machete.github.annotateWithUrls`           | `true`   | Include PR URLs in branch annotations |
| `machete.status.extraSpaceBeforeBranchName` | `true`   | Easier terminal selection             |
| `machete.traverse.push`                     | `true`   | Auto-push during traverse (optional)  |

**Git Performance Settings (recommended by Git core developers):**

| Setting                  | Value             | Purpose                         |
| ------------------------ | ----------------- | ------------------------------- |
| `diff.algorithm`         | `histogram`       | Better diff output than myers   |
| `diff.colorMoved`        | `plain`           | Highlight moved code            |
| `push.autoSetupRemote`   | `true`            | Auto-setup tracking branches    |
| `fetch.prune`            | `true`            | Clean stale remote refs         |
| `fetch.pruneTags`        | `true`            | Clean stale tag refs            |
| `column.ui`              | `auto`            | Better branch/tag listing       |
| `branch.sort`            | `-committerdate`  | Recent branches first           |
| `tag.sort`               | `version:refname` | Semantic version sorting        |
| `core.fsmonitor`         | `true`            | Faster git status (large repos) |
| `core.untrackedCache`    | `true`            | Cache untracked files           |
| `fetch.writeCommitGraph` | `true`            | Faster log/blame                |

</configuration_reference>

<success_criteria>

- [ ] git-machete installed and accessible
- [ ] Optimal configuration settings applied
- [ ] Shell completions configured (optional)
- [ ] Layout file exists or created
- [ ] `git machete status` runs successfully

</success_criteria>
