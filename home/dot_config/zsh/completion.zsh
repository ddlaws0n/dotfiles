# Faster compinit
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
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

# Generate completions for tools that support it
if command -v gh &> /dev/null; then
  eval "$(gh completion -s zsh)"
fi

if command -v fnm &> /dev/null; then
  eval "$(fnm completions --shell zsh)"
fi

if command -v uv &> /dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v op &> /dev/null; then
  eval "$(op completion zsh)"
fi

# Bun completions (if available)
if command -v bun &> /dev/null && [[ -f "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi

# Starship completions (prompt tool)
if command -v starship &> /dev/null; then
  eval "$(starship completions zsh)"
fi

# Turso completions (database CLI)
if command -v turso &> /dev/null; then
  eval "$(turso completion zsh)"
fi

# Additional completions for tools in Brewfile
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi
