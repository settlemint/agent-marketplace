#!/bin/bash
# Planning phase reminder hook - always allows, provides guidance and skill hints
cat << 'JSON'
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "<system-reminder>\nPLANNING: Follow the 7-phase planning workflow.\n\nFor full planning methodology, invoke:\n  Skill({ skill: \"plan-mode:planning-methodology\" })\n\nFor iterative context gathering:\n  Skill({ skill: \"plan-mode:iterative-retrieval\" })\n</system-reminder>"
}
JSON
