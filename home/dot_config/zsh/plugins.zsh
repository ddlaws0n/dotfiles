# Zinit plugins.
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"

# Bootstrap Zinit
if [[ ! -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-history-substring-search
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
zinit light zdharma-continuum/fast-syntax-highlighting

# Config
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'

# Vi-mode hook (for keybindings)
zvm_after_init() {
  bindkey '^P' history-search-backward
  bindkey '^N' history-search-forward
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  bindkey '^R' history-incremental-search-backward
  bindkey '^S' history-incremental-search-forward
}

# Compinit (cached, 24h)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh-24) ]]; then
  compinit -C -d "${ZDOTDIR}/.zcompdump"
else
  compinit -d "${ZDOTDIR}/.zcompdump"
fi
zinit cdreplay -q

# Dynamic completions (cached for CLI tools)
_load_completion() {
  local tool=$1
  shift
  command -v $tool &>/dev/null || return
  local cache_file="${COMPLETION_CACHE_DIR}/_${tool}"
  if [[ ! -f "$cache_file" ]] || [[ "$(command -v $tool)" -nt "$cache_file" ]]; then
    "$@" > "$cache_file" 2>/dev/null
  fi
  [[ -f "$cache_file" ]] && source "$cache_file"
}

# Standard format: <tool> completion zsh
for tool in kubectl op docker chezmoi pnpm golangci-lint deno; do
  _load_completion $tool $tool completion zsh
done

# Special cases
_load_completion gh gh completion -s zsh
_load_completion just just --completions zsh
_load_completion bun bun completions
