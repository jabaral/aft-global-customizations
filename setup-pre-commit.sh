#!/bin/bash
# Pre-commit setup script for AFT Global Customizations
# This script installs all required tools and sets up pre-commit hooks

set -e

echo "========================================="
echo "Pre-commit Setup for AFT Global Customizations"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Python
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✓${NC} Python 3 installed: $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python 3 not found. Please install Python 3.8+"
    exit 1
fi

# Check pip
if command_exists pip3; then
    echo -e "${GREEN}✓${NC} pip3 installed"
else
    echo -e "${RED}✗${NC} pip3 not found. Please install pip3"
    exit 1
fi

# Check Terraform
if command_exists terraform; then
    TF_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    echo -e "${GREEN}✓${NC} Terraform installed: $TF_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Terraform not found. Some hooks will be skipped."
fi

# Check Git
if command_exists git; then
    echo -e "${GREEN}✓${NC} Git installed"
else
    echo -e "${RED}✗${NC} Git not found. Please install Git"
    exit 1
fi

echo ""
echo "Installing tools..."
echo ""

# Install pre-commit
echo "Installing pre-commit..."
pip3 install --user pre-commit
print_status "pre-commit installed"

# Install Checkov
echo "Installing Checkov..."
pip3 install --user checkov
print_status "Checkov installed"

# Install yamllint
echo "Installing yamllint..."
pip3 install --user yamllint
print_status "yamllint installed"

# Install detect-secrets
echo "Installing detect-secrets..."
pip3 install --user detect-secrets
print_status "detect-secrets installed"

# Check for Homebrew (macOS/Linux)
if command_exists brew; then
    echo ""
    echo "Homebrew detected. Installing additional tools..."

    # Install TFLint
    if ! command_exists tflint; then
        echo "Installing TFLint..."
        brew install tflint
        print_status "TFLint installed"
    else
        echo -e "${GREEN}✓${NC} TFLint already installed"
    fi

    # Install TFSec
    if ! command_exists tfsec; then
        echo "Installing TFSec..."
        brew install tfsec
        print_status "TFSec installed"
    else
        echo -e "${GREEN}✓${NC} TFSec already installed"
    fi

    # Install terraform-docs
    if ! command_exists terraform-docs; then
        echo "Installing terraform-docs..."
        brew install terraform-docs
        print_status "terraform-docs installed"
    else
        echo -e "${GREEN}✓${NC} terraform-docs already installed"
    fi

    # Install actionlint
    if ! command_exists actionlint; then
        echo "Installing actionlint..."
        brew install actionlint
        print_status "actionlint installed"
    else
        echo -e "${GREEN}✓${NC} actionlint already installed"
    fi

    # Install Node.js if not present
    if ! command_exists node; then
        echo "Installing Node.js..."
        brew install node
        print_status "Node.js installed"
    else
        echo -e "${GREEN}✓${NC} Node.js already installed"
    fi
else
    echo -e "${YELLOW}⚠${NC} Homebrew not found. Please install remaining tools manually:"
    echo "  - TFLint: https://github.com/terraform-linters/tflint"
    echo "  - TFSec: https://github.com/aquasecurity/tfsec"
    echo "  - terraform-docs: https://github.com/terraform-docs/terraform-docs"
    echo "  - actionlint: https://github.com/rhysd/actionlint"
    echo "  - Node.js: https://nodejs.org/"
fi

# Install Node.js packages if Node is available
if command_exists npm; then
    echo ""
    echo "Installing Node.js packages..."

    npm install -g markdownlint-cli2 2>/dev/null
    print_status "markdownlint-cli2 installed"

    npm install -g markdown-link-check 2>/dev/null
    print_status "markdown-link-check installed"
fi

echo ""
echo "Setting up pre-commit in repository..."
echo ""

# Install pre-commit hooks
pre-commit install
print_status "Pre-commit hooks installed"

pre-commit install --hook-type commit-msg
print_status "Commit-msg hooks installed"

# Initialize TFLint
if command_exists tflint; then
    echo ""
    echo "Initializing TFLint..."
    tflint --init
    print_status "TFLint initialized"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run 'pre-commit run --all-files' to test the setup"
echo "2. Make a commit to see hooks in action"
echo "3. Review PRE_COMMIT_SETUP.md for detailed documentation"
echo ""
echo "Hooks will now run automatically on every commit!"
echo ""


echo ""
echo "========================================="
echo "Important: Network Restrictions"
echo "========================================="
echo ""
echo "If you're in a restricted network environment where Go domains are blocked,"
echo "the following tools must be pre-installed on your system:"
echo ""
echo "  - actionlint (GitHub Actions linter)"
echo "  - tfsec (Terraform security scanner)"
echo "  - markdown-link-check (Link checker)"
echo ""
echo "These tools are configured to use system installations (repo: local)"
echo "instead of downloading from GitHub to avoid network issues."
echo ""
echo "Installation methods:"
echo "  1. Homebrew: brew install actionlint tfsec"
echo "  2. npm: npm install -g markdown-link-check"
echo "  3. Download pre-compiled binaries from GitHub releases"
echo ""
echo "See PRE_COMMIT_NETWORK_RESTRICTIONS.md for detailed instructions."
echo ""
