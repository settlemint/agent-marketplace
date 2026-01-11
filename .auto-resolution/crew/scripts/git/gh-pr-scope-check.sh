#!/usr/bin/env bash
# Check if PR title/body reflects current scope of changes
# Usage: ./gh-pr-scope-check.sh
# Called after git push to suggest PR updates if scope has changed
#
# Output: Suggestions for updating PR if needed

set -uo pipefail

# Check if we have a PR for this branch
PR_JSON=$(gh pr view --json number,title,body,commits 2>/dev/null)
if [[ -z $PR_JSON ]]; then
  # No PR exists, nothing to check
  exit 0
fi

PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number')
PR_TITLE=$(echo "$PR_JSON" | jq -r '.title')
PR_BODY=$(echo "$PR_JSON" | jq -r '.body')

# Get base branch for comparison
BASE_BRANCH=$(gh pr view --json baseRefName -q '.baseRefName' 2>/dev/null || echo "main")

# Get all commit messages in this PR
COMMIT_MESSAGES=$(git log "origin/${BASE_BRANCH}..HEAD" --pretty=format:"%s" 2>/dev/null)
COMMIT_COUNT=$(echo "$COMMIT_MESSAGES" | grep -c . || echo "0")

# Get file count
FILE_COUNT=$(git diff --name-only "origin/${BASE_BRANCH}..HEAD" 2>/dev/null | wc -l | tr -d ' ')

# Analyze commit types
FEAT_COUNT=$(echo "$COMMIT_MESSAGES" | grep -c "^feat" || echo "0")
FIX_COUNT=$(echo "$COMMIT_MESSAGES" | grep -c "^fix" || echo "0")
REFACTOR_COUNT=$(echo "$COMMIT_MESSAGES" | grep -c "^refactor" || echo "0")
DOCS_COUNT=$(echo "$COMMIT_MESSAGES" | grep -c "^docs" || echo "0")
CHORE_COUNT=$(echo "$COMMIT_MESSAGES" | grep -c "^chore" || echo "0")

# Build scope summary
SCOPE_PARTS=()
[[ $FEAT_COUNT -gt 0 ]] && SCOPE_PARTS+=("${FEAT_COUNT} feature(s)")
[[ $FIX_COUNT -gt 0 ]] && SCOPE_PARTS+=("${FIX_COUNT} fix(es)")
[[ $REFACTOR_COUNT -gt 0 ]] && SCOPE_PARTS+=("${REFACTOR_COUNT} refactor(s)")
[[ $DOCS_COUNT -gt 0 ]] && SCOPE_PARTS+=("${DOCS_COUNT} doc change(s)")
[[ $CHORE_COUNT -gt 0 ]] && SCOPE_PARTS+=("${CHORE_COUNT} chore(s)")

# Check if PR might need updating
NEEDS_UPDATE="false"
REASONS=()

# Multiple commits but title only mentions one thing
if [[ $COMMIT_COUNT -gt 1 ]]; then
  # Check if title seems too narrow for the scope
  if [[ ${#SCOPE_PARTS[@]} -gt 1 ]]; then
    NEEDS_UPDATE="true"
    REASONS+=("PR has ${COMMIT_COUNT} commits spanning multiple types: ${SCOPE_PARTS[*]}")
  fi
fi

# Check if body is too short for the scope
BODY_LENGTH=${#PR_BODY}
if [[ $BODY_LENGTH -lt 100 && $COMMIT_COUNT -gt 2 ]]; then
  NEEDS_UPDATE="true"
  REASONS+=("PR body is short ($BODY_LENGTH chars) but has $COMMIT_COUNT commits")
fi

# Check if significant files changed but not mentioned
if [[ $FILE_COUNT -gt 10 ]]; then
  NEEDS_UPDATE="true"
  REASONS+=("$FILE_COUNT files changed - ensure PR description covers the scope")
fi

# Output results
if [[ $NEEDS_UPDATE == "true" ]]; then
  echo ""
  echo "## PR Scope Review (PR #${PR_NUMBER})"
  echo ""
  echo "**Current title:** $PR_TITLE"
  echo ""
  echo "**Commits in PR ($COMMIT_COUNT):**"
  echo '```'
  echo "$COMMIT_MESSAGES" | head -10
  [[ $COMMIT_COUNT -gt 10 ]] && echo "... and $((COMMIT_COUNT - 10)) more"
  echo '```'
  echo ""
  echo "**Scope:** ${SCOPE_PARTS[*]:-"(no conventional commits)"}"
  echo "**Files changed:** $FILE_COUNT"
  echo ""
  echo "### Suggestions"
  for reason in "${REASONS[@]}"; do
    echo "- $reason"
  done
  echo ""
  echo "**ACTION REQUIRED:** Use Skill(skill: \"crew:git:pr:update\") to update title and body"
  echo ""
  echo "This will preserve git-machete generated sections automatically."
fi

exit 0
