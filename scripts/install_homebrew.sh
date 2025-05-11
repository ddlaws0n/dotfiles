#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking for Homebrew..."

# Check if Homebrew is installed
if ! command -v brew >/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  # Install Homebrew - Sourced from https://brew.sh
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for the current session
  # For M1 Macs (arm64)
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  # For Intel Macs (x86_64)
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "Homebrew installed successfully."
else
  echo "Homebrew is already installed."
fi

echo "Making sure Homebrew is up to date..."
brew update

echo "Homebrew setup complete."
