# Session Summary - 2026-01-01 - MH Wilds Crash & GPU Stability

## Objectives
- Diagnose crashes in *Monster Hunter Wilds* on CachyOS.
- Verify GPU undervolt stability and CoreCtrl persistence.
- Fix system-level issues related to Ryzen 7000 (UMIP) and Polkit.

## Changes Made
### 🛠️ Hardware & Kernel
- **GRUB**: Added `clearcpuid=514` to `GRUB_CMDLINE_LINUX_DEFAULT`. This disables UMIP, a known cause of crashes for Capcom's RE Engine games on Ryzen 7000 series CPUs.
- **Polkit**: Created `/etc/polkit-1/rules.d/90-corectrl.rules` to allow `corectrl` to apply GPU profiles without a password prompt.
- **Module Refactor**: Restructured `modules/hardware/amdgpu` into a directory-based module with a `setup.sh` hook for automated rule installation and GRUB updates.

### 🖥️ Desktop (Niri)
- **Startup**: Added `spawn-at-startup "bash" "-c" "sleep 2 && corectrl --minimize"` to `modules/desktop/theme/dotfiles/niri/config.kdl`.

### 📦 Package Management
- Moved `corectrl` and `coolercontrol` from `apps/utils` to `hardware/amdgpu`.

## Findings
- **Log Analysis**: `re2_framework_log.txt` confirmed an Access Violation (`c0000005`) at `18:06:56`. This points to either a software conflict with REFramework or memory instability.
- **UMIP Warnings**: Journal logs showed `umip: MonsterHunterWi... SGDT instruction cannot be used`, confirming the need for the `clearcpuid` fix.
- **GPU State**: Confirmed `corectrl` was applying a `-70mV` undervolt.

## Open Tasks
- [ ] **User**: Reboot to apply `clearcpuid=514`.
- [ ] **User**: Rename `dinput8.dll` to test without REFramework.
- [ ] **User**: Monitor stability; if crashes continue, reduce undervolt to `-50mV`.
