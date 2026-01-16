---
description: Create a feature branch with naming convention
argument-hint: [branch description or type/name]
allowed-tools: Bash(git:*), Bash(whoami:*)
---

Create a feature branch with naming convention.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/branch-create.md`.

User message: $ARGUMENTS
