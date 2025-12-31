#!/usr/bin/env bash
# Nix Setup Hook for Arch Linux
set -euo pipefail

echo ":: Configuring Nix daemon..."
systemctl enable --now nix-daemon.service

# Add current user to nix-users if not already there
if ! grep -q "^nix-users:" /etc/group; then
    echo ":: Creating nix-users group..."
    groupadd -rf nix-users
fi

TARGET_USER="${SUDO_USER:-$USER}"
if ! groups "$TARGET_USER" | grep -q "\bnix-users\b"; then
    echo ":: Adding $TARGET_USER to nix-users..."
    usermod -aG nix-users "$TARGET_USER"
fi

echo ":: Enabling Nix flakes and experimental features..."
mkdir -p /etc/nix
cat > /etc/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
trusted-users = root lune
EOF

echo ":: Nix setup complete. You may need to log out and back in for group changes to take effect."

