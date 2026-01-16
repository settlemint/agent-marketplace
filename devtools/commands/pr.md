---
description: Create a pull request with smart defaults
argument-hint: [optional PR title]
allowed-tools: Bash(git:*), Bash(gh:*), Read, Glob, Grep, AskUserQuestion
---

Create a pull request following the git skill workflow.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Ahead: !`git log origin/main..HEAD --oneline 2>/dev/null | wc -l | tr -d ' '` commits

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/pr-create.md`.

User message: $ARGUMENTS
