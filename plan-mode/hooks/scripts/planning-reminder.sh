#!/bin/bash
# Planning phase reminder hook - always allows, provides guidance
# Usage: Called by hooks.json as a command hook
cat << 'JSON'
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "PLANNING REMINDER: Follow the 7-phase planning process: Context → Clarifying Questions → Specification → Architecture → Tasks → Validation → Documentation. Use AskUserQuestion for clarifications."
}
JSON
