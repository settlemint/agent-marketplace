#!/bin/bash
# Get unresolved review threads for a PR
# Usage: ./gh-pr-threads.sh [PR_NUMBER]
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

# Get repo info
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')

# GraphQL query for review threads
# shellcheck disable=SC2016 # Single quotes intentional - $owner/$repo/$pr are GraphQL variables, not shell
QUERY='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          path
          line
          comments(first: 1) {
            nodes {
              body
              author {
                login
              }
            }
          }
        }
      }
    }
  }
}
'

# Execute query and filter unresolved threads
RESULT=$(gh api graphql \
	-F owner="$OWNER" \
	-F repo="$REPO" \
	-F pr="$PR_NUMBER" \
	-f query="$QUERY" 2>/dev/null)
if [ -z "$RESULT" ]; then
	echo "Failed to fetch review threads"
	exit 0
fi

# Parse and output unresolved threads with IDs for resolution
echo "$RESULT" | jq -r '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | "- \(.path):\(.line // "?") [@\(.comments.nodes[0].author.login)]: \(.comments.nodes[0].body | split("\n")[0])\n  THREAD_ID=\(.id)"
' 2>/dev/null || echo "No unresolved threads found"
