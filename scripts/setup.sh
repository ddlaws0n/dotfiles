#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting main setup process..."

# Determine the directory where this script is located
SCRIPT_DIR_REAL_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" > /dev/null && pwd)
echo "Script directory: $SCRIPT_DIR_REAL_PATH"

# --- Step 1: Install Homebrew ---
echo ""
echo "--- Running Homebrew Installation Script ---"
if [ -f "$SCRIPT_DIR_REAL_PATH/install_homebrew.sh" ]; then
    bash "$SCRIPT_DIR_REAL_PATH/install_homebrew.sh"
else
    echo "ERROR: install_homebrew.sh not found in $SCRIPT_DIR_REAL_PATH. Skipping."
    # exit 1 # Optionally exit if this is critical
fi
echo "--- Homebrew Installation Script Finished ---"

# --- Step 2: Install Dependencies ---
echo ""
echo "--- Running Dependency Installation Script ---"
if [ -f "$SCRIPT_DIR_REAL_PATH/install_dependencies.sh" ]; then
    bash "$SCRIPT_DIR_REAL_PATH/install_dependencies.sh"
else
    echo "ERROR: install_dependencies.sh not found in $SCRIPT_DIR_REAL_PATH. Skipping."
    # exit 1 # Optionally exit if this is critical
fi
echo "--- Dependency Installation Script Finished ---"

# --- Step 3: Create Symlinks ---
# Note: Review the create_symlinks.sh script for how it interacts with chezmoi's own symlinking.
echo ""
echo "--- Running Symlink Creation Script ---"
if [ -f "$SCRIPT_DIR_REAL_PATH/create_symlinks.sh" ]; then
    bash "$SCRIPT_DIR_REAL_PATH/create_symlinks.sh"
else
    echo "ERROR: create_symlinks.sh not found in $SCRIPT_DIR_REAL_PATH. Skipping."
fi
echo "--- Symlink Creation Script Finished ---"


# --- Step 4: Initialize and Apply Chezmoi ---
echo ""
echo "--- Running Chezmoi ---"
if command -v chezmoi >/dev/null; then
    echo "Initializing Chezmoi (if not already initialized)..."
    # chezmoi init will prompt for repository if not already configured.
    # This assumes the user has already cloned their dotfiles or will provide the repo.
    # For an automated script, one might pre-configure the repo or pass it as an argument.
    # Depending on how chezmoi is set up (e.g. if .chezmoi.toml.tmpl exists and is configured)
    # `chezmoi init` might require user input if it's the very first run.
    # If the repo is already cloned and chezmoi is initialized in this directory, this step is quick.
    chezmoi init

    echo "Applying Chezmoi configuration..."
    # This is where chezmoi creates its symlinks, runs its scripts, etc.
    # The prompt for `work_computer` (if configured in chezmoi) would happen here.
    chezmoi apply -v # -v for verbose output
    echo "Chezmoi apply finished."
else
    echo "ERROR: chezmoi command not found. Please install chezmoi first."
    echo "You might need to add it to your PATH or install it via Homebrew (brew install chezmoi)."
    # exit 1 # Optionally exit
fi
echo "--- Chezmoi Finished ---"

echo ""
echo "Main setup process complete."
echo "Please ensure all scripts executed as expected and review any output for errors or warnings."
echo "You may need to restart your shell or source your .zshrc/.bashrc for all changes to take effect."
