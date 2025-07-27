# =============================================================================
# ANTIDOTE PLUGIN MANAGER CONFIGURATION
# =============================================================================
# This file configures antidote for managing zsh plugins, themes, and 
# shell-integrated CLI tools from GitHub releases.

# Plugin file paths
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins

# Ensure plugins file exists
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Source antidote (installed via Homebrew)
source /opt/homebrew/share/antidote/antidote.zsh

# Generate static plugin file when bundle file is newer
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  echo "Generating antidote plugin cache..."
  antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
fi

# Source the generated static plugin file
source ${zsh_plugins}.zsh

# =============================================================================
# PLUGIN CONFIGURATION
# =============================================================================

# fzf-tab configuration
zstyle ':completion:*' fzf-tab-command fzf
zstyle ':fzf-tab:complete:*' fzf-bindings 'tab:accept'
zstyle ':fzf-tab:*' single-group prefix

# Autosuggestions styling
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=60"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# You-should-use configuration
export YSU_MESSAGE_POSITION="after"
export YSU_HARDCORE=1

# =============================================================================
# CLI TOOL CONFIGURATION
# =============================================================================
# Note: Antidote doesn't automatically download GitHub release binaries like zinit
# For now, we'll install CLI tools via Homebrew and focus antidote on shell plugins only

# =============================================================================
# COMPLETION SETUP
# =============================================================================

# Ensure completion functions are loaded
autoload -Uz compinit
compinit

# Setup completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'