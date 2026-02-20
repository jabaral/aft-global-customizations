# Pre-commit Setup Guide

## Overview

This guide will help you set up pre-commit hooks that run the same validation checks locally that GitHub Actions runs on pull requests. This catches issues before you push code, saving time and reducing failed CI runs.

## What Gets Checked

The pre-commit hooks run the following checks (matching GitHub Actions):

### Terraform Checks
- ✅ **terraform fmt** - Format Terraform files
- ✅ **terraform validate** - Validate Terraform syntax
- ✅ **TFLint** - Terraform linting and best practices
- ✅ **Checkov** - Security and compliance scanning
- ✅ **terraform-docs** - Auto-generate documentation
- ✅ **TFSec** - Additional security scanning

### Documentation Checks
- ✅ **Markdown Lint** - Markdown formatting
- ✅ **Markdown Link Check** - Validate links in documentation
- ✅ **YAML Lint** - YAML file validation

### General Checks
- ✅ **GitHub Actions Lint** - Validate workflow files
- ✅ **Detect Secrets** - Prevent committing secrets
- ✅ **File Size Check** - Prevent large files
- ✅ **Trailing Whitespace** - Clean up whitespace
- ✅ **End of File** - Ensure newline at end
- ✅ **Merge Conflicts** - Detect unresolved conflicts
- ✅ **Private Keys** - Detect private key files

## Prerequisites

### Required Tools

1. **Python 3.8+**
   ```bash
   python3 --version
   ```

2. **pip** (Python package manager)
   ```bash
   pip3 --version
   ```

3. **Terraform** (for terraform hooks)
   ```bash
   terraform --version
   ```

4. **Git** (obviously!)
   ```bash
   git --version
   ```

## Installation

### Step 1: Install pre-commit

```bash
# Using pip
pip3 install pre-commit

# Or using Homebrew (macOS)
brew install pre-commit

# Verify installation
pre-commit --version
```

### Step 2: Install TFLint

```bash
# Using Homebrew (macOS/Linux)
brew install tflint

# Or using curl (Linux)
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Verify installation
tflint --version
```

### Step 3: Install Checkov

```bash
# Using pip
pip3 install checkov

# Verify installation
checkov --version
```

### Step 4: Install TFSec

```bash
# Using Homebrew (macOS/Linux)
brew install tfsec

# Or using curl (Linux)
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Verify installation
tfsec --version
```

### Step 5: Install terraform-docs

```bash
# Using Homebrew (macOS/Linux)
brew install terraform-docs

# Or download from releases
# https://github.com/terraform-docs/terraform-docs/releases

# Verify installation
terraform-docs --version
```

### Step 6: Install Node.js tools (for Markdown linting)

```bash
# Install Node.js if not already installed
# Using Homebrew (macOS)
brew install node

# Install markdownlint-cli
npm install -g markdownlint-cli

# Install markdown-link-check
npm install -g markdown-link-check

# Verify installations
markdownlint --version
markdown-link-check --version
```

### Step 7: Install yamllint

```bash
# Using pip
pip3 install yamllint

# Or using Homebrew (macOS)
brew install yamllint

# Verify installation
yamllint --version
```

### Step 8: Install actionlint

```bash
# Using Homebrew (macOS/Linux)
brew install actionlint

# Or download from releases
# https://github.com/rhysd/actionlint/releases

# Verify installation
actionlint --version
```

### Step 9: Install detect-secrets

```bash
# Using pip
pip3 install detect-secrets

# Verify installation
detect-secrets --version
```

## Setup in Repository

### Step 1: Navigate to repository

```bash
cd /path/to/your/aft-global-customizations
```

### Step 2: Install pre-commit hooks

```bash
# This installs the git hooks
pre-commit install

# Also install for commit-msg hook
pre-commit install --hook-type commit-msg
```

You should see:
```
pre-commit installed at .git/hooks/pre-commit
pre-commit installed at .git/hooks/commit-msg
```

### Step 3: Initialize TFLint plugins

```bash
# Initialize TFLint with AWS plugin
tflint --init
```

### Step 4: Test the setup

```bash
# Run all hooks on all files (first run will be slow)
pre-commit run --all-files
```

## Usage

### Automatic (Recommended)

Once installed, pre-commit hooks run automatically when you commit:

```bash
git add .
git commit -m "feat: Add new S3 bucket"
# Hooks run automatically here
```

If any hook fails:
1. Review the error messages
2. Fix the issues
3. Stage the fixed files
4. Commit again

### Manual Execution

Run hooks manually without committing:

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run all hooks on staged files only
pre-commit run

# Run specific hook on all files
pre-commit run terraform_fmt --all-files
pre-commit run terraform_checkov --all-files
pre-commit run tflint --all-files

# Run on specific files
pre-commit run --files terraform/main.tf
```

### Skip Hooks (Use Sparingly)

If you need to skip hooks (not recommended):

```bash
# Skip all hooks
git commit -m "message" --no-verify

# Skip specific hook (set in commit message)
SKIP=terraform_checkov git commit -m "message"
```

## Configuration Files

### .pre-commit-config.yaml
Main configuration file defining all hooks and their settings.

### .tflint.hcl
TFLint configuration with AWS plugin and rule settings.

### .secrets.baseline
Baseline file for detect-secrets to track known false positives.

### .github/workflow-configs/checkov_config.yaml
Checkov configuration (shared with GitHub Actions).

### .github/workflow-configs/link-checker_config.json
Link checker configuration (shared with GitHub Actions).

### .github/linters/
Linter configuration files for YAML, Markdown, etc.

## Troubleshooting

### Hook Installation Failed

**Issue**: `pre-commit install` fails

**Solution**:
```bash
# Ensure you're in a git repository
git status

# Reinstall pre-commit
pip3 install --upgrade pre-commit
pre-commit install --install-hooks
```

### TFLint Plugin Download Failed

**Issue**: TFLint can't download AWS plugin

**Solution**:
```bash
# Manually initialize TFLint
tflint --init

# Or specify plugin directory
export TFLINT_PLUGIN_DIR=~/.tflint.d/plugins
tflint --init
```

### Checkov Takes Too Long

**Issue**: Checkov scan is very slow

**Solution**:
```bash
# Run Checkov only on changed files
pre-commit run terraform_checkov --files terraform/main.tf

# Or skip Checkov for quick commits
SKIP=terraform_checkov git commit -m "message"
```

### Terraform Docs Not Updating

**Issue**: terraform-docs doesn't update README.md

**Solution**:
1. Ensure README.md has markers:
   ```markdown
   <!-- BEGIN_TF_DOCS -->
   <!-- END_TF_DOCS -->
   ```
2. Run manually:
   ```bash
   terraform-docs markdown table --output-file README.md --output-mode inject terraform/
   ```

### Markdown Link Check Fails

**Issue**: Link checker reports false positives

**Solution**:
1. Add patterns to `.github/workflow-configs/link-checker_config.json`
2. Or skip the check:
   ```bash
   SKIP=markdown-link-check git commit -m "message"
   ```

### Detect Secrets False Positives

**Issue**: detect-secrets flags non-secrets

**Solution**:
```bash
# Update baseline to include the false positive
detect-secrets scan --baseline .secrets.baseline

# Or add inline comment in code
# pragma: allowlist secret
```

## Performance Optimization

### Speed Up First Run

The first run downloads all dependencies and can be slow:

```bash
# Pre-install all environments
pre-commit install-hooks
```

### Run Only on Changed Files

By default, pre-commit only runs on staged files:

```bash
# This is fast (only staged files)
pre-commit run

# This is slow (all files)
pre-commit run --all-files
```

### Skip Slow Hooks During Development

For rapid iteration, skip slow hooks:

```bash
# Skip Checkov and TFSec during development
SKIP=terraform_checkov,tfsec git commit -m "WIP: testing"

# Run full validation before pushing
pre-commit run --all-files
```

### Use Parallel Execution

Pre-commit runs hooks in parallel by default. Ensure you have enough CPU:

```bash
# Check parallel execution
pre-commit run --all-files --verbose
```

## Best Practices

### 1. Run Before Pushing

Always run full validation before pushing:

```bash
# Before pushing
pre-commit run --all-files

# Then push
git push origin feature-branch
```

### 2. Update Hooks Regularly

Keep hooks up to date:

```bash
# Update to latest versions
pre-commit autoupdate

# Review changes
git diff .pre-commit-config.yaml

# Commit updates
git add .pre-commit-config.yaml
git commit -m "chore: Update pre-commit hooks"
```

### 3. Document Suppressions

When suppressing checks, always document why:

```hcl
# checkov:skip=CKV_AWS_18:Public access required for static website hosting
resource "aws_s3_bucket" "website" {
  # ...
}
```

### 4. Fix Issues, Don't Skip

Resist the temptation to skip hooks. Fix the issues instead:

```bash
# Bad
git commit --no-verify

# Good
# Fix the issues, then commit normally
```

### 5. Use Meaningful Commit Messages

Pre-commit can validate commit messages (if configured):

```bash
# Good commit messages
git commit -m "feat: Add S3 bucket for logs"
git commit -m "fix: Correct IAM policy syntax"
git commit -m "docs: Update README with new module"

# Bad commit messages
git commit -m "stuff"
git commit -m "fix"
```

## Integration with IDEs

### VS Code

Install the pre-commit extension:

1. Open VS Code
2. Install "Pre-commit" extension
3. Hooks run automatically on save (if configured)

### IntelliJ/PyCharm

1. Go to Settings → Tools → External Tools
2. Add pre-commit as external tool
3. Configure to run on file save

### Vim/Neovim

Add to your `.vimrc`:

```vim
" Run pre-commit on save
autocmd BufWritePost * silent! !pre-commit run --files %
```

## CI/CD Integration

Pre-commit can also run in CI/CD:

```yaml
# .github/workflows/pre-commit.yml
name: Pre-commit

on:
  pull_request:

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
      - uses: pre-commit/action@v3.0.1
```

## Comparison: Pre-commit vs GitHub Actions

| Aspect | Pre-commit | GitHub Actions |
|--------|-----------|----------------|
| When | Before commit | After push (on PR) |
| Speed | Fast (local) | Slower (remote) |
| Feedback | Immediate | Delayed |
| Cost | Free (local CPU) | Free (GitHub minutes) |
| Scope | Changed files | All files |
| Enforcement | Optional | Required (branch protection) |

**Best Practice**: Use both!
- Pre-commit catches issues early (before push)
- GitHub Actions enforces standards (before merge)

## Uninstalling

If you need to remove pre-commit:

```bash
# Uninstall hooks
pre-commit uninstall
pre-commit uninstall --hook-type commit-msg

# Remove pre-commit package
pip3 uninstall pre-commit
```

## Summary

Pre-commit hooks provide fast, local validation that matches your GitHub Actions workflows. This catches issues early and speeds up development.

### Quick Start Commands

```bash
# Install pre-commit
pip3 install pre-commit

# Install hooks in repository
cd /path/to/repo
pre-commit install

# Run all checks
pre-commit run --all-files

# Normal workflow (hooks run automatically)
git add .
git commit -m "feat: Add new feature"
```

### Required Tools Checklist

- [ ] Python 3.8+
- [ ] pre-commit
- [ ] Terraform
- [ ] TFLint
- [ ] Checkov
- [ ] TFSec
- [ ] terraform-docs
- [ ] Node.js
- [ ] markdownlint-cli
- [ ] markdown-link-check
- [ ] yamllint
- [ ] actionlint
- [ ] detect-secrets

### Next Steps

1. Install all required tools
2. Run `pre-commit install` in your repository
3. Run `pre-commit run --all-files` to test
4. Start committing with automatic validation!

For questions or issues, refer to:
- [Pre-commit documentation](https://pre-commit.com/)
- [TFLint documentation](https://github.com/terraform-linters/tflint)
- [Checkov documentation](https://www.checkov.io/)
