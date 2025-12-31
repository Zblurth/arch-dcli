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

## Troubleshooting After Reboot

If Bluetooth does not work after a reboot, follow these checks:

### 1. Check Service Status
Ensure the service is running and enabled.
```bash
systemctl status bluetooth
```
It should say `Active: active (running)` and `Loaded: ... ; enabled;`.
If disabled, run: `sudo systemctl enable --now bluetooth`

### 2. Check Block Status
Ensure it's not soft-blocked (airplane mode).
```bash
rfkill list bluetooth
```
If `Soft blocked: yes`, run: `sudo rfkill unblock bluetooth`

### 3. Check Configuration
Verify `AutoEnable` is still set.
```bash
grep "AutoEnable" /etc/bluetooth/main.conf
```
It should return `AutoEnable=true`.

### 4. Controller Visibility
Check if the controller is powered on.
```bash
bluetoothctl show
```
Look for `Powered: yes`. If `no`, run `bluetoothctl power on`.

### 5. Check Log for Errors
```bash
journalctl -u bluetooth -b --no-pager
```
