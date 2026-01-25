# Session Summary: Niri PiP Tuning & Hardware ID

**Date:** 2026-01-05
**Agent:** Gemini

## Objectives
- Refine Vivaldi Picture-in-Picture window sizing (Make it smaller).
- Identify the specific monitor model from the "Beihai Century" EDID string.

## Changes Made
- **Niri Config (`modules/desktop/theme/dotfiles/niri/config.kdl`):**
    - Reduced Vivaldi PiP `default-column-width` from `0.3` (30%) to `0.2` (20%).
    - Note: Niri does not enforce aspect ratio via window rules, but the video player should handle 16:9 automatically at this new width (~688px wide).
- **Host Config (`hosts/arch.yaml`):**
    - Added a comment documenting the monitor model: `Fox Spirit PGM340 (34" VA 100Hz UWQHD)`.

## Hardware Identification
- **EDID Name:** "Beihai Century Joint Innovation Technology Co.,Ltd PGM340"
- **Real Model:** **Fox Spirit PGM340** (Manufactured by Innocn/Beihai).
- **Specs:** 34" VA Panel, 3440x1440, 100Hz, 1500R Curve.
- **VRR Status:** Monitor supports FreeSync, but user reports flickering (common with cheap VA panels), so it remains disabled in Niri.

## Open Tasks
- None.
