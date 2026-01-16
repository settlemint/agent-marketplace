---
description: Fix all unresolved PR review comments and CI failures
argument-hint: [PR number, defaults to current branch PR]
allowed-tools: Bash(git:*), Bash(gh:*), Read, Edit, Glob, Grep
---

Fix all unresolved PR review comments and CI failures following the fix-pr-reviews skill guidelines.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`
- PR: !`gh pr view --json number,url,title 2>/dev/null | jq -r '"\(.number): \(.title)"' || echo "No PR found"`

## Instructions

Load Skill({ skill: "flow:fix-pr-reviews" })

PR number: $ARGUMENTS
