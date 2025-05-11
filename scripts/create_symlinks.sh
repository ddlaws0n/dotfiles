#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting symlink creation..."

# Determine the absolute path of the chezmoi root directory
# This script assumes it is located in a subdirectory (e.g., scripts/) of the chezmoi root.
SCRIPT_DIR_REAL_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" > /dev/null && pwd)
CHEZMOI_ROOT_DIR=$(dirname "$SCRIPT_DIR_REAL_PATH")

echo "Chezmoi root identified as: $CHEZMOI_ROOT_DIR"

# Function to create a symlink
# $1: User-friendly name for the source (for logging)
# $2: Source directory/file path relative to chezmoi root
# $3: Target symlink path (absolute)
create_symlink() {
    local name="$1"
    local source_rel_path="$2"
    local target_path="$3"
    local source_abs_path="$CHEZMOI_ROOT_DIR/$source_rel_path"

    echo "Processing symlink for $name: $source_abs_path -> $target_path"

    if [ ! -e "$source_abs_path" ]; then
        echo "WARNING: Source path $source_abs_path does not exist. Skipping $name."
        return
    fi

    # Ensure the parent directory of the target exists
    local target_parent_dir
    target_parent_dir=$(dirname "$target_path")
    if [ ! -d "$target_parent_dir" ]; then
        echo "Creating parent directory for target: $target_parent_dir"
        mkdir -p "$target_parent_dir"
    fi

    # Create or update the symlink
    # -s: symbolic link
    # -f: force (remove existing destination file if it exists)
    # -n: no-dereference / directory (treat LINK_NAME as a normal file if it is a symbolic link to a directory)
    if ln -sfn "$source_abs_path" "$target_path"; then
        echo "Successfully created/updated symlink for $name."
    else
        echo "ERROR: Failed to create symlink for $name. Exit code: $?"
        # Consider exiting or allowing to continue: exit 1
    fi
}

# VSCode User Settings
# On macOS, the typical path is ~/Library/Application Support/Code/User
# The source in chezmoi is specified as home/dot_config/vscode
# This script will link $CHEZMOI_ROOT_DIR/home/dot_config/vscode to $HOME/Library/Application Support/Code/User on macOS.
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Platform is macOS. Setting up VSCode symlink."
    VSCODE_SOURCE_RELATIVE="home/dot_config/vscode"
    VSCODE_TARGET_ABSOLUTE="$HOME/Library/Application Support/Code/User"
    create_symlink "VSCode User Settings (macOS)" "$VSCODE_SOURCE_RELATIVE" "$VSCODE_TARGET_ABSOLUTE"
else
    echo "Platform is not macOS. Skipping macOS-specific VSCode symlink to ~/Library/Application Support/Code/User."
    echo "If you intend to link home/dot_config/vscode to ~/.config/vscode on this platform, chezmoi's default behavior might handle it, or you can add specific logic here."
    # Example for Linux-like systems if desired:
    # VSCODE_SOURCE_RELATIVE="home/dot_config/vscode"
    # VSCODE_TARGET_ABSOLUTE="$HOME/.config/vscode" # Or $HOME/.config/Code/User depending on convention
    # create_symlink "VSCode User Settings (Linux-like)" "$VSCODE_SOURCE_RELATIVE" "$VSCODE_TARGET_ABSOLUTE"
fi

# Roo Code Settings
# Source: home/dot_config/roocode in chezmoi repository
# Target: ~/.config/roocode
ROOCODE_SOURCE_RELATIVE="home/dot_config/roocode"
ROOCODE_TARGET_ABSOLUTE="$HOME/.config/roocode"
create_symlink "Roo Code Settings" "$ROOCODE_SOURCE_RELATIVE" "$ROOCODE_TARGET_ABSOLUTE"

echo ""
echo "---"
echo "Important Considerations for Symlinks and Chezmoi:"
echo "1. Chezmoi's Purpose: 'chezmoi apply' is designed to create symlinks (or copy files, etc.) from your source directory (e.g., $CHEZMOI_ROOT_DIR/home/dot_config/something) to the target location (e.g., $HOME/.config/something)."
echo "2. Potential Overlap: This script creates symlinks directly. If the source paths (e.g., '$VSCODE_SOURCE_RELATIVE', '$ROOCODE_SOURCE_RELATIVE') are also managed by chezmoi in a way that targets the same destination paths, there could be overlap or conflict. 'chezmoi apply' might try to manage the same symlinks."
echo "3. macOS VSCode Path: For VSCode on macOS, if your chezmoi source is '$VSCODE_SOURCE_RELATIVE' (`home/dot_config/vscode`), chezmoi would typically target `$HOME/.config/vscode`. This script explicitly targets `$HOME/Library/Application Support/Code/User`. If this specific mapping is desired, using this script (or a chezmoi 'run_' script) is one way to achieve it. Alternatively, structuring your chezmoi source as 'home/Library/Application Support/Code/User' would allow 'chezmoi apply' to handle it directly for macOS."
echo "4. Idempotency: This script uses 'ln -sfn' to be idempotent, replacing existing symlinks or files at the target."
echo "5. Review and Test: Ensure these symlinking operations align with your overall chezmoi strategy and test thoroughly."
echo "---"
echo ""
echo "Symlink creation script finished."
