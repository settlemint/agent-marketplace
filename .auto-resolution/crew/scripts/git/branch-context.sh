#!/usr/bin/env bash
set -euo pipefail

echo "## Current Branch"
echo '```'
git branch --show-current
echo '```'
echo

echo "## Status"
echo '```'
git status --short || echo "(clean)"
echo '```'
echo

echo "## Existing Branches"
echo '```'
git branch --list | head -10
echo '```'
echo

# Warn if dirty
if [[ -n "$(git status --porcelain)" ]]; then
  echo "## ⚠️ UNCOMMITTED CHANGES"
  echo "Commit or stash before creating new branch."
  echo
fi
