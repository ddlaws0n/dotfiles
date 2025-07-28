# =============================================================================
# LAZY COMPLETION LOADING SYSTEM
# =============================================================================
# This file implements lazy loading for expensive completion generation
# to dramatically improve shell startup time

# Completion cache directory
typeset -g ZSH_COMPLETION_CACHE_DIR="${ZDOTDIR:-$HOME/.config/zsh}/completions"
[[ -d "$ZSH_COMPLETION_CACHE_DIR" ]] || mkdir -p "$ZSH_COMPLETION_CACHE_DIR"

# =============================================================================
# LAZY LOADING FUNCTIONS
# =============================================================================

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

# =============================================================================
# IMMEDIATE LOADING FOR CRITICAL TOOLS
# =============================================================================

# Load critical completions immediately (fast tools only)
if command -v bun &> /dev/null && [[ -f "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi

# Load terraform completion (already optimized by terraform)
if command -v terraform &> /dev/null; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

# =============================================================================
# LAZY LOADING SETUP
# =============================================================================

# List of tools to lazy load (expensive completion generators)
typeset -a LAZY_COMPLETION_TOOLS=(
  gh
  fnm  
  uv
  op
  starship
  turso
  mise
)

# Create lazy wrappers for each tool
for tool in $LAZY_COMPLETION_TOOLS; do
  if command -v "$tool" &> /dev/null; then
    _create_lazy_wrapper "$tool"
  fi
done

# =============================================================================
# BACKGROUND COMPLETION PRELOADING
# =============================================================================

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