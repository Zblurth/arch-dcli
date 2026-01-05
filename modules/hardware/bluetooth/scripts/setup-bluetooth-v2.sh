#!/bin/bash
# Enable AutoEnable in /etc/bluetooth/main.conf
# This ensures Bluetooth is powered on at boot

set -e

CONFIG="/etc/bluetooth/main.conf"

if [ -f "$CONFIG" ]; then
    echo "Configuring Bluetooth auto-enable..."
    
    # Replace commented or disabled AutoEnable
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' "$CONFIG"
    sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/' "$CONFIG"
    sudo sed -i 's/^AutoEnable=false/AutoEnable=true/' "$CONFIG"
    
    # If AutoEnable line doesn't exist at all, add it under [Policy] section
    if ! grep -q "^AutoEnable=true" "$CONFIG"; then
        if grep -q "^\[Policy\]" "$CONFIG"; then
            sudo sed -i '/^\[Policy\]/a AutoEnable=true' "$CONFIG"
        else
            echo -e "\n[Policy]\nAutoEnable=true" | sudo tee -a "$CONFIG"
        fi
    fi
    
    echo "✓ Bluetooth AutoEnable configured"
    
    # Install Unblock Rule (The "Slap Awake" Fix)
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    RULE_FILE="$SCRIPT_DIR/../files/70-bluetooth-unblock.rules"
    if [ -f "$RULE_FILE" ]; then
        echo "Installing persistent unblock rule..."
        sudo cp "$RULE_FILE" /etc/udev/rules.d/
        sudo udevadm control --reload-rules
        sudo udevadm trigger
    fi

    # Install Systemd Force Service (The "Sledgehammer" Fix)
    SERVICE_FILE="$SCRIPT_DIR/../files/bluetooth-force-enable.service"
    if [ -f "$SERVICE_FILE" ]; then
        echo "Installing force-enable service..."
        sudo cp "$SERVICE_FILE" /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable --now bluetooth-force-enable.service
    fi

    # Unblock rfkill if soft-blocked
    if command -v rfkill &> /dev/null; then
        echo "Unblocking Bluetooth via rfkill..."
        sudo rfkill unblock bluetooth
    fi

    # Restart service to apply changes if it's already running
    if systemctl is-active --quiet bluetooth; then
        echo "Restarting bluetooth service to apply changes..."
        sudo systemctl try-restart bluetooth
    fi
else
    echo "Warning: $CONFIG not found. Is bluez installed?"
fi
