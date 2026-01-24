#!/bin/bash
# Soft warning for Edit operations
# Exits 0 (warn only, don't block)

echo "WORKFLOW REMINDER: Did you output GATE-3 before this Edit?"
echo "WORKFLOW REMINDER: For TDD, is there a failing test first?"
exit 0
