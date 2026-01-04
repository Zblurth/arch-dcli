# FULL SYSTEM & CONTROLLER DUMP

## 1. Project Configuration

### hosts/arch.yaml
```yaml
# Host configuration for arch
# Optimized CachyOS Workstation (Hierarchical Architecture)

host: arch
description: CachyOS Workstation (Ryzen 7800X3D + AMD GPU)

# Enabled modules (Hierarchical)
enabled_modules:
  # --- Core (Bootable Layer) ---
  - core/base
  - core/network
  - hardware/bluetooth
  - core/admin
  - core/cachyos
  - core/nix
  
  # --- Hardware ---
  - hardware/amdgpu
  - hardware/controllers
  
  # --- Desktop (Graphical Layer) ---
  - desktop/niri
  - desktop/audio
  - desktop/shell
  - desktop/visuals
  - desktop/theme
  - fonts            # Kept top-level for now
  
  # --- Apps (User Layer) ---
  - apps/internet
  - apps/media
  - apps/dev
  - apps/utils
  - apps/gaming

# Host-specific packages
packages: []

# Exclude packages
exclude: []

# System Settings
flatpak_scope: user
auto_prune: false
backup_tool: snapper
snapper_config: root

# Service Management (Rescued & Optimized)
services:
  enabled:
    - NetworkManager
    - NetworkManager-dispatcher
    - bluetooth
    - sshd
    - ly@tty2               # TUI Login Manager
    - ananicy-cpp           # CachyOS Auto-Nice
    - ufw                   # Firewall
    - avahi-daemon          # Local Network Discovery
    - swayosd-libinput-backend # OSD Backend
    - inputplumber          # Flydigi/Controller Router
    - snapper-timeline.timer
    - snapper-cleanup.timer
    - grub-btrfsd
    - power-profiles-daemon
    - coolercontrold
  disabled:
    - sddm
    - lightdm
    - gdm
```

### modules/hardware/controllers/files/60-flydigi_vader_4_pro.yaml
```yaml
version: 1
kind: CompositeDevice
name: flydigi-vader-4-pro
matches: []
maximum_sources: 5
source_devices:
  - group: gamepad
    udev:
      attributes:
        - name: idVendor
          value: "04b4"
        - name: idProduct
          value: "2412"
        - name: bInterfaceNumber
          value: "02"
      subsystem: hidraw
target_devices:
  - deck
capability_map_id: flydigi-vader-4-pro
options:
  auto_manage: true
```

### modules/hardware/controllers/files/99-vader-hide.rules
```udev
SUBSYSTEM=="input", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", ENV{ID_INPUT}:="", ENV{ID_INPUT_JOYSTICK}:="", ENV{ID_INPUT_KEY}:="", ENV{LIBINPUT_IGNORE_DEVICE}:="1", RUN+="/usr/bin/rm -f %E{DEVNAME}"
```

### modules/hardware/controllers/files/inputplumber-config.yaml
```yaml
options:
  manage_all_devices: true
```

### modules/hardware/controllers/scripts/install-rules.sh
```bash
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
```

## 2. Session History & Troubleshooting

### sessions/2026-01-01_InputPlumber_Vader4_Setup.md
```md
# Session Summary: InputPlumber & Flydigi Vader 4 Pro Setup

**Date:** Thursday, January 1, 2026
**Objective:** Manage Flydigi Vader 4 Pro extra buttons and resolve "duplicate controller" issue using InputPlumber.

## 🛠 Changes Made

### 1. Package Management
- Created `modules/hardware/controllers/packages.yaml` containing `inputplumber`.
- Updated `modules/hardware/controllers/module.yaml` to include the new package file.
- Installed `inputplumber` (v0.70.1) and its dependencies (`libiio`, `libserialport`).

### 2. Service Integration
- Enabled `inputplumber` service in `hosts/arch.yaml`.
- Verified service is active and listening on D-Bus.

### 3. Udev Rule Hardening
- Modified `modules/hardware/controllers/files/60-controller-support.rules`.
- **Hiding Strategy**: Cleared `ID_INPUT_JOYSTICK` for the physical Flydigi VID:PID (04b4:2412).
- This prevents Steam/SDL from seeing the raw hardware, leaving only the virtual InputPlumber device visible.

### 4. System Sanity Check
- Verified `niri` configuration for input conflicts (none found).
- Verified PipeWire audio stack.

## ✅ Verification Required
- [ ] Connect Vader 4 Pro in D-Input mode.
- [ ] Verify single controller visibility in Steam.
- [ ] Verify C/Z buttons map to virtual trackpad/buttons as per InputPlumber defaults.

## 📌 Open Tasks
- [ ] Push changes to remote repository.

## 🚀 Final Refinements & Success

### 1. Diagnostic: Interface Fingerprint
- Confirmed the Vader 4 Pro in D-Input mode presents 4 `hidraw` nodes.
- Identified that `bInterfaceNumber == "02"` is the specific node required for the Gamepad profile.

### 2. Profile Optimization
- Refined `/etc/inputplumber/devices.d/60-flydigi_vader_4_pro.yaml` to specifically match interface `02`.
- This prevents InputPlumber from creating 4 separate virtual controllers (one for every raw node).

### 3. Service & Policy Hardening
- Created `/etc/inputplumber/config.yaml` with `manage_all_devices: true` to force the daemon to claim the hardware.
- Updated the systemd unit override to set `WorkingDirectory=/` to fix a bug where InputPlumber couldn't find its internal drivers.

### 4. Ghost Node "Nuclear" Fix
- Updated `99-vader-hide.rules` with a high-priority rule.
- **Aggressive Hiding**: In addition to clearing ID tags, the rule now executes `RUN+="/usr/bin/rm -f %E{DEVNAME}"` on the physical event/joystick nodes.
- **Result**: The physical "VADER4" joystick is physically removed from `/dev/input/`, ensuring MHWilds sees **only** the virtual Steam Deck controller created by InputPlumber.

## ✅ Final Verification
- `inputplumber devices list` confirms 1 composite device active.
- `/dev/input/by-id/` shows only the `InputPlumber_Generic_Steam_Controller`.
- **Status**: Monster Hunter Wilds input is fully functional with extra buttons mapped.
```

### sessions/BLUETOOTH_TROUBLESHOOTING.md
```md
# Bluetooth Fix & Troubleshooting Guide

## What Was Wrong
1. **Script Path Mismatch**: The setup script was being edited in the global `scripts/` directory, but `dcli` was configured to use a script inside the module directory.
2. **Missing Logic**: The original script only set `AutoEnable=true` but didn't handle `rfkill` unblocking or service restarting.
3. **Corrupted State**: The user couldn't connect or remove devices, indicating corruption in `/var/lib/bluetooth`.

## What Was Fixed
1. **Updated Script**: Created `modules/hardware/bluetooth/scripts/setup-bluetooth-v2.sh` which:
   - Sets `AutoEnable=true` in `/etc/bluetooth/main.conf`.
   - Runs `rfkill unblock bluetooth`.
   - Restarts `bluetooth.service`.
2. **State Reset**: Completely cleared `/var/lib/bluetooth/*` to remove corrupted device cache.
3. **Module Config**: Updated `module.yaml` to point to the new v2 script.
```

## 3. Runtime State Information

### lsmod | grep vhci
```
vhci_hcd               73728  0
usbip_core             45056  1 vhci_hcd
```

### lsusb -t (Virtual Bus Highlight)
```
/:  Bus 008.Port 001: Dev 001, Class=root_hub, Driver=vhci_hcd/8p, 480M
    |__ Port 001: Dev 006, If 0, Class=Human Interface Device, Driver=usbhid, 480M
    |__ Port 001: Dev 006, If 1, Class=Human Interface Device, Driver=usbhid, 480M
    |__ Port 001: Dev 006, If 2, Class=Human Interface Device, Driver=usbhid, 480M
```

### Virtual Device Details (008:006)
```
  idVendor           0x28de Valve Software
  idProduct          0x12f0 Generic Steam Controller
  iManufacturer           1 InputPlumber
  iProduct                2 Generic Steam Controller 
```

### Suspend Error Logs
```
janv. 03 16:20:13 arch kernel: usb usb8-port1: device 8-1 not suspended yet
janv. 03 16:20:13 arch kernel: vhci_hcd vhci_hcd.0: We have 1 active connection. Do not suspend.
janv. 03 16:20:13 arch kernel: vhci_hcd vhci_hcd.0: PM: dpm_run_callback(): platform_pm_suspend returns -16
janv. 03 16:20:13 arch kernel: vhci_hcd vhci_hcd.0: PM: failed to suspend: error -16
janv. 03 16:20:13 arch systemd-sleep[194208]: Failed to put system to sleep. System resumed again: Device or resource busy
janv. 03 16:20:13 arch bluetoothd[1096]: Controller resume with wake event 0x0
```