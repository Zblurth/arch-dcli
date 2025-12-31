#!/bin/bash
# Niri Keybind Helper
CONFIG_FILE="$HOME/.config/niri/config.kdl"

echo "=== Niri Keybindings ==="
grep -E "Mod\+|XF86" "$CONFIG_FILE" | grep "{" | sed 's/{//g' | sed 's/spawn//g' | sed 's/"//g' | sed 's/;//g' | sed 's/^[ \t]*//'
echo "========================"
echo "Press any key to exit..."
read -n 1
