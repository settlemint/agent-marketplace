# Bash ast-grep Patterns

Pattern reference for Bash/shell scripts.

**Language flag:** `-l bash`

**Supported extensions:** `.sh`, `.bash`, `.zsh`, `.ksh`, `.env`, `.bats`

## Functions

### Function Definitions

```bash
# POSIX style
sg -p '$NAME() { $$$BODY }' -l bash

# Bash style with function keyword
sg -p 'function $NAME { $$$BODY }' -l bash
sg -p 'function $NAME() { $$$BODY }' -l bash

# Exported functions
sg -p 'export -f $NAME' -l bash
```

### Function Calls

```bash
# Simple call
sg -p '$FUNC' -l bash

# With arguments
sg -p '$FUNC $$$ARGS' -l bash

# Command substitution
sg -p '$($COMMAND)' -l bash
sg -p '$($COMMAND $$$ARGS)' -l bash
```

## Variables

### Variable Assignment

```bash
# Simple assignment
sg -p '$VAR=$VALUE' -l bash
sg -p '$VAR="$VALUE"' -l bash

# With export
sg -p 'export $VAR=$VALUE' -l bash
sg -p 'export $VAR="$VALUE"' -l bash

# Local variables
sg -p 'local $VAR=$VALUE' -l bash
sg -p 'local $VAR' -l bash

# Readonly
sg -p 'readonly $VAR=$VALUE' -l bash

# Declare
sg -p 'declare $VAR=$VALUE' -l bash
sg -p 'declare -r $VAR=$VALUE' -l bash
sg -p 'declare -a $VAR=($$$VALUES)' -l bash
sg -p 'declare -A $VAR=($$$VALUES)' -l bash
```

### Variable Expansion

```bash
# Simple expansion
sg -p '$VAR' -l bash
sg -p '${VAR}' -l bash

# Default values
sg -p '${VAR:-$DEFAULT}' -l bash
sg -p '${VAR:=$DEFAULT}' -l bash

# Substring
sg -p '${VAR:$START:$LENGTH}' -l bash

# Length
sg -p '${#VAR}' -l bash
```

### Arrays

```bash
# Array declaration
sg -p '$ARRAY=($$$ELEMENTS)' -l bash
sg -p 'declare -a $ARRAY=($$$ELEMENTS)' -l bash

# Array access
sg -p '${ARRAY[$INDEX]}' -l bash
sg -p '${ARRAY[@]}' -l bash
sg -p '${ARRAY[*]}' -l bash

# Array length
sg -p '${#ARRAY[@]}' -l bash
```

## Conditionals

### If Statements

```bash
# Basic if
sg -p 'if $CONDITION; then $$$BODY fi' -l bash
sg -p 'if $CONDITION; then $$$BODY; fi' -l bash

# If-else
sg -p 'if $CONDITION; then $$$THEN else $$$ELSE fi' -l bash

# If-elif-else
sg -p 'if $COND1; then $$$BODY1 elif $COND2; then $$$BODY2 fi' -l bash

# Test with [[ ]]
sg -p 'if [[ $CONDITION ]]; then $$$BODY fi' -l bash

# Test with [ ]
sg -p 'if [ $CONDITION ]; then $$$BODY fi' -l bash
```

### Test Expressions

```bash
# Double bracket (preferred)
sg -p '[[ $EXPR ]]' -l bash

# Single bracket (POSIX)
sg -p '[ $EXPR ]' -l bash

# Test command
sg -p 'test $EXPR' -l bash

# File tests
sg -p '[[ -f $FILE ]]' -l bash
sg -p '[[ -d $DIR ]]' -l bash
sg -p '[[ -e $PATH ]]' -l bash
sg -p '[[ -r $FILE ]]' -l bash
sg -p '[[ -w $FILE ]]' -l bash
sg -p '[[ -x $FILE ]]' -l bash

# String tests
sg -p '[[ -z $VAR ]]' -l bash
sg -p '[[ -n $VAR ]]' -l bash
sg -p '[[ $A == $B ]]' -l bash
sg -p '[[ $A != $B ]]' -l bash

# Numeric comparisons
sg -p '[[ $A -eq $B ]]' -l bash
sg -p '[[ $A -ne $B ]]' -l bash
sg -p '[[ $A -lt $B ]]' -l bash
sg -p '[[ $A -gt $B ]]' -l bash
sg -p '[[ $A -le $B ]]' -l bash
sg -p '[[ $A -ge $B ]]' -l bash

# Arithmetic comparison (preferred)
sg -p '(( $A == $B ))' -l bash
sg -p '(( $A < $B ))' -l bash
```

### Case Statements

```bash
sg -p 'case $VAR in $$$CASES esac' -l bash

# Specific patterns
sg -p '$PATTERN) $$$COMMANDS ;;' -l bash
sg -p '*) $$$COMMANDS ;;' -l bash
```

## Loops

### For Loops

```bash
# C-style for
sg -p 'for (( $INIT; $COND; $UPDATE )); do $$$BODY done' -l bash

# For-in loop
sg -p 'for $VAR in $$$LIST; do $$$BODY done' -l bash
sg -p 'for $VAR in "$@"; do $$$BODY done' -l bash
sg -p 'for $VAR in "${ARRAY[@]}"; do $$$BODY done' -l bash

# Range
sg -p 'for $VAR in {$START..$END}; do $$$BODY done' -l bash
```

### While/Until Loops

```bash
# While loop
sg -p 'while $CONDITION; do $$$BODY done' -l bash
sg -p 'while read $VAR; do $$$BODY done' -l bash
sg -p 'while IFS= read -r $LINE; do $$$BODY done' -l bash

# Until loop
sg -p 'until $CONDITION; do $$$BODY done' -l bash

# Infinite loop
sg -p 'while true; do $$$BODY done' -l bash
sg -p 'while :; do $$$BODY done' -l bash
```

## Command Substitution

```bash
# Modern style (preferred)
sg -p '$($COMMAND)' -l bash
sg -p '$($COMMAND $$$ARGS)' -l bash

# Backtick style (deprecated)
sg -p '`$COMMAND`' -l bash

# Nested
sg -p '$($($$INNER))' -l bash
```

## Pipelines & Redirections

### Pipelines

```bash
# Simple pipe
sg -p '$CMD1 | $CMD2' -l bash

# Multiple pipes
sg -p '$CMD1 | $CMD2 | $CMD3' -l bash

# With process substitution
sg -p '<($COMMAND)' -l bash
sg -p '>($COMMAND)' -l bash
```

### Redirections

```bash
# Output redirection
sg -p '$COMMAND > $FILE' -l bash
sg -p '$COMMAND >> $FILE' -l bash

# Input redirection
sg -p '$COMMAND < $FILE' -l bash

# Stderr redirection
sg -p '$COMMAND 2> $FILE' -l bash
sg -p '$COMMAND 2>&1' -l bash
sg -p '$COMMAND &> $FILE' -l bash

# Here document
sg -p '$COMMAND <<$DELIMITER $$$CONTENT $DELIMITER' -l bash

# Here string
sg -p '$COMMAND <<< $STRING' -l bash
```

### Command Chaining

```bash
# Logical AND
sg -p '$CMD1 && $CMD2' -l bash

# Logical OR
sg -p '$CMD1 || $CMD2' -l bash

# Sequence
sg -p '$CMD1; $CMD2' -l bash

# Background
sg -p '$COMMAND &' -l bash
```

## Special Parameters

```bash
# Script arguments
sg -p '$0' -l bash        # Script name
sg -p '$1' -l bash        # First argument
sg -p '$@' -l bash        # All arguments (array)
sg -p '$*' -l bash        # All arguments (string)
sg -p '$#' -l bash        # Argument count
sg -p '$$' -l bash        # Process ID
sg -p '$?' -l bash        # Exit status
sg -p '$!' -l bash        # Last background PID
```

## Common Anti-Patterns (Audit)

### Unquoted Variables (ShellCheck SC2086)

```bash
# Find unquoted variables (potential word splitting)
sg -p 'echo $VAR' -l bash
sg -p 'rm $FILE' -l bash
sg -p 'cd $DIR' -l bash

# Should be quoted:
# echo "$VAR"
# rm "$FILE"
# cd "$DIR"
```

### Deprecated Syntax

```bash
# Backticks (use $() instead)
sg -p '`$COMMAND`' -l bash

# [ ] instead of [[ ]] for bash
sg -p 'if [ $COND ]; then $$$BODY fi' -l bash

# = instead of == in test
sg -p '[[ $A = $B ]]' -l bash
```

### Security Issues

```bash
# Eval usage
sg -p 'eval $EXPR' -l bash

# Unquoted command substitution
sg -p 'VAR=$($COMMAND)' -l bash

# Source without path verification
sg -p 'source $FILE' -l bash
sg -p '. $FILE' -l bash
```

## Common Refactoring

### Fix Unquoted Variables

```bash
sg -p 'echo $VAR' -r 'echo "$VAR"' -l bash
sg -p 'rm $FILE' -r 'rm "$FILE"' -l bash
```

### Modernize Command Substitution

```bash
sg -p '`$COMMAND`' -r '$($COMMAND)' -l bash
```

### Use Double Brackets

```bash
sg -p 'if [ $COND ]; then $$$BODY fi' -r 'if [[ $COND ]]; then $$$BODY fi' -l bash
```

## Shebang Patterns

```bash
sg -p '#!/bin/bash' -l bash
sg -p '#!/usr/bin/env bash' -l bash
sg -p '#!/bin/sh' -l bash
sg -p '#!/usr/bin/env sh' -l bash
```

## Common Script Patterns

```bash
# Error handling
sg -p 'set -e' -l bash
sg -p 'set -euo pipefail' -l bash
sg -p 'trap $HANDLER $SIGNAL' -l bash

# Script directory
sg -p 'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"' -l bash

# Default values
sg -p '${VAR:-$DEFAULT}' -l bash

# Required variables
sg -p ': ${VAR:?$MESSAGE}' -l bash
```
