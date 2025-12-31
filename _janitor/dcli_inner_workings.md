# DCLI Technical Architecture & Dotfile Specification

This document details the inner workings of the `dcli` declarative management tool and its "hidden" dotfile orchestration engine.

## 1. The Declarative Core
`dcli` operates on a hierarchical declarative model. Unlike standard package managers, it separates the *desired state* from the *current state* using a multi-layered configuration:

*   **Host Pointer (`config.yaml`):** A top-level pointer that defines the active environment (e.g., `host: arch`).
*   **Host Configuration (`hosts/*.yaml`):** The primary source of truth for a specific machine. It defines enabled modules, host-specific packages, and service states.
*   **Modules (`modules/`):** Reusable units of configuration. 
    *   **Legacy Modules:** Single `.yaml` files containing a simple package list.
    *   **Directory Modules:** Folders containing a `module.yaml` manifest, multiple package files, `scripts/` (hooks), and `dotfiles/`.

## 2. The Sync Pipeline (Execution Flow)
When `dcli sync` is executed, the following sequence occurs within `src/commands/sync.rs`:

1.  **Pre-flight Validation:** Scans all enabled modules and host files for YAML syntax errors, circular dependencies, or invalid package names.
2.  **State Loading:** Reads `state/installed.yaml` to identify which packages were previously managed by `dcli`.
3.  **Backup Layer:** If enabled, triggers a system snapshot (Timeshift/Snapper) or a configuration backup (`state/config-backups/`).
4.  **Pre-install Hooks:** Executes scripts defined in modules before package installation.
5.  **Package Orchestration:**
    *   Calculates the "Diff" between declared packages and installed packages.
    *   Invokes the AUR helper (defaulting to `paru` or `yay`) for Pacman/AUR packages.
    *   Handles Flatpaks separately via `flatpak install`.
6.  **Dotfile Synchronization:** (See Section 3).
7.  **Service Synchronization:** Reconciles systemd unit states (`enabled`/`disabled`/`started`/`stopped`).
8.  **Post-install Hooks:** Executes final configuration scripts, tracked by SHA256 hashes to prevent redundant runs.
9.  **State Finalization:** Updates `state/installed.yaml` with the new set of managed packages.

## 3. Deep Dive: Dotfile Management Engine
While documentation suggests this feature is experimental, `src/dotfiles.rs` contains a fully functional symlink engine.

**Mechanism:**
*   **Source:** Any directory named `dotfiles/` found inside a **Directory Module**.
*   **Target:** The user's `$HOME/.config/` directory.
*   **Logic:**
    1.  `dcli` iterates through every subdirectory within `module/dotfiles/`.
    2.  For a subdirectory named `niri/`, it targets `~/.config/niri/`.
    3.  **Conflict Resolution:**
        *   If `~/.config/niri/` exists as a real directory, `dcli` creates a timestamped backup (e.g., `niri.backup.20251231_120000`) and records it in `state/dotfiles-state.yaml`.
        *   If it exists as a symlink pointing elsewhere, it is removed.
    4.  **Symlinking:** A recursive symlink is created: `~/.config/niri -> arch-config/modules/.../dotfiles/niri`.

**Pruning Logic:**
If a module is removed from the `enabled_modules` list in the host file, the next `dcli sync --prune` will:
1.  Identify the symlinks owned by that module via `state/dotfiles-state.yaml`.
2.  Remove the symlinks from `~/.config/`.
3.  The system effectively "forgets" the configuration without manual cleanup.

## 4. Service Orchestration & Filtering
`dcli` manages services declaratively through `src/services.rs`. A critical "safety" feature exists in the `merge` command:

*   **Filtered Services:** To prevent bricking the system, `dcli` maintains a hardcoded list of ~50 "system-critical" services (e.g., `dbus`, `systemd-journald`, `getty@`, `display-manager`).
*   **State Reconciler:** During sync, `dcli` checks both the `enabled` state (boot time) and the `active` state (runtime). If a service is declared `enabled` but is `stopped`, `dcli` will start it immediately.

## 5. Tracking and Drift Detection
The "inner soul" of `dcli` is the `state/` directory:
*   **`installed.yaml`:** This is the "Lockfile." It tracks every package `dcli` believes it owns.
*   **`services-state.yaml`:** Tracks the last known good state of system services.
*   **`dotfiles-state.yaml`:** Maps symlinks to their parent modules and tracks backups.

This state-heavy approach allows `dcli` to offer a "Kill List" (drift detection). By comparing `pacman -Qeq` (manually installed packages) against `installed.yaml`, it identifies exactly what has been installed "outside" the declarative system.
