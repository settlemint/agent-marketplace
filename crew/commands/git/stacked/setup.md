---
name: crew:git:stacked:setup
description: Configure optimal git-machete settings for stacked PRs
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Stacked branches (git-machete) are not compatible with GitButler virtual branches.

GitButler has its own stacking system. Use these instead:
- `crew:git:butler:status` - View virtual branches
- `crew:git:butler:branch` - Create virtual branch
- `crew:git:butler:sync` - Sync with upstream

To use machete, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with machete commands.

</gitbutler_incompatible>

<objective>

Install git-machete if needed. Configure optimal settings. Initialize layout.

</objective>

<workflow>

## Step 1: Check Installation

```bash
if ! command -v git-machete &>/dev/null; then
    echo "git-machete is not installed"
fi
git-machete version
```

If not installed:

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
git config machete.github.prDescriptionIntroStyle full
git config machete.squashMergeDetection simple
git config machete.github.annotateWithUrls true
git config machete.status.extraSpaceBeforeBranchName true
```

## Step 3: Configure Git Performance (Recommended)

```bash
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global branch.sort -committerdate
```

## Step 4: Initialize Layout (if none exists)

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No machete layout found. How to initialize?",
      header: "Layout",
      options: [
        {
          label: "Auto-discover (Recommended)",
          description: "Detect from git reflog",
        },
        { label: "Start fresh", description: "Empty layout" },
        { label: "Skip", description: "Set up later" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Auto-discover":

```javascript
Skill({ skill: "crew:git:stacked:discover" });
```

## Step 5: Verify

```bash
git config --get-regexp machete 2>/dev/null
git machete status 2>/dev/null
```

</workflow>

<success_criteria>

- [ ] git-machete installed
- [ ] Optimal settings configured
- [ ] Layout initialized
- [ ] `git machete status` runs

</success_criteria>
