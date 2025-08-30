#!/bin/bash
set -euo pipefail

# Simple Template Test Script for Chezmoi
# Tests critical templates with different variable combinations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHEZMOI_DIR="$REPO_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

run_test() {
    ((TESTS_RUN++))
}

# Test template rendering with specific variables
test_template() {
    local template_file="$1"
    local test_name="$2"
    local prompt_args="$3"

    run_test

    if [ ! -f "$CHEZMOI_DIR/$template_file" ]; then
        log_error "$test_name: Template file $template_file not found"
        return 1
    fi

    log_info "Testing $test_name..."

    # Create temporary output file
    local temp_output
    temp_output=$(mktemp)

    # Test template rendering
    if chezmoi execute-template --init $prompt_args < "$CHEZMOI_DIR/$template_file" > "$temp_output" 2>/dev/null; then
        # Check if output is not empty
        if [ -s "$temp_output" ]; then
            log_success "$test_name: Template renders successfully"
            rm -f "$temp_output"
            return 0
        else
            log_error "$test_name: Template renders but produces empty output"
            rm -f "$temp_output"
            return 1
        fi
    else
        log_error "$test_name: Template failed to render"
        rm -f "$temp_output"
        return 1
    fi
}

# Test TOML validity for config template
test_config_toml() {
    local test_name="$1"
    local prompt_args="$2"

    run_test

    log_info "Testing $test_name TOML validity..."

    local temp_output
    temp_output=$(mktemp)

    # Generate config
    if chezmoi execute-template --init $prompt_args < "$CHEZMOI_DIR/home/.chezmoi.toml.tmpl" > "$temp_output" 2>/dev/null; then
        # Test TOML validity with Python (most reliable)
        if command -v python3 >/dev/null 2>&1; then
            if python3 -c "import tomllib; tomllib.loads(open('$temp_output').read())" 2>/dev/null; then
                log_success "$test_name: Generated config is valid TOML"
                rm -f "$temp_output"
                return 0
            else
                log_error "$test_name: Generated config is not valid TOML"
                echo "Generated content:"
                cat "$temp_output" | head -20
                rm -f "$temp_output"
                return 1
            fi
        else
            # Fallback: basic syntax check
            if grep -q '^\[.*\]' "$temp_output" && ! grep -q 'undefined\|<no value>' "$temp_output"; then
                log_success "$test_name: Generated config appears valid (basic check)"
                rm -f "$temp_output"
                return 0
            else
                log_error "$test_name: Generated config appears invalid"
                rm -f "$temp_output"
                return 1
            fi
        fi
    else
        log_error "$test_name: Config template failed to render"
        rm -f "$temp_output"
        return 1
    fi
}

# Main test function
main() {
    log_info "Starting Chezmoi Template Tests"
    log_info "Working directory: $CHEZMOI_DIR"

    # Check if chezmoi is available
    if ! command -v chezmoi >/dev/null 2>&1; then
        log_error "chezmoi command not found. Please install chezmoi first."
        exit 1
    fi

    # Test scenarios with different variable combinations

    # Scenario 1: CI environment (no secrets, not work computer)
    test_config_toml "CI Environment" \
        '--promptString "git_dir=repos" --promptBool "work_computer=false,is_ci_workflow=true,use_secrets=false"'

    # Scenario 2: Personal computer with secrets
    test_config_toml "Personal with Secrets" \
        '--promptString "git_dir=code,personal_1p_account=personal@example.com,personal_vault_name=Personal" --promptBool "work_computer=false,is_ci_workflow=false,use_secrets=true"'

    # Scenario 3: Work computer with secrets
    test_config_toml "Work with Secrets" \
        '--promptString "git_dir=work,personal_1p_account=personal@example.com,personal_vault_name=Personal,work_1p_account=work@company.com,work_vault_name=Work" --promptBool "work_computer=true,is_ci_workflow=false,use_secrets=true"'

    # Test other critical templates if they exist
    if [ -f "$CHEZMOI_DIR/home/dot_zprofile.tmpl" ]; then
        test_template "home/dot_zprofile.tmpl" "ZSH Profile Template" \
            '--promptString "git_dir=repos" --promptBool "work_computer=false,is_ci_workflow=true,use_secrets=false"'
    fi

    if [ -f "$CHEZMOI_DIR/home/dot_gitconfig.tmpl" ]; then
        test_template "home/dot_gitconfig.tmpl" "Git Config Template" \
            '--promptString "git_dir=repos" --promptBool "work_computer=false,is_ci_workflow=true,use_secrets=false"'
    fi

    # Test template helpers
    log_info "Testing template helpers..."
    run_test
    if find "$CHEZMOI_DIR/home/.chezmoitemplates" -name "*.tmpl" 2>/dev/null | head -1 | read -r template; then
        log_success "Template helpers found"
    else
        log_info "No template helpers to test"
        ((TESTS_PASSED++))
    fi

    # Summary
    echo
    log_info "Test Summary:"
    echo "  Tests run: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"

    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed!"
        exit 0
    else
        log_error "Some tests failed!"
        exit 1
    fi
}

# Show usage if help requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Test chezmoi templates with different variable combinations"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo
    echo "Examples:"
    echo "  $0            Run all template tests"
    echo
    exit 0
fi

main "$@"