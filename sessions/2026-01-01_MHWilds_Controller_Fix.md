# Session Summary: MHWilds Controller Input Fix

**Date:** Thursday, January 1, 2026
**Objective:** Resolve "no input" issue in Monster Hunter Wilds for Flydigi Vader 4 Pro in D-Input mode.

## 🛠 Changes Made

### 1. Udev Rule Refinement
- **Reverted** Flydigi Vader 4 Pro rules to a "hidraw-only" configuration.
- Removed `SUBSYSTEM=="input"` rules that were causing duplicate/ghost controller entries.
- **Why**: Capcom games (MHWilds) often fail when multiple device paths exist for the same physical controller.

### 2. Module Persistence
- Committed the `hardware/controllers` module to Git.
- Verified that `scripts/install-rules.sh` correctly deploys rules to `/etc/udev/rules.d/`.

### 3. Manual Sync
- Executed `sudo ./modules/hardware/controllers/scripts/install-rules.sh` to force a udev reload and trigger.

## ✅ Verification
- User confirmed controller input is working in MHWilds while in D-Input mode.
- Paddles and Steam API features remain functional via the `hidraw` rule.

## 📌 Open Tasks
- [ ] Monitor for ghost controllers if other gamepads (Switch, etc.) are connected.
- [ ] Push changes to remote repository (`dcli repo push`).
