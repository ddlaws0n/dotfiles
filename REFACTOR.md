# Chezmoi Dotfiles Refactoring Plan

> Comprehensive analysis and refactoring recommendations for improving maintainability, security, and functionality.

## 🎯 Executive Summary

Your chezmoi setup has a solid foundation with good organization and modern tooling. Key areas for improvement include fixing broken template references, centralizing secret management, reducing configuration duplication, and adding automation/validation.

**Overall Health Score: ⭐⭐⭐ (3/5)**

---

## 📊 Analysis Results

### 1. File Organization & Structure ⭐⭐⭐⭐⭐

**Current State:** Well-organized with templates properly structured.

**CORRECTION: Templates Already Exist**
The `.chezmoitemplates/dot_templates/` directory contains:
- `mcp/mcp_server_settings.json.tmpl` - MCP server configuration
- `rules/` - LLM instruction files (coding patterns, doc generation, project-specific rules)
- `git-ignores/` - Gitignore templates

**Minor Issues:**
- Template organization uses `dot_templates/` subdirectory (works but unconventional)
- Inconsistent `.tmpl` usage on static files
- Limited use of `.chezmoidata/` (only onepassword.toml exists)

**Action Items:**
```bash
# Option 1: Keep current working structure (no action needed)
# Option 2: Simplify by removing dot_templates layer:
mv home/.chezmoitemplates/dot_templates/* home/.chezmoitemplates/
rmdir home/.chezmoitemplates/dot_templates

# Expand data organization
mkdir -p .chezmoidata
touch .chezmoidata/defaults.yaml
touch .chezmoidata/platforms.yaml
```

### 2. Template Complexity ⭐⭐

**Current State:** Simple and readable templates with good conditionals.

**Issues:**
- Repetitive 1Password calls across files
- Hard-coded vault names
- Complex nested conditionals in `.chezmoi.toml.tmpl`

**Solution:** Create reusable template functions and centralize secret mappings.

### 3. Secret Management ⭐⭐⭐⭐

**Current State:** Excellent 1Password integration with proper separation.

**Enhancement Opportunities:**
- Configurable vault names
- Fallback mechanisms
- Better secret inventory management

### 4. Configuration Patterns ⭐⭐⭐

**Issues:** Duplicate configurations, mixed data types, no shared defaults.

### 5. Scripts & Automation ⭐⭐⭐⭐

**Current State:** Well-structured with modern practices.

**Missing:** Dependency validation, automated testing, consolidated setup logic.

### 6. Missing Features ⭐⭐

**Gaps:** No testing framework, macOS defaults, backup mechanism, or CI/CD integration.

---

## 🚀 Implementation Roadmap

### Phase 1: Critical Fixes (HIGH Priority)

#### 1.1 Template Organization (Optional Improvement)
```bash
# Current structure (WORKING):
# .chezmoitemplates/dot_templates/{mcp,rules,git-ignores}/

# Templates are correctly referenced with:
# {{ template "dot_templates/mcp/mcp_server_settings.json.tmpl" . }}

# Optional: Simplify structure
mv home/.chezmoitemplates/dot_templates/* home/.chezmoitemplates/
# Then update references to: {{ template "mcp/mcp_server_settings.json.tmpl" . }}
```

#### 1.2 Centralize Secret Management
Create `.chezmoidata/secrets.yaml`:
```yaml
secrets:
  openrouter_api_key: "op://my/openrouter-api/credential"
  firecrawl_api_key: "op://my/firecrawl-api/credential"
  gemini_api_key: "op://my/gemini-api/credential"
  
vaults:
  personal: "my"
  work: "wizio"
```

#### 1.3 Create Reusable Template Functions
Create `home/.chezmoitemplates/secrets.tmpl`:
```go
{{- define "apiKey" -}}
{{- if and .use_secrets (not .is_ci_workflow) -}}
{{- onepasswordRead (index .secrets .key) .vault -}}
{{- end -}}
{{- end -}}
```

### Phase 2: Configuration Optimization (MEDIUM Priority)

#### 2.1 Create Shared Configuration Blocks
Create `.chezmoidata/defaults.yaml`:
```yaml
editor:
  font_family: "JetBrains Mono"
  font_size: 12
  theme: "Catppuccin Mocha"

git:
  name: "David D Lawson"
  user: "ddlaws0n"

paths:
  projects: "{{ .chezmoi.homeDir }}/{{ .git_dir }}"
  work_projects: "{{ .chezmoi.homeDir }}/{{ .git_dir }}/work"
```

#### 2.2 Consolidate Setup Scripts
Create unified `scripts/setup-unified.sh` with modular functions:
```bash
check_dependencies() {
    local deps=("chezmoi" "op" "gh" "code" "brew")
    for dep in "${deps[@]}"; do
        command -v "$dep" >/dev/null || {
            echo "❌ Missing dependency: $dep"
            exit 1
        }
    done
    echo "✅ All dependencies found"
}
```

#### 2.3 Remove Unnecessary Templates
Audit and remove `.tmpl` extension from files that don't use templating:
- `home/dot_config/starship.toml` (if no templating used)
- Static configuration files

### Phase 3: Modern Features (LOW Priority)

#### 3.1 Add Automated Testing
Create `tests/validate-dotfiles.sh`:
```bash
#!/bin/bash
set -e

echo "🧪 Testing chezmoi configuration..."
chezmoi verify

# Test template execution without applying
echo "📝 Testing template rendering..."
chezmoi execute-template < home/.chezmoi.toml.tmpl > /dev/null

# Validate critical templates
for tmpl in home/dot_zprofile.tmpl home/dot_gitconfig.tmpl; do
    if [ -f "$tmpl" ]; then
        echo "✓ Testing $tmpl"
        chezmoi cat ~/${tmpl%.tmpl} > /dev/null || echo "✗ Failed: $tmpl"
    fi
done

echo "🔐 Testing 1Password integration..."
if command -v op >/dev/null; then
    op whoami >/dev/null && echo "✅ 1Password authenticated"
fi

echo "🛠  Testing key applications..."
code --version >/dev/null && echo "✅ VS Code working"
git --version >/dev/null && echo "✅ Git working"
```

**Additional Testing Commands (from chezmoi docs):**
```bash
# Test specific template execution
chezmoi execute-template '{{ .chezmoi.hostname }}'

# Preview file output without applying
chezmoi cat ~/.zprofile

# Dry run to see what would change
chezmoi diff
```

#### 3.2 Implement macOS Defaults
Create `home/dot_scripts/executable_macos-defaults`:
```bash
#!/bin/bash
# macOS System Defaults

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Restart affected applications
killall Dock Finder SystemUIServer
```

#### 3.3 Add CI/CD Integration
Create `.github/workflows/validate-dotfiles.yml`:
```yaml
name: Validate Dotfiles
on: [push, pull_request]

jobs:
  validate:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install chezmoi
        run: brew install chezmoi
      - name: Validate configuration
        run: |
          chezmoi verify
          echo "✅ Dotfiles validation passed"
```

---

## 📋 Detailed Action Items

### Immediate Actions (This Week)
- [ ] Create missing template directories and files
- [ ] Fix broken template references
- [ ] Test current setup with `chezmoi verify`

### Short-term (Next 2 Weeks)
- [ ] Implement centralized secret management
- [ ] Create reusable template functions
- [ ] Add dependency validation to setup scripts
- [ ] Remove unnecessary `.tmpl` extensions

### Medium-term (Next Month)
- [ ] Create shared configuration blocks
- [ ] Implement macOS defaults script
- [ ] Add automated testing framework
- [ ] Consolidate setup script logic

### Long-term (Next Quarter)
- [ ] Add GitHub Actions CI/CD
- [ ] Implement modular component system
- [ ] Create comprehensive documentation
- [ ] Add backup/restore mechanisms

---

## 🔧 Key Files to Refactor

| File | Priority | Action | Estimated Time |
|------|----------|--------|---------------|
| `home/.chezmoi.toml.tmpl` | HIGH | Restructure data organization | 2h |
| `home/dot_zprofile.tmpl` | HIGH | Centralize secret patterns | 1h |
| `home/dot_config/vscode/settings.json.tmpl` | MEDIUM | Reduce duplication | 1h |
| `scripts/setup.sh` | MEDIUM | Consolidate logic | 2h |
| Missing template files | HIGH | Create structure | 1h |

---

## ⚠️ Risk Assessment

**Low Risk:**
- Adding automation and testing
- Creating shared templates
- Documentation improvements

**Medium Risk:**
- Restructuring secret management (test thoroughly)
- Changing file organization
- Modifying setup scripts

**High Risk:**
- Breaking existing 1Password integration
- Removing working configurations

**Mitigation Strategy:**
1. Always backup current working state
2. Test changes in isolated environment first
3. Implement incrementally with rollback plans
4. Validate each phase before proceeding

---

## 🎉 Expected Benefits

After implementing these refactoring recommendations:

- **🔒 Enhanced Security**: Centralized secret management with proper fallbacks
- **🛠 Improved Maintainability**: Reduced duplication and cleaner templates
- **🚀 Better Automation**: Automated testing and validation
- **📈 Increased Reliability**: Dependency checking and error handling
- **🎯 Modern Best Practices**: CI/CD integration and modular architecture

---

## 📚 Next Steps

1. **Review this plan** and prioritize based on your immediate needs
2. **Backup current setup**: `chezmoi archive > dotfiles-backup.tar`
3. **Start with Phase 1**: Fix critical issues first
4. **Test incrementally**: Validate each change before proceeding
5. **Document changes**: Update README as you implement

**Estimated Total Implementation Time: 12-16 hours across 4-6 weeks**

---

## 📖 Additional Context from Chezmoi Documentation

### Template Organization Best Practices

1. **Template Directory Structure:**
   - Templates in `.chezmoitemplates/` are referenced by relative path
   - No `dot_` prefix needed for template files
   - Subdirectories help organize complex setups

2. **Template Functions vs Include:**
   - `{{ define "name" }}...{{ end }}` - Creates reusable named templates
   - `{{ template "name" . }}` - Calls a defined template
   - `{{ includeTemplate "file" . }}` - Includes file content as template

3. **Data Organization:**
   - `.chezmoidata.*` files for static data
   - `[data]` section in `.chezmoi.toml` for dynamic data
   - Template functions can access all data with `.`

4. **1Password Integration:**
   - `onepasswordRead "op://vault/item/field"` for secrets
   - Cache results to avoid repeated CLI calls
   - Consider using `onepasswordDocument` for complex items

### Common Pitfalls to Avoid

1. **Template Path Confusion:**
   - ❌ `{{ template "dot_templates/file.tmpl" . }}`
   - ✅ `{{ template "file.tmpl" . }}`

2. **Missing Context:**
   - ❌ `{{ template "mytemplate" }}`
   - ✅ `{{ template "mytemplate" . }}`

3. **Eager Evaluation:**
   - Templates evaluate all branches of conditionals
   - Use nested `if` statements carefully
   - Consider using `and`/`or` for complex logic

---

*Generated: 2025-01-27*
*Based on latest chezmoi documentation via context7*