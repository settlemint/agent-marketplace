#!/usr/bin/env bash
# PreToolUse hook: Warn on large PRs (>500 lines)
# Non-blocking informational warning to encourage smaller PRs
#
# Based on: https://addyosmani.com/blog/code-review-ai/
# "PRs are getting larger (~18% more additions as AI adoption increases)
#  while incidents per PR are up ~24%"

set +e

# Skip if DEVTOOLS_QUIET is set
if [[ "${DEVTOOLS_QUIET:-}" == "1" ]]; then
  exit 0
fi

# Read tool input from stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Skip if no command
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Only trigger on gh pr create
if [[ "$COMMAND" != *"gh pr create"* ]]; then
  exit 0
fi

# Get the base branch (default to main)
BASE_BRANCH="main"
if [[ "$COMMAND" =~ --base[[:space:]]+([^[:space:]]+) ]]; then
  BASE_BRANCH="${BASH_REMATCH[1]}"
elif [[ "$COMMAND" =~ --base=([^[:space:]]+) ]]; then
  BASE_BRANCH="${BASH_REMATCH[1]}"
fi

# Get the head branch (default to HEAD)
HEAD_REF="HEAD"
if [[ "$COMMAND" =~ --head[[:space:]]+([^[:space:]]+) ]]; then
  HEAD_REF="${BASH_REMATCH[1]}"
elif [[ "$COMMAND" =~ --head=([^[:space:]]+) ]]; then
  HEAD_REF="${BASH_REMATCH[1]}"
fi

# Calculate additions using numstat for reliable machine-parseable output
ADDITIONS=$(git diff --numstat "${BASE_BRANCH}...${HEAD_REF}" 2>/dev/null | awk '{s+=$1} END {print s+0}')

# Threshold for warning
SIZE_THRESHOLD=500

if [[ "$ADDITIONS" -gt "$SIZE_THRESHOLD" ]]; then
  cat <<EOF

<devtools-pr-size-notice>
Large PR detected: ~$ADDITIONS additions (recommended: <$SIZE_THRESHOLD)

Research shows larger PRs correlate with more incidents:
"PRs are getting larger (~18% more additions as AI adoption increases)
 while incidents per PR are up ~24%, and change failure rates up ~30%."
 — https://addyosmani.com/blog/code-review-ai/

Consider:
- Split into smaller, focused PRs (feature flag if needed)
- Create a PR stack (base PR + follow-up PRs)
- Extract refactoring into a separate PR

Smaller PRs are:
- Easier to review thoroughly
- Less likely to introduce bugs
- Faster to merge and deploy
</devtools-pr-size-notice>

EOF
fi

exit 0
