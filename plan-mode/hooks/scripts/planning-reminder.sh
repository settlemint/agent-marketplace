#!/bin/bash
# Planning phase reminder hook - always allows, provides guidance and skill hints for all plan-mode skills
cat << 'JSON'
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "<system-reminder>\nPLAN MODE SKILLS AVAILABLE:\n\n1. 7-Phase Planning Methodology:\n   Skill({ skill: \"plan-mode:planning-methodology\" })\n\n2. Iterative Context Gathering (explore codebase):\n   Skill({ skill: \"plan-mode:iterative-retrieval\" })\n\nREMINDER: Follow Context → Questions → Spec → Architecture → Tasks → Validation → Documentation\n</system-reminder>"
}
JSON
