#!/bin/zsh

# Set paths
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
XDG_VSCODE_DIR="$XDG_CONFIG_HOME/vscode"

# Move files
mv "$VSCODE_USER_DIR/settings.json" "$XDG_VSCODE_DIR/"
mv "$VSCODE_USER_DIR/keybindings.json" "$XDG_VSCODE_DIR/"
mv "$VSCODE_USER_DIR/snippets" "$XDG_VSCODE_DIR/" 2>/dev/null

# Symlink them back
echo "Creating symlinks for VSCode configuration files..."
ln -sfn "$XDG_VSCODE_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
ln -sfn "$XDG_VSCODE_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
ln -sfn "$XDG_VSCODE_DIR/snippets" "$VSCODE_USER_DIR/snippets"