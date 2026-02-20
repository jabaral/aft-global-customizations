# AFT Global Customizations

[![Checkov](https://github.com/jabaral/aft-global-customizations/.github/workflows/checkov.yml/badge.svg)](https://github.com/jabaral/aft-global-customizations/.github/workflows/checkov.yml)
[![TFLint](https://github.com/jabaral/aft-global-customizations/.github/workflows/tflint.yml/badge.svg)](https://github.com/jabaral/aft-global-customizations/.github/workflows/tflint.yml)
[![Terraform Docs](https://github.com/jabaral/aft-global-customizations/.github/workflows/terraform-docs.yml/badge.svg)](https://github.com/jabaral/aft-global-customizations/.github/workflows/terraform-docs.yml)

# Introduction
This repo stores the Terraform and API helpers for the Global Customizations. Global Customizations are used to customize all provisioned accounts with customer defined resources. The resources can be created through Terraform or through Python, leveraging the API helpers. The customization run is parameterized at runtime.

# Usage
To leverage Global Customizations, populate this repo as per the instructions below.

## Terraform
AFT provides Jinja templates for Terraform backend and providers. These render at the time Terraform is applied. If needed, additional providers can be defined by creating a providers.tf file.

To create Terraform resources, provide your own Terraform files (ex. main.tf, variables.tf, etc) with the resources you would like to create, placing them in the 'terraform' directory.

## API Helpers
The purpose of API helpers is to perform actions that cannot be performed within Terraform.

### Python
The api_helpers/python folder contains a requirements.txt, where you can specify libraries/packages to be installed via PIP.

### Bash
This is where you define what runs before/after Terraform, as well as the order the Python scripts execute, along with any command line parameters. These bash scripts can be extended to perform other actions, such as leveraging the AWS CLI or performing additional/custom Bash scripting.

- pre-api-helpers.sh - Actions to execute prior to running Terraform.
- post-api-helpers.sh - Actions to execute after running Terraform.

### Sample api-helpers.sh

Sample #1 - Using AWS CLI to query for resources, save to a variable, and then pass to a script. In the example below, all running instances are queried, stopped, and started using AWS CLI and custom Python scritpts.
```
instances=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running")
python ./python/source/stop_instances.py --instances $instances
sleep 10s
python ./python/source/start_instances.py --instances $instances
```

Sample #2 - Query a 3rd party IPAM solution, and save the given CIDR to AWS Parameter Store. This SSM parameter could be leveraged from Terraform using a data object to create a VPC.
```
account = $(aws sts get-caller-identity --query Account --output text)
region = $(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].[RegionName]' --output text)
cidr = $(python ./python/source/get_cidr_range.py)
aws ssm put-parameter --name /$account/$region/vpc/cidr --value $cidr
```


---

## GitOps Workflow

This repository follows a GitOps approach where changes are automatically applied by AFT when merged to the appropriate branch.

### Environments
- **Production**: `main` branch → ca-central-1
- **Test**: `test` branch → ca-central-1

### Workflow
1. Create feature branch from `main` or `test`
2. Make changes to Terraform code
3. Create pull request to target branch (`main` or `test`)
4. Automated validation runs:
   - Security scanning (Checkov)
   - Terraform linting (TFLint)
   - Documentation generation
   - Link validation
5. Review and approve PR
6. Merge to target branch
7. AFT automatically applies changes to corresponding environment

### GitHub Actions

All pull requests are validated with:
- **Checkov**: Security and compliance scanning
- **TFLint**: Terraform best practices validation
- **Terraform Docs**: Auto-generated documentation
- **Link Checker**: Documentation link validation
- **Release Notes**: Ensures RELEASE_NOTES.md is updated

### Pre-commit Hooks (Local Validation)

Run the same checks locally before committing:

```bash
# One-time setup
./setup-pre-commit.sh

# Or manual setup
pip install pre-commit
pre-commit install

# Hooks run automatically on commit
git commit -m "feat: Add new resource"
```

See [PRE_COMMIT_SETUP.md](PRE_COMMIT_SETUP.md) for detailed setup instructions.

For detailed workflow documentation, see:
- [GITHUB_ACTIONS_DOCUMENTATION.md](GITHUB_ACTIONS_DOCUMENTATION.md) - Complete workflow documentation
- [WORKFLOWS_QUICK_REFERENCE.md](WORKFLOWS_QUICK_REFERENCE.md) - Quick reference guide
- [GITHUB_ACTIONS_REVIEW_SUMMARY.md](GITHUB_ACTIONS_REVIEW_SUMMARY.md) - Summary of changes

### Branch Protection

Recommended branch protection rules:

- Require pull request reviews
- Require status checks to pass before merging
- Require branches to be up to date before merging

---
