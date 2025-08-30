#!/bin/bash

# Setup secrets directory with proper permissions
# This runs once before templates are applied

set -euo pipefail

SECRETS_DIR="$HOME/.local/share/secrets"

# Create secrets directory if it doesn't exist
if [[ ! -d "$SECRETS_DIR" ]]; then
    echo "Creating secrets directory: $SECRETS_DIR"
    mkdir -p "$SECRETS_DIR"
fi

# Set restrictive permissions (only owner can read/write/execute)
chmod 700 "$SECRETS_DIR"

echo "Secrets directory configured at: $SECRETS_DIR"
echo "Permissions set to 700 (owner only)"