# GitHub Actions Documentation - AFT Global Customizations (GitOps)

## Overview

This repository uses GitHub Actions to automate validation and quality checks for AWS Account Factory for Terraform (AFT) Global Customizations. This is a **GitOps-based repository** where changes are applied automatically by AFT when merged to the appropriate branch. No direct deployments are performed by GitHub Actions.

## Repository Structure

### Environments
- **Production (prod)**: `main` branch → ca-central-1
- **Test**: `test` branch → ca-central-1

### Region
- **ca-central-1**: Single region for both environments

## Active Workflows

All workflows trigger on pull requests to `main` or `test` branches to validate changes before they're merged and applied by AFT.

### 1. Security & Code Quality Workflows

#### checkov.yml - Infrastructure Security Scanning
**Purpose**: Scans Terraform code for security vulnerabilities and compliance issues

**Triggers**:
- Pull requests to `main` or `test` branches
- Changes to `*.tf` or `*.tfvars` files
- Manual workflow dispatch

**Key Features**:
- **Smart directory detection**: Only scans directories with changes
- **Suppression tracking**: Detects and reports:
  - TFLint suppressions (`tflint-ignore`)
  - Checkov suppressions (`checkov:skip`)
  - Module references without version tags
- **PR comments**: Posts automated code review warnings
- **SARIF upload**: Integrates findings with GitHub Security tab
- **Matrix strategy**: Scans each changed directory in parallel

**Configuration** (`.github/workflow-configs/checkov_config.yaml`):
```yaml
branch: main
framework:
  - terraform
  - github_actions
output:
  - sarif
skip-check:
  - CKV_TF_1      # Terraform version constraint
  - CKV2_GHA_1    # GitHub Actions check
```

**Process**:
1. Detects which directories have Terraform changes
2. Scans for suppressions and non-versioned module references
3. Runs Checkov security scan on each changed directory
4. Posts findings as PR comment
5. Uploads SARIF results to GitHub Security

#### tflint.yml - Terraform Linting
**Purpose**: Validates Terraform code syntax and best practices

**Triggers**:
- Pull requests to `main` or `test` branches
- Changes to `*.tf` or `*.tfvars` files
- Manual workflow dispatch

**Process**:
1. Checks out repository
2. Sets up TFLint
3. Initializes TFLint with plugins
4. Runs recursive linting across all Terraform files

**Configuration**: Uses `.tflint.hcl` if present in repository root

### 2. Documentation Workflows

#### terraform-docs.yml - Auto-generate Documentation
**Purpose**: Automatically generates and updates Terraform documentation in README files

**Triggers**:
- Pull requests to `main` or `test` branches
- Changes to `*.tf`, `*.tfvars`, or `*.md` files

**Process**:
1. Checks out the PR branch
2. Finds all directories with Terraform files
3. Generates documentation using terraform-docs
4. Injects documentation into README.md files
5. Commits changes back to the PR branch

**Usage**: Add the following markers to your README.md files:
```markdown
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

Documentation will be automatically injected between these markers.

#### link-checker.yml - Documentation Link Validation
**Purpose**: Validates all links in Markdown files to prevent broken documentation

**Triggers**:
- Pull requests to `main` or `test` branches
- Manual workflow dispatch

**Configuration** (`.github/workflow-configs/link-checker_config.json`):
```json
{
  "aliveStatusCodes": [200, 206],
  "retryCount": 5,
  "timeout": "20s",
  "ignorePatterns": [
    {"pattern": "^http[s]*.*example.com"},
    {"pattern": "^#[a-z\\/_]*"},
    {"pattern": "*/actions/workflows/*.yml$"}
  ]
}
```

### 3. Maintenance Workflows

#### pull-request-check.yml - Release Notes Validation
**Purpose**: Ensures release notes are updated for changes that will be released

**Triggers**:
- Pull requests to `main` or `test` branches

**Process**:
1. Checks commit message for `#norelease` flag
2. If flag is absent, verifies `RELEASE_NOTES.md` has been updated
3. Fails PR if release notes are missing

**Usage**: 
- Add `#norelease` to commit message to skip release notes requirement
- Update `RELEASE_NOTES.md` for all other changes

#### stale.yml - Issue Management
**Purpose**: Automatically manages stale issues

**Triggers**:
- Daily schedule (midnight UTC)
- Manual workflow dispatch

**Configuration**:
- Marks issues stale after 15 days of inactivity
- Closes stale issues after additional 15 days
- Exempts issues with labels: `question`, `MUST-DO`, `mustfix`, `enhancement`

## Workflow Permissions

All workflows follow the principle of least privilege:

```yaml
permissions:
  contents: read          # Read repository code
  security-events: write  # Upload security findings
  actions: read          # Read workflow status
  pull-requests: write   # Comment on PRs
```

## Required Secrets

### GitHub Tokens
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions (no configuration needed)

**Note**: No AWS credentials or Terraform Enterprise tokens are needed since this is a GitOps repository. AFT handles all deployments.

## GitOps Workflow

### How Changes Are Applied

1. **Developer creates PR** to `main` (prod) or `test` branch
2. **GitHub Actions run validation**:
   - Checkov security scan
   - TFLint validation
   - Terraform docs generation
   - Link checking
   - Release notes verification
3. **PR is reviewed and approved** by team members
4. **PR is merged** to target branch
5. **AFT detects the change** and automatically applies it to the corresponding environment
6. **AFT provisions resources** in ca-central-1 region

### Branch Strategy

```
┌─────────────┐
│   Feature   │
│   Branch    │
└──────┬──────┘
       │
       ├──────► PR to test ──► Merge ──► AFT applies to test environment
       │
       └──────► PR to main ──► Merge ──► AFT applies to prod environment
```

## Best Practices Implemented

1. **Path filtering**: Workflows only trigger on relevant file changes
2. **Branch protection**: Validation must pass before merge
3. **Security scanning**: Automated Checkov and TFLint checks
4. **Documentation**: Auto-generated and always up-to-date
5. **SARIF reporting**: Security findings integrated with GitHub Security tab
6. **Matrix strategies**: Parallel execution for efficiency
7. **Suppression tracking**: Visibility into security exceptions
8. **Link validation**: Prevents broken documentation

## Configuration Files

### Linter Configurations
Located in `.github/linters/`:
- `.jscpd.json` - Copy-paste detection
- `.markdown-lint.yml` - Markdown linting rules
- `.python-lint` - Python linting (if needed in future)
- `.yaml-lint.yml` - YAML linting rules
- `actionlint.yml` - GitHub Actions workflow linting

### Workflow Configurations
Located in `.github/workflow-configs/`:
- `checkov_config.yaml` - Checkov security scanner settings
- `link-checker_config.json` - Link checker settings

## Terraform Structure

### Main Configuration
- `terraform/main.tf` - Main Terraform configuration
- `terraform/aft-providers.jinja` - AFT-managed provider configuration
- `terraform/backend.jinja` - AFT-managed backend configuration

### Modules
- `terraform/modules/util-bucket/` - Utility bucket module

### API Helpers
- `api_helpers/pre-api-helpers.sh` - Runs before Terraform
- `api_helpers/post-api-helpers.sh` - Runs after Terraform
- `api_helpers/python/requirements.txt` - Python dependencies (if needed)

## Troubleshooting

### Checkov Failures
If Checkov reports security issues:
1. Review the findings in the PR comment
2. Fix the security issues in your code
3. If a check is a false positive, add suppression with justification:
   ```hcl
   # checkov:skip=CKV_AWS_123:Justification for skipping this check
   resource "aws_s3_bucket" "example" {
     # ...
   }
   ```

### TFLint Failures
If TFLint reports issues:
1. Review the error messages
2. Fix syntax or best practice violations
3. For intentional exceptions, add suppression:
   ```hcl
   # tflint-ignore: aws_instance_invalid_type
   resource "aws_instance" "example" {
     # ...
   }
   ```

### Terraform Docs Not Updating
Ensure your README.md has the markers:
```markdown
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

### Link Checker Failures
1. Fix broken links in documentation
2. For intentional external links that may be temporarily down, add to ignore patterns in config
3. For internal anchors, ensure they exist in the target file

## Workflow Status Badges

Add these to your README.md to show workflow status:

```markdown
[![Checkov](https://github.com/OWNER/REPO/actions/workflows/checkov.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/checkov.yml)
[![TFLint](https://github.com/OWNER/REPO/actions/workflows/tflint.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/tflint.yml)
[![Terraform Docs](https://github.com/OWNER/REPO/actions/workflows/terraform-docs.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/terraform-docs.yml)
```

## Future Enhancements

### Potential Additions
1. **Terraform Cost Estimation**: Add Infracost to estimate cost impact of changes
2. **Drift Detection**: Scheduled workflow to detect configuration drift
3. **Dependency Review**: Automated dependency vulnerability scanning
4. **Slack Notifications**: Alert team of PR status and merge events
5. **Custom Policy Checks**: Organization-specific compliance validation

### Not Applicable (GitOps)
The following are intentionally NOT included:
- Deployment workflows (handled by AFT)
- Terraform plan/apply actions (handled by AFT)
- AWS credential management (handled by AFT)
- Multi-region deployment logic (single region: ca-central-1)
- Environment-specific deployment workflows (GitOps via branches)

## Support and Maintenance

### Updating Action Versions
Regularly update GitHub Actions to latest versions:
```yaml
- uses: actions/checkout@v4.2.2  # Check for updates
- uses: hashicorp/setup-terraform@v3  # Check for updates
```

### Monitoring Workflow Health
1. Review workflow run history regularly
2. Address failing workflows promptly
3. Keep dependencies updated
4. Monitor security advisories

### Adding New Checks
To add new validation workflows:
1. Create workflow file in `.github/workflows/`
2. Set triggers to `pull_request` on `main` and `test` branches
3. Add appropriate path filters
4. Test on a feature branch PR
5. Document in this file

## Summary

This GitHub Actions setup provides comprehensive validation for a GitOps-based AFT Global Customizations repository. All workflows focus on validation and quality checks, with actual deployments handled automatically by AFT when changes are merged to `main` or `test` branches.

The simplified structure reflects the GitOps approach:
- No deployment workflows
- No Python linting (no Python code)
- Single region (ca-central-1)
- Two environments (prod via main, test via test branch)
- Focus on security, quality, and documentation
