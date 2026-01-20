#!/usr/bin/env bash
# Completion Gate - Fast pass-through with verification reminder (no LLM call)
set -uo pipefail

INPUT=$(cat)

# MANDATORY verification gate before completion
cat <<EOFMSG
{
  "continue": true,
  "systemMessage": "<system-reminder>MANDATORY VERIFICATION GATE: You MUST NOT complete until you have FRESH evidence that: (1) All tests pass, (2) Lint is clean, (3) CI gates satisfied. Run verification commands NOW and include output as evidence. Claims without evidence are violations.</system-reminder>"
}
EOFMSG
