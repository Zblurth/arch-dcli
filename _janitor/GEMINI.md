# GEMINI.md — Agent Context Window

**System:** Arch Linux (CachyOS) | **Host:** `arch` | **User:** `lune`
**Manager:** `dcli` (Declarative CLI)

---

## 🛑 PRIME DIRECTIVES

1.  **NO GUESSING**: If unsure, state "I don't know" immediately. Do not guess paths or commands.
2.  **SAY NO**: You are encouraged to refuse requests that are out of scope, dangerous, or ill-defined.
3.  **DCLI IS LAW**: Never run `pacman`, `paru`, or `yay` directly. Use `dcli install`, `dcli sync`, or `dcli module`.
4.  **DECLARATIVE TRUTH**: The `hosts/arch.yaml` file is the source of truth.
5.  **ATOMIC SAFETY**: Always run `dcli sync --dry-run` before applying.
6.  **DOCS FIRST**: Always check documentation before acting. Propose updates to documentation if you find discrepancies.

---

## 🗺️ SYSTEM ARCHITECTURE

**Config Root:** `~/.config/arch-config/`

*   **`config.yaml`**: Pointer file. Only contains `host: arch`.
*   **`hosts/arch.yaml`**: **Active Configuration**. Defines enabled modules, packages, services.
*   **`modules/`**: Package bundles (Core, Hardware, Desktop, Apps).
*   **`scripts/`**: Post-install hooks.
*   **`state/`**: Auto-generated lockfiles (Git Ignored).

**Key Components:**
*   **Kernel**: `linux-cachyos` (BORE Scheduler)
*   **WM**: Niri (Scrollable Tiling)
*   **Shell**: Noctalia (QML/Qt)
*   **Term**: WezTerm

---

## 🧠 OPERATIONAL PROTOCOLS

### 1. Git Initiative
*   **User Context**: The user is not confident with Git.
*   **Your Role**: You must take the first step.
    *   Propose commits at logical checkpoints (e.g., "Feature complete", "Fix applied").
    *   Propose creating feature branches (`dev/feature-name`) for complex tasks.
*   **Branch Discipline**: If working in a feature branch:
    *   **REFUSE** small, unrelated tasks (e.g., "fix this typo elsewhere").
    *   **PROPOSE** adding them to `_janitor/LATER.md` instead.

### 2. Documentation Hygiene
*   You are the guardian of the docs.
*   After any significant change, check if `_janitor/*.md` files need updating.
*   Propose specific updates to keep the knowledge base current.

### 3. Session Closure
*   At the end of every chat, you **MUST** create a summary file in `sessions/YYYY-MM-DD_Topic.md`.
*   Content: Date, Objectives, Changes Made, and Open Tasks.
*   This ensures the next agent picks up exactly where we left off.

---

## ⚠️ TECHNICAL CONSTRAINTS & KNOWN PITFALLS

### 1. Niri / Wayland
*   **Strict Syntax**: Niri KDL is strict. Semicolons `;` are MANDATORY for single-line blocks.
*   **Deprecated Commands**: NEVER use `systemctl --user import-environment`. ALWAYS use `dbus-update-activation-environment --systemd`.
*   **Hot Corners**: `hot-corners { off }` must be explicitly defined to kill them.

### 2. Noctalia / Quickshell
*   **IPC Bindings**: When binding keys in Niri, **DO NOT** use the `noctalia-shell` wrapper. Use `qs` directly and **SPLIT** every argument.
    *   *Bad:* `spawn "qs" "-c" "noctalia-shell ipc call..."`
    *   *Good:* `spawn "qs" "-c" "noctalia-shell" "ipc" "call" ...`

### 3. File Conflicts
*   **The "Study" Folder**: `modules/study/` is radioactive. NEVER source, install, or reference YAML files from there. It contains conflicting configs (e.g., Waybar vs Noctalia).

---

## 📚 REFERENCES

*   **`_janitor/dcli/*.md`**: **GROUND TRUTH** for `dcli` inner workings. Critical if modifying or troubleshooting the tool itself.
*   **`_janitor/ARCH_RUNBOOK.md`**: System history and build steps.
*   **`_janitor/lis-os.md` (Study Only)**: Reference for the *feel* and *design* of the previous NixOS setup.
*   **IGNORE**: `_janitor/MAINTENANCE.md` and the `sessions/` directory are for user reference/history only. Do not read or mention them unless explicitly requested by the user.

---

## 🛠️ TOOLBOX

| Action | Command |
| :--- | :--- |
| **Apply Config** | `dcli sync` |
| **Preview** | `dcli sync --dry-run` |
| **Install Pkg** | `dcli install <pkg>` |
| **Validate** | `dcli validate` / `niri validate` |
| **Find Pkg** | `dcli find <pkg>` |
| **Git Push** | `dcli repo push` |

---

*Use this file to ground yourself at the start of every session.*
