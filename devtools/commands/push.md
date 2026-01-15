---
description: Push commits to remote with QA check
argument-hint: [--force-with-lease for rebased branches]
allowed-tools: Bash(git:*)
---

Push commits to remote following the push skill guidelines.

## Current State
- Branch: !`git branch --show-current`
- Unpushed: !`git log @{u}..HEAD --oneline 2>/dev/null || echo "No upstream"`

## Instructions

Load Skill({ skill: "devtools:push" })

User message: $ARGUMENTS
