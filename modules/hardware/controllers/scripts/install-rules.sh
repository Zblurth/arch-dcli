#!/bin/bash
set -e

SOURCE_DIR="$(dirname "$(dirname "$0")")/files"
TARGET_DIR="/etc/udev/rules.d"

echo "Checking Hardware Udev Rules..."

# Function to install and reload
install_rule() {
    local source_path="$1"
    local target_path="$2"
    local filename=$(basename "$source_path")
    
    echo "Installing $filename..."
    sudo cp "$source_path" "$target_path"
    return 0
}

RELOAD_REQUIRED=false

# Iterate over all .rules files in the module's files directory
for rule_path in "$SOURCE_DIR"/*.rules; do
    [ -e "$rule_path" ] || continue
    filename=$(basename "$rule_path")
    target_path="$TARGET_DIR/$filename"
    
    if [ ! -f "$target_path" ] || ! cmp -s "$rule_path" "$target_path"; then
        install_rule "$rule_path" "$target_path"
        RELOAD_REQUIRED=true
    fi
done

if [ "$RELOAD_REQUIRED" = true ]; then
    echo "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "✓ Rules updated and applied."
else
    echo "✓ All hardware rules are up to date."
fi