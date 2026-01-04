# Session Summary: Niri Layout & App Setup (2026-01-02)

## Objectives
- Configure Vivaldi to spawn full screen on Workspace 2.
- Configure Deezer Enhanced and Vesktop to spawn on Workspace 1 with 1/3 and 2/3 width respectively.
- Ensure Deezer and Vesktop auto-start on Niri login.
- Fix Deezer startup issues (binary name and Wayland flags).

## Changes Made
### 🖥️ Niri Configuration (`modules/desktop/theme/dotfiles/niri/config.kdl`)
- **Workspaces**: Swapped definitions for `social` (1) and `browser` (2).
- **Window Rules**:
    - Added `open-fullscreen true` for Vivaldi on `browser`.
    - Set `deezer-enhanced` to `0.33333` width and `vesktop` to `0.66667` width on `social`.
- **Startup**:
    - Added `deezer-enhanced.js` with Wayland flags (`--ozone-platform=wayland`, etc.).
    - Added `vesktop` with Wayland flags.
    - Ordered startup: Deezer -> Vesktop -> Vivaldi.
- **Keybinds**: Updated `Mod+1/2` and `Mod+Shift+1/2` to target the correct workspace names.

### 📦 Package Management
- Verified `deezer-enhanced` is installed (it is the "enhanced" version as requested).
- Ran `dcli sync` to apply dotfile symlinks and install missing Thunar plugins.

## Verification
- `niri validate` passed.
- Manually spawned apps via `niri msg action spawn` to verify rules and connectivity.

## Open Tasks
- [ ] User to verify if the 1/3 and 2/3 split feels correct on their ultrawide monitor.
- [ ] Monitor Deezer for any stability issues with the new flags.
