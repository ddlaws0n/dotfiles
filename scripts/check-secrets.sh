#!/bin/bash
# Enhanced secret detection script for lefthook
# Detects potential hardcoded secrets in staged files

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

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# If no files provided, exit gracefully
if [[ $# -eq 0 ]]; then
    log_info "No files to check for secrets"
    exit 0
fi

# Secret detection patterns
declare -a SECRET_PATTERNS=(
    # Generic patterns for common secret formats
    '(password|passwd|pwd)\s*[:=]\s*["\047][^"\047\s]{8,}["\047]'                    # password="secretvalue"
    '(secret|key|token|api_key|apikey)\s*[:=]\s*["\047][^"\047\s]{16,}["\047]'        # api_key="longsecretvalue"
    'bearer\s+[a-zA-Z0-9_-]{20,}'                                                     # Bearer tokens
    '["\047]?[a-zA-Z0-9]{20,}["\047]?\s*:\s*["\047][^"\047\s]{16,}["\047]'          # key: "value" pairs

    # Specific service patterns
    'sk-[a-zA-Z0-9]{32,}'                                                            # OpenAI API keys
    'ghp_[a-zA-Z0-9]{36}'                                                            # GitHub personal access tokens
    'gho_[a-zA-Z0-9]{36}'                                                            # GitHub OAuth tokens
    'ghu_[a-zA-Z0-9]{36}'                                                            # GitHub user tokens
    'ghs_[a-zA-Z0-9]{36}'                                                            # GitHub server tokens
    'ghr_[a-zA-Z0-9]{36}'                                                            # GitHub refresh tokens
    'AKIA[0-9A-Z]{16}'                                                               # AWS Access Key IDs
    '[0-9a-zA-Z/+]{40}'                                                              # AWS Secret Access Keys (base64-like)
    'ya29\.[0-9A-Za-z_-]+'                                                          # Google OAuth2 tokens
    'AIza[0-9A-Za-z_-]{35}'                                                          # Google API keys
    'pk_live_[0-9a-zA-Z]{24,}'                                                       # Stripe live keys
    'sk_live_[0-9a-zA-Z]{24,}'                                                       # Stripe live secret keys
    'rk_live_[0-9a-zA-Z]{24,}'                                                       # Stripe live restricted keys

    # SSH and crypto patterns
    'BEGIN\s+(RSA\s+)?PRIVATE\s+KEY'                                                 # Private keys
    'BEGIN\s+OPENSSH\s+PRIVATE\s+KEY'                                                # OpenSSH private keys
    'BEGIN\s+PGP\s+PRIVATE\s+KEY'                                                    # PGP private keys

    # Database connection strings
    '(mysql|postgres|postgresql|mongodb)://[^@]+:[^@]+@'                            # DB connection strings with credentials

    # Generic high-entropy strings (likely to be secrets)
    '["\047][a-zA-Z0-9/+=]{32,}["\047]'                                             # Base64-like strings
)

# Patterns that are often false positives (to exclude)
declare -a FALSE_POSITIVE_PATTERNS=(
    'password.*example'                # Example passwords
    'password.*test'                   # Test passwords
    'password.*demo'                   # Demo passwords
    'password.*placeholder'            # Placeholder text
    'password.*your.?password'         # Documentation placeholders
    'secret.*example'                  # Example secrets
    'secret.*test'                     # Test secrets
    'key.*example'                     # Example keys
    'token.*example'                   # Example tokens
    'XXXXXXXX'                         # Placeholder X's
    'xxxxxxxx'                         # Placeholder x's
    '12345678'                         # Obvious test values
    'abcdefgh'                         # Obvious test values
    'password123'                      # Obvious test values
    'secretkey'                        # Obvious test values
)

# Files to always skip (in addition to CLI exclude patterns)
declare -a SKIP_FILES=(
    '*.md'
    '*.txt'
    '*.log'
    '*.lock'
    'CLAUDE.md'
    'README.md'
    'CHANGELOG.md'
    'LICENSE'
    'package-lock.json'
    'yarn.lock'
    'Pipfile.lock'
)

# Check if a file should be skipped
should_skip_file() {
    local file="$1"

    # Skip binary files
    if file "$file" 2>/dev/null | grep -q 'binary'; then
        return 0
    fi

    # Skip files in skip list
    for pattern in "${SKIP_FILES[@]}"; do
        if [[ "$file" == $pattern ]]; then
            return 0
        fi
    done

    # Skip large files (>1MB) - likely not config files with secrets
    if [[ -f "$file" && $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) -gt 1048576 ]]; then
        return 0
    fi

    return 1
}

# Check if a match is likely a false positive
is_false_positive() {
    local match="$1"

    for pattern in "${FALSE_POSITIVE_PATTERNS[@]}"; do
        if echo "$match" | grep -qi "$pattern"; then
            return 0
        fi
    done

    return 1
}

# Check a single file for secrets
check_file_for_secrets() {
    local file="$1"
    local findings=()

    # Skip files that shouldn't be checked
    if should_skip_file "$file"; then
        return 0
    fi

    # Check each secret pattern
    for pattern in "${SECRET_PATTERNS[@]}"; do
        while IFS= read -r match; do
            if [[ -n "$match" ]]; then
                # Extract just the matched content (remove filename and line number)
                local clean_match
                clean_match=$(echo "$match" | sed 's/^[^:]*:[^:]*://')

                # Skip false positives
                if ! is_false_positive "$clean_match"; then
                    findings+=("$match")
                fi
            fi
        done < <(grep -n -i -E "$pattern" "$file" 2>/dev/null || true)
    done

    # Report findings
    if [[ ${#findings[@]} -gt 0 ]]; then
        log_error "Potential secrets found in: $file"
        for finding in "${findings[@]}"; do
            echo "  → $finding"
        done
        return 1
    fi

    return 0
}

# Special check for 1Password references that should be templated
check_onepassword_refs() {
    local file="$1"

    # Only check template files for 1Password patterns
    if [[ "$file" =~ \.tmpl$ ]]; then
        # Look for hardcoded op:// references that should be templated
        if grep -n 'op://[^{]' "$file" 2>/dev/null; then
            log_error "Found hardcoded 1Password references in: $file"
            echo "  → Use template variables for vault names instead"
            return 1
        fi

        # Look for malformed onepasswordRead calls
        if grep -n -E 'onepassword[^"]*"[^"]*"[^"]*"[^"]*"[^"]*"' "$file" 2>/dev/null; then
            log_error "Found malformed 1Password references in: $file"
            echo "  → Expected format: onepasswordRead \"op://vault/item/field\""
            return 1
        fi
    fi

    return 0
}

# Main function
main() {
    log_info "Checking ${#@} files for potential secrets..."

    local total_files=0
    local clean_files=0
    local files_with_secrets=0
    local overall_success=true

    for file in "$@"; do
        # Skip files that don't exist or aren't readable
        if [[ ! -f "$file" || ! -r "$file" ]]; then
            continue
        fi

        ((total_files++))

        local file_clean=true

        # Check for general secrets
        if ! check_file_for_secrets "$file"; then
            file_clean=false
        fi

        # Check for 1Password specific issues
        if ! check_onepassword_refs "$file"; then
            file_clean=false
        fi

        if [[ "$file_clean" == "true" ]]; then
            ((clean_files++))
        else
            ((files_with_secrets++))
            overall_success=false
        fi
    done

    # Summary
    echo
    log_info "Secret Detection Summary:"
    echo "  Files checked: $total_files"
    echo -e "  ${GREEN}Clean files: $clean_files${NC}"
    echo -e "  ${RED}Files with potential secrets: $files_with_secrets${NC}"

    if [[ "$overall_success" == "true" ]]; then
        log_success "No secrets detected!"
        exit 0
    else
        echo
        log_error "Potential secrets detected!"
        echo "If these are false positives, consider:"
        echo "  1. Adding them to the false positive patterns"
        echo "  2. Using environment variables or 1Password integration"
        echo "  3. Moving sensitive files to home/private_* (excluded from checks)"
        exit 1
    fi
}

# Handle help flag
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [files...]"
    echo
    echo "Check files for potential hardcoded secrets and credentials."
    echo "Designed for use with chezmoi dotfiles and lefthook."
    echo
    echo "The script checks for:"
    echo "  - Common secret patterns (passwords, API keys, tokens)"
    echo "  - Service-specific patterns (GitHub, AWS, Google, etc.)"
    echo "  - SSH private keys"
    echo "  - Database connection strings"
    echo "  - 1Password reference issues in templates"
    echo
    echo "Files automatically excluded:"
    echo "  - Binary files"
    echo "  - Documentation files (*.md, *.txt)"
    echo "  - Large files (>1MB)"
    echo "  - Lock files"
    echo
    echo "Examples:"
    echo "  $0 home/dot_gitconfig"
    echo "  $0 \$(git diff --cached --name-only)"
    echo
    exit 0
fi

main "$@"
