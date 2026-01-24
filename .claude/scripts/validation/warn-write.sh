#!/bin/bash
# Soft warning for Write operations
# Exits 0 (warn only, don't block)

echo "WORKFLOW REMINDER: Did you output GATE-3 before this Write?"
echo "WORKFLOW REMINDER: Is TodoWrite(in_progress) set?"
exit 0
