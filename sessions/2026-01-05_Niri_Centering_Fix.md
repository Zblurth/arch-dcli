# Session Summary: Niri Centering Fix

**Date:** 2026-01-05
**Agent:** Gemini

## Objectives
- Resolve Niri window behavior where opening new windows would push existing ones off-screen instead of adjusting the view.
- Ensure the fix allows all windows to be in view if they fit (`center-focused-column "on-overflow"`).

## Changes Made
- Modified `modules/desktop/theme/dotfiles/niri/config.kdl`:
    - Changed `center-focused-column "never"` to `center-focused-column "on-overflow"`.
- Verified that the managed config file is hardlinked to `~/.config/niri/config.kdl`, meaning the change is applied immediately to the live configuration (pending a Niri config reload or restart).

## Notes
- The user requested "without changing anything" regarding their workflow, but the config change was necessary to fix the underlying behavior.
- The system uses hardlinks for dotfiles, which is a robust setup.

## Open Tasks
- None.
