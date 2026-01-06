#!/usr/bin/env bash
#
# Provides git-machete context for commands
# Outputs machete status if available
#
# NOTE: Supports worktrees - uses git-common-dir for machete file location
#
set -euo pipefail

# Check if git-machete is installed
if ! command -v git-machete &>/dev/null; then
  echo "## Git Machete"
  echo "⚠️ git-machete is not installed."
  echo "Install with: \`brew install git-machete\` or \`pip install git-machete\`"
  echo
  exit 0
fi

# Check if in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "")

# Get the correct machete file path (supports worktrees)
# git-common-dir returns the main .git directory even in worktrees
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
machete_file="${git_common_dir}/machete"

echo "## Git Machete Status"
echo

# Check if machete file exists
if [[ -f "$machete_file" ]]; then
  echo "**Layout file:** \`${machete_file}\`"
  echo

  # Check if current branch is in machete layout
  if git machete is-managed "$branch" 2>/dev/null; then
    echo "**Current branch:** \`$branch\` is in machete layout"

    # Get parent branch
    parent=$(git machete show up 2>/dev/null || echo "")
    if [[ -n "$parent" ]]; then
      echo "**Parent branch:** \`$parent\`"
    else
      echo "**Parent branch:** (root branch)"
    fi

    # Get child branches
    children=$(git machete show down 2>/dev/null || echo "")
    if [[ -n "$children" ]]; then
      echo "**Child branches:** \`$children\`"
    fi

    # Check sync status
    echo
    echo "### Sync Status"
    echo '```'
    git machete status 2>/dev/null | head -20 || echo "(unable to get status)"
    echo '```'

    # Check if out of sync with parent
    if [[ -n "$parent" ]]; then
      if ! git machete is-ancestor "$parent" "$branch" 2>/dev/null; then
        echo
        echo "⚠️ **Out of sync with parent** - consider running \`git machete update\`"
      fi
    fi
  else
    echo "**Current branch:** \`$branch\` is NOT in machete layout"
    echo
    echo "To add to stack: \`git machete add --onto <parent-branch>\`"
    echo
    echo "### Current Layout"
    echo '```'
    cat "$machete_file" 2>/dev/null | head -20 || echo "(unable to read)"
    echo '```'
  fi
else
  echo "**No machete layout** - \`${machete_file}\` does not exist"
  echo
  echo "To set up stacked branches:"
  echo "1. \`git machete discover\` - auto-detect layout"
  echo "2. \`git machete edit\` - manually define layout"
  echo
  echo "**Note:** In worktrees, the machete file is shared with the main repo."
fi

echo
