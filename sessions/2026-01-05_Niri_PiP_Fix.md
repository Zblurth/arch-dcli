# Session Summary: Niri Vivaldi PiP Fix

**Date:** 2026-01-05
**Agent:** Gemini

## Objectives
- Fix Vivaldi Picture-in-Picture (PiP) windows tiling instead of floating.

## Investigation
- Ran `niri msg windows` to identify the PiP window properties.
- **Findings:**
    - Window ID 39
    - Title: "Picture in picture"
    - App ID: "" (Empty string)
    - Is floating: no

## Changes Made
- Modified `modules/desktop/theme/dotfiles/niri/config.kdl`:
    - Added a new `window-rule` matching `title="^Picture in picture$"`.
    - Set `open-floating true` and a default width of 30%.
    - Note: This rule matches by title alone because the App ID is empty for these windows in Vivaldi.

## Notes
- Monitor identified as: "Beihai Century Joint Innovation Technology Co.,Ltd PGM340 Unknown" (Likely a rebranded panel, user mentioned it's a "cheap VA").
- User confirmed they do not use VRR due to flickering.

## Open Tasks
- None.
