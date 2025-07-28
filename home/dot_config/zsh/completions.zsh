# ZSH COMPLETIONS
# Combined completion management with lazy loading for optimal startup performance

# Completion cache directory
typeset -g ZSH_COMPLETION_CACHE_DIR="${ZDOTDIR:-$HOME/.config/zsh}/completions"
[[ -d "$ZSH_COMPLETION_CACHE_DIR" ]] || mkdir -p "$ZSH_COMPLETION_CACHE_DIR"

# COMPINIT SETUP
# Smart daily rebuild pattern for optimal performance
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "${ZDOTDIR}/.zcompdump"
else
  compinit -C -d "${ZDOTDIR}/.zcompdump"
fi

# COMPLETION STYLES
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# Note: FPATH setup moved to .zprofile to ensure it's available before compinit

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

# Note: gh and starship completions now handled via lazy loading system to avoid duplication

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
    source "$cache_file" 2>/dev/null || true
    return 0
  fi
  
  # Only generate completion if tool exists and is executable
  if ! command -v "$tool" &> /dev/null; then
    return 1
  fi
  
  # Generate completion based on tool with error handling
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
      # Remove the wrapper function to avoid infinite recursion
      unfunction $tool 2>/dev/null || true
      
      # Try to load completion (with error handling)
      _lazy_load_completion $tool 2>/dev/null || true
      
      # Execute the actual command if it exists
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
typeset -a LAZY_COMPLETION_TOOLS=(
  fnm  
  uv
  op
  turso
  gh
  starship
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