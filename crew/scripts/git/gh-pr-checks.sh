#!/bin/bash
# Get CI check status for a PR
# Usage: ./gh-pr-checks.sh [PR_NUMBER]
# If PR_NUMBER is omitted, uses current branch's PR
# Exits gracefully with message if no PR found (for use in dynamic patterns)

set -uo pipefail

PR_NUMBER="${1:-}"

# Get PR number if not provided
if [ -z "$PR_NUMBER" ]; then
	PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
	if [ -z "$PR_NUMBER" ]; then
		echo "No PR found for current branch"
		exit 0
	fi
fi

# Validate PR number is numeric
if ! [[ $PR_NUMBER =~ ^[0-9]+$ ]]; then
	echo "Error: Invalid PR number"
	exit 1
fi

# Get all checks with their status
# Valid fields: bucket, completedAt, description, event, link, name, startedAt, state, workflow
CHECKS=$(gh pr checks "$PR_NUMBER" --json name,state,link,description,workflow 2>/dev/null)
if [ -z "$CHECKS" ]; then
	echo "No checks found for PR #$PR_NUMBER"
	exit 0
fi

# Count by state
TOTAL=$(echo "$CHECKS" | jq 'length')
FAILED=$(echo "$CHECKS" | jq '[.[] | select(.state == "FAILURE")] | length')
PENDING=$(echo "$CHECKS" | jq '[.[] | select(.state == "PENDING")] | length')
SUCCESS=$(echo "$CHECKS" | jq '[.[] | select(.state == "SUCCESS")] | length')

echo "## CI Checks for PR #$PR_NUMBER"
echo ""
echo "Summary: $SUCCESS passed, $FAILED failed, $PENDING pending (total: $TOTAL)"
echo ""

# Show failed checks with details
if [ "$FAILED" -gt 0 ]; then
	echo "### Failed Checks"
	echo ""
	echo "$CHECKS" | jq -r '.[] | select(.state == "FAILURE") | "- **\(.name)**: \(.description // "No description")\n  Link: \(.link)"'
	echo ""
fi

# Show pending checks
if [ "$PENDING" -gt 0 ]; then
	echo "### Pending Checks"
	echo ""
	echo "$CHECKS" | jq -r '.[] | select(.state == "PENDING") | "- \(.name)"'
	echo ""
fi

# Show success summary (just names, no details)
if [ "$SUCCESS" -gt 0 ]; then
	echo "### Passed Checks"
	echo ""
	echo "$CHECKS" | jq -r '.[] | select(.state == "SUCCESS") | "- \(.name)"' | head -10
	if [ "$SUCCESS" -gt 10 ]; then
		echo "- ... and $((SUCCESS - 10)) more"
	fi
fi
