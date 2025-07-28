# =============================================================================
# COMPLETION CACHE OPTIMIZATION
# =============================================================================
# Note: Primary compinit is handled by mattmc3/ez-compinit plugin
# This provides fallback and cache optimization for additional completions

# Only run compinit if ez-compinit hasn't already done it
if [[ -z "$_comps[zstyle]" ]]; then
  autoload -Uz compinit
  if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "${ZDOTDIR}/.zcompdump"
  else
    compinit -C -d "${ZDOTDIR}/.zcompdump"
  fi
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# Bash completions
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Ensure fpath includes paths for custom completions
fpath=(
  $HOMEBREW_PREFIX/share/zsh/site-functions
  $HOME/.local/share/zsh/site-functions  # Custom completions
  $fpath
)

# =============================================================================
# OPTIMIZED COMPLETION LOADING
# =============================================================================

# Load immediate completions (fast tools only)
if command -v bun &> /dev/null && [[ -f "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi

# Terraform completion (already optimized)
if command -v terraform &> /dev/null; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

# Note: Expensive completion generators (gh, fnm, uv, op, starship, turso, mise)
# are now handled by lazy-completions.zsh for optimal startup performance
