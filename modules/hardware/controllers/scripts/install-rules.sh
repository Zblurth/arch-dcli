#!/bin/bash
set -e
echo "Installing Native Flydigi Udev Rules & InputPlumber Configs..."

# Robustly find the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FILES_DIR="$SCRIPT_DIR/../files"

# 1. Install Udev Rules
echo "--- Udev Rules ---"
sudo cp "$FILES_DIR/99-flydigi.rules" /etc/udev/rules.d/
sudo cp "$FILES_DIR/60-controller-support.rules" /etc/udev/rules.d/
echo "✓ Udev rules installed."

# 2. Install InputPlumber Configs
echo "--- InputPlumber ---"
sudo mkdir -p /etc/inputplumber/devices.d
sudo cp "$FILES_DIR/inputplumber-config.yaml" /etc/inputplumber/config.yaml
sudo cp "$FILES_DIR/60-flydigi_vader_4_pro.yaml" /etc/inputplumber/devices.d/
echo "✓ InputPlumber profiles installed."

# 3. Install Sleep Guard Script
echo "--- Sleep Guard ---"
SLEEP_SCRIPT="/usr/lib/systemd/system-sleep/50-vhci-fix.sh"
sudo cp "$FILES_DIR/50-vhci-fix.sh" "$SLEEP_SCRIPT"
sudo chmod +x "$SLEEP_SCRIPT"
echo "✓ Sleep fix installed to $SLEEP_SCRIPT"

# 4. Cleanup Old Hiding Rules (The "Nuclear" option is gone)
if [ -f /etc/udev/rules.d/99-vader-hide.rules ]; then
    echo "Removing old nuclear hiding rules..."
    sudo rm /etc/udev/rules.d/99-vader-hide.rules
fi

# 5. Reload
echo "--- Reloading ---"
sudo udevadm control --reload-rules
sudo udevadm trigger
# We do not restart inputplumber here; dcli sync will handle the service start.

echo "✓ Setup Complete. Please restart."