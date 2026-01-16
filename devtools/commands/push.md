---
description: Push commits to remote with QA check
argument-hint: [--force-with-lease for rebased branches]
allowed-tools: Bash(git:*)
---

Push commits to remote with smart QA check.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Unpushed: !`git log @{u}..HEAD --oneline 2>/dev/null || echo "No upstream"`

## Instructions

Load Skill({ skill: "devtools:git" })

Then read and follow `workflows/push.md`.

User message: $ARGUMENTS
