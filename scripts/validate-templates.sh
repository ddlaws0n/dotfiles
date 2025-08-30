#!/bin/bash
# Template validation script for lefthook
# Validates chezmoi template syntax for staged files

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

# Check if chezmoi is available
if ! command -v chezmoi >/dev/null 2>&1; then
    log_error "chezmoi command not found. Please install chezmoi first."
    exit 1
fi

# If no files provided, exit gracefully
if [[ $# -eq 0 ]]; then
    log_info "No template files to validate"
    exit 0
fi

# Count results
total_files=0
passed_files=0
failed_files=0

# Template validation function
validate_template() {
    local template_file="$1"
    ((total_files++))

    log_info "Validating template: $template_file"

    # Check if file exists and is readable
    if [[ ! -f "$template_file" || ! -r "$template_file" ]]; then
        log_error "Template file not found or not readable: $template_file"
        ((failed_files++))
        return 1
    fi

    # Create temporary output file
    local temp_output
    temp_output=$(mktemp)

    # Test multiple scenarios to ensure template works in different contexts
    local scenarios=(
        # CI scenario (no secrets)
        '--promptString "git_dir=test" --promptBool "work_computer=false,is_ci_workflow=true,use_secrets=false"'
        # Personal scenario
        '--promptString "git_dir=code" --promptBool "work_computer=false,is_ci_workflow=false,use_secrets=false"'
    )

    local scenario_failed=false

    for scenario in "${scenarios[@]}"; do
        # Test template rendering with current scenario
        local cmd="chezmoi execute-template --init $scenario"

        if eval "$cmd" < "$template_file" > "$temp_output" 2>/dev/null; then
            # Check if output is not empty for non-empty templates
            if [[ -s "$template_file" ]] && [[ ! -s "$temp_output" ]]; then
                log_error "Template renders but produces empty output: $template_file (scenario: CI/personal)"
                scenario_failed=true
                break
            fi
        else
            log_error "Template failed to render: $template_file (scenario: $(echo "$scenario" | cut -d'"' -f2))"
            scenario_failed=true
            break
        fi
    done

    # Clean up temp file
    rm -f "$temp_output"

    if [[ "$scenario_failed" == "true" ]]; then
        ((failed_files++))
        return 1
    else
        log_success "Template validation passed: $template_file"
        ((passed_files++))
        return 0
    fi
}

# Special validation for the main config template
validate_config_template() {
    local config_file="$1"

    log_info "Running special validation for config template: $config_file"

    local temp_config
    temp_config=$(mktemp)

    # Test config template with CI settings
    if chezmoi execute-template --init \
        --promptString "git_dir=test" \
        --promptBool "work_computer=false,is_ci_workflow=true,use_secrets=false" \
        < "$config_file" > "$temp_config" 2>/dev/null; then

        # Validate TOML syntax if python3 is available
        if command -v python3 >/dev/null 2>&1; then
            if python3 -c "import tomllib; tomllib.loads(open('$temp_config').read())" 2>/dev/null; then
                log_success "Config template generates valid TOML"
                rm -f "$temp_config"
                return 0
            else
                log_error "Config template generates invalid TOML"
                echo "Generated content (first 20 lines):"
                head -20 "$temp_config"
                rm -f "$temp_config"
                return 1
            fi
        else
            # Basic validation without TOML parsing
            if grep -q '^\[.*\]' "$temp_config" && ! grep -q 'undefined\|<no value>' "$temp_config"; then
                log_success "Config template appears valid (basic check)"
                rm -f "$temp_config"
                return 0
            else
                log_error "Config template appears invalid (basic check)"
                rm -f "$temp_config"
                return 1
            fi
        fi
    else
        log_error "Config template failed to render"
        rm -f "$temp_config"
        return 1
    fi
}

# Main validation loop
main() {
    log_info "Starting template validation for ${#@} files"

    local overall_success=true

    for template_file in "$@"; do
        # Skip non-template files that might have been passed
        if [[ ! "$template_file" =~ \.tmpl$ ]]; then
            log_info "Skipping non-template file: $template_file"
            continue
        fi

        # Special handling for the main config template
        if [[ "$template_file" == *".chezmoi.toml.tmpl" ]]; then
            if ! validate_config_template "$template_file"; then
                overall_success=false
            fi
        else
            # Regular template validation
            if ! validate_template "$template_file"; then
                overall_success=false
            fi
        fi
    done

    # Summary
    echo
    log_info "Template Validation Summary:"
    echo "  Total files: $total_files"
    echo -e "  ${GREEN}Passed: $passed_files${NC}"
    echo -e "  ${RED}Failed: $failed_files${NC}"

    if [[ "$overall_success" == "true" ]]; then
        log_success "All template validations passed!"
        exit 0
    else
        log_error "Some template validations failed!"
        exit 1
    fi
}

# Handle help flag
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [template_files...]"
    echo
    echo "Validate chezmoi template syntax for the provided template files."
    echo "Files are tested with multiple variable scenarios to ensure compatibility."
    echo
    echo "Examples:"
    echo "  $0 home/dot_gitconfig.tmpl"
    echo "  $0 home/*.tmpl"
    echo
    exit 0
fi

main "$@"
