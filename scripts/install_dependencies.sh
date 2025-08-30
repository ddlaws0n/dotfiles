#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting dependency installation..."

# Ensure Homebrew is available
if ! command -v brew >/dev/null; then
  echo "Error: Homebrew is not installed. Please run install_homebrew.sh first."
  exit 1
fi

# Function to check if a formula is installed
is_installed() {
  brew list "$1" >/dev/null 2>&1
}

# Install zsh
echo "Checking for zsh..."
if ! is_installed zsh; then
  echo "Installing zsh..."
  brew install zsh
  echo "zsh installed successfully."
else
  echo "zsh is already installed."
fi

# Install antidote
echo "Checking for antidote..."
if ! is_installed antidote; then
  echo "Installing antidote..."
  brew install antidote
  echo "antidote installed successfully."
  echo "Note: antidote will be configured via chezmoi dotfiles, not directly in ~/.zshrc"
else
  echo "antidote is already installed."
fi

# Install uv
echo "Checking for uv (Python package manager)..."
if ! is_installed uv; then
  echo "Installing uv..."
  brew install uv
  echo "uv installed successfully."
else
  echo "uv is already installed."
fi

echo "Dependency installation complete."
