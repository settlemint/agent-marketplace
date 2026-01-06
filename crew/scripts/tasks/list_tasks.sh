#!/usr/bin/env bash
# List tasks for current branch with status summary
#
# Usage: list_tasks.sh [branch]
#   If branch not specified, uses current git branch (slugified).
#
# Output: Task files grouped by status with counts

set -euo pipefail

branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
slug="${branch//\//-}"
tasks_dir=".claude/branches/${slug}/tasks"

if [[ ! -d "$tasks_dir" ]]; then
	echo "No tasks directory: $tasks_dir"
	exit 0
fi

# Count tasks by status
pending=$(find "$tasks_dir" -name '*-pending-*.md' 2>/dev/null | wc -l | tr -d ' ')
in_progress=$(find "$tasks_dir" -name '*-in_progress-*.md' 2>/dev/null | wc -l | tr -d ' ')
complete=$(find "$tasks_dir" -name '*-complete-*.md' 2>/dev/null | wc -l | tr -d ' ')

echo "Branch: $branch"
echo "Tasks:  $pending pending, $in_progress in progress, $complete complete"
echo ""

# List in progress first
if [[ "$in_progress" -gt 0 ]]; then
	echo "=== In Progress ==="
	ls -1 "$tasks_dir"/*-in_progress-*.md 2>/dev/null | xargs -n1 basename
	echo ""
fi

# Then pending
if [[ "$pending" -gt 0 ]]; then
	echo "=== Pending ==="
	ls -1 "$tasks_dir"/*-pending-*.md 2>/dev/null | xargs -n1 basename
	echo ""
fi

# Completed last (optional, often long)
if [[ "$complete" -gt 0 ]] && [[ "${SHOW_COMPLETE:-0}" == "1" ]]; then
	echo "=== Complete ==="
	ls -1 "$tasks_dir"/*-complete-*.md 2>/dev/null | xargs -n1 basename
fi
