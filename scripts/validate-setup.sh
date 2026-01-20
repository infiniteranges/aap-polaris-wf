#!/bin/bash
# Validation script for AAP Polaris Workflows setup

set -e

echo "=========================================="
echo "AAP Polaris Workflows - Setup Validation"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track validation results
PASSED=0
FAILED=0
WARNINGS=0

# Function to check command availability
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        ((FAILED++))
        return 1
    fi
}

# Function to check version
check_version() {
    local cmd=$1
    local min_version=$2
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $cmd: $version"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $cmd is NOT installed"
        ((FAILED++))
    fi
}

# Function to check Python package
check_python_package() {
    local package=$1
    if python3 -c "import $package" 2>/dev/null; then
        local version=$(python3 -c "import $package; print($package.__version__)" 2>/dev/null || echo "installed")
        echo -e "${GREEN}✓${NC} Python package: $package ($version)"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Python package: $package is NOT installed"
        ((FAILED++))
    fi
}

# Function to check file/directory
check_file() {
    local path=$1
    local description=$2
    if [ -e "$path" ]; then
        echo -e "${GREEN}✓${NC} $description: $path exists"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description: $path does NOT exist"
        ((FAILED++))
    fi
}

# Function to warn
warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "1. Checking Required Commands"
echo "----------------------------"
check_version "terraform" "1.0+"
check_version "terragrunt" "0.40+"
check_version "python3" "3.9+"
check_version "ansible" "2.14+"
check_command "git"
check_command "curl"
echo ""

echo "2. Checking Python Packages"
echo "---------------------------"
check_python_package "ansible"
check_python_package "requests"
echo ""

echo "3. Checking Repository Structure"
echo "---------------------------------"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check_file "$REPO_ROOT/playbooks/terraform.yml" "Terraform playbook"
check_file "$REPO_ROOT/playbooks/terragrunt.yml" "Terragrunt playbook"
check_file "$REPO_ROOT/playbooks/tfc.yml" "TFC playbook"
check_file "$REPO_ROOT/roles/callback_notify" "Callback notify role"
check_file "$REPO_ROOT/roles/terraform_plan" "Terraform plan role"
check_file "$REPO_ROOT/roles/terraform_apply" "Terraform apply role"
check_file "$REPO_ROOT/roles/terragrunt_plan" "Terragrunt plan role"
check_file "$REPO_ROOT/roles/terragrunt_apply" "Terragrunt apply role"
check_file "$REPO_ROOT/roles/tfc_workspace" "TFC workspace role"
check_file "$REPO_ROOT/roles/tfc_plan" "TFC plan role"
check_file "$REPO_ROOT/roles/tfc_apply" "TFC apply role"
echo ""

echo "4. Checking Ansible Syntax"
echo "---------------------------"
if command -v ansible-playbook &> /dev/null; then
    echo "Validating playbook syntax..."
    for playbook in "$REPO_ROOT"/playbooks/*.yml; do
        if ansible-playbook --syntax-check "$playbook" &> /dev/null; then
            echo -e "${GREEN}✓${NC} $(basename "$playbook") syntax is valid"
            ((PASSED++))
        else
            echo -e "${RED}✗${NC} $(basename "$playbook") has syntax errors"
            ((FAILED++))
        fi
    done
else
    warn "ansible-playbook not found, skipping syntax check"
fi
echo ""

echo "5. Checking Environment Variables (Optional)"
echo "---------------------------------------------"
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo -e "${GREEN}✓${NC} AWS_ACCESS_KEY_ID is set"
    ((PASSED++))
else
    warn "AWS_ACCESS_KEY_ID is not set (optional for testing)"
fi

if [ -n "$TFC_API_TOKEN" ]; then
    echo -e "${GREEN}✓${NC} TFC_API_TOKEN is set"
    ((PASSED++))
else
    warn "TFC_API_TOKEN is not set (optional for testing)"
fi
echo ""

echo "6. Network Connectivity (Optional)"
echo "----------------------------------"
if curl -s --max-time 5 https://app.terraform.io/api/v2/ping &> /dev/null; then
    echo -e "${GREEN}✓${NC} Can reach Terraform Cloud API"
    ((PASSED++))
else
    warn "Cannot reach Terraform Cloud API (may be network/firewall issue)"
fi

if curl -s --max-time 5 https://github.com &> /dev/null; then
    echo -e "${GREEN}✓${NC} Can reach GitHub"
    ((PASSED++))
else
    warn "Cannot reach GitHub (may be network/firewall issue)"
fi
echo ""

echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All required checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please fix the issues above.${NC}"
    exit 1
fi
