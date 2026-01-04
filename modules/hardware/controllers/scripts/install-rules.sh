#!/bin/bash
set -e
echo "Installing Native Flydigi Udev Rules & InputPlumber Configs..."

# Robustly find the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FILES_DIR="$SCRIPT_DIR/../files"

# 1. Install Udev Rules (Nuclear Option)
echo "--- Udev Rules ---"
# Clean up old junk rules if they exist
sudo rm -f /etc/udev/rules.d/60-controller-support.rules
sudo rm -f /etc/udev/rules.d/70-bluetooth-unblock.rules
sudo rm -f /etc/udev/rules.d/40-flydigi-deny.rules
sudo rm -f /etc/udev/rules.d/99-flydigi.rules

# Install the active rule
sudo cp "$FILES_DIR/99-vader-hide.rules" /etc/udev/rules.d/
echo "✓ Udev rules installed."

# 2. Install InputPlumber Configs
echo "--- InputPlumber ---"
sudo mkdir -p /etc/inputplumber/devices.d
sudo cp "$FILES_DIR/config.yaml" /etc/inputplumber/config.yaml
sudo cp "$FILES_DIR/60-flydigi_vader_4_pro.yaml" /etc/inputplumber/devices.d/
echo "✓ InputPlumber profiles installed."

# 3. Install Sleep Guard Script
echo "--- Sleep Guard ---"
SLEEP_SCRIPT="/usr/lib/systemd/system-sleep/50-vhci-fix.sh"
# Clean up dead service file if it exists
sudo rm -f /etc/systemd/system/inputplumber-suspend.service
# Install script
sudo cp "$FILES_DIR/50-vhci-fix.sh" "$SLEEP_SCRIPT"
sudo chmod +x "$SLEEP_SCRIPT"
echo "✓ Sleep fix installed to $SLEEP_SCRIPT"

# 4. Reload
echo "--- Reloading ---"
sudo udevadm control --reload-rules
sudo udevadm trigger
# Ensure InputPlumber is running
sudo systemctl enable --now inputplumber

echo "✓ Setup Complete. System is Clean."