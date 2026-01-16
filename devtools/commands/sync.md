---
description: Sync branch with main and resolve conflicts
argument-hint: [base branch, defaults to main]
allowed-tools: Bash(git:*), Read, Edit
---

Sync branch with main and resolve conflicts.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/sync.md`.

Base branch: $ARGUMENTS
