#!/bin/bash
# TDD reminder hook - always allows, provides guidance and skill hints for all build-mode skills
cat << 'JSON'
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "<system-reminder>\nBUILD MODE SKILLS AVAILABLE:\n\n1. TDD Implementation (REQUIRED for all code):\n   Skill({ skill: \"build-mode:implementing-code\" })\n\n2. Code Review Patterns (after implementation):\n   Skill({ skill: \"build-mode:reviewing-code\" })\n\n3. Code Health Audit (find dead code, tech debt):\n   Skill({ skill: \"build-mode:improving-code-health\" })\n\n4. AST-based Refactoring (rename, replace patterns):\n   Skill({ skill: \"build-mode:using-ast-grep\" })\n\n5. Iterative Context Gathering (research bugs):\n   Skill({ skill: \"build-mode:iterative-retrieval\" })\n\nREMINDER: Write a failing test FIRST, then implement, then refactor.\n</system-reminder>"
}
JSON
