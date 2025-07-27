# [ddlaws0n](https://github.com/ddlaws0n)’s dotfiles 🚀

My personal and work-related dotfiles. managed via [chezmoi](https://github.com/twpayne/chezmoi)

## Key Technologies & Tools

- **Configuration Management**: Chezmoi v2.x
- **Secret Management**: 1Password CLI (`op`)
- **Package Management**: Homebrew, fnm (Node), uv (Python)
- **Shell**: Zsh with Zinit, Starship prompt
- **Primary Editor**: VS Code with 50+ extensions
- **Secondary Editors**: Windsurf, Roocode (both with MCP integrations)
- **Development Languages**: Python 3.12+, Go, TypeScript/JavaScript

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

3. **Install packages:**

   ```sh
   ./setup.sh
   ```

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
