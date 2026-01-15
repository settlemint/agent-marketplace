# Terraform (HCL) ast-grep Patterns

Pattern reference for Terraform/OpenTofu HCL files.

**Language flag:** `-l hcl`

**Supported extensions:** `.tf`, `.hcl`

## Resources

### Resource Blocks

```bash
# Find all resources
sg -p 'resource "$TYPE" "$NAME" { $$$BODY }' -l hcl

# Specific resource types
sg -p 'resource "aws_instance" "$NAME" { $$$BODY }' -l hcl
sg -p 'resource "aws_s3_bucket" "$NAME" { $$$BODY }' -l hcl
sg -p 'resource "aws_lambda_function" "$NAME" { $$$BODY }' -l hcl
sg -p 'resource "aws_iam_role" "$NAME" { $$$BODY }' -l hcl

# Any AWS resource
sg -p 'resource "aws_$SUFFIX" "$NAME" { $$$BODY }' -l hcl

# Google Cloud resources
sg -p 'resource "google_$SUFFIX" "$NAME" { $$$BODY }' -l hcl

# Azure resources
sg -p 'resource "azurerm_$SUFFIX" "$NAME" { $$$BODY }' -l hcl

# Kubernetes resources
sg -p 'resource "kubernetes_$SUFFIX" "$NAME" { $$$BODY }' -l hcl
```

### Resource Attributes

```bash
# Find specific attributes
sg -p '$ATTR = $VALUE' -l hcl

# Tags
sg -p 'tags = { $$$TAGS }' -l hcl
sg -p 'tags = $VARIABLE' -l hcl

# Common attributes
sg -p 'name = $VALUE' -l hcl
sg -p 'description = $VALUE' -l hcl
sg -p 'region = $VALUE' -l hcl
sg -p 'environment = $VALUE' -l hcl
```

## Data Sources

```bash
# Find all data sources
sg -p 'data "$TYPE" "$NAME" { $$$BODY }' -l hcl

# Specific data sources
sg -p 'data "aws_ami" "$NAME" { $$$BODY }' -l hcl
sg -p 'data "aws_vpc" "$NAME" { $$$BODY }' -l hcl
sg -p 'data "aws_subnet" "$NAME" { $$$BODY }' -l hcl
sg -p 'data "aws_iam_policy_document" "$NAME" { $$$BODY }' -l hcl
sg -p 'data "template_file" "$NAME" { $$$BODY }' -l hcl
```

## Variables

### Variable Declarations

```bash
# All variables
sg -p 'variable "$NAME" { $$$BODY }' -l hcl

# With type
sg -p 'variable "$NAME" { type = $TYPE $$$REST }' -l hcl

# With default
sg -p 'variable "$NAME" { default = $VALUE $$$REST }' -l hcl

# With description
sg -p 'variable "$NAME" { description = $DESC $$$REST }' -l hcl

# With validation
sg -p 'variable "$NAME" { $$$BEFORE validation { $$$VALIDATION } $$$AFTER }' -l hcl

# Sensitive variables
sg -p 'variable "$NAME" { $$$BEFORE sensitive = true $$$AFTER }' -l hcl
```

### Variable References

```bash
# Direct reference
sg -p 'var.$NAME' -l hcl

# In expressions
sg -p '${var.$NAME}' -l hcl
```

## Outputs

```bash
# All outputs
sg -p 'output "$NAME" { $$$BODY }' -l hcl

# With value
sg -p 'output "$NAME" { value = $VALUE $$$REST }' -l hcl

# Sensitive outputs
sg -p 'output "$NAME" { $$$BEFORE sensitive = true $$$AFTER }' -l hcl
```

## Locals

```bash
# Locals block
sg -p 'locals { $$$LOCALS }' -l hcl

# Local reference
sg -p 'local.$NAME' -l hcl
```

## Modules

### Module Calls

```bash
# All modules
sg -p 'module "$NAME" { $$$BODY }' -l hcl

# With source
sg -p 'module "$NAME" { source = $SOURCE $$$REST }' -l hcl

# Registry modules
sg -p 'module "$NAME" { source = "$NAMESPACE/$NAME/$PROVIDER" $$$REST }' -l hcl

# Git modules
sg -p 'module "$NAME" { source = "git::$URL" $$$REST }' -l hcl

# Local modules
sg -p 'module "$NAME" { source = "./$PATH" $$$REST }' -l hcl

# With version
sg -p 'module "$NAME" { $$$BEFORE version = $VERSION $$$AFTER }' -l hcl
```

### Module References

```bash
sg -p 'module.$NAME.$OUTPUT' -l hcl
```

## Providers

```bash
# Provider blocks
sg -p 'provider "$NAME" { $$$BODY }' -l hcl

# AWS provider
sg -p 'provider "aws" { $$$BODY }' -l hcl
sg -p 'provider "aws" { region = $REGION $$$REST }' -l hcl

# Provider aliases
sg -p 'provider "$NAME" { alias = $ALIAS $$$REST }' -l hcl
```

## Terraform Block

```bash
# Terraform configuration
sg -p 'terraform { $$$BODY }' -l hcl

# Required version
sg -p 'required_version = $VERSION' -l hcl

# Required providers
sg -p 'required_providers { $$$PROVIDERS }' -l hcl

# Backend configuration
sg -p 'backend "$TYPE" { $$$CONFIG }' -l hcl
sg -p 'backend "s3" { $$$CONFIG }' -l hcl
sg -p 'backend "gcs" { $$$CONFIG }' -l hcl
sg -p 'backend "azurerm" { $$$CONFIG }' -l hcl
```

## Lifecycle Rules

```bash
# Lifecycle block
sg -p 'lifecycle { $$$RULES }' -l hcl

# Prevent destroy
sg -p 'lifecycle { prevent_destroy = true $$$REST }' -l hcl

# Ignore changes
sg -p 'lifecycle { ignore_changes = [$$$ATTRS] $$$REST }' -l hcl

# Create before destroy
sg -p 'lifecycle { create_before_destroy = true $$$REST }' -l hcl

# Replace triggered by
sg -p 'lifecycle { replace_triggered_by = [$$$TRIGGERS] $$$REST }' -l hcl
```

## Dynamic Blocks

```bash
# Dynamic block
sg -p 'dynamic "$NAME" { $$$BODY }' -l hcl

# With content
sg -p 'dynamic "$NAME" { for_each = $EXPR content { $$$CONTENT } }' -l hcl
```

## Expressions

### For Expressions

```bash
# For in list
sg -p '[for $ITEM in $LIST : $EXPR]' -l hcl

# For in map
sg -p '{ for $KEY, $VALUE in $MAP : $KEY_EXPR => $VALUE_EXPR }' -l hcl

# With condition
sg -p '[for $ITEM in $LIST : $EXPR if $CONDITION]' -l hcl
```

### Conditionals

```bash
# Ternary
sg -p '$COND ? $TRUE : $FALSE' -l hcl

# Null coalescing
sg -p 'coalesce($$$VALUES)' -l hcl
```

### Count and For Each

```bash
# Count
sg -p 'count = $VALUE' -l hcl
sg -p 'count.index' -l hcl

# For each
sg -p 'for_each = $VALUE' -l hcl
sg -p 'each.key' -l hcl
sg -p 'each.value' -l hcl
```

## Functions

```bash
# String functions
sg -p 'format($$$ARGS)' -l hcl
sg -p 'join($SEPARATOR, $LIST)' -l hcl
sg -p 'split($SEPARATOR, $STRING)' -l hcl
sg -p 'replace($STRING, $SEARCH, $REPLACE)' -l hcl
sg -p 'lower($STRING)' -l hcl
sg -p 'upper($STRING)' -l hcl
sg -p 'trimspace($STRING)' -l hcl

# Collection functions
sg -p 'length($COLLECTION)' -l hcl
sg -p 'lookup($MAP, $KEY)' -l hcl
sg -p 'lookup($MAP, $KEY, $DEFAULT)' -l hcl
sg -p 'merge($$$MAPS)' -l hcl
sg -p 'concat($$$LISTS)' -l hcl
sg -p 'flatten($LIST)' -l hcl
sg -p 'distinct($LIST)' -l hcl

# Encoding functions
sg -p 'jsonencode($VALUE)' -l hcl
sg -p 'jsondecode($STRING)' -l hcl
sg -p 'yamlencode($VALUE)' -l hcl
sg -p 'yamldecode($STRING)' -l hcl
sg -p 'base64encode($STRING)' -l hcl
sg -p 'base64decode($STRING)' -l hcl

# File functions
sg -p 'file($PATH)' -l hcl
sg -p 'fileexists($PATH)' -l hcl
sg -p 'templatefile($PATH, $VARS)' -l hcl

# Type functions
sg -p 'tostring($VALUE)' -l hcl
sg -p 'tonumber($VALUE)' -l hcl
sg -p 'tolist($VALUE)' -l hcl
sg -p 'tomap($VALUE)' -l hcl
sg -p 'toset($VALUE)' -l hcl

# Try function
sg -p 'try($$$EXPRESSIONS)' -l hcl
sg -p 'can($EXPRESSION)' -l hcl
```

## Common Audit Patterns

### Security Issues

```bash
# Hardcoded credentials
sg -p 'password = "$VALUE"' -l hcl
sg -p 'secret = "$VALUE"' -l hcl
sg -p 'api_key = "$VALUE"' -l hcl
sg -p 'access_key = "$VALUE"' -l hcl

# Public access
sg -p 'publicly_accessible = true' -l hcl
sg -p 'public_access = true' -l hcl

# Open CIDR blocks
sg -p 'cidr_blocks = ["0.0.0.0/0"]' -l hcl

# Unencrypted resources
sg -p 'encrypted = false' -l hcl
sg -p 'storage_encrypted = false' -l hcl
```

### Best Practices

```bash
# Missing lifecycle rules on critical resources
sg -p 'resource "aws_db_instance" "$NAME" { $$$BODY }' -l hcl | grep -v "lifecycle"

# Resources without tags
sg -p 'resource "$TYPE" "$NAME" { $$$BODY }' -l hcl

# Variables without descriptions
sg -p 'variable "$NAME" { type = $TYPE }' -l hcl

# Hardcoded values (should be variables)
sg -p 'region = "us-east-1"' -l hcl
sg -p 'instance_type = "t2.micro"' -l hcl
```

## Common Refactoring

```bash
# Rename resource type
sg -p 'resource "aws_instance" "$NAME" { $$$BODY }' \
   -r 'resource "aws_instance" "$NAME" { $$$BODY }' -l hcl

# Add tags to resources
sg -p 'resource "$TYPE" "$NAME" { $$$BODY }' -l hcl

# Update provider version constraint
sg -p 'version = "~> 4.0"' -r 'version = "~> 5.0"' -l hcl

# Migrate deprecated attributes
sg -p 'tags { $$$TAGS }' -r 'tags = { $$$TAGS }' -l hcl
```
