#!/usr/bin/env bash
# Docker Setup Hook
# Handles adding the user to the docker group safely

set -euo pipefail

# 1. Detect the target user
TARGET_USER="${SUDO_USER:-$USER}"

if [[ "$TARGET_USER" == "root" ]]; then
    echo ":: Warning: Detected 'root' as the target user."
    echo "   Skipping docker group addition (root already has full access)."
    exit 0
fi

# 2. Check if user is already in the group
if groups "$TARGET_USER" | grep -q "\bdocker\b"; then
    echo ":: User '$TARGET_USER' is already in the docker group."
else
    echo ":: Adding '$TARGET_USER' to docker group..."
    usermod -aG docker "$TARGET_USER"
    echo ":: Done. NOTE: You may need to log out and back in for this to take effect."
fi
