#!/usr/bin/env bash
# PreToolUse hook: Auto-load security review for sensitive code changes
# Silently activates differential-review skill when security patterns detected
#
# Detection patterns:
# - auth|login|session|token|credential|password
# - payment|billing|charge|transaction|invoice
# - secret|key|api.?key|private.?key
# - sanitize|escape|validate|trusted
#
# Based on: https://addyosmani.com/blog/code-review-ai/

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="security-gate"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Skip if no command
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Skip if not a git commit command
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

log_info "event=COMMIT_DETECTED_SECURITY_CHECK"

# Check for session marker to avoid duplicate skill loads
if session_marker_exists "security-skill-loaded"; then
  log_info "event=SKIP_ALREADY_LOADED"
  exit 0
fi

# Get staged diff to check for security patterns
STAGED_DIFF=$(git diff --cached --unified=0 2>/dev/null || echo "")

if [[ -z "$STAGED_DIFF" ]]; then
  log_info "event=SKIP_NO_STAGED_DIFF"
  exit 0
fi

# Security-sensitive patterns (case insensitive)
SECURITY_PATTERNS="(auth|login|logout|session|token|credential|password|passkey|oauth|jwt|bearer)"
SECURITY_PATTERNS+="|"
SECURITY_PATTERNS+="(payment|billing|charge|transaction|invoice|stripe|paypal|checkout)"
SECURITY_PATTERNS+="|"
SECURITY_PATTERNS+="(secret|api.?key|private.?key|encryption|decrypt|hmac|hash)"
SECURITY_PATTERNS+="|"
SECURITY_PATTERNS+="(sanitize|escape|validate|trusted|untrusted|injection|xss|csrf)"
SECURITY_PATTERNS+="|"
SECURITY_PATTERNS+="(permission|access.?control|role|privilege|admin|sudo)"

# Check if diff contains security patterns
if echo "$STAGED_DIFF" | grep -qiE "$SECURITY_PATTERNS"; then
  # Find which patterns matched for logging
  MATCHED=$(echo "$STAGED_DIFF" | grep -oiE "$SECURITY_PATTERNS" | head -5 | tr '\n' ',' | sed 's/,$//')
  log_info "event=SECURITY_PATTERNS_DETECTED" "matched=$MATCHED"

  create_session_marker "security-skill-loaded"

  # Silently suggest loading differential review skill
  cat <<EOF

<flow-security-context>
Security-sensitive code detected in staged changes (patterns: $MATCHED).

Loading security review context:
Skill({ skill: "differential-review:differential-review" })

The differential-review skill will help analyze:
- Authentication/authorization bypass risks
- Injection vulnerabilities
- Secret exposure risks
- Access control issues
</flow-security-context>

EOF

  log_skill_activation "differential-review:differential-review" "security-patterns" "auto-detected security-sensitive code" "security-gate"
  exit 0
fi

log_info "event=NO_SECURITY_PATTERNS"
exit 0
