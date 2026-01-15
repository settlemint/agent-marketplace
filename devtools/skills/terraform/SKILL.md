---
name: terraform
description: Terraform/OpenTofu infrastructure as code patterns. READ-ONLY - Claude NEVER executes terraform commands.
license: MIT
triggers:
  [
    "terraform",
    "opentofu",
    "tofu",
    "terrafrom",
    "terrform",
    "\\.tf$",
    "tfvars",
    "tfstate",
    "provider\\s*[\"\\{]",
    "resource\\s*\"",
    "module\\s*\"",
    "data\\s*\"\\w+\"",
    "infrastructure.*(code|as)",
    "iac\\b",
    "hcl\\b",
    "aws_|azurerm_|google_",
    "hashicorp",
    "state\\s*(file|backend|lock)",
    "backend\\s*\"s3\"",
    "plan\\s+output",
    "apply\\s+change",
    "provision.*infra",
    "cloud\\s*resource",
  ]
---

<objective>
Write, review, and help manage Terraform/OpenTofu infrastructure code. Claude can run most terraform commands but **NEVER executes `apply` or `destroy`** - those must be run by the user.
</objective>

<critical_restriction>

## APPLY/DESTROY PROHIBITION

**Claude MUST NEVER execute `terraform apply` or `terraform destroy`. This is non-negotiable.**

### Forbidden Commands (NEVER run these):

```
terraform apply
terraform destroy
tofu apply
tofu destroy
```

### Allowed Commands (Claude CAN run these):

```
terraform init       # Initialize working directory
terraform plan       # Preview changes
terraform validate   # Validate configuration
terraform fmt        # Format code
terraform output     # Show outputs
terraform show       # Show state/plan
terraform state list # List resources in state
terraform workspace list  # List workspaces
terraform providers  # Show providers
tofu init/plan/validate/fmt/etc.
```

### Why apply/destroy Are Blocked:

1. **Infrastructure mutations are irreversible** - `terraform apply` can delete production databases
2. **terraform destroy removes everything** - Catastrophic if run accidentally
3. **Cost implications** - Can provision expensive resources instantly
4. **No rollback** - Unlike code, infrastructure changes often cannot be reverted

### What Claude CAN Do:

- Write `.tf` files with proper HCL syntax
- Run `terraform init` to initialize providers
- Run `terraform plan` to preview changes
- Run `terraform validate` and `terraform fmt`
- Review existing Terraform code for issues
- Suggest improvements to modules and resources
- Explain Terraform concepts and patterns
- Generate `terraform.tfvars` templates
- Write Terratest test files

### What The User Must Do:

- Run `terraform apply` to apply changes
- Run `terraform destroy` to remove infrastructure
- Review plan output before applying

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

<anti_patterns>

- **Hardcoded Values:** Magic strings/numbers in resources instead of variables
- **Monolithic State:** Single state file for entire infrastructure; split by environment/component
- **Missing Lifecycle Rules:** Databases without `prevent_destroy`; data loss risk
- **Implicit Dependencies:** Relying on implicit ordering instead of explicit `depends_on`
- **Unversioned Modules:** Using `main` branch for modules; always pin versions
  </anti_patterns>

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

Claude can run most terraform commands to help you work with infrastructure:

```bash
# Claude CAN run these:
terraform init           # Initialize providers
terraform plan -out=tfplan  # Preview changes
terraform validate       # Check syntax
terraform fmt -recursive # Format code
terraform output         # Show outputs
terraform show           # Show state

# YOU must run these (Claude is blocked):
terraform apply tfplan   # Apply changes
terraform destroy        # Remove infrastructure
```

**Claude helps with init, plan, validate, format. You run apply/destroy yourself.**

</user_instructions>

<library_ids>
Skip resolve step for these known IDs:

| Library   | Context7 ID                       |
| --------- | --------------------------------- |
| Terraform | /hashicorp/terraform              |
| AWS       | /hashicorp/terraform-provider-aws |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Terraform patterns",
      researchGoal: "Search for module and resource patterns",
      reasoning: "Need real-world examples of Terraform usage",
      keywordsToSearch: ["resource", "module", "variable", "terraform"],
      extension: "tf",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Modules: `keywordsToSearch: ["module", "source", "version", "terraform"]`
- AWS resources: `keywordsToSearch: ["aws_", "provider", "resource"]`
- State management: `keywordsToSearch: ["backend", "s3", "dynamodb_table"]`
- Lifecycle rules: `keywordsToSearch: ["lifecycle", "prevent_destroy", "ignore_changes"]`
  </research>

<related_skills>

**Kubernetes deployment:** Load via `Skill({ skill: "devtools:helm" })` when:

- Deploying to Kubernetes after infrastructure provisioning
- Managing Helm charts for applications on provisioned infrastructure

**CI/CD pipelines:** Load via `Skill({ skill: "devtools:turbo" })` when:

- Building monorepo that includes Terraform modules
- Running Terraform in CI pipelines
  </related_skills>

<success_criteria>

1. [ ] No terraform/tofu apply or destroy executed by Claude
2. [ ] All variables have description and type
3. [ ] All outputs have description
4. [ ] Sensitive values marked appropriately
5. [ ] Critical resources have lifecycle rules
6. [ ] Modules use explicit version constraints
7. [ ] No hardcoded secrets
8. [ ] User informed they must run apply/destroy
</success_criteria>

<evolution>
**Extension Points:**
- Add provider-specific patterns via references (AWS, GCP, Azure)
- Extend with Terratest templates for infrastructure testing
- Integrate with CI/CD patterns for automated plan/apply workflows

**Timelessness:** Infrastructure as Code is a foundational DevOps practice; Terraform/OpenTofu patterns apply regardless of cloud provider evolution.
</evolution>
