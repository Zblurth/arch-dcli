# Arch Config — Agent Protocol

**System:** Arch Linux (CachyOS kernel) | **User:** `lune` | **Host:** `arch`
**Last Updated:** 2025-12-31

---

## 1. System Identity

| Component | Value |
|-----------|-------|
| **Distro** | Arch Linux (CachyOS repos + kernel) |
| **Config Tool** | `dcli` — Declarative package/service manager |
| **Config Location** | `~/.config/arch-config/` |
| **WM** | Niri (permanent choice) |
| **Shell/Bar** | Noctalia |
| **Terminal** | WezTerm |
| **Backup** | Snapper (Btrfs snapshots) |
| **Login** | ly (TUI on tty2) |

### Hardware
- **CPU:** Ryzen 7800X3D (undervolted)
- **GPU:** AMD 9070XT (undervolted, RDNA4)
- **RAM:** 32GB
- **Storage:** 2TB NVMe (Btrfs)
- **Special:** Motherboard requires `it87` driver for sensor monitoring

---

## 2. Directory Structure

```
~/.config/arch-config/
├── config.yaml          # Points to active host (host: arch)
├── hosts/arch.yaml      # THE source of truth (modules, packages, services)
├── modules/             # Hierarchical package groups
│   ├── core/            # Bootable layer (base, network, admin, cachyos)
│   ├── hardware/        # Drivers (amdgpu)
│   ├── desktop/         # Graphical layer (niri, audio, shell)
│   ├── apps/            # User apps (internet, media, dev, utils, gaming)
│   └── study/           # Learning/experimental
├── scripts/             # Post-install hooks
├── state/               # Auto-generated (git-ignored)
├── udev-rules/          # Hardware rules
└── _janitor/            # LLM context, docs, reference material
```

**Module Hierarchy:** Core → Hardware → Desktop → Apps
Read `hosts/arch.yaml` for currently enabled modules. Do not assume.

---

## 3. Core Commands

| Task | Command |
|------|---------|
| **Preview changes** | `dcli sync --dry-run` |
| **Apply changes** | `dcli sync` |
| **Prune orphans** | `dcli sync --prune` |
| **Search packages** | `dcli search` ⚠️ **Interactive TUI — LLM cannot use this directly. Ask user to run it.** |
| **Find package location** | `dcli find <pkg>` |
| **Enable module** | `dcli module enable <name>` |
| **Check status** | `dcli status` |
| **Validate niri** | `niri validate` |
| **Create snapshot** | `sudo snapper create -d "description"` |
| **List snapshots** | `sudo snapper list` |

---

## 4. Agent Protocol

### Prime Directives
1. **NEVER use `pacman` or `paru` directly.** All packages via `dcli`.
2. **NEVER code before plan approval.** Discuss first, execute after explicit go.
3. **NEVER assume file contents.** Read with `cat`/`view_file` before editing.
4. **NEVER place packages randomly.** Follow the hierarchy, find the correct module.

### Before Any Change
- [ ] Read the target file(s)
- [ ] Read `hosts/arch.yaml` for current state
- [ ] Create a plan, share with user
- [ ] Wait for explicit approval
- [ ] Run `dcli sync --dry-run` first, show output

### After Config Changes
- [ ] Run `niri validate` after Niri edits
- [ ] Run `dcli sync --dry-run` after module/package edits
- [ ] Suggest a git commit with clear message

### Communication Style
- **Dense.** No filler phrases, no "Great question!", no unnecessary context.
- **Precise.** Cite file paths, line numbers, exact commands.
- **Honest.** Say "I don't know" rather than guess.
- **Explain why.** State reasoning for non-obvious decisions.

---

## 5. Git Workflow

The agent should guide the user through git best practices:

### When to Commit
- After each logical change (one feature/fix = one commit)
- Before risky operations (provides rollback point)
- After successful `dcli sync`

### Commit Messages
Format: `<type>: <short description>`

| Type | Use |
|------|-----|
| `feat` | New module, package, or feature |
| `fix` | Bug fix, broken config repair |
| `refactor` | Reorganization, no behavior change |
| `docs` | Documentation updates |
| `chore` | Maintenance, cleanup |

Examples:
- `feat: add gaming module with Steam + Gamescope`
- `fix: correct niri workspace keybinds`
- `refactor: move fonts to desktop layer`

### When to Branch
- **Experimental changes:** `git checkout -b experiment/<name>`
- **Major refactors:** `git checkout -b refactor/<name>`
- **Merge back:** `git checkout main && git merge <branch> && git branch -d <branch>`

### Branch Discipline
**Stay in scope.** If working on a feature branch, only touch files related to that feature.

- User asks to refactor Magician → Only touch Magician files
- User asks to "also fix zsh while we're at it" → **Say no.**
- Offer: "That's out of scope for this branch. Want me to add it to `_janitor/later.md`?"

The `later.md` file collects deferred tasks. Review it when starting new work.

### Daily Flow
```bash
git status                    # Check state
git add -A && git commit -m "..."  # Commit changes
dcli repo push                # Push to remote (if configured)
```

---

## 6. Troubleshooting Playbook

| Symptom | First Check |
|---------|-------------|
| Package not found | `dcli find <pkg>` — is it declared? |
| Service not starting | `systemctl status <service>` + `journalctl -u <service>` |
| Niri won't start | `niri validate` — check for syntax errors |
| GUI broken | Switch to TTY (`Ctrl+Alt+F2`), check `journalctl -xe` |
| System borked | Boot from Snapper snapshot (GRUB menu) |
| Pacman locked | `sudo rm /var/lib/pacman/db.lck` |

### Rollback Options
1. **Config:** `git checkout -- <file>` or `git reset --hard HEAD~1`
2. **System:** `sudo snapper rollback <snapshot-id>`
3. **Boot:** Select snapshot from GRUB menu

---

## 7. File Reference

| File | Purpose |
|------|---------|
| `_janitor/GEMINI.md` | **This file.** Agent protocol. |
| `_janitor/ARCH_RUNBOOK.md` | System architecture, philosophy, setup history |
| `_janitor/MAINTENANCE.md` | Daily commands cheatsheet |
| `_janitor/dcli/` | dcli source code and documentation |
| `_janitor/Lis-os/` | NixOS reference (legacy, for Magician context) |
| `_janitor/Lis-os/janitor/THEME_ENGINE.md` | Color science pipeline (future use) |

---

## 8. Philosophy

This system is **declarative Arch**. The goal is NixOS-like reproducibility without NixOS complexity:

- **Single source of truth:** `hosts/arch.yaml` defines the system
- **Atomic rollbacks:** Snapper snapshots before every sync
- **Hierarchical modules:** Clear separation of concerns
- **Version controlled:** Everything in git

The user values:
- **Efficiency over ceremony**
- **Understanding over magic**
- **Explicit over implicit**
- **Brutalist UI, dense information**

---

*Read `_janitor/ARCH_RUNBOOK.md` for system history and detailed architecture.*
