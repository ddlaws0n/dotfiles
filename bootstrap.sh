#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Bootstrapping environment…"

# 1. Install or update Homebrew non-interactively
if ! command -v brew >/dev/null 2>&1; then
  echo "⏳ Installing Homebrew…"
  NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Load brew into PATH for this session
  eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
else
  echo "🔄 Updating Homebrew…"
  brew update
fi

# 2. Install 1Password CLI
if ! brew list --cask 1password-cli >/dev/null 2>&1; then
  echo "⏳ Installing 1Password CLI…"
  brew install --cask 1password-cli
else
  echo "✅ 1Password CLI already present."
fi

# 3. Install chezmoi
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "⏳ Installing chezmoi…"
  # Prefer Homebrew formula for simplicity:
  brew install chezmoi
  # Or one-liner installer:
  # sh -c "$(curl -fsLS get.chezmoi.io)"
else
  echo "✅ chezmoi already installed."
fi

# 4. Initialize and apply your dotfiles
echo "🚀 Running chezmoi init and apply…"
chezmoi init --apply ddlaws0n
