#!/bin/bash
# Disables problematic wakeup sources on AMD Ryzen 7000 series
# Identified as causing immediate wake from suspend (Spurious native interrupt)

SERVICE_NAME="disable-wakeup-gpp.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

# List of wake sources to disable
# GPP7: Chipset/USB/SATA Bridge (Primary culprit)
# GP17: Internal GPP Bridge (Audio/USB/PSP)
# GPP0: GPU Bridge (Radeon RX 9070)
# XH00: USB Controller (0000:0f:00.0) - Causing resume errors
TARGETS="GPP7 GP17 GPP0 XHC0 XHC1 XH00"

echo "Creating $SERVICE_NAME..."
cat <<EOF | sudo tee $SERVICE_PATH
[Unit]
Description=Disable wakeup on problematic PCI bridges and USB controllers
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for dev in $TARGETS; do grep -q "\$dev.*enabled" /proc/acpi/wakeup && echo \$dev > /proc/acpi/wakeup; done || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Restarting service..."
sudo systemctl restart $SERVICE_NAME

echo "Current wakeup status:"
cat /proc/acpi/wakeup | grep -E "($(echo $TARGETS | tr ' ' '|'))"