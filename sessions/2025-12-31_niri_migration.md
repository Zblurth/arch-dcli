# Session Summary: Niri & Noctalia Migration
**Date:** 2025-12-31

## 🎯 Objectives
1.  **Context**: Analyze previous Lis-OS config vs current DCLI setup.
2.  **Migration**: Port key Niri configurations (gaps, rules, keybinds).
3.  **Fixes**: Resolve "dead pixel" padding issues and broken clipboard history.

## 🛠️ Changes Implemented

### 1. Niri Configuration (`modules/desktop/config.kdl`)
*   **Gaps**: Reduced from `16` to `8`.
*   **Padding**: Disabled "Overview" hotcorner to prevent accidental triggering.
*   **Window Rules**:
    *   Added `yazi-floating` rule (opacity 0.95, floating).
    *   Ensured consistent opacity for terminal/discord apps.
*   **Keybinds**:
    *   Restored `Mod+Shift+Y` for floating Yazi.
    *   Verified `Mod+Space` for Noctalia launcher.

### 2. Noctalia Padding Fix (`~/.config/noctalia/settings.json`)
*   **Problem**: Significant gap above the top bar ("dead pixels").
*   **Fix**: Set `"marginVertical": 0` (was 0.25). This flushes the bar to the top, equalizing the 8px gap from Niri.

### 3. Clipboard History Fix
*   **Root Cause**: Feature disabled in config AND missing dependencies.
*   **Actions**:
    *   Enabled `"enableClipboardHistory": true` in `settings.json`.
    *   Added `cliphist` and `wl-clipboard` to `modules/desktop/niri.yaml`.
    *   Ran `dcli sync` to install packages.
    *   *Note*: Niri startup command `wl-paste --watch cliphist store` was already present.

## 📂 File Organization
*   Created `sessions/` directory for tracking these summaries.
*   *Action Item*: Reviewing `_janitor/GEMINI.md` for potential relocation.

## 🔮 Future Recommendations
1.  **Keybind Assist**: The IPC command for the cheat sheet menu is still missing. Needs deep dive into Astal source when ready.
2.  **Magician Engine**: The wallpaper/theming engine from Lis-OS is still absent. Bringing this back would require porting the Python scripts and `swww` integration.
3.  **Yazi Icon**: Ensure the `yazi.desktop` file uses a valid icon name if it appears as a placeholder in the dock.
