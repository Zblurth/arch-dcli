#!/bin/bash
set -e
echo "Installing InputPlumber & Vader 4 Pro Support..."
sudo mkdir -p /etc/inputplumber/devices.d
sudo cp modules/hardware/controllers/files/inputplumber-config.yaml /etc/inputplumber/config.yaml
sudo cp modules/hardware/controllers/files/60-flydigi_vader_4_pro.yaml /etc/inputplumber/devices.d/
sudo cp modules/hardware/controllers/files/99-vader-hide.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo systemctl restart inputplumber
echo "✓ Configs applied and service restarted."
