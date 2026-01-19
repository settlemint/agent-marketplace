#!/usr/bin/env bash
# Get CI check status for PR
# Usage: pr-checks.sh [PR_NUMBER]
set -uo pipefail

PR_NUMBER="${1:-}"

if [[ -z "$PR_NUMBER" ]]; then
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null || true)
  if [[ -z "$PR_NUMBER" ]]; then
    echo "No PR found for current branch"
    exit 0
  fi
fi

CHECKS=$(gh pr checks "$PR_NUMBER" --json name,state,link,description 2>/dev/null)
if [[ -z "$CHECKS" ]]; then
  echo "No checks found for PR #$PR_NUMBER"
  exit 0
fi

TOTAL=$(echo "$CHECKS" | jq 'length')
FAILED=$(echo "$CHECKS" | jq '[.[] | select(.state == "FAILURE")] | length')
PENDING=$(echo "$CHECKS" | jq '[.[] | select(.state == "PENDING")] | length')
SUCCESS=$(echo "$CHECKS" | jq '[.[] | select(.state == "SUCCESS")] | length')

echo "## CI Checks"
echo "Summary: $SUCCESS passed, $FAILED failed, $PENDING pending (total: $TOTAL)"
echo

if [[ "$FAILED" -gt 0 ]]; then
  echo "### Failed"
  echo "$CHECKS" | jq -r '.[] | select(.state == "FAILURE") | "- \(.name): \(.description // "No details")\n  \(.link)"'
  echo
fi

if [[ "$PENDING" -gt 0 ]]; then
  echo "### Pending"
  echo "$CHECKS" | jq -r '.[] | select(.state == "PENDING") | "- \(.name)"'
fi
