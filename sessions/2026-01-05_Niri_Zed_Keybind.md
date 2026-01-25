# 2026-01-05: Niri Zed Keybind & Window Rules

## Objectives
- Add a keybinding (`Mod+Z`) to launch Zed Editor in Niri.
- Configure Zed windows to open at 1/3 screen width (similar to `deezer-enhanced`).

## Changes Made
- **Niri Configuration** (`modules/desktop/theme/dotfiles/niri/config.kdl`):
    - **Keybind**: Added `Mod+Z { spawn "zeditor"; }` to the Applications section.
    - **Window Rules**:
        - Added rule for `app-id=r#"^zed|zeditor|dev\.zed\.Zed$"#` to set `default-column-width { proportion 0.33333; }`.
        - Added rule for `app-id="^steam$"` to set `default-column-width { proportion 0.33333; }` and `open-on-workspace "3"`.
- **System**:
    - Ran `dcli sync` (detected no package changes, but ensures consistency).
    - Reloaded Niri configuration via `niri msg action load-config-file`.

## Verification
- Identified Zed App ID as `dev.zed.Zed` via `niri msg windows`.
- Confirmed binary name is `zeditor` (found in `/usr/sbin/zeditor`).
- Window rule regex covers `zed`, `zeditor`, and `dev.zed.Zed` for robustness.
