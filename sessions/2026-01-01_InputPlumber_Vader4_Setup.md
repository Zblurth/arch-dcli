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
