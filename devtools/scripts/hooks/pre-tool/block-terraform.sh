#!/usr/bin/env bash
# Block Terraform/OpenTofu command execution
# Returns "BLOCK" to prevent execution if terraform/tofu command detected

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract command from input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Check for terraform/tofu commands (case insensitive)
if echo "$COMMAND" | grep -qiE '^\s*(terraform|tofu)\s+(init|plan|apply|destroy|import|state|workspace|refresh|taint|untaint|validate|fmt|output|show|get|providers|force-unlock)'; then
	cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Terraform/OpenTofu execution is prohibited in Claude Code.

Claude can WRITE .tf files but MUST NOT execute terraform/tofu commands.

Why this is blocked:
- Infrastructure mutations are irreversible
- terraform apply can delete production databases
- State file corruption can brick infrastructure
- No rollback capability for infrastructure changes

What to do:
1. Copy the terraform command Claude suggested
2. Run it in your local terminal
3. Review the plan output carefully before applying

The user must run terraform commands themselves."
}
EOF
	exit 0
fi

# Also block direct terraform binary calls that might bypass the above
if echo "$COMMAND" | grep -qiE '(^|[;&|])\s*(terraform|tofu)\s'; then
	cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Direct terraform/tofu execution is not allowed.

Claude writes infrastructure code but does not execute it.
Run terraform commands in your local terminal."
}
EOF
	exit 0
fi

# Allow the command
exit 0
