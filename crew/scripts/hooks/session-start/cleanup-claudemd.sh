#!/usr/bin/env bash
#
# Temporary cleanup script for claude-mem generated CLAUDE.md files
# See: https://github.com/thedotmack/claude-mem/pull/589
#
# Removes CLAUDE.md files that only contain <claude-mem-context> sections
# Preserves files with user-written content outside those tags
#
set -euo pipefail

# Only run in git repos
if ! git rev-parse --git-dir &>/dev/null 2>&1; then
	exit 0
fi

# Find all CLAUDE.md files
while IFS= read -r -d '' file; do
	# Check if file only contains claude-mem generated content
	# Strip the <claude-mem-context>...</claude-mem-context> block and whitespace
	content_outside_tags=$(sed '/<claude-mem-context>/,/<\/claude-mem-context>/d' "$file" | tr -d '[:space:]')

	if [[ -z "$content_outside_tags" ]]; then
		# File only has claude-mem content, safe to delete
		rm -f "$file"
	fi
done < <(find . -name "CLAUDE.md" -type f -print0 2>/dev/null || true)

exit 0
