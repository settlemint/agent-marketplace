#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_SH="$ROOT_DIR/setup.sh"

if [[ ! -f "$SETUP_SH" ]]; then
  echo "setup.sh not found at $SETUP_SH"
  exit 1
fi

tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

(
  cd "$tmp_dir"
  bash "$SETUP_SH" --skip-skills --skip-postinstall --skip-codex-mcp >"$tmp_dir/output.log" 2>&1
)

required_paths=(
  ".agents/setup.sh"
  ".agents/setup.json"
  ".agents/templates/claude/CLAUDE.md"
  ".agents/templates/codex/AGENTS.md"
  ".agents/templates/claude/.claude/settings.json"
  ".agents/skills/test-driven-development/SKILL.md"
  ".claude/settings.json"
  "CLAUDE.md"
  "AGENTS.md"
  ".mcp.json"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$tmp_dir/$path" ]]; then
    echo "Missing expected file: $path"
    echo "Setup output:"
    cat "$tmp_dir/output.log"
    exit 1
  fi
done

check_xml_tags() {
  local file="$1"
  local tags=(
    "task-classification"
    "hard-requirements"
    "anti-patterns"
    "workflows"
    "skill-routing-table"
  )

  local prev_close=0
  for tag in "${tags[@]}"; do
    local open_count close_count open_line close_line
    open_count=$(grep -c "^<${tag}>$" "$file" || true)
    close_count=$(grep -c "^</${tag}>$" "$file" || true)
    if [[ "$open_count" -ne 1 || "$close_count" -ne 1 ]]; then
      echo "Tag check failed in $file for <$tag> (open=$open_count close=$close_count)"
      exit 1
    fi

    open_line=$(grep -n "^<${tag}>$" "$file" | cut -d: -f1)
    close_line=$(grep -n "^</${tag}>$" "$file" | cut -d: -f1)

    if [[ -z "$open_line" || -z "$close_line" ]]; then
      echo "Tag check failed in $file for <$tag> (missing line numbers)"
      exit 1
    fi

    if (( open_line <= prev_close )); then
      echo "Tag order failed in $file for <$tag> (open_line=$open_line prev_close=$prev_close)"
      exit 1
    fi

    if (( close_line <= open_line )); then
      echo "Tag order failed in $file for <$tag> (close_line=$close_line open_line=$open_line)"
      exit 1
    fi

    prev_close=$close_line
  done
}

check_xml_tags "$tmp_dir/AGENTS.md"
check_xml_tags "$tmp_dir/CLAUDE.md"

echo "setup.sh created expected files in $tmp_dir"
