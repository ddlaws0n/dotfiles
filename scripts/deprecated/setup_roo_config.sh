#!/bin/bash

# setup_roo_config.sh
# This script sets up the configuration files for Roo code in VS Code.
# It ensures the real configuration files are in the VS Code directory where the application expects them,
# and creates symlinks in ~/.config/roocode/ for easier management with tools like chezmoi.

set -e  # Exit immediately if a command exits with a non-zero status

# Define directories and files
VS_CODE_DIR="$HOME/Library/Application Support/Code/User/globalStorage/rooveterinaryinc.roo-cline/settings"
CONFIG_DIR="$HOME/.config/roocode"
FILES=("custom_modes.json" "mcp_settings.json")

# Function to print messages with color
print_message() {
  local color=$1
  local message=$2

  # Colors
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[0;33m'
  local BLUE='\033[0;34m'
  local NC='\033[0m' # No Color

  case $color in
    red) echo -e "${RED}$message${NC}" ;;
    green) echo -e "${GREEN}$message${NC}" ;;
    yellow) echo -e "${YELLOW}$message${NC}" ;;
    blue) echo -e "${BLUE}$message${NC}" ;;
    *) echo "$message" ;;
  esac
}

# Create the configuration directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  print_message "blue" "Creating configuration directory: $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
fi

# Create the VS Code directory if it doesn't exist
if [ ! -d "$VS_CODE_DIR" ]; then
  print_message "blue" "Creating VS Code directory: $VS_CODE_DIR"
  mkdir -p "$VS_CODE_DIR"
fi

# Process each configuration file
for file in "${FILES[@]}"; do
  vs_code_file="$VS_CODE_DIR/$file"
  config_file="$CONFIG_DIR/$file"

  # Check if the file exists in either location
  vs_code_file_exists=false
  config_file_exists=false

  if [ -e "$vs_code_file" ] && [ ! -L "$vs_code_file" ]; then
    vs_code_file_exists=true
  fi

  if [ -e "$config_file" ] && [ ! -L "$config_file" ]; then
    config_file_exists=true
  fi

  # If the file exists as a real file in both locations, keep the VS Code one and update the symlink
  if $vs_code_file_exists && $config_file_exists; then
    print_message "yellow" "File $file exists in both locations. Keeping VS Code version and updating symlink."
    rm "$config_file"
    ln -sf "$vs_code_file" "$config_file"
    continue
  fi

  # If the file exists only in the config dir, move it to VS Code dir and create symlink
  if $config_file_exists && ! $vs_code_file_exists; then
    print_message "blue" "Moving $file from config directory to VS Code directory"
    mv "$config_file" "$vs_code_file"
    ln -sf "$vs_code_file" "$config_file"
    continue
  fi

  # If the file exists only in VS Code dir, create the symlink
  if $vs_code_file_exists && ! $config_file_exists; then
    print_message "blue" "Creating symlink for $file in config directory"
    ln -sf "$vs_code_file" "$config_file"
    continue
  fi

  # If the file doesn't exist in either location, create an empty file in VS Code dir
  if ! $vs_code_file_exists && ! $config_file_exists; then
    print_message "yellow" "File $file doesn't exist in either location. Creating empty file in VS Code directory."
    touch "$vs_code_file"
    ln -sf "$vs_code_file" "$config_file"
    continue
  fi

  # Handle symlinks with wrong direction
  if [ -L "$vs_code_file" ] && [ ! -L "$config_file" ]; then
    # VS Code file is a symlink but config file is not
    print_message "yellow" "Symlink direction is wrong for $file. Fixing..."
    target=$(readlink "$vs_code_file")
    rm "$vs_code_file"

    if [ -e "$config_file" ]; then
      # If config file exists, move it to VS Code dir
      mv "$config_file" "$vs_code_file"
    else
      # If config file doesn't exist, create empty file in VS Code dir
      touch "$vs_code_file"
    fi

    # Create symlink in config dir
    ln -sf "$vs_code_file" "$config_file"
  fi
done

print_message "green" "Configuration setup complete. Roo configuration files are now in:"
print_message "green" "  $VS_CODE_DIR"
print_message "green" "with symlinks in:"
print_message "green" "  $CONFIG_DIR"
print_message "green" "You can now manage these files with chezmoi or other configuration tools."

# Make the script executable
chmod +x "$0"

