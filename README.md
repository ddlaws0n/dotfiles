# [ddlaws0n](https://github.com/ddlaws0n)’s dotfiles 🚀

My personal and work-related dotfiles. managed via [chezmoi](https://github.com/twpayne/chezmoi)

## Key Technologies & Tools

- **Configuration Management**: Chezmoi v2.x
- **Secret Management**: 1Password CLI (`op`)
- **Package Management**: Homebrew (system tools), mise (runtimes), antidote (shell plugins)
- **Shell**: Zsh with antidote, Starship prompt
- **Primary Editor**: VS Code with 50+ extensions
- **Secondary Editors**: Windsurf, Roocode (both with MCP integrations)
- **Development Languages**: Python 3.12+, Go, TypeScript/JavaScript

## Tool Management Philosophy

This dotfiles setup uses a **separation of concerns** approach:

- 🏠 **Homebrew**: System tools, GUI apps, core dependencies
- 🔧 **mise**: Development runtimes & version-managed tools (Node, Python, Go)
- 🚀 **antidote**: Shell plugins, themes, completions (fast startup)
- ⭐ **Starship**: Cross-shell prompt with Git integration

Benefits: Fast shell startup, clear responsibilities, easy maintenance.

## Project Structure

```
.
├── home/                          # All dotfiles with chezmoi naming
│   ├── .chezmoi.toml.tmpl        # Main chezmoi config template
│   ├── .chezmoidata/             # Static data files
│   │   └── onepassword.toml      # 1Password secret mappings
│   ├── .chezmoitemplates/        # Reusable templates (currently empty)
│   ├── dot_config/               # XDG config files
│   ├── dot_scripts/              # Executable utility scripts
│   └── dot_zprofile.tmpl         # Zsh profile with secrets
├── scripts/                       # Setup and installation scripts
├── tests/                        # Test scripts (to be created)
├── README.md                     # Basic documentation
└── REFACTOR.md                   # Detailed refactoring plan
```

## Setup Instructions ⚡

1. **Install chezmoi** (if not already installed):

   ```sh
   brew install chezmoi
   ```

2. **Initialize dotfiles:**

   ```sh
   chezmoi init https://github.com/ddlaws0n/dotfiles.git
   chezmoi apply
   ```

3. **Install packages and dependencies:**

   ```sh
   ./setup.sh
   bun install  # Install prettier and formatting tools
   ```

## Git Hooks & Code Quality 🔍

This repository uses **lefthook** for fast, reliable git hooks that ensure code quality:

### Features

- **Template Validation**: Native chezmoi template validation
- **Code Formatting**: Prettier with go-template support for `.tmpl` files
- **Secret Detection**: Quick checks for hardcoded secrets/credentials
- **State Verification**: Ensures chezmoi state consistency
- **Merge Conflict Detection**: Prevents accidental commits with conflicts

### Usage

```sh
# Hooks are automatically installed with lefthook
# Run manually:
lefthook run pre-commit    # Run all pre-commit checks
lefthook run pre-push      # Run pre-push validation

# Skip hooks when needed:
LEFTHOOK=0 git commit      # Skip all hooks
LEFTHOOK_EXCLUDE=format git commit  # Skip specific hooks

# Format templates:
bunx prettier --write **/*.tmpl
```

### Configuration

- `lefthook.yml` - Simplified hook configuration (~50 lines vs 260+ in old setup)
- `.prettierrc` - Prettier configuration with go-template plugin
- `scripts/quick-validate.sh` - Consolidated validation script

---

## References

- [mac.install.guide](https://mac.install.guide/)
- [eddies notes](https://eddiesnotes.com/apple/macos-defaults-guide/)
- [emmer.dev](https://emmer.dev/blog/automate-your-macos-defaults/)

---

## Inspiration 🙏

- [anthonycorletti](https://github.com/anthonycorletti/dotfiles)
- [emmercm](https://github.com/emmercm/dotfiles)
- [jessfraz](https://github.com/jessfraz/dotfiles)

---

## License 📄

The code is available under the [MIT license](LICENSE).
