# Session Summary: Apps & Bluetooth Persistence

**Date:** Monday, January 5, 2026
**Objective:** Install Orca Slicer and WinBoat, and fix persistent Bluetooth soft-lock.

## 🛠 Changes Made

### 1. New Packages
- Added `orca-slicer` to `modules/apps/dev.yaml`.
- Added `winboat` to `modules/apps/utils/packages.yaml`.

### 2. Bluetooth "Hammer" Fix
- **Problem**: Bluetooth was soft-locked on every boot, requiring manual `rfkill unblock`.
- **Solution**: Created a custom systemd service `bluetooth-force-enable.service` that:
    - Waits 5 seconds after boot (to bypass race conditions).
    - Runs `rfkill unblock bluetooth`.
    - Runs `bluetoothctl power on`.
- **Implementation**: Updated `modules/hardware/bluetooth/scripts/setup-bluetooth-v2.sh` to install and enable this service automatically.

### 3. Bluetooth "Nuclear" Fix (Update)
- **Investigation**: The "Hammer" fix was insufficient because the MediaTek controller was stuck in a `Failed (0x03)` or `Busy` state, requiring a kernel module reload.
- **Root Cause**: Likely aggressive power management (autosuspend) putting the MT7921/MT7922 chip into a zombie state.
- **Solution**:
    1.  **Disable Autosuspend**: Added `options btusb enable_autosuspend=n` to `/etc/modprobe.d/btusb-mediatek.conf`.
    2.  **Module Reload Cycle**: Updated `bluetooth-force-enable.service` to:
        - Stop `bluetooth.service`.
        - Unload `btusb` module.
        - Reload `btusb` module.
        - Restart `bluetooth.service`.
        - Unblock and Power On.
- **Result**: Immediate recovery of Bluetooth functionality without reboot.

## ✅ Verification Required
- [ ] Run `dcli sync` to apply changes.
- [ ] Verify `orca-slicer` and `winboat` appear in the launcher.
- [ ] Reboot and verify Bluetooth is active without manual intervention.