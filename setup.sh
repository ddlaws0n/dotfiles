#!/bin/zsh

# Source the symlinks script
SYMLINKS_SCRIPT="$(dirname "$0")/scripts/symlinks.sh"

if [ -f "$SYMLINKS_SCRIPT" ]; then
    echo "Sourcing symlinks script at $SYMLINKS_SCRIPT"
    . "$SYMLINKS_SCRIPT"
else
    echo "Error: Symlinks script not found at $SYMLINKS_SCRIPT" >&2
    exit 1
fi