---
description: Create a pull request with smart defaults
argument-hint: [optional PR title]
allowed-tools: Bash(git:*), Bash(gh:*), Read, Glob, Grep
---

Create a pull request following the pr skill guidelines.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Instructions

Load Skill({ skill: "devtools:pr" })

User message: $ARGUMENTS
