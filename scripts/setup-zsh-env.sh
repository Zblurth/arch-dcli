#!/bin/bash
# One-time setup to point Zsh to the XDG config location

TARGET="$HOME/.zshenv"
CONFIG_DIR="$HOME/.config/zsh"

echo ":: Setting up Zsh XDG compliance..."

# Create the config dir if dcli hasn't yet
mkdir -p "$CONFIG_DIR"

# Write the .zshenv
cat > "$TARGET" << EOF
# Point Zsh to XDG config directory
export ZDOTDIR="$CONFIG_DIR"
export HISTFILE="$CONFIG_DIR/.zsh_history"
EOF

echo ":: Created $TARGET pointing to $CONFIG_DIR"
echo ":: Done."
