#!/usr/bin/env bash
# Ultimate Antigravity Launcher for Arch
# Fixes permissions, invisible text, and session loss

export PATH="/usr/bin:/usr/local/bin:$PATH"
export XDG_DATA_DIRS="/usr/share:/usr/local/share:$XDG_DATA_DIRS"
export FONTCONFIG_PATH="/etc/fonts"

# Kill old instances safely
# We target the binary specifically to avoid killing this script
pkill -9 -x antigravity || true
pkill -9 -f "/opt/Antigravity/antigravity" || true

# Ensure the Gemini folder is writable before launch
chmod -R u+rw ~/.gemini/antigravity

# Launch with flags to fix Wayland/Niri rendering and xdg-open
# Added --enable-proposed-api for internal Google extensions
/usr/bin/antigravity \
    --no-sandbox \
    --disable-gpu \
    --enable-features=UseOzonePlatform \
    --ozone-platform=wayland \
    --password-store="gnome-libsecret" \
    --enable-proposed-api google.antigravity \
    "$@" &
