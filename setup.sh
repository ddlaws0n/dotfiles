#!/bin/bash

# Reference: https://github.com/joelazar/dotfiles/blob/main/run_once_install_packages.sh
# Source the Chezmoi environment
SOURCE_DIR=$(chezmoi source-path)

# Source the symlinks script
SYMLINKS_SCRIPT="$(dirname "$0")/scripts/symlinks.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "Install packages\n"

ask_for_confirmation "Would you like to do it now? It can take a bit of time."
if ! answer_is_yes; then
    exit
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f "$SYMLINKS_SCRIPT" ]; then
    echo "Sourcing symlinks script at $SYMLINKS_SCRIPT"
    . "$SYMLINKS_SCRIPT"
else
    echo "Error: Symlinks script not found at $SYMLINKS_SCRIPT" >&2
    exit 1
fi
