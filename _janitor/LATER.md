# Later — Deferred Tasks

## 🚧 ACTIVE: Magician V3 (Theme Engine)
**Status:** In Active Development (Architect Phase)
**Spec:** `_janitor/MAGICIAN_V3_SPEC.md`
**Source:** `modules/theme/magician/`

### Goals
1.  **Refactor:** Implement Hexagonal Architecture (Core/App/Infra/UI).
2.  **Science:** Switch to Oklch + APCA + Spatial Mean Shift.
3.  **Features:** Textual TUI + Circadian Chroma Breathing.
4.  **Integration:** Output to `modules/desktop/dotfiles/colors.yaml` for `dcli` consumption.

### Tasks
- [x] Create Architecture Spec (`MAGICIAN_V3_SPEC.md`)
- [ ] Scaffold Directory Structure
- [ ] Implement Core Models (Pydantic V2)
- [ ] Implement Extraction (Mean Shift)
- [ ] Implement Solver (APCA)
- [ ] Implement Harmony (Elastic Hue)
- [ ] Implement TUI (Textual)

---

## Priority: Dotfile Management System
### Goal
Bring app dotfiles into arch-config with symlink management via dcli, designed for future Magician integration.

### Architecture
```
modules/desktop/dotfiles/
├── colors.yaml     # Central color definitions (Target for Magician)
├── niri/
├── wezterm/
├── noctalia/
└── ...
```

### Strategy
1.  `dcli` syncs symlinks from `dotfiles/` to `~/.config/`.
2.  `magician` writes to `colors.yaml`.
3.  Apps read from `colors.yaml` (via include or reload).

### Migration Order
- [ ] WezTerm
- [ ] Niri (color injection)
- [ ] Noctalia
- [ ] Zsh/Starship

---

## Backlog (On Hold)
- [ ] **Icon Themer V2**: Researching Tela Circle SVG patching. Low priority until Magician Core is stable.
- [ ] **Snapper Rollback Test**: Validate atomic recovery.
- [ ] **Maintenance Docs**: Update for Arch context.

---

## Hardware Upgrade: OLED Font Tuning (ETA: 6 Months)
### Goal
Adjust font rendering for OLED subpixel layout (or lack thereof) to avoid fringing and preserve panel health.

**Note for LLMs:** This section is for future hardware and should **not** be used or referenced for the current system configuration until explicitly activated by the user.

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="rgba" mode="assign">
      <const>none</const>
    </edit>
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hintstyle" mode="assign">
      <const>hintslight</const>
    </edit>
  </match>
</fontconfig>
```
