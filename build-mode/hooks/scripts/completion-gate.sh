#!/usr/bin/env bash
# Completion Gate - Fast pass-through with verification reminder (no LLM call)
set -uo pipefail

INPUT=$(cat)

# Remind about verification before completion
cat <<EOFMSG
{
  "continue": true,
  "systemMessage": "Before completing: Verify tests pass, lint is clean, and CI gates satisfied. Evidence required for all claims."
}
EOFMSG
