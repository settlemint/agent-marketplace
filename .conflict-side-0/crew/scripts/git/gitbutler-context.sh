#!/usr/bin/env bash
# GitButler context detection script
# Checks if GitButler is active and provides status

set -euo pipefail

# Check if but CLI is available
if ! command -v but &>/dev/null; then
	echo "GITBUTLER_AVAILABLE=false"
	echo "GITBUTLER_ACTIVE=false"
	exit 0
fi

echo "GITBUTLER_AVAILABLE=true"

# Check if GitButler is initialized in this repo
if [[ -d ".git/gitbutler" ]]; then
	echo "GITBUTLER_ACTIVE=true"

	# Get virtual branches
	if branches=$(but branch list 2>/dev/null); then
		echo "VIRTUAL_BRANCHES:"
		echo "$branches" | sed 's/^/  /'
	fi

	# Get base branch status
	if base_status=$(but base check 2>/dev/null); then
		echo "BASE_STATUS:"
		echo "$base_status" | head -5 | sed 's/^/  /'
	fi
else
	echo "GITBUTLER_ACTIVE=false"
fi
