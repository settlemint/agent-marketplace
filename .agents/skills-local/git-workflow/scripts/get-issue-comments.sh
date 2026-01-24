#!/usr/bin/env bash
# Get PR issue comments (general comments, not inline review threads) via GitHub API
# Usage: get-issue-comments.sh [--full] [--actionable] [owner/repo#pr]
# Examples:
#   get-issue-comments.sh                           # Use current branch's PR
#   get-issue-comments.sh settlemint/dalp#5493      # Specify PR directly
#   get-issue-comments.sh --full                    # Full comment body
#   get-issue-comments.sh --actionable              # Only comments with code suggestions
# Output: JSON objects with id, author, body, url, created_at

set -euo pipefail

FULL_BODY=false
ACTIONABLE_ONLY=false
PR_REF=""

for arg in "$@"; do
  case "$arg" in
    --full) FULL_BODY=true ;;
    --actionable) ACTIONABLE_ONLY=true ;;
    */*#*) PR_REF="$arg" ;;
  esac
done

if [[ -n "$PR_REF" ]]; then
  # Parse owner/repo#pr format
  OWNER=$(echo "$PR_REF" | cut -d'/' -f1)
  REPO=$(echo "$PR_REF" | cut -d'/' -f2 | cut -d'#' -f1)
  PR_NUM=$(echo "$PR_REF" | cut -d'#' -f2)
else
  # Get PR info from current branch
  PR_URL=$(gh pr view --json url -q '.url' 2>/dev/null) || {
    echo "No PR found for current branch. Use: $0 owner/repo#pr" >&2
    exit 1
  }
  OWNER=$(echo "$PR_URL" | sed -n 's|.*github.com/\([^/]*\)/.*|\1|p')
  REPO=$(echo "$PR_URL" | sed -n 's|.*github.com/[^/]*/\([^/]*\)/.*|\1|p')
  PR_NUM=$(gh pr view --json number -q '.number')
fi

# Use REST API to get issue comments (simpler than GraphQL for this use case)
COMMENTS=$(gh api "repos/$OWNER/$REPO/issues/$PR_NUM/comments" --paginate)

# Filter and format comments
if $ACTIONABLE_ONLY; then
  # Only comments that look actionable (contain code blocks, suggestions, or keywords)
  FILTER='
    .[] |
    select(
      (.body | test("```"; "i")) or
      (.body | test("suggestion"; "i")) or
      (.body | test("\\bP[0-2]\\b"; "i")) or
      (.body | test("should|must|fix|change|update|add|remove"; "i"))
    ) |
    {
      id: .id,
      author: .user.login,
      url: .html_url,
      created_at: .created_at,
      body: (if $full then .body else .body[0:500] end)
    }
  '
else
  FILTER='
    .[] |
    {
      id: .id,
      author: .user.login,
      url: .html_url,
      created_at: .created_at,
      body: (if $full then .body else .body[0:500] end)
    }
  '
fi

echo "$COMMENTS" | jq --argjson full "$FULL_BODY" "$FILTER"
