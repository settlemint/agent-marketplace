#!/usr/bin/env bash
set -euo pipefail

echo "## Branch"
echo '```'
branch=$(git branch --show-current)
echo "$branch"
echo '```'
echo

# Check if on feature branch
if echo "$branch" | grep -qE '^(feat|fix|refactor|chore|docs)/'; then
  echo "✓ On feature branch"
else
  echo "⚠️ Not on feature branch - consider creating one first"
fi
echo

echo "## Git Status"
echo '```'
git status --short || echo "(clean)"
echo '```'
echo

branch_slug=$(echo "$branch" | tr '/' '-')
tasks_dir=".claude/branches/$branch_slug/tasks"

echo "## Task Index (Progressive Disclosure Layer 1)"
echo
if [[ -d "$tasks_dir" ]]; then
  task_files=$(find "$tasks_dir" -name "*.md" -type f 2>/dev/null | sort)
  if [[ -n "$task_files" ]]; then
    echo "| File | Pri | Type | Title | ~Tokens |"
    echo "|------|-----|------|-------|---------|"
    while IFS= read -r file; do
      filename=$(basename "$file")
      # Extract priority from filename (e.g., 001-pending-p1-setup-foo.md)
      priority=$(echo "$filename" | sed -n 's/.*-\(p[123]\)-.*/\1/p' | tr '[:lower:]' '[:upper:]')
      priority_icon="🟢"
      [[ "$priority" == "P1" ]] && priority_icon="🔴"
      [[ "$priority" == "P2" ]] && priority_icon="🟡"
      [[ "$priority" == "P3" ]] && priority_icon="🟢"

      # Extract type from frontmatter (default to change)
      type_val=$(grep -m1 "^type:" "$file" 2>/dev/null | sed 's/type:[[:space:]]*//' | cut -d'#' -f1 | tr -d ' ' || echo "change")
      type_icon="🟢"
      case "$type_val" in
        gotcha) type_icon="🔴" ;;
        problem) type_icon="🟡" ;;
        howto) type_icon="🔵" ;;
        change) type_icon="🟢" ;;
        discovery) type_icon="🟣" ;;
        rationale) type_icon="🟠" ;;
        decision) type_icon="🟤" ;;
        tradeoff) type_icon="⚖️" ;;
      esac

      # Extract title from first heading
      title=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //' | head -c 40 || echo "Untitled")

      # Get approximate token count (chars / 4)
      chars=$(wc -c <"$file" | tr -d ' ')
      tokens=$((chars / 4))

      echo "| $filename | $priority_icon $priority | $type_icon | $title | ~$tokens |"
    done <<<"$task_files"
  else
    echo "(no tasks yet)"
  fi
else
  echo "(tasks directory not created yet)"
fi
echo

echo "## Handoffs Directory"
echo '```'
handoffs_dir=".claude/branches/$branch_slug/handoffs"
if [[ -d "$handoffs_dir" ]]; then
  ls "$handoffs_dir"/*.md 2>/dev/null || echo "(no handoffs yet)"
else
  echo "(directory not created yet)"
fi
echo '```'
