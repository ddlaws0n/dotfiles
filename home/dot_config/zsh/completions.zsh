# ZSH COMPLETIONS
# Combined completion management with lazy loading for optimal startup performance

# Completion cache directory
typeset -g ZSH_COMPLETION_CACHE_DIR="${ZDOTDIR:-$HOME/.config/zsh}/completions"
[[ -d "$ZSH_COMPLETION_CACHE_DIR" ]] || mkdir -p "$ZSH_COMPLETION_CACHE_DIR"

# COMPINIT SETUP
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

# COMPLETION STYLES
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# FPATH SETUP
# Ensure fpath includes paths for custom completions
fpath=(
  $HOMEBREW_PREFIX/share/zsh/site-functions
  $HOME/.local/share/zsh/site-functions  # Custom completions
  $fpath
)

# BASH COMPLETIONS
autoload -U +X bashcompinit && bashcompinit

# IMMEDIATE COMPLETIONS (fast loading only)
# Load immediate completions (fast tools only)
if command -v bun &> /dev/null && [[ -f "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi

# Terraform completion (already optimized by terraform)
if command -v terraform &> /dev/null; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

# Essential commands that should load immediately (not wrapped)
if command -v gh &> /dev/null; then
  eval "$(gh completion -s zsh)" 2>/dev/null || true
fi

if command -v starship &> /dev/null; then
  eval "$(starship completions zsh)" 2>/dev/null || true
fi

# Note: mise completion is handled by mise activate, no additional setup needed

# LAZY COMPLETION LOADING SYSTEM
# For expensive completion generators to improve shell startup time

# Generate and cache completion for a tool
_lazy_load_completion() {
  local tool="$1"
  local cache_file="$ZSH_COMPLETION_CACHE_DIR/_${tool}"
  local completion_age_hours=168  # 1 week
  
  # Check if cache exists and is fresh
  if [[ -f "$cache_file" ]] && [[ ! "$cache_file" -ot "$(date -v-${completion_age_hours}H +%Y%m%d%H%M)" ]]; then
    source "$cache_file"
    return 0
  fi
  
  # Generate completion based on tool
  case "$tool" in
    gh)
      if command -v gh &> /dev/null; then
        gh completion -s zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
    fnm)
      if command -v fnm &> /dev/null; then
        fnm completions --shell zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
    uv)
      if command -v uv &> /dev/null; then
        uv generate-shell-completion zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
    op)
      if command -v op &> /dev/null; then
        op completion zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
    starship)
      if command -v starship &> /dev/null; then
        starship completions zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
    turso)
      if command -v turso &> /dev/null; then
        turso completion zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
    mise)
      # Note: mise completion is usually handled by mise activate
      # This is a fallback for cases where completion isn't loaded via activate
      if command -v mise &> /dev/null; then
        mise completion zsh > "$cache_file" 2>/dev/null && source "$cache_file"
      fi
      ;;
  esac
}

# Create lazy-loading wrapper functions
_create_lazy_wrapper() {
  local tool="$1"
  eval "
    $tool() {
      unfunction $tool 2>/dev/null || true
      _lazy_load_completion $tool
      if command -v $tool &> /dev/null; then
        command $tool \"\$@\"
      else
        echo \"$tool: command not found\" >&2
        return 127
      fi
    }
  "
}

# List of tools to lazy load (expensive completion generators)
# Note: Removed essential commands that shouldn't be wrapped (gh, mise, etc.)
typeset -a LAZY_COMPLETION_TOOLS=(
  fnm  
  uv
  op
  turso
)

# Create lazy wrappers for each tool
for tool in $LAZY_COMPLETION_TOOLS; do
  if command -v "$tool" &> /dev/null; then
    _create_lazy_wrapper "$tool"
  fi
done

# BACKGROUND COMPLETION PRELOADING
# Preload completions in background (run after shell is interactive)
_preload_completions() {
  for tool in $LAZY_COMPLETION_TOOLS; do
    if command -v "$tool" &> /dev/null; then
      _lazy_load_completion "$tool" &
    fi
  done
  wait  # Wait for all background jobs
}

# Schedule background preloading after shell startup
if [[ -o interactive ]]; then
  # Use zsh/zutil module for background execution
  zmodload zsh/zutil 2>/dev/null || true
  
  # Schedule preloading after a short delay
  () {
    sleep 0.1
    _preload_completions
  } &!
fi