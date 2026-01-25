# Session: Fixing Niri & Noctalia (Jan 2026 Update)
**Date**: 2026-01-25
**Topic**: Debugging broken session after CachyOS January 2026 Update.

## 🚨 Symptoms
1. **Launch Failure**: `ly` failed to launch Niri/Noctalia (returned to login or hung).
2. **UI Glitches**: Massive gap between Noctalia bar and Niri windows.
3. **Performance**: Browser and other apps taking 20+ seconds to launch.
4. **Logs**: `systemd` showed repeated failures of `xdg-desktop-portal-kde` and `plasma` services.

## 🕵️ Diagnosis
- **Portals**: The system was trying to use the KDE Desktop Portal (`xdg-desktop-portal-kde`), which depends on a full KDE session. Since we are in Niri (independent Wayland compositor), these services crashed/timed out. This caused apps waiting for a portal (for file pickers, etc.) to hang during startup.
- **UI Gap**: The `config.kdl` had hardcoded monitor positions (`position x=... y=...`) which likely conflicted with the updated compositor or display detection, leading to incorrect workspace geometry.

## 🛠️ Fixes Applied

### 1. Fixed Portals (App Slowness & Launch Stability)
- **Action**: Ensured `xdg-desktop-portal-gnome` is installed (via `dcli`/`pacman`).
- **Configuration**: Created `~/.config/xdg-desktop-portal/portals.conf` to FORCE the use of the GNOME portal and disable the KDE fallback.
  ```ini
  [preferred]
  default=gnome;gtk;
  org.freedesktop.impl.portal.ScreenCast=gnome;
  org.freedesktop.impl.portal.Screenshot=gnome;
  ```
- **Result**: Apps launch instantly; systemd logs are clean of KDE crashes.

### 2. Fixed UI Layout (The Gap)
- **Action**: Modified `~/.config/niri/config.kdl`.
- **Change**: Commented out hardcoded `position` lines for monitors `DP-1`, `DP-2`, `DP-3`.
  ```kdl
  output "DP-1" {
      // position x=2740 y=1455  <-- Commented out
  }
  ```
- **Result**: Niri correctly auto-detects layout; gap is gone.

## 📝 Maintenance Notes
- If monitors get scrambled, use `niri msg output ...` or re-enable positions *after* using `niri msg outputs` to get fresh coordinates.
- Ensure `xdg-desktop-portal-gnome` stays in `arch.yaml`.
