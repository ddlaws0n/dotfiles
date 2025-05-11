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

# Install zinit
echo "Checking for zinit..."
if ! is_installed zinit; then
  echo "Installing zinit..."
  brew install zinit
  echo "zinit installed successfully."
  echo "Ensuring zinit is sourced in ~/.zshrc..."
  # Add zinit sourcing to .zshrc if not already present
  # This path comes from `brew info zinit`
  ZINIT_SOURCE_LINE="source \$HOMEBREW_PREFIX/opt/zinit/zinit.zsh"
  if ! grep -qF -- "$ZINIT_SOURCE_LINE" ~/.zshrc >/dev/null 2>&1; then
    echo "$ZINIT_SOURCE_LINE" >> ~/.zshrc
    echo "Added zinit source to ~/.zshrc."
  else
    echo "zinit source already in ~/.zshrc."
  fi
else
  echo "zinit is already installed."
  # Still ensure it's sourced, in case it was removed from .zshrc
  echo "Ensuring zinit is sourced in ~/.zshrc..."
  ZINIT_SOURCE_LINE="source \$HOMEBREW_PREFIX/opt/zinit/zinit.zsh"
  if ! grep -qF -- "$ZINIT_SOURCE_LINE" ~/.zshrc >/dev/null 2>&1; then
    echo "$ZINIT_SOURCE_LINE" >> ~/.zshrc
    echo "Added zinit source to ~/.zshrc."
  else
    echo "zinit source already in ~/.zshrc."
  fi
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
