---
description: Create a conventional commit
argument-hint: [optional commit message]
allowed-tools: Bash(git:*), Read, Glob, Grep
---

Create a conventional commit following the commit skill guidelines.

## Current State
- Status: !`git status --short`
- Staged: !`git diff --cached --stat`

## Instructions

Load Skill({ skill: "devtools:commit" })

User message: $ARGUMENTS
