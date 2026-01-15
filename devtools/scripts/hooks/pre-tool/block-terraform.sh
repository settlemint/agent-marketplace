#!/usr/bin/env bash
# Block Terraform/OpenTofu command execution
# Returns "BLOCK" to prevent execution if terraform/tofu command detected

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="block-terraform"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read hook input from stdin
INPUT=$(cat)

# Extract command from input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Only block terraform/tofu apply and destroy commands (case insensitive)
# Other commands like init, plan, validate, fmt are allowed
if echo "$COMMAND" | grep -qiE '^\s*(terraform|tofu)\s+(apply|destroy)'; then
	log_warn "event=TERRAFORM_BLOCKED" "command=$COMMAND"
	cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: terraform apply/destroy is prohibited in Claude Code.

Claude can run terraform init, plan, validate, fmt, etc.
But apply and destroy MUST be run by the user.

Why apply/destroy is blocked:
- Infrastructure mutations are irreversible
- terraform apply can delete production databases
- terraform destroy removes all infrastructure
- No rollback capability for infrastructure changes

What to do:
1. Review the terraform plan output
2. Run 'terraform apply' or 'terraform destroy' in your local terminal
3. Confirm the changes when prompted

The user must run apply/destroy commands themselves."
}
EOF
	exit 0
fi

# Also block apply/destroy in chained commands
if echo "$COMMAND" | grep -qiE '(^|[;&|])\s*(terraform|tofu)\s+(apply|destroy)'; then
	log_warn "event=TERRAFORM_BLOCKED" "command=$COMMAND" "reason=chained_command"
	cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: terraform apply/destroy is not allowed.

Claude can run other terraform commands but apply/destroy must be run by the user.
Run 'terraform apply' or 'terraform destroy' in your local terminal."
}
EOF
	exit 0
fi

# Allow the command
exit 0
