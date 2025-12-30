# Arch Config & Lis-os System Context

**Last Updated:** 2025-12-30
**Primary User:** `lune`
**System Type:** Hybrid (Arch Linux with Declarative Config + Nested NixOS Flake)

## 1. Project Overview

This directory (`/home/lune/.config/arch-config`) is the central configuration hub for the user's system. It serves two distinct purposes:
1.  **Arch Linux Management:** Uses `dcli` (Declarative CLI) to manage Arch Linux packages and configuration declaratively, similar to NixOS.
2.  **Lis-os (NixOS):** Contains a nested NixOS flake (`Lis-os/`) for a separate or reference system configuration.

## 2. Arch Linux Configuration (dcli)

The root of this repository is an **Arch Linux** configuration managed by `dcli`.

### Core Workflow
*   **Edit Config:** Modify declarative YAML files in `hosts/` or `modules/`.
*   **Preview:** `dcli sync --dry-run` (Check what will happen).
*   **Apply:** `dcli sync` (Installs/removes packages, runs hooks).
*   **Prune:** `dcli sync --prune` (Removes packages not explicitly declared).

### Directory Structure
| Path | Description |
| :--- | :--- |
| `config.yaml` | **Entry Point.** Points to the active host configuration (currently `arch`). |
| `dcli/` | **Source Code.** The Rust source code for the `dcli` tool itself. |
| `hosts/` | **Machine Specs.** Per-host configurations (e.g., `arch.yaml`). Defines enabled modules. |
| `modules/` | **Package Sets.** Reusable groupings of packages (e.g., `base.yaml`, `gaming/`). |
| `scripts/` | **Hooks.** Shell scripts executed after package installation (defined in modules). |
| `state/` | **Runtime State.** Auto-generated files tracking installed packages and backups. |

### Key Commands (dcli)
*   **Sync System:** `dcli sync`
*   **Search Packages:** `dcli search` (Interactive TUI)
*   **Manage Modules:** `dcli module enable` / `dcli module disable`
*   **Update Tool:** `dcli self-update` (Rebuilds `dcli` from `dcli/` source)
*   **Backup Config:** `dcli save-config`
*   **System Snapshot:** `dcli backup` (Timeshift/Snapper)

## 3. Lis-os (NixOS Configuration)

Located in `Lis-os/`, this is a standard NixOS Flake configuration.

*   **Host:** `nixos`
*   **User:** `lune`
*   **Key Features:** Niri (WM), Noctalia (Shell), Stylix (Theming).
*   **Documentation:** See `Lis-os/janitor/GEMINI.md` for specific NixOS protocols.

## 4. Development & Maintenance

### Managing `dcli` (The Tool)
The `dcli` tool is developed locally in the `dcli/` directory.
*   **Language:** Rust.
*   **Build:** `cargo build --release` (inside `dcli/`).
*   **Install:** `./install.sh` (inside `dcli/`).

### Managing the System (The Config)
*   **Active Host:** `hosts/arch.yaml` is the source of truth for the current machine.
*   **Base Packages:** Defined in `modules/base.yaml`.
*   **New Modules:** Create a YAML file in `modules/` and enable it in the host config or via `dcli module enable`.

## 5. Agent Protocol

1.  **Identify Context:** Determine if the user is asking about the **Arch system** (root dirs) or the **NixOS system** (`Lis-os/`).
2.  **Safety First:** `dcli sync` can install/remove packages. Always check `config.yaml` and the active host file before suggesting changes.
3.  **Tool Usage:** Prefer using `dcli` commands for package management over raw `pacman`/`paru` when applicable.
4.  **Do Not Assume:** Use `read_file` to verify the contents of module files before editing, as they can be simple YAML or directories.
