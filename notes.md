# Terraform - Infrastructure as Code

## Table of Contents
1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
3. [Terraform Architecture](#terraform-architecture)
4. [Terraform Terminology](#terraform-terminology)
5. [Write](#write)
6. [Plan](#plan)
7. [Execute](#execute)
8. [Basic Syntax](#basic-syntax)
9. [Providers & Resources](#providers--resources)
10. [State Management](#state-management)
11. [Best Practices](#best-practices)
12. [Common Commands](#common-commands)

---

## Overview

Terraform is an open-source Infrastructure as Code (IaC) tool developed by HashiCorp. It allows you to define, preview, and deploy cloud infrastructure using a declarative configuration language (HCL - HashiCorp Configuration Language).

**Key Benefits:**
- Infrastructure version control
- Reusable configurations
- Multi-cloud support (AWS, Azure, GCP, etc.)
- Automation and consistency
- Easy collaboration

---

## Core Concepts

Terraform follows a three-step workflow:

### **1. Write**
- Define infrastructure resources in `.tf` files
- Use HCL (declarative syntax)
- Organize code into modules for reusability
- Specify providers (AWS, Azure, Google Cloud, etc.)

### **2. Plan**
- Review what changes will be made
- Preview resource creation, modification, or deletion
- Identify potential issues before execution
- Helps prevent mistakes and unexpected changes

### **3. Execute (Apply)**
- Apply the planned changes to infrastructure
- Create, update, or delete resources
- Maintain state file for tracking infrastructure
- Idempotent - safe to run multiple times

---

## Terraform Architecture

### Core Components

Terraform's architecture consists of four main layers:

#### **1. Configuration Layer (HCL)**
- **HashiCorp Configuration Language (HCL)** - Human-readable syntax
- `.tf` files define desired infrastructure state
- Declarative format (what you want, not how to achieve it)
- Parsed and validated before execution

#### **2. State Layer**
- **Terraform State File** (`terraform.tfstate`) - JSON file tracking actual infrastructure
- Maps configuration resources to real resources
- Contains metadata, resource IDs, and attribute values
- Critical for tracking changes and dependencies
- Can be stored locally or remotely

#### **3. Backend Layer**
- Manages state file storage and locking
- **Local Backend** - State stored on local disk (default)
- **Remote Backends** - S3, Azure Blob Storage, Terraform Cloud, etc.
- Enables team collaboration and prevents concurrent modifications

#### **4. Provider Layer**
- Interfaces with cloud platforms and services
- **Official Providers** - Maintained by HashiCorp (AWS, Azure, GCP)
- **Community Providers** - Maintained by community
- Translates Terraform code into API calls

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Terraform Workflow                       │
└─────────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐         ┌───▼────┐        ┌───▼────┐
    │ Write  │         │  Plan  │        │ Apply  │
    │ (Write)│         │(Refresh│        │(Execute│
    │        │         │ & Plan)│        │        │
    └────┬───┘         └────┬───┘        └────┬───┘
         │                  │                  │
    ┌────▼──────────────────┼──────────────────▼────┐
    │                 HCL Parser                     │
    │          (Configuration Parsing)              │
    └────┬──────────────────┬──────────────────┬────┘
         │                  │                  │
    ┌────▼──────┐      ┌────▼──────┐      ┌───▼─────┐
    │  Variables │      │  Locals   │      │Resources│
    └────┬──────┘      └────┬──────┘      └───┬─────┘
         │                  │                  │
         └──────────────────┼──────────────────┘
                            │
                ┌───────────▼──────────────┐
                │   State Management      │
                │  (terraform.tfstate)    │
                └───────────┬──────────────┘
                            │
                ┌───────────▼──────────────┐
                │   Backend Storage       │
                │ (Local/Remote/S3/etc)   │
                └───────────┬──────────────┘
                            │
                ┌───────────▼──────────────┐
                │   Provider Layer        │
                │ (AWS/Azure/GCP/etc)     │
                └───────────┬──────────────┘
                            │
                ┌───────────▼──────────────┐
                │   Cloud APIs            │
                │  (Create/Update/Delete) │
                └────────────────────────┘
```

### Component Interaction Flow

```
User Commands
     │
     ▼
┌─────────────────────┐
│ terraform init      │  ← Download providers & modules
│ terraform validate  │  ← Syntax check
│ terraform fmt       │  ← Format code
└─────────┬───────────┘
          │
          ▼
┌─────────────────────────────────────┐
│   Configuration Files (.tf)         │
│  ├── main.tf                        │
│  ├── variables.tf                   │
│  ├── outputs.tf                     │
│  └── provider.tf                    │
└─────────┬───────────────────────────┘
          │
          ▼
    terraform plan
          │
    ┌─────┴─────┐
    │           │
    ▼           ▼
 Refresh    Compare with
 Current    Desired State
 State          │
    │           │
    └─────┬─────┘
          │
          ▼
    Execution Plan
    (resource changes)
          │
          ▼
    terraform apply
          │
    ┌─────┴──────────┐
    │                │
    ▼                ▼
Execute       Update State
API Calls     File with new
              resource IDs
    │                │
    └─────┬──────────┘
          │
          ▼
    terraform.tfstate
    (Updated State)
```

### State Management Architecture

```
┌──────────────────────────────────────────────────┐
│          State File Structure                    │
│  ┌────────────────────────────────────────────┐  │
│  │  Version: 4                                │  │
│  │  Terraform Version: 1.0.0                  │  │
│  │  Serial: 42                                │  │
│  │  Lineage: uuid                             │  │
│  │                                            │  │
│  │  Resources:                                │  │
│  │  [{                                        │  │
│  │    type: "aws_instance"                   │  │
│  │    name: "web"                            │  │
│  │    instances: [{                          │  │
│  │      id: "i-1234567890"                   │  │
│  │      attributes: {...}                    │  │
│  │    }]                                      │  │
│  │  }]                                        │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
         │                          │
    ┌────▼────┐            ┌───────▼──────┐
    │  Local  │            │Remote Backend│
    │ Storage │            │  (S3, Azure, │
    │         │            │ Terraform    │
    │         │            │ Cloud, etc)  │
    └─────────┘            └──────────────┘
```

### Provider Architecture

```
┌─────────────────────────────────────────────────┐
│         Terraform Provider System               │
├─────────────────────────────────────────────────┤
│                                                 │
│  Provider Requirements (terraform.tf)           │
│  ├── Source: hashicorp/aws                      │
│  ├── Version: ~> 5.0                           │
│  └── Configuration: region, credentials         │
│                     │                           │
│  Provider Instance                              │
│  └── Initialization with credentials            │
│      ├── Load credentials (AWS_ACCESS_KEY_ID)   │
│      ├── Validate permissions                   │
│      └── Initialize API client                  │
│                     │                           │
│  Resource Types                                 │
│  ├── aws_instance                               │
│  ├── aws_vpc                                    │
│  ├── aws_subnet                                 │
│  └── 100+ more resource types                   │
│                     │                           │
│  CRUD Operations                                │
│  ├── Create (POST)                              │
│  ├── Read (GET)                                 │
│  ├── Update (PUT)                               │
│  └── Delete (DELETE)                            │
│                     │                           │
│  Cloud Provider API                             │
│  └── AWS/Azure/GCP API Calls                    │
└─────────────────────────────────────────────────┘
```

### Execution Flow in Detail

#### **terraform init**
```
1. Initialize .terraform directory
2. Download provider plugins
3. Create .terraform.lock.hcl (version locking)
4. Initialize backend
5. Create local state file (if local backend)
```

#### **terraform plan**
```
1. Read configuration (.tf files)
2. Validate syntax and semantics
3. Load current state (from backend)
4. Connect to providers
5. Refresh current state from cloud providers
6. Compare desired vs. actual state
7. Generate execution plan (add/change/delete)
8. Display plan to user
```

#### **terraform apply**
```
1. Read configuration and execution plan
2. Ask for approval (or -auto-approve)
3. Connect to providers
4. Execute create/update/delete operations
5. Update state file with new resource IDs
6. Display outputs
7. Save updated state to backend
```

### Key Architectural Principles

#### **Declarative Model**
- You declare **what** infrastructure you want
- Terraform determines **how** to achieve it
- State file tracks the gap between desired and actual

#### **Idempotency**
- Running terraform apply multiple times is safe
- Only changes are applied, not all resources
- State prevents redundant operations

#### **State as Source of Truth**
- State file is the single source of truth
- Real resources match the state file
- Losing state is catastrophic (loss of tracking)

#### **Provider Abstraction**
- Single code can target multiple cloud providers
- Consistent syntax across different platforms
- Reduces vendor lock-in

#### **Graph-Based Dependency Resolution**
- Terraform builds a dependency graph
- Understands resource relationships
- Parallelizes non-dependent operations
- Ensures correct execution order

### Common Architectures

#### **Single Region (Simple)**
```
User → Terraform CLI → Local State → AWS Region
```

#### **Multi-Region (Complex)**
```
User → Terraform CLI → Remote State (S3/DynamoDB) → AWS Regions
                                    │
                                    └→ Multiple Workspaces
```

#### **Team Collaboration**
```
Developer → VCS (Git) → Terraform Cloud/Enterprise
                               │
                               └→ Run Queue → Apply
                               
            Remote State → Consistent Infrastructure
```

---

## Terraform Terminology

### Core Terms

#### **Resource**
- A managed object in your infrastructure (e.g., EC2 instance, VPC, RDS database)
- Declared in configuration files with a type and name
- Example: `resource "aws_instance" "web_server" { ... }`
- Terraform tracks resources in the state file

#### **Provider**
- A plugin that interfaces with cloud platforms or services
- Authenticates to cloud providers and manages resources
- Configured with credentials and regional settings
- Examples: AWS, Azure, GCP, Kubernetes, Docker

#### **Module**
- A reusable package of Terraform configurations
- Contains resources, variables, and outputs
- Can be local or from Terraform Registry
- Enables code organization and reusability
- Example: `module "vpc" { source = "./modules/vpc" }`

#### **State File** (`terraform.tfstate`)
- JSON file that tracks real infrastructure resources
- Contains resource IDs, attributes, and metadata
- Terraform's source of truth for what exists
- Must be protected and backed up
- Never should be committed to version control

#### **Backend**
- Storage location for state files
- Can be local (default) or remote (S3, Terraform Cloud, etc.)
- Enables team collaboration and state locking
- Prevents concurrent modifications

#### **Variable**
- Input parameter for Terraform configurations
- Defined with type and optional default value
- Can be overridden via `.tfvars` files or CLI flags
- Promotes code reusability
- Example: `variable "instance_type" { type = string }`

#### **Output**
- Value returned from Terraform after resource creation
- Used to expose important resource information
- Can be queried with `terraform output` command
- Useful for passing data between modules
- Example: `output "instance_ip" { value = aws_instance.web.public_ip }`

#### **Data Source**
- Read-only reference to existing infrastructure
- Queries cloud provider for current information
- Does not create or manage resources
- Used to fetch existing resources
- Example: `data "aws_ami" "ubuntu" { ... }`

#### **Local Value** (Locals)
- Local variable for within-module use
- Computed from other values
- Cannot be overridden by users
- Useful for repeated expressions
- Example: `locals { environment = "production" }`

### Workflow Terms

#### **Plan**
- Preview of infrastructure changes
- Shows what will be added, changed, or destroyed
- No resources are created during planning
- Output: Execution plan file (`.tfplan`)

#### **Apply**
- Execute the planned infrastructure changes
- Creates, updates, or deletes resources
- Updates the state file with new resource information
- Idempotent - safe to run multiple times

#### **Destroy**
- Remove all infrastructure managed by Terraform
- Deletes all resources from the state file
- Be cautious with production environments
- Command: `terraform destroy`

#### **Refresh**
- Update state file with actual cloud resource status
- Queries cloud provider for current state
- Happens automatically during `terraform plan` and `terraform apply`
- Manual refresh: `terraform refresh`

#### **Drift**
- Difference between desired state (configuration) and actual state (infrastructure)
- Occurs when resources are manually modified outside Terraform
- Detected by `terraform plan`
- Can cause unexpected behavior

### Configuration Terms

#### **HCL** (HashiCorp Configuration Language)
- Terraform's configuration language
- Human-readable, declarative syntax
- Combines JSON-like syntax with Ruby-like features
- Files use `.tf` extension

#### **Root Module**
- Primary Terraform configuration directory
- Contains main.tf, variables.tf, outputs.tf
- Can reference child modules
- Executed when running terraform commands

#### **Child Module**
- Reusable module called by root or other modules
- Located in subdirectories or remote repositories
- Encapsulates related resources
- Receives inputs via module arguments

#### **Workspace**
- Named state environment within a backend
- Allows multiple states with same configuration
- Default workspace: `default`
- Useful for dev/staging/prod environments
- Command: `terraform workspace`

#### **Lock File** (`.terraform.lock.hcl`)
- Records exact provider versions used
- Ensures consistency across team
- Should be committed to version control
- Prevents unintended provider upgrades

#### **Dependency**
- Relationship between resources
- Explicit: declared with `depends_on`
- Implicit: referenced resource attributes
- Terraform builds dependency graph to determine execution order

### State Management Terms

#### **Remote State**
- State file stored on remote backend (S3, Terraform Cloud, etc.)
- Enables team collaboration
- Provides centralized state management
- Can be encrypted and locked

#### **State Lock**
- Mechanism to prevent concurrent modifications
- Implemented via DynamoDB (AWS) or similar
- Prevents race conditions
- Automatically managed by Terraform

#### **State Migration**
- Process of moving state from one backend to another
- Uses `terraform init` with new backend configuration
- Can be automatic or manual

#### **Resource Import**
- Add existing infrastructure to Terraform state
- Does not create configuration automatically
- Useful for managing legacy infrastructure
- Command: `terraform import`

### Advanced Terms

#### **Provisioner**
- Used to run scripts or commands on resources
- Types: `local-exec`, `remote-exec`
- Not recommended for production use
- Alternative: Use user data, cloud-init, or configuration management

#### **Splat Expression**
- Extract values from multiple resources
- Syntax: `resource_type.*.attribute`
- Simplifies working with lists of resources
- Example: `aws_instance.web.*.id` (all instance IDs)

#### **Interpolation**
- Embed variables and expressions in strings
- Syntax: `${var.variable_name}` or `${resource.attribute}`
- Automatically triggered by Terraform

#### **For Expression**
- Loop through values to create multiple resources
- Syntax: `for item in list : item => expression`
- More flexible than count

#### **Count**
- Create multiple instances of a resource
- Meta-argument: `count.index`, `count.each`
- Alternative to `for_each`
- Each instance has independent state

#### **For Each**
- Create multiple instances using a map or set
- More readable than count in most cases
- Preserves individual resource state
- Better for dynamic resource creation

#### **Meta-Arguments**
- Arguments that apply to any resource
- Types: `count`, `for_each`, `depends_on`, `lifecycle`, `provider`
- Control resource behavior and relationships

#### **Lifecycle Hooks**
- Control resource creation, update, or deletion behavior
- Types: `create_before_destroy`, `prevent_destroy`, `ignore_changes`
- Used in `lifecycle` block

#### **Conditional Logic**
- Ternary operator: `condition ? true_value : false_value`
- Used to create resources conditionally
- Example: `create = var.environment == "prod" ? true : false`

### Interaction Terms

#### **Apply/Destroy Target**
- `-target` flag to apply/destroy specific resources
- Useful for testing or fixing individual resources
- Use cautiously as it can create inconsistencies
- Syntax: `terraform apply -target=aws_instance.web`

#### **Parallelism**
- Number of concurrent resource operations
- Default: 10
- Configured with `-parallelism=n` flag
- Terraform respects dependencies even with parallelism

#### **Validate**
- Check syntax and semantic validity of configuration
- Does not access remote state or cloud provider
- Catches errors before planning
- Command: `terraform validate`

#### **Format**
- Auto-format Terraform code to canonical style
- Enforces consistent coding standards
- Command: `terraform fmt`
- Recursive: `terraform fmt -recursive`

#### **Console**
- Interactive REPL for testing expressions
- Query resources and variables
- Test functions and interpolation
- Command: `terraform console`

### File Organization Terms

#### **Configuration Files** (`.tf`)
- Main Terraform files
- Convention: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`
- Multiple files in same directory are automatically combined

#### **Variable Definition File** (`.tfvars`)
- Assign values to variables
- Convention: `terraform.tfvars` (automatically loaded)
- Can create multiple for different environments
- Use `-var-file` flag to specify

#### **Override Files**
- `override.tf` and `override.tf.json` override other definitions
- Useful for temporary changes or testing
- Processed last

#### **Ignored Files**
- Standard: `terraform.tfstate`, `.terraform/`, `*.tfstate*`, `.terraform.lock.hcl`
- Should be in `.gitignore`

---

## Write
```
project/
├── main.tf          # Primary configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── terraform.tfvars # Variable values
├── provider.tf      # Provider configuration
└── modules/
    └── networking/
```

### Basic Example: AWS EC2 Instance
```hcl
# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# main.tf
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "MyInstance"
  }
}

# variables.tf
variable "aws_region" {
  default = "us-east-1"
}

# outputs.tf
output "instance_id" {
  value = aws_instance.example.id
}
```

---

## Plan

The `terraform plan` command:
- Reads your configuration files
- Compares desired state with current state
- Generates an execution plan
- Shows exactly what will change

```bash
# Generate and review the plan
terraform plan

# Save plan to a file for later application
terraform plan -out=tfplan

# Show detailed plan
terraform plan -detailed-exitcode
```

**Plan Output Example:**
```
Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                    = "ami-0c55b159cbfafe1f0"
      + instance_type          = "t2.micro"
      + tags                   = {
          + "Name" = "MyInstance"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

## Execute

### Apply Changes
```bash
# Interactively apply (requires approval)
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Apply a saved plan
terraform apply tfplan
```

### Destroy Infrastructure
```bash
# Remove all resources
terraform destroy

# Destroy without confirmation
terraform destroy -auto-approve

# Destroy specific resources
terraform destroy -target=aws_instance.example
```

### Other Useful Commands
```bash
# Initialize working directory (download providers)
terraform init

# Validate configuration syntax
terraform validate

# Format code according to standards
terraform fmt

# Show current state
terraform show

# Show specific resource
terraform state show aws_instance.example

# List all resources in state
terraform state list
```

---

## Basic Syntax

### Resource Declaration
```hcl
resource "resource_type" "resource_name" {
  argument1 = "value1"
  argument2 = "value2"
}
```

### Variables
```hcl
# Declaration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Usage
instance_type = var.instance_type

# Assignment (terraform.tfvars)
instance_type = "t2.small"
```

### Outputs
```hcl
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.example.public_ip
}
```

### Locals
```hcl
locals {
  common_tags = {
    Environment = "production"
    Project     = "MyProject"
  }
}

tags = local.common_tags
```

### Data Sources
```hcl
# Fetch existing AWS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }
}
```

---

## Providers & Resources

### Commonly Used Providers
- **AWS** - Amazon Web Services
- **Azure** - Microsoft Azure
- **GCP** - Google Cloud Platform
- **Kubernetes** - Container orchestration
- **Docker** - Container images and containers

### Example: Multi-Provider Configuration
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}
```

---

## State Management

### What is State?
- Terraform tracks infrastructure in a `terraform.tfstate` file
- JSON format containing resource metadata
- Critical for Terraform to map config to real resources
- Never commit to version control (use `.gitignore`)

### State File Operations
```bash
# View state
terraform show

# List resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.example

# Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state (doesn't destroy)
terraform state rm aws_instance.example

# Backup state
terraform state pull > backup.tfstate
```

### Remote State (Best Practice)
```hcl
# Using S3 backend
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

## Best Practices

### 1. **Module Organization**
```hcl
# Root module calls child modules
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
}
```

### 2. **Use Remote State**
- Store state in S3, Terraform Cloud, or similar
- Enable state locking to prevent conflicts
- Encrypt state files

### 3. **Version Control**
```bash
# .gitignore
terraform.tfstate*
.terraform/
.terraform.lock.hcl
*.tfvars
!example.tfvars
```

### 4. **Naming Conventions**
```hcl
resource "aws_instance" "web_server" {  # snake_case
  tags = {
    Name = "WebServer"  # PascalCase
  }
}
```

### 5. **Use Input Validation**
```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 6. **Document Everything**
```hcl
variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t2.micro"
}
```

### 7. **Use Workspaces for Environments**
```bash
# Create separate environments
terraform workspace new prod
terraform workspace new dev
terraform workspace select prod
```

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize Terraform working directory |
| `terraform validate` | Validate configuration files |
| `terraform fmt` | Format code |
| `terraform plan` | Create execution plan |
| `terraform apply` | Apply changes |
| `terraform destroy` | Remove all resources |
| `terraform state` | Manage state |
| `terraform import` | Import existing resources |
| `terraform get` | Download modules |
| `terraform workspace` | Manage workspaces |
| `terraform console` | Interactive console for testing expressions |

---

## Example: Complete AWS Setup

```hcl
# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# main.tf
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "primary" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "primary-subnet"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.primary.id
  
  tags = {
    Name = "web-server"
  }
}

# variables.tf
variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

# outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "instance_ip" {
  value = aws_instance.web.private_ip
}

output "instance_id" {
  value = aws_instance.web.id
}
```

---

## Getting Started

1. **Install Terraform** - Download from [terraform.io](https://www.terraform.io)
2. **Configure Provider Credentials** - Set up AWS/Azure/GCP credentials
3. **Create Configuration Files** - Write `.tf` files
4. **Run `terraform init`** - Initialize working directory
5. **Run `terraform plan`** - Review changes
6. **Run `terraform apply`** - Deploy infrastructure

---

## Resources

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io) - Providers and modules
- [HashiCorp Learning](https://learn.hashicorp.com/terraform) 