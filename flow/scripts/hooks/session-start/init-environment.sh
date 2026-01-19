#!/usr/bin/env bash
# Initialize flow environment on session start
# Consolidates: check-dependencies.sh + load-enhance.sh + superpowers check + worktree detection
# Runs on: SessionStart (once per session)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="init-environment"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read event data from stdin
EVENT_DATA=$(cat)

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")
if [[ "$AGENT_TYPE" != "main" ]]; then
  exit 0
fi

# --- Dependency checks ---

# Check for jq (required for JSON processing)
if ! command -v jq &>/dev/null; then
  log_warn "event=DEPENDENCY_MISSING" "dependency=jq"
  echo "Flow: Warning - 'jq' not found. Some flow features may not work correctly."
  echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
else
  log_debug "event=DEPENDENCIES_OK"
fi

# --- Superpowers plugin check (HARD DEPENDENCY) ---
SUPERPOWERS_PATH="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
if [[ ! -d "$SUPERPOWERS_PATH" ]]; then
  log_warn "event=SUPERPOWERS_MISSING"
  cat <<'EOF'
BLOCKED: superpowers plugin required but not installed.

Install with:
  /plugin marketplace add claude-plugins-official
  /plugin install superpowers@4.0.3

This plugin provides TDD, debugging, and planning workflows.
EOF
else
  # Version check (pin to tested version)
  INSTALLED_VERSION=$(jq -r '.version' "$SUPERPOWERS_PATH"/*/plugin.json 2>/dev/null | head -1)
  REQUIRED_VERSION="4.0.3"
  if [[ -n "$INSTALLED_VERSION" && "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]]; then
    log_warn "event=SUPERPOWERS_VERSION_MISMATCH" "installed=$INSTALLED_VERSION" "required=$REQUIRED_VERSION"
    echo "Warning: superpowers version mismatch - have $INSTALLED_VERSION, expected $REQUIRED_VERSION"
  else
    log_debug "event=SUPERPOWERS_OK" "version=$INSTALLED_VERSION"
  fi
fi

# --- Worktree detection ---
if git rev-parse --is-inside-work-tree &>/dev/null; then
  GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ "$GIT_COMMON_DIR" != ".git" && "$GIT_COMMON_DIR" != *"/.git" ]]; then
    WORKTREE_PATH=$(git rev-parse --show-toplevel)
    MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
    log_info "event=WORKTREE_DETECTED" "worktree=$WORKTREE_PATH" "main_repo=$MAIN_REPO"
    echo "Note: Running in git worktree at $WORKTREE_PATH"
    echo "Main repository: $MAIN_REPO"
    echo "To create new worktrees, use the main repository."
  fi
fi

# --- Load core skills ---

# Core workflow skills (always loaded)
cat <<'EOF'
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })
EOF

# Superpowers skills (process workflows)
cat <<'EOF'
Skill({ skill: "superpowers:using-superpowers" })
Skill({ skill: "superpowers:test-driven-development" })
Skill({ skill: "superpowers:systematic-debugging" })
Skill({ skill: "superpowers:verification-before-completion" })
Skill({ skill: "superpowers:brainstorming" })
Skill({ skill: "superpowers:writing-plans" })
Skill({ skill: "superpowers:executing-plans" })
Skill({ skill: "superpowers:using-git-worktrees" })
Skill({ skill: "superpowers:finishing-a-development-branch" })
Skill({ skill: "superpowers:subagent-driven-development" })
Skill({ skill: "superpowers:requesting-code-review" })
Skill({ skill: "superpowers:receiving-code-review" })
EOF

# Meta/review skills (always available for quality work)
cat <<'EOF'
Skill({ skill: "devtools:codex-patterns" })
Skill({ skill: "devtools:security-checklist" })
Skill({ skill: "devtools:code-health" })
Skill({ skill: "devtools:spec-writing" })
Skill({ skill: "devtools:stack-review" })
Skill({ skill: "devtools:typescript-lsp" })
Skill({ skill: "devtools:visual-context" })
Skill({ skill: "devtools:critique-driven" })
Skill({ skill: "devtools:vercel-design-guidelines" })
Skill({ skill: "devtools:agent-browser" })
Skill({ skill: "devtools:ast-grep" })
Skill({ skill: "devtools:design-principles" })
Skill({ skill: "devtools:react-best-practices" })
EOF

# Official Anthropic plugins (always available)
cat <<'EOF'
Skill({ skill: "code-simplifier:code-simplifier" })
EOF

exit 0
