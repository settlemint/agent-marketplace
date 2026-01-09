---
name: terraform
description: Terraform/OpenTofu infrastructure as code patterns. READ-ONLY - Claude NEVER executes terraform commands.
triggers:
  [
    "terraform",
    "opentofu",
    "tofu",
    "\\.tf$",
    "tfvars",
    "tfstate",
    "provider\\s*\"",
  ]
---

<objective>
Write and review Terraform/OpenTofu infrastructure code. **Claude is READ-ONLY for Terraform - it writes .tf files but NEVER executes terraform/tofu commands.**
</objective>

<critical_restriction>

## ABSOLUTE PROHIBITION - READ THIS FIRST

**Claude MUST NEVER execute ANY Terraform or OpenTofu commands. This is non-negotiable.**

### Forbidden Commands (NEVER run these):

```
terraform init
terraform plan
terraform apply
terraform destroy
terraform import
terraform state *
terraform workspace *
terraform refresh
terraform taint
terraform untaint
terraform validate
terraform fmt
tofu init
tofu plan
tofu apply
tofu destroy
tofu import
tofu state *
```

### Why This Restriction Exists:

1. **Infrastructure mutations are irreversible** - `terraform apply` can delete production databases
2. **State file corruption** - Running terraform without proper state access corrupts infrastructure
3. **Cost implications** - Terraform can provision expensive resources instantly
4. **Security risks** - Terraform has full cloud provider credentials access
5. **No rollback** - Unlike code, infrastructure changes often cannot be reverted

### What Claude CAN Do:

- Write `.tf` files with proper HCL syntax
- Review existing Terraform code for issues
- Suggest improvements to modules and resources
- Explain Terraform concepts and patterns
- Generate `terraform.tfvars` templates
- Write Terratest test files

### What The User Must Do:

- Run `terraform init` locally
- Run `terraform plan` to preview changes
- Run `terraform apply` to apply changes
- Manage state files and workspaces
- Handle provider authentication

</critical_restriction>

<quick_start>

**Provider configuration:**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

**Module structure:**

```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── rds/
│   └── ...
environments/
├── prod/
│   ├── main.tf
│   ├── terraform.tfvars
│   └── backend.tf
├── staging/
│   └── ...
```

</quick_start>

<constraints>

**Banned:**

- Running ANY terraform/tofu commands (see critical_restriction)
- Hardcoded secrets in .tf files
- Resources without lifecycle blocks for critical infrastructure
- Missing `prevent_destroy` on databases/storage
- Inline policies instead of managed policies
- Resources without tags
- Using `count` when `for_each` is more appropriate

**Required:**

- All variables must have `description` and `type`
- All outputs must have `description`
- Use `terraform fmt` style (user runs locally)
- Sensitive variables marked with `sensitive = true`
- Lifecycle rules for stateful resources
- Module versioning with explicit versions

**Naming:** Resources=`snake_case`, Modules=`kebab-case`, Variables=`snake_case`

</constraints>

<patterns>

**Variables with validation:**

```hcl
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Only t2 and t3 instances allowed."
  }
}
```

**Lifecycle rules for critical resources:**

```hcl
resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}"
  # ... other config

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [password]
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.project}-${var.environment}-data"

  lifecycle {
    prevent_destroy = true
  }
}
```

**Dynamic blocks:**

```hcl
resource "aws_security_group" "main" {
  name        = "${var.project}-sg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

**Module composition:**

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"  # Always pin versions

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = var.environment != "prod"

  tags = local.common_tags
}
```

</patterns>

<user_instructions>

When you need to test or apply Terraform changes, run these commands locally:

```bash
# Initialize (downloads providers)
terraform init

# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Preview changes (REVIEW CAREFULLY)
terraform plan -out=tfplan

# Apply changes (DESTRUCTIVE - review plan first!)
terraform apply tfplan

# Destroy (VERY DESTRUCTIVE)
terraform destroy
```

**Claude will write the .tf files. You must run these commands yourself.**

</user_instructions>

<success_criteria>

- [ ] No terraform/tofu commands executed by Claude
- [ ] All variables have description and type
- [ ] All outputs have description
- [ ] Sensitive values marked appropriately
- [ ] Critical resources have lifecycle rules
- [ ] Modules use explicit version constraints
- [ ] No hardcoded secrets
- [ ] User instructed to run commands locally

</success_criteria>
