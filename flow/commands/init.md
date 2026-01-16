---
description: Deep codebase analysis with progressive disclosure docs
argument-hint: [--incremental for updates only]
allowed-tools: Bash(git:*), Read, Write, Edit, Glob, Grep, Task
---

Generate modular documentation in `.claude/docs/` following the init-enhanced skill guidelines.

## Current State
- Branch: !`git branch --show-current`
- Docs exist: !`test -d .claude/docs && echo "yes" || echo "no"`
- Meta: !`cat .claude/docs/.meta.json 2>/dev/null | jq -r '.generated // "none"' || echo "none"`

## Instructions

Load Skill({ skill: "flow:init-enhanced" })

Arguments: $ARGUMENTS
