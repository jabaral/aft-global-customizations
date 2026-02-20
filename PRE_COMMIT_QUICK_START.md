# Pre-commit Quick Start

## One-Command Setup

```bash
./setup-pre-commit.sh
```

This installs all tools and configures pre-commit hooks.

## Manual Setup

```bash
# Install pre-commit
pip3 install pre-commit

# Install in repository
pre-commit install

# Test it
pre-commit run --all-files
```

## Daily Usage

### Automatic (Recommended)
Hooks run automatically when you commit:
```bash
git add .
git commit -m "feat: Add new feature"
# Hooks run here automatically
```

### Manual
Run hooks without committing:
```bash
# All hooks on all files
pre-commit run --all-files

# All hooks on staged files
pre-commit run

# Specific hook
pre-commit run terraform_fmt --all-files
```

## Common Commands

```bash
# Format Terraform files
pre-commit run terraform_fmt --all-files

# Run security scan
pre-commit run terraform_checkov --all-files

# Run linting
pre-commit run tflint --all-files

# Update documentation
pre-commit run terraform_docs --all-files

# Skip hooks (use sparingly)
git commit -m "message" --no-verify
SKIP=terraform_checkov git commit -m "message"
```

## What Gets Checked

✅ Terraform formatting and validation
✅ TFLint (Terraform best practices)
✅ Checkov (security scanning)
✅ TFSec (additional security)
✅ Terraform docs (auto-generate)
✅ Markdown linting
✅ Link checking
✅ YAML validation
✅ Secret detection
✅ Trailing whitespace
✅ File size limits

## Troubleshooting

### Hook fails
1. Read the error message
2. Fix the issue
3. Stage the fixed files
4. Commit again

### Too slow
```bash
# Skip slow hooks during development
SKIP=terraform_checkov,tfsec git commit -m "WIP"

# Run full validation before pushing
pre-commit run --all-files
```

### False positive
```bash
# Update secrets baseline
detect-secrets scan --baseline .secrets.baseline

# Add suppression in code
# checkov:skip=CKV_AWS_18:Reason here
```

## Required Tools

- Python 3.8+
- pre-commit
- Terraform
- TFLint
- Checkov
- TFSec
- terraform-docs
- Node.js (for Markdown tools)
- markdownlint-cli
- markdown-link-check
- yamllint
- actionlint
- detect-secrets

## Installation Shortcuts

### macOS (Homebrew)
```bash
brew install pre-commit tflint tfsec terraform-docs actionlint yamllint node
pip3 install checkov detect-secrets
npm install -g markdownlint-cli markdown-link-check
```

### Linux (apt + pip)
```bash
pip3 install pre-commit checkov detect-secrets yamllint
# Install others from releases or package manager
```

## Configuration Files

- `.pre-commit-config.yaml` - Main configuration
- `.tflint.hcl` - TFLint settings
- `.secrets.baseline` - Known false positives
- `.github/workflow-configs/checkov_config.yaml` - Checkov settings
- `.github/linters/` - Linter configurations

## Best Practices

1. ✅ Run `pre-commit run --all-files` before pushing
2. ✅ Fix issues, don't skip hooks
3. ✅ Document suppressions with reasons
4. ✅ Update hooks regularly: `pre-commit autoupdate`
5. ✅ Use meaningful commit messages

## Help

For detailed documentation, see:
- [PRE_COMMIT_SETUP.md](PRE_COMMIT_SETUP.md) - Complete setup guide
- [Pre-commit docs](https://pre-commit.com/)
- [TFLint docs](https://github.com/terraform-linters/tflint)
- [Checkov docs](https://www.checkov.io/)

## Summary

Pre-commit hooks catch issues before you push, matching GitHub Actions validation. Install once, use automatically!

```bash
# Setup (once)
./setup-pre-commit.sh

# Use (automatic)
git commit -m "feat: Add feature"
# Hooks run automatically ✓
```
