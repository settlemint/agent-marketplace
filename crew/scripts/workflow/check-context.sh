#!/usr/bin/env bash
set -euo pipefail

branch=$(git branch --show-current)

echo "## Branch"
echo '```'
echo "$branch"
echo '```'
echo

echo "## Changed Files (vs main)"
echo '```'
git diff main...HEAD --name-only 2>/dev/null || git diff HEAD~5 --name-only 2>/dev/null || echo "(no changes)"
echo '```'
echo

echo "## File Types"
echo '```'
files=$(git diff main...HEAD --name-only 2>/dev/null || git diff HEAD~5 --name-only 2>/dev/null)
if [[ -n "$files" ]]; then
  echo "$files" | sed 's/.*\.//' | sort | uniq -c | sort -rn
else
  echo "(no changes)"
fi
echo '```'
echo

echo "## Recommended Reviewers"
echo '```'
echo "Always: kieran-typescript-reviewer, security-sentinel, code-simplicity-reviewer, architecture-strategist"
# Conditional reviewers based on file types
echo "$files" | grep -qE '\.sol$' && echo "Solidity: solidity-security-auditor"
echo "$files" | grep -qE 'migrations?' && echo "Migrations: data-migration-expert"
echo "$files" | grep -qE '(orpc|api)' && echo "API: data-integrity-guardian"
echo "$files" | grep -qE '\.claude/' && echo "Skills: agent-context-reviewer"
echo '```'
