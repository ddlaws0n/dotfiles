# Shell Plugin Manager Migration: Zinit → Antidote

## Migration Overview

This project is migrating from zinit to antidote for shell plugin and CLI tool management, following a clear separation of concerns strategy.

## Tool Management Strategy

### **Homebrew** - System Tools, Dependencies & CLI Utilities
- **Purpose**: System-level tools, GUI applications, core dependencies, and CLI tools
- **Examples**: Core utilities, system libraries, GUI apps, fzf, bat, ripgrep, git-delta, gh, jq
- **Location**: `home/dot_config/homebrew/Brewfile`
- **Note**: ✅ Now includes CLI tools originally planned for antidote due to binary download limitations

### **mise** - Development Runtimes & Version Management
- **Purpose**: Language runtimes, development tools requiring version management
- **Examples**: Node.js, Python, Go, Terraform, kubectl
- **Location**: `home/dot_config/mise/config.toml`

### **antidote** - Shell Plugins, Themes & Completions
- **Purpose**: Zsh plugins, themes, shell completions only  
- **Examples**: Syntax highlighting, autosuggestions, fzf-tab, Oh-My-Zsh plugins
- **Location**: `$ZDOTDIR/.zsh_plugins.txt` (`~/.config/zsh/.zsh_plugins.txt`)
- **Note**: ⚠️ Unlike zinit, antidote doesn't automatically download GitHub release binaries

### **Starship** - Cross-Shell Prompt
- **Purpose**: Fast, customizable prompt with Git integration
- **Location**: `home/dot_config/starship.toml`

## Antidote Research Findings

### Core Advantages Over Zinit
- **Simplicity**: Text-based configuration vs complex ice modifiers
- **Performance**: Generates ultra-fast static plugin files
- **Maintainability**: Easier debugging and troubleshooting
- **Stability**: Focus on core plugin management without complexity

### Configuration Syntax
Antidote uses a simple `.zsh_plugins.txt` file format:
```bash
# Essential completions
mattmc3/ez-compinit
zsh-users/zsh-completions kind:fpath path:src

# CLI tools from GitHub releases
user/cli-tool kind:path

# Shell enhancements (deferred for performance)
zsh-users/zsh-autosuggestions kind:defer
zdharma-continuum/fast-syntax-highlighting kind:defer

# Theme
romkatv/powerlevel10k
```

### Migration Patterns from Zinit

| Zinit Ice | Antidote Equivalent | Purpose |
|-----------|-------------------|---------|
| `wait lucid` | `kind:defer` | Lazy loading |
| `as"program"` | `kind:path` | Add to PATH |
| `atload` | `post:command` | Run after loading |
| `src` | `path:file` | Source specific file |
| `pick` | `path:file` | Select file to load |

### Performance Setup
High-performance antidote configuration pattern:
```zsh
# In .zshrc
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

fpath=(/path/to/antidote/functions $fpath)
autoload -Uz antidote

# Generate static file when .txt is updated
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh
```

## Migration Plan

### Phase 1: Infrastructure Setup ✅
- [x] Update CLAUDE.md with separation of concerns strategy
- [x] Update README.md to reflect new tool management philosophy
- [x] Set ZDOTDIR environment variable in zprofile

### Phase 2: Configuration Migration
- [ ] Analyze current zinit plugins and CLI tools
- [ ] Create antidote bundle file (`.zsh_plugins.txt`)
- [ ] Update Brewfile to include CLI tools not suitable for antidote
- [ ] Configure antidote installation and static file generation

### Phase 3: Testing & Cleanup
- [ ] Test shell startup performance
- [ ] Verify all plugins and CLI tools work correctly
- [ ] Remove zinit configuration and plugin directories
- [ ] Update documentation with final configuration

## CLI Tools Categorization (Revised)

### **Key Discovery**: Antidote Binary Management Limitations
❌ **Original Plan**: Use antidote for GitHub release binaries like fzf, bat, ripgrep, etc.  
✅ **Reality**: Antidote doesn't have built-in binary download/compilation like zinit  
🔄 **Solution**: Move CLI tools to Homebrew, focus antidote on shell plugins only

### Final Tool Distribution

#### **Homebrew** (All CLI Tools)
- `fzf`, `bat`, `ripgrep`, `git-delta`, `gh`, `jq` - Originally planned for antidote
- `eza`, `tree`, `starship` - System integration required
- Core system utilities and GUI applications

#### **mise** (Development Runtimes)
- `node`, `python`, `go` runtimes
- `terraform`, `kubectl` - tools needing project-specific versions

#### **antidote** (Shell Plugins Only)
- `zsh-autosuggestions`, `fast-syntax-highlighting`, `fzf-tab`
- Oh-My-Zsh plugins (git, terraform, docker, kubectl)
- Completion system enhancements

## Configuration Structure

```
~/.config/zsh/
├── .zshrc                 # Main zsh configuration
├── .zsh_plugins.txt       # Antidote bundle file
├── .zsh_plugins.zsh       # Generated static file (auto-created)
├── aliases.zsh            # Command aliases
├── completion.zsh         # Completion configuration
├── functions.zsh          # Custom functions
└── plugins.zsh            # Plugin-specific configurations
```

## Benefits of This Revised Approach

1. **Clear Separation**: Each tool handles what it does best
2. **Maintainability**: Simpler configurations, easier debugging  
3. **Performance**: Antidote's static file generation for fast startup
4. **Reliability**: Homebrew's mature ecosystem for all CLI tools
5. **Flexibility**: mise for project-specific tool versions
6. **Pragmatic**: Uses each tool's strengths rather than forcing capabilities

## Lessons Learned

### **Antidote vs Zinit for Binary Management**
- **Zinit**: Complex but powerful binary management with `gh-r`, `sbin`, `make` ices
- **Antidote**: Focused on plugin management, simpler but no built-in binary downloads
- **Trade-off**: Lost some advanced features but gained simplicity and reliability

## Testing Checklist

### Pre-Migration Testing
- [ ] Record current shell startup time (`zsh-bench` or similar)
- [ ] List all currently working CLI tools and plugins
- [ ] Backup current zinit configuration

### Post-Migration Testing
- [ ] Shell startup time comparison
- [ ] All CLI tools accessible via `which` command
- [ ] Tab completion works for all tools
- [ ] Shell plugins function correctly (syntax highlighting, autosuggestions)
- [ ] Git integration works (delta, gh, starship)
- [ ] Project-specific tool versions work (mise)

## Rollback Plan

If migration fails:
1. Restore zinit configuration from backup
2. Reinstall zinit plugins: `zinit self-update && zinit update --all`
3. Remove antidote installation
4. Revert ZDOTDIR and other environment changes

## Next Steps

1. **Analyze current zinit setup** - Document all plugins and ice modifiers
2. **Create antidote bundle** - Convert zinit configuration to antidote syntax  
3. **Test incrementally** - Migrate one category at a time
4. **Optimize performance** - Use `kind:defer` for non-essential plugins
5. **Document final state** - Update all documentation with working configuration