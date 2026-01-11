#!/bin/bash
# Get the diff for a PR
# Usage: ./gh-pr-diff.sh [PR_NUMBER] [--files-only]
# If PR_NUMBER is omitted, uses current branch's PR

set -uo pipefail

PR_NUMBER=""
FILES_ONLY=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --files-only)
      FILES_ONLY="true"
      ;;
    *)
      if [[ "$arg" =~ ^[0-9]+$ ]]; then
        PR_NUMBER="$arg"
      fi
      ;;
  esac
done

# Build gh pr diff command
if [ -n "$PR_NUMBER" ]; then
  PR_CMD="gh pr diff $PR_NUMBER"
else
  PR_CMD="gh pr diff"
fi

if [ "$FILES_ONLY" = "true" ]; then
  # Get just the files changed
  if [ -n "$PR_NUMBER" ]; then
    gh pr view "$PR_NUMBER" --json files -q '.files[].path'
  else
    gh pr view --json files -q '.files[].path'
  fi
else
  # Get full diff
  $PR_CMD 2>/dev/null || {
    echo "No PR found or error fetching diff"
    exit 0
  }
fi
