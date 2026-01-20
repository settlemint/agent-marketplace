#!/bin/bash
# TDD reminder hook - always allows, provides guidance
# Usage: Called by hooks.json as a command hook
cat << 'JSON'
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "TDD REMINDER: Write a failing test FIRST, then implement, then refactor. If you're about to write implementation code without a test, STOP and write the test first."
}
JSON
