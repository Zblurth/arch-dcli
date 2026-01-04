# Session Summary - 2026-01-03 - MH Wilds GPU Stability & REFramework Fix

## Objectives
- Resolve recurring crashes in *Monster Hunter Wilds*.
- Fix REFramework black screen and unclickable menu issues.

## Findings
- **GPU Instability**: System logs (`journalctl`) confirmed `amdgpu: MES(1) failed to respond` errors, indicating the previous -70mV undervolt was too aggressive for the current kernel/game state.
- **REFramework Conflict**: Using `gamescope` in the launch command while REFramework was active caused a black screen.
- **Mouse Capture**: The game was capturing the hardware cursor, preventing interaction with the REFramework overlay.

## Changes Made
### 🛠️ Hardware & Stability
- **GPU Undervolt**: User relaxed the GPU undervolt in `corectrl` (moved from -70mV to a less aggressive value).
- **Verification**: Confirmed `amdgpu` errors ceased after adjusting the voltage offset.

### 🎮 Game & Mod Configuration
- **Launch Options**: Simplified launch command to `WINEDLLOVERRIDES="dinput8.dll=n,b" %command%`, removing `gamescope` to fix the black screen.
- **REFramework**: Reactivated REFramework by ensuring `dinput8.dll` was correctly named in the game directory.
- **Menu Interaction**: Modified `/home/lune/.local/share/Steam/steamapps/common/MonsterHunterWilds/re2_fw_config.txt` to set `REFrameworkConfig_DrawCursorWithMenuOpen=true`. This forces the mod to draw its own cursor, allowing interaction even when the game captures the system mouse.

## ✅ Verification
- User confirmed the game boots successfully without a black screen.
- User confirmed the REFramework menu is now fully interactive.

## Open Tasks
- [ ] Monitor for any "Access Violation" crashes; if they return, check if REFramework needs an update or if the undervolt needs further relaxation.
