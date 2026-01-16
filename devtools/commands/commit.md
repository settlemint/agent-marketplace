---
description: Create a conventional commit
argument-hint: [optional commit message]
allowed-tools: Bash(git:*), Read, Glob, Grep
---

Create a commit following conventional commit format.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Staged: !`git diff --cached --stat 2>/dev/null || echo "(none)"`

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/commit.md`.

User message: $ARGUMENTS
