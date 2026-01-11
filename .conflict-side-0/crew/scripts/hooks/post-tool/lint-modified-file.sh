#!/usr/bin/env bash
# Lint and format the file that was just modified
# Runs immediately after Edit/Write so issues can be fixed in same turn
#
# PERFORMANCE OPTIMIZATIONS:
# - Uses direct binaries from node_modules/.bin instead of bunx (saves ~200ms per call)
# - Early exit for non-existent files
# - Caches binary paths to avoid repeated lookups
set +e

# Read hook input from stdin
INPUT=$(cat)

# Extract file path from tool input - single jq call
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Early exit if file doesn't exist
[[ -z $FILE_PATH || ! -f $FILE_PATH ]] && exit 0

# Get file extension
EXT="${FILE_PATH##*.}"

# Find project root (for node_modules/.bin)
find_project_root() {
	local dir="$1"
	while [[ $dir != "/" ]]; do
		[[ -f "$dir/package.json" ]] && echo "$dir" && return
		dir=$(dirname "$dir")
	done
	echo ""
}

# Cache project root and binary paths (only computed once per invocation)
PROJECT_ROOT=""
PRETTIER_BIN=""
BIOME_BIN=""

# Get binary path - prefers local node_modules, falls back to bunx
get_bin() {
	local name="$1"
	if [[ -z $PROJECT_ROOT ]]; then
		PROJECT_ROOT=$(find_project_root "$(dirname "$FILE_PATH")")
	fi
	local local_bin="$PROJECT_ROOT/node_modules/.bin/$name"
	if [[ -x $local_bin ]]; then
		echo "$local_bin"
	else
		echo "bunx $name"
	fi
}

case "$EXT" in
sol)
	# Format Solidity with forge (no node_modules dependency)
	forge fmt "$FILE_PATH" 2>/dev/null || true
	;;
sh)
	# Format shell scripts with shfmt (fast, native binary)
	command -v shfmt &>/dev/null && shfmt -w "$FILE_PATH" 2>/dev/null || true

	# Lint with shellcheck (fast, native binary)
	if command -v shellcheck &>/dev/null; then
		sc_output=$(shellcheck -f gcc "$FILE_PATH" 2>&1)
		if [[ -n $sc_output ]]; then
			# Filter out common false positives (SC1091 = not following sourced file)
			issues=$(echo "$sc_output" | grep -v "SC1091" | head -10)
			[[ -n $issues ]] && echo "ACTION REQUIRED: Fix shellcheck issues in $FILE_PATH:" && echo "$issues"
		fi
	fi
	;;
ts | tsx | js | jsx)
	# TypeScript/JavaScript: use local binaries when available (saves ~400ms)
	PRETTIER_BIN=$(get_bin "prettier")
	BIOME_BIN=$(get_bin "biome")

	# Format with prettier
	$PRETTIER_BIN --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true

	# Run biome with noUnusedImports disabled to preserve imports during edits
	$BIOME_BIN check --write --unsafe \
		--rules-disabled=lint/correctness/noUnusedImports \
		"$FILE_PATH" 2>/dev/null || true
	;;
json | css | scss | yaml | yml)
	# Non-code files: safe to fully lint
	PRETTIER_BIN=$(get_bin "prettier")
	$PRETTIER_BIN --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true
	;;
md)
	# Markdown files: format with prettier
	PRETTIER_BIN=$(get_bin "prettier")
	$PRETTIER_BIN --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true

	# Lint with markdownlint if available (native binary, fast)
	if command -v markdownlint &>/dev/null; then
		ml_output=$(markdownlint "$FILE_PATH" 2>&1)
		[[ -n $ml_output ]] && echo "ACTION REQUIRED: Fix markdownlint issues in $FILE_PATH:" && echo "$ml_output" | head -10
	fi
	;;
esac
