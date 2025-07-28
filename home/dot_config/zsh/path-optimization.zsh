#!/usr/bin/env zsh
# PATH OPTIMIZATION AND DEDUPLICATION
# This file provides utilities for efficient PATH management to reduce
# shell startup time by avoiding redundant directory checks and path modifications

# Ensure proper zsh mode
setopt NO_KSH_ARRAYS
setopt NO_SH_WORD_SPLIT

# PATH DEDUPLICATION FUNCTIONS

# Fast path deduplication using associative arrays
dedupe_path() {
  # Declare variables
  typeset -A seen_paths
  typeset -a new_path_array
  typeset path_element
  typeset IFS=':'
  
  # Convert PATH to array and deduplicate
  for path_element in $PATH; do
    if [[ -n "$path_element" ]] && [[ -z "${seen_paths[$path_element]}" ]]; then
      seen_paths[$path_element]=1
      new_path_array+=("$path_element")
    fi
  done
  
  # Reconstruct PATH
  export PATH="${(j/:/)new_path_array}"
}

# Add to PATH only if not already present and directory exists
add_to_path() {
  typeset new_path="$1"
  typeset position="${2:-end}"  # 'start' or 'end' (default)
  
  # Skip if path is empty or already in PATH
  [[ -n "$new_path" ]] || return 1
  [[ ":$PATH:" == *":$new_path:"* ]] && return 0
  
  # Only add if directory exists (with caching for performance)
  if [[ -d "$new_path" ]]; then
    case "$position" in
      start)
        export PATH="$new_path:$PATH"
        ;;
      *)
        export PATH="$PATH:$new_path"
        ;;
    esac
  fi
}

# Batch add multiple paths efficiently
add_paths_batch() {
  typeset position="${1:-end}"
  shift
  typeset path
  
  for path in "$@"; do
    add_to_path "$path" "$position"
  done
}

# OPTIMIZED PATH SETUP

# Cache directory existence checks for performance
typeset -A _path_exists_cache

path_exists() {
  typeset path="$1"
  
  # Check cache first
  if [[ -n "${_path_exists_cache[$path]}" ]]; then
    return "${_path_exists_cache[$path]}"
  fi
  
  # Check and cache result
  if [[ -d "$path" ]]; then
    _path_exists_cache[$path]=0
    return 0
  else
    _path_exists_cache[$path]=1
    return 1
  fi
}

# ENVIRONMENT-SPECIFIC PATH SETUP

# Homebrew paths (optimized check)
setup_homebrew_paths() {
  typeset brew_prefix
  
  # Determine Homebrew prefix efficiently
  if path_exists "/opt/homebrew/bin"; then
    brew_prefix="/opt/homebrew"
  elif path_exists "/usr/local/bin"; then
    brew_prefix="/usr/local"
  else
    return 1
  fi
  
  export HOMEBREW_PREFIX="$brew_prefix"
  add_paths_batch start "$brew_prefix/bin" "$brew_prefix/sbin"
}

# Development tool paths (non-mise managed only)
setup_dev_tool_paths() {
  # User local paths (always needed)
  add_paths_batch end \
    "$HOME/.scripts" \
    "$HOME/.local/bin"
  
  # Note: bun, go, node, pnpm, uv are managed by mise activate
  # Only add paths for tools NOT managed by mise
  
  # Windsurf (not managed by mise)
  add_to_path "/Users/dlawson/.codeium/windsurf/bin"
  
  # Legacy pnpm path (if PNPM_HOME is set by non-mise installation)
  # Note: mise-managed pnpm doesn't need this
  if [[ -n "$PNPM_HOME" && ! command -v mise &> /dev/null ]]; then
    add_to_path "$PNPM_HOME" start
  fi
}

# AUTOMATIC OPTIMIZATION

# Run optimization automatically when sourced
() {
  # Set up paths in optimal order
  setup_homebrew_paths
  setup_dev_tool_paths
  
  # Final deduplication
  dedupe_path
}