---
description: Update PR title and body from commits
argument-hint: [PR number, defaults to current branch PR]
allowed-tools: Bash(git:*,gh:*)
---

Update PR title and body to match current commits.

## Current State
- Branch: !`git branch --show-current`
- PR: !`gh pr view --json number,title -q '"\(.number): \(.title)"' 2>/dev/null || echo "No PR"`

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/pr-update.md`.

User message: $ARGUMENTS
