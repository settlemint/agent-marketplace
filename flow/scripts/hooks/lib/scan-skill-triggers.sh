#!/usr/bin/env bash
# Scan skill files and extract trigger patterns from YAML frontmatter
# Generates a simple text cache file with skill→trigger mappings
#
# Usage: scan-skill-triggers.sh [--force]
#   --force: Rebuild cache even if fresh
#
# Cache location: $PROJECT_DIR/.claude/flow/cache/skill-triggers.txt
# Cache format: skill|pattern1|pattern2|... (one skill per line)
#
# Bash 3.2 compatible - no associative arrays

set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="scan-skill-triggers"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
log_init

CACHE_MAX_AGE_SECONDS=300 # 5 minutes

# --- Setup paths ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CACHE_DIR="$PROJECT_DIR/.claude/flow/cache"
CACHE_FILE="$CACHE_DIR/skill-triggers.txt"
LOCK_FILE="$CACHE_DIR/.triggers.lock"

# --- Check if cache is fresh ---
is_cache_fresh() {
  [[ ! -f "$CACHE_FILE" ]] && return 1

  local cache_age
  if [[ "$(uname)" == "Darwin" ]]; then
    cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE")))
  else
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
  fi

  [[ $cache_age -lt $CACHE_MAX_AGE_SECONDS ]]
}

# --- Early exit if cache is fresh ---
if [[ "$1" != "--force" ]] && is_cache_fresh; then
  log_debug "event=CACHE_HIT" "file=$CACHE_FILE"
  echo "$CACHE_FILE"
  exit 0
fi

# --- Simple lock to prevent concurrent rebuilds ---
if [[ -f "$LOCK_FILE" ]]; then
  # Wait briefly for existing build
  log_debug "event=LOCK_WAIT"
  sleep 0.5
  if [[ -f "$CACHE_FILE" ]]; then
    log_debug "event=CACHE_READY_AFTER_WAIT"
    echo "$CACHE_FILE"
    exit 0
  fi
fi

log_info "event=CACHE_REBUILD" "reason=${1:-stale}"
mkdir -p "$CACHE_DIR" 2>/dev/null
touch "$LOCK_FILE" 2>/dev/null

cleanup() {
  rm -f "$LOCK_FILE" 2>/dev/null
}
trap cleanup EXIT

# --- Find all skill directories ---
find_skill_files() {
  local dirs=()

  # Current plugin root (if set)
  if [[ -n "$CLAUDE_PLUGIN_ROOT" ]]; then
    # Go up to find sibling plugins
    local plugin_parent
    plugin_parent=$(dirname "$CLAUDE_PLUGIN_ROOT")
    [[ -d "$plugin_parent" ]] && dirs+=("$plugin_parent")
  fi

  # Global plugins
  [[ -d "$HOME/.claude/plugins" ]] && dirs+=("$HOME/.claude/plugins")

  # Project plugins
  [[ -d "$PROJECT_DIR/.claude/plugins" ]] && dirs+=("$PROJECT_DIR/.claude/plugins")

  # Scan for SKILL.md files (excluding enhance/ skills which are agent enhancers)
  for dir in "${dirs[@]}"; do
    find "$dir" -path "*/skills/*/SKILL.md" -type f 2>/dev/null | grep -v "/enhance/"
  done | sort -u
}

# --- Strip PCRE-specific patterns for bash ERE compatibility ---
# Removes (?i), \b word boundaries, and converts YAML-escaped backslashes
sanitize_pattern() {
  local pattern="$1"
  # Remove (?i) case-insensitive flag (prompts are already lowercased)
  pattern="${pattern//\(\?i\)/}"
  # Convert YAML-escaped double backslashes to single backslashes
  # In YAML double-quoted strings, \\ represents a literal \
  pattern="${pattern//\\\\/\\}"
  # Remove \b word boundaries (PCRE-only, not supported in bash ERE)
  # This makes patterns slightly less precise but still functional
  pattern="${pattern//\\b/}"
  echo "$pattern"
}

# --- Parse frontmatter from a skill file ---
# Extracts: plugin_name, skill_name, triggers[]
# Outputs: skill_name|pattern1|pattern2|...
parse_skill_frontmatter() {
  local file="$1"
  local skill_name=""
  local triggers=()
  local in_frontmatter=false
  local in_triggers=false
  local line_num=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    ((line_num++))

    # Limit parsing to first 100 lines (frontmatter should be at top)
    [[ $line_num -gt 100 ]] && break

    # Track frontmatter boundaries (---)
    if [[ "$line" == "---" ]]; then
      if [[ "$in_frontmatter" == "true" ]]; then
        break # End of frontmatter
      else
        in_frontmatter=true
        continue
      fi
    fi

    [[ "$in_frontmatter" != "true" ]] && continue

    # Extract name field
    if [[ "$line" =~ ^name:[[:space:]]*(.+)$ ]]; then
      skill_name="${BASH_REMATCH[1]}"
      # Remove surrounding quotes
      skill_name="${skill_name#\"}"
      skill_name="${skill_name%\"}"
      skill_name="${skill_name#\'}"
      skill_name="${skill_name%\'}"
      continue
    fi

    # Detect triggers section start
    if [[ "$line" =~ ^triggers:[[:space:]]*$ ]]; then
      in_triggers=true
      continue
    fi

    # End triggers section on new top-level key
    if [[ "$in_triggers" == "true" ]] && [[ "$line" =~ ^[a-z] ]]; then
      in_triggers=false
      continue
    fi

    # Extract trigger items (  - "pattern" or  - 'pattern')
    if [[ "$in_triggers" == "true" ]]; then
      local trigger=""
      if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+[\"\'](.+)[\"\'][[:space:]]*$ ]]; then
        trigger="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)[[:space:]]*$ ]]; then
        # Unquoted trigger
        trigger="${BASH_REMATCH[1]}"
        trigger="${trigger#\"}"
        trigger="${trigger%\"}"
      fi
      if [[ -n "$trigger" ]]; then
        # Sanitize the pattern for bash ERE compatibility
        trigger=$(sanitize_pattern "$trigger")
        triggers+=("$trigger")
      fi
    fi
  done <"$file"

  # Determine plugin name from path
  # Path formats:
  #   Local: .../plugin_name/skills/skill_folder/SKILL.md
  #   Versioned: .../plugin_name@version/skills/...
  #   Global cache: .../cache/marketplace/plugin_name/version/skills/...
  local plugin_name=""

  # Try global cache format first: cache/marketplace/plugin_name/version/skills/
  if [[ "$file" =~ /cache/[^/]+/([^/]+)/[0-9]+\.[0-9]+\.[0-9]+/skills/ ]]; then
    plugin_name="${BASH_REMATCH[1]}"
  # Then try versioned plugin format: plugin_name@version/skills/
  elif [[ "$file" =~ /([^/@]+)@[^/]+/skills/ ]]; then
    plugin_name="${BASH_REMATCH[1]}"
  # Finally, standard format: plugin_name/skills/
  elif [[ "$file" =~ /([^/]+)/skills/[^/]+/SKILL.md$ ]]; then
    plugin_name="${BASH_REMATCH[1]}"
  fi

  # Skip if no name or no triggers
  [[ -z "$skill_name" ]] && return
  [[ ${#triggers[@]} -eq 0 ]] && return

  # Build full skill name (plugin:skill format)
  local full_name="$skill_name"
  [[ -n "$plugin_name" ]] && full_name="$plugin_name:$skill_name"

  # Join triggers with | to form a single regex pattern
  local pattern
  pattern=$(
    IFS="|"
    echo "${triggers[*]}"
  )

  # Output as simple text: skill|pattern
  printf '%s|%s\n' "$full_name" "$pattern"
}

# --- Build the cache file ---

# First, collect all entries to a temp file
ENTRIES_FILE="$CACHE_DIR/.triggers-entries.tmp"
: >"$ENTRIES_FILE"

while IFS= read -r skill_file; do
  parse_skill_frontmatter "$skill_file" >>"$ENTRIES_FILE"
done < <(find_skill_files)

# Deduplicate entries (keep first occurrence of each skill)
DEDUP_FILE="$CACHE_DIR/.triggers-dedup.tmp"
awk -F'|' '!seen[$1]++' "$ENTRIES_FILE" >"$DEDUP_FILE"

# Build final cache file
{
  cat <<'HEADER'
# Auto-generated skill trigger cache
# DO NOT EDIT - regenerated by scan-skill-triggers.sh
#
# Format: skill_name|pattern1|pattern2|...
# Patterns are joined with | for regex alternation
# Bash 3.2 compatible - no associative arrays
#
HEADER

  cat "$DEDUP_FILE"

  echo ""
  echo "# Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

} >"$CACHE_FILE.tmp"

# Cleanup temp files
rm -f "$ENTRIES_FILE" "$DEDUP_FILE"

mv "$CACHE_FILE.tmp" "$CACHE_FILE"

# Count skills in cache
SKILL_COUNT=$(grep -v '^#' "$CACHE_FILE" | grep -c '|' || echo 0)
log_info "event=CACHE_BUILT" "skills=$SKILL_COUNT" "file=$CACHE_FILE"

echo "$CACHE_FILE"
