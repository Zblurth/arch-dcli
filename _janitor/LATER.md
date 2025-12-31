# Later — Deferred Tasks
## Priority: Dotfile Management System
### Goal
Bring app dotfiles into arch-config with symlink management via dcli, designed for future Magician integration.
### Architecture
modules/desktop/dotfiles/
├── colors.yaml     # Central color definitions
├── niri/
├── wezterm/
├── noctalia/
└── ...
### Central Color System
colors.yaml — Single source of truth for all colors:
# Static palette (Catppuccin Mocha to start)
# Magician will overwrite this when ready
background: "#1e1e2e"
foreground: "#cdd6f4"
cursor: "#f5e0dc"
primary: "#89b4fa"
secondary: "#74c7ec"
accent: "#f5c2e7"
warning: "#f9e2af"
error: "#f38ba8"
success: "#a6e3a1"
color0: "#45475a"
color1: "#f38ba8"
color2: "#a6e3a1"
color3: "#f9e2af"
color4: "#89b4fa"
color5: "#f5c2e7"
color6: "#94e2d5"
color7: "#bac2de"
### Dotfile Strategy
1. Write fresh for Arch (don't copy NixOS)
2. Each app template reads from colors.yaml
3. dcli syncs via symlink engine
4. Preprocessor: simple shell/yq now, Magician later
### Migration Order
- [ ] Create colors.yaml with Catppuccin
- [ ] WezTerm
- [ ] Niri (color injection)
- [ ] Noctalia
- [ ] Zsh/Starship
### Open Questions
- Does dcli dotfile engine handle templating or just symlinks?
- Format: YAML vs TOML vs JSON?
- Preprocessing: at sync time or Magician time?
## Magician: Arch Refactor & Icon System V2
### Goal
Transform Magician from a NixOS-dependent script into a standalone, platform-agnostic theme engine that integrates with the new `dcli` dotfile system.

### Tasks
- [ ] **Standalone Migration**: Move core logic out of the legacy `Lis-os` folder. Decouple from Nix paths and use XDG base directories.
- [ ] **Centralized Output**: Update Magician to write its generated palette directly to `arch-config/modules/desktop/dotfiles/colors.yaml` (the "Single Source of Truth" file).
- [ ] **Port to Arch**: Finalize the `dcli` module for dependencies (`python-pillow`, `python-opencv`, `coloraide`, etc.).
- [ ] **Icon Themer V2**:
    - [ ] **Research Tela Coloring**: Investigate how Tela Circle handles its color variants (check their SVG path `fill` manipulation logic).
    - [ ] **Automation**: Build a Magician sub-module that can dynamically patch an icon set's SVG colors to match the current wallpaper's "Anchor" color.
- [ ] **Shareability**: Structure the project with a clean CLI/TUI entry point and a `requirements.txt` so other Arch users can easily adopt it.

### Reference Files
- `_janitor/THEME_ENGINE.md`: Core Oklch pipeline and science.
- `_janitor/MAGICIAN_TUI.md`: Brutalist UI/TUI specifications.

---
## Backlog
- [ ] Magician refactor for Arch
- [ ] Magician TUI
- [ ] ARCH_RUNBOOK.md — condense
- [ ] MAINTENANCE.md — new for Arch
- [ ] Test Snapper rollback
- [ ] Review/condense audit docs