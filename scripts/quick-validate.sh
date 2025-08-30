#!/bin/bash
# Quick validation script for lefthook
# Consolidates essential checks without complexity

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# If no files provided, exit gracefully
if [[ $# -eq 0 ]]; then
    log_info "No files to validate"
    exit 0
fi

# Count results
total_files=0
issues_found=0

# Main validation function
validate_file() {
    local file="$1"
    ((total_files++))

    # Skip files that don't exist or aren't readable
    if [[ ! -f "$file" || ! -r "$file" ]]; then
        return 0
    fi

    # Skip binary files
    if file "$file" 2>/dev/null | grep -q 'binary'; then
        return 0
    fi

    local file_issues=0

    # Check for trailing whitespace
    if grep -q '[[:space:]]$' "$file" 2>/dev/null; then
        log_error "Trailing whitespace in: $file"
        ((file_issues++))
    fi

    # Check for common secrets patterns (simplified)
    local secret_patterns=(
        'password.*=.*["\047][^"\047\s]{8,}["\047]'
        'api[_-]?key.*=.*["\047][^"\047\s]{16,}["\047]'
        'secret.*=.*["\047][^"\047\s]{16,}["\047]'
        'token.*=.*["\047][^"\047\s]{20,}["\047]'
        'BEGIN.*PRIVATE.*KEY'
    )

    for pattern in "${secret_patterns[@]}"; do
        if grep -qi "$pattern" "$file" 2>/dev/null; then
            # Skip obvious false positives
            if ! grep -qi 'example\|test\|placeholder\|xxx\|demo' "$file" 2>/dev/null; then
                log_error "Potential secret in: $file"
                ((file_issues++))
                break
            fi
        fi
    done

    # Check for hardcoded 1Password references in templates
    if [[ "$file" =~ \.tmpl$ ]]; then
        if grep -q 'op://[^{]' "$file" 2>/dev/null; then
            log_error "Hardcoded 1Password reference in: $file (use template variables)"
            ((file_issues++))
        fi
    fi

    # Track total issues
    if [[ $file_issues -gt 0 ]]; then
        ((issues_found += file_issues))
    fi
}

# Main execution
log_info "Quick validation of ${#@} files..."

for file in "$@"; do
    validate_file "$file"
done

# Summary
echo
log_info "Quick Validation Summary:"
echo "  Files checked: $total_files"
if [[ $issues_found -eq 0 ]]; then
    log_success "No issues found!"
    exit 0
else
    echo -e "  ${RED}Issues found: $issues_found${NC}"
    log_error "Validation failed!"
    echo
    echo "Common fixes:"
    echo "  • Remove trailing whitespace: sed -i '' 's/[[:space:]]*\$//' filename"
    echo "  • Use environment variables or 1Password integration for secrets"
    echo "  • Move sensitive files to home/private_* (excluded from checks)"
    exit 1
fi