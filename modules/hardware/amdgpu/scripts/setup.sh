#!/bin/bash
set -e

SOURCE_DIR="$(dirname "$(dirname "$0")")/files"
POLKIT_TARGET="/etc/polkit-1/rules.d/90-corectrl.rules"

echo "Applying AMD GPU Optimizations..."

# 1. Install Polkit Rule for CoreCtrl
if [ -f "$SOURCE_DIR/90-corectrl.rules" ]; then
    echo "Installing CoreCtrl Polkit rules..."
    sudo cp "$SOURCE_DIR/90-corectrl.rules" "$POLKIT_TARGET"
    sudo chown root:root "$POLKIT_TARGET"
    sudo chmod 644 "$POLKIT_TARGET"
fi

# 2. Add clearcpuid=514 to GRUB (Fix for MH Wilds / Ryzen 7000 UMIP)
GRUB_FILE="/etc/default/grub"
if grep -q "clearcpuid=514" "$GRUB_FILE"; then
    echo "✓ UMIP fix already present in GRUB."
else
    echo "Adding UMIP fix (clearcpuid=514) to GRUB..."
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="clearcpuid=514 /' "$GRUB_FILE"
    sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT='/GRUB_CMDLINE_LINUX_DEFAULT='clearcpuid=514 /" "$GRUB_FILE"
    
    echo "Regenerating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "✓ AMD GPU optimizations applied."
