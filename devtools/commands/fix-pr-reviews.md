---
description: Fix all unresolved PR review comments and CI failures
argument-hint: [PR number, defaults to current branch PR]
allowed-tools: Bash(git:*), Bash(gh:*), Read, Edit, Glob, Grep
---

Fix all unresolved PR review comments and CI failures.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`

## PR Info
!`gh pr view --json number,url,title,state 2>/dev/null || echo "No PR found"`

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/pr-fix-reviews.md`.

User message: $ARGUMENTS
