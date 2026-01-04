#!/usr/bin/env bash

# setup-vivaldi.sh
# Symlinks vivaldi-stable.conf to ~/.config/

CONF_NAME="vivaldi-stable.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_FILE="$MODULE_DIR/$CONF_NAME"

# Determine the target home directory
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TARGET_FILE="$TARGET_HOME/.config/$CONF_NAME"

echo "Setting up Vivaldi flags for user $TARGET_USER..."

if [ -f "$SOURCE_FILE" ]; then
    mkdir -p "$TARGET_HOME/.config"
    if [ -L "$TARGET_FILE" ]; then
        rm "$TARGET_FILE"
    elif [ -f "$TARGET_FILE" ]; then
        mv "$TARGET_FILE" "${TARGET_FILE}.bak"
    fi
    ln -s "$SOURCE_FILE" "$TARGET_FILE"
    chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_FILE"
    echo "✓ Symlinked $CONF_NAME to $TARGET_HOME/.config/"
else
    echo "✗ Source file $SOURCE_FILE not found!"
    exit 1
fi
