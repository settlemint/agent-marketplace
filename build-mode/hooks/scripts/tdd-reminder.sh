#!/bin/bash
# TDD reminder hook - always allows, provides guidance and skill hints
cat << 'JSON'
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "<system-reminder>\nTDD REMINDER: Write a failing test FIRST, then implement, then refactor.\n\nFor full TDD methodology and subagent orchestration, invoke:\n  Skill({ skill: \"build-mode:implementing-code\" })\n\nFor code review patterns after implementation:\n  Skill({ skill: \"build-mode:reviewing-code\" })\n</system-reminder>"
}
JSON
