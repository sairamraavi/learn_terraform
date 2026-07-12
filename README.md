# Terraform Learning Exercises

This repository contains small Terraform exercises for managing AWS S3 buckets. It is intended for learning Terraform configuration, planning, applying changes, viewing outputs, and importing existing infrastructure into Terraform state.

## Repository layout

| Directory | Purpose |
| --- | --- |
| `simple_s3_tf/` | Creates one S3 bucket and returns its ARN. |
| `terraform_import/` | Brings two existing S3 buckets under Terraform management using declarative `import` blocks. |
| `notes.md` | General Terraform learning notes. |

Each exercise is a separate Terraform root module. Run Terraform commands from the exercise directory you want to work with.

## Install Terraform locally

Install Terraform on your operating system, then confirm that the installed version meets this repository's `>= 1.15.8` requirement.

### macOS

Install [Homebrew](https://brew.sh/) first if it is not already available, then run:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

### Windows

In PowerShell, install Terraform with Windows Package Manager and verify it:

```powershell
winget install Hashicorp.Terraform
terraform version
```

If `winget` is unavailable, download the Windows ZIP for your system architecture from the [official Terraform installation page](https://developer.hashicorp.com/terraform/install), extract `terraform.exe` to a directory such as `C:\Terraform`, and add that directory to your user `Path`:

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Terraform", "User")
```

Open a new PowerShell window, then run `terraform version`.

### Linux

For Ubuntu or Debian, add HashiCorp's official package repository and install Terraform:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
terraform version
```

For Fedora, RHEL, Amazon Linux, or a manual binary installation, use the commands for your distribution on HashiCorp's [official installation page](https://developer.hashicorp.com/terraform/install).

## Prerequisites

- Terraform `>= 1.15.8`
- AWS credentials configured for an account that can read, create, tag, and delete the relevant S3 buckets
- Access to the AWS region configured in `terraform.tfvars` (currently `ap-south-1`)

Terraform can use any standard AWS credential source, such as an AWS CLI profile or environment variables. Do not commit credentials or generated state files.

## Exercise 1: Create an S3 bucket

The [`simple_s3_tf/`](./simple_s3_tf/) module creates the bucket named by `bucket_name` and outputs its ARN.

```bash
cd simple_s3_tf
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output bucket_arn
```

Update `simple_s3_tf/terraform.tfvars` before applying if the default bucket name is not globally unique. S3 bucket names must be unique across all AWS accounts.

When you no longer need the resources created by this exercise, run:

```bash
terraform destroy
```

## Exercise 2: Import existing S3 buckets

The [`terraform_import/`](./terraform_import/) module manages two existing buckets through the `import` blocks in `imports.tf`. Their IDs must match the existing bucket names, and the configured AWS credentials must have access to them.

```bash
cd terraform_import
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform state list
```

`terraform apply` performs the declared imports and then reconciles the imported resources with `main.tf`. Review the plan carefully: changing `terraform.tfvars` or resource configuration can cause Terraform to propose changes to those existing buckets.

Avoid running `terraform destroy` in this module unless you deliberately intend to delete the imported buckets.

## Common commands

Run these from the relevant exercise directory:

```bash
# Format all Terraform files in the current module
terraform fmt

# Check formatting without modifying files
terraform fmt -check

# Validate configuration syntax and internal consistency
terraform validate

# Preview infrastructure changes
terraform plan

# Apply the reviewed changes
terraform apply

# Show module outputs
terraform output
```

## Configuration

Both modules use the AWS provider (`hashicorp/aws` `~> 6.0`) and accept values through `terraform.tfvars`:

- `aws_region` — AWS region for the provider.
- `bucket_name` — primary S3 bucket name.
- `sample_bucket_name` — second bucket used only by `terraform_import/`.
- `project_name` — learning metadata variable retained in the configuration.
