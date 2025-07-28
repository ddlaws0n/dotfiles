#!/usr/bin/env zsh
# PATH MANAGEMENT
# Handles PATH setup and deduplication for optimal shell startup

# Add Homebrew to PATH if not already present
if [[ -d "/opt/homebrew/bin" ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local/bin" ]] && [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  export HOMEBREW_PREFIX="/usr/local"
fi

# Add user paths
for dir in "$HOME/.scripts" "$HOME/.local/bin" "/Users/dlawson/.codeium/windsurf/bin"; do
  if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$PATH:$dir"
  fi
done

# PATH deduplication
if [[ -n "$PATH" ]]; then
  OLD_IFS="$IFS"
  IFS=":"
  NEWPATH=""
  for p in $PATH; do
    if [[ -n "$p" ]] && [[ ":$NEWPATH:" != *":$p:"* ]]; then
      if [[ -n "$NEWPATH" ]]; then
        NEWPATH="$NEWPATH:$p"
      else
        NEWPATH="$p"
      fi
    fi
  done
  export PATH="$NEWPATH"
  IFS="$OLD_IFS"
fi