# Native completions - performance optimized with daily cache

# Daily completion cache (2025 best practice)
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
  compinit
else
  compinit -C
fi

# Completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# Bash completions support
autoload -U +X bashcompinit && bashcompinit

# Native tool completions (replaces Oh-My-Zsh plugins)
if command -v terraform &> /dev/null; then
  complete -o nospace -C terraform terraform
fi

if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

if command -v gh &> /dev/null; then
  eval "$(gh completion -s zsh)"
fi

if command -v op &> /dev/null; then
  eval "$(op completion zsh)"
fi

if command -v bun &> /dev/null && [[ -f "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi