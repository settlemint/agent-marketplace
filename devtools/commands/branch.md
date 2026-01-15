---
description: Create a feature branch with naming convention
argument-hint: [branch description or type/name]
allowed-tools: Bash(git:*), Bash(whoami:*)
---

Create a feature branch following the branch skill guidelines.

## Current State
- Branch: !`git branch --show-current`

## Instructions

Load Skill({ skill: "devtools:branch" })

User message: $ARGUMENTS
