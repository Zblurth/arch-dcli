# Lis-OS Technical Reference Manual
**Version:** 2.0 (Final Audit)
**Source:** `arch-config/Lis-os`
**Target:** Arch Linux (Declarative Implementation)

---

## 1. Executive Summary
**Lis-OS** is a hyper-optimized, aesthetics-driven Linux environment originally built on NixOS Unstable. It is characterized by a "Brutalist" design philosophy (no focus rings, sharp shadows, efficiency first), a custom Python-based color science engine ("Magician"), and a heavily patched software stack (Zen Kernel, Mesa Git, Noctalia Shell).

This document details every configuration parameter, internal logic flow, and architectural decision required to replicate the system 1:1 on Arch Linux.

---

## 2. Kernel & Boot Subsystem

### A. Kernel Selection
*   **Package:** `linuxPackages_zen` (NixOS) / `linux-cachyos` (Arch Target).
*   **Scheduler:** **BORE** (Burst-Oriented Response Enhancer).
    *   *Function:* Modifies CFS (Completely Fair Scheduler) to prioritize interactive tasks (like Niri, Firefox) over background batch jobs.
    *   *Impact:* Reduces micro-stutter during high load.
*   **Parameters:**
    *   `usbcore.autosuspend=-1`: **CRITICAL.**
        *   *Context:* The **VXE Dragonfly R1** wireless receiver chip has aggressive sleep states that cause disconnection loops on standard kernels. This forces USB ports to stay awake.
    *   `pcie_aspm=off`:
        *   *Context:* The **MediaTek MT7925e (WiFi 7)** card has broken Active State Power Management support in Linux 6.x. Enabling ASPM causes hard system freezes.
    *   `quiet splash loglevel=3`: Standard silent boot.

### B. Bootloader
*   **Loader:** `systemd-boot` (NixOS) / `GRUB` (Arch).
*   **Plymouth:** Enabled. Provides seamless boot transitions.
*   **EFI:** `canTouchEfiVariables = true`. Allows `efibootmgr` to manage boot order from userspace.

---

## 3. Hardware Abstraction Layer (HAL)

### A. GPU & Graphics Stack
*   **Driver:** `amdgpu`.
*   **Mesa:** **Mesa Git** (via Chaotic-Nyx overlay).
    *   *Why:* Provides bleeding-edge RDNA 3/4 support and Ray Tracing fixes not yet in stable Mesa.
*   **Overdrive:**
    *   `ppfeaturemask = "0xffffffff"`.
    *   *Effect:* Unlocks all Overdrive features (Voltage, Clock, Fan control) in the kernel driver, allowing userspace tools like **CoreCtrl** to bypass safety limits.

### B. Input Devices
*   **VXE Dragonfly R1 Mouse (The "Hacker" Fix):**
    *   *Problem:* This mouse identifies as 3 devices: 2 fake Keyboards (for macros) and 1 Mouse. This confuses libinput/Wayland.
    *   *Udev Solution:*
        ```bash
        # Force unbind the 'usbhid' driver from the fake keyboard interfaces (00, 01)
        SUBSYSTEM=="usb", DRIVER=="usbhid", ATTRS{idVendor}=="373b", ATTR{bInterfaceNumber}=="00", RUN+="/bin/sh -c 'echo $kernel > /sys/bus/usb/drivers/usbhid/unbind'"
        SUBSYSTEM=="usb", DRIVER=="usbhid", ATTRS{idVendor}=="373b", ATTR{bInterfaceNumber}=="01", RUN+="/bin/sh -c 'echo $kernel > /sys/bus/usb/drivers/usbhid/unbind'"
        ```
    *   *WebHID:* Grants `uaccess` to the `hidraw` node (`0660` permissions) to allow Chromium-based browsers to flash firmware updates without root.

### C. Display & Monitors
*   **DDCCI Control:**
    *   **Modules:** `i2c-dev`, `ddcci_backlight`.
    *   **Automation:** A udev rule triggers when the AMDGPU display manager (`AMDGPU DM`) initializes I2C. It echoes `ddcci 0x37` to the new device, forcing the driver to attach.
    *   *Result:* `brightnessctl` can control external monitor brightness immediately after boot.

---

## 4. Network & Security Subsystem

### A. Networking
*   **Backend:** `NetworkManager` + `wpa_supplicant`.
*   **Firewall (`nftables`/`iptables`):**
    *   **TCP Ports Open:**
        *   `22` (SSH)
        *   `80/443` (HTTP/S - Web Server dev)
        *   `8080` (Alt Web)
        *   `59010-59011` (Spice/VNC Console for Virtual Machines)
    *   **UDP Ports Open:**
        *   `59010-59011` (Spice/VNC Audio)
*   **DNS:** Adds `pool.ntp.org` to time servers.

### B. Authorization (Polkit)
*   **CoreCtrl Escalation:**
    *   *Rule:* Checks if action is `org.corectrl.helper.init` and user is in `wheel`.
    *   *Result:* Returns `polkit.Result.YES`. Eliminates the password prompt on login when CoreCtrl applies GPU profiles.
*   **Session Management:** Allows `users` group to `reboot`, `power-off`, and `reboot-multiple-sessions` without authentication.

---

## 5. The "Magician" Theme Engine (Architecture)

**Role:** A custom ETL pipeline for color data. It replaces tools like `pywal`.
**Languages:** Python (Core), Bash (Wrappers), C++ (ImageMagick).

### Phase 1: Mood Grading (`mood.py`)
Before analysis, the wallpaper is processed to enforce an aesthetic "Mood". This ensures the theme matches the *desired* vibe, not necessarily the *actual* image.
*   **Implementation:** Vectorized Numpy operations (no slow for-loops).
*   **Presets:**
    *   **Deep:** Shadows tint `(0.0, 0.02, 0.05)` (Cyan), Highlights `(0.0, 0.0, 0.0)`, Contrast `1.1`, Brightness `-0.1`.
    *   **Pastel:** Shadows tint `(0.05, 0.02, 0.02)` (Warm), Saturation `0.7`, Contrast `0.85`.
    *   **Vibrant:** Saturation `1.4`, Contrast `1.2`.
    *   **Nord:** Shadows tint `(0.15, 0.18, 0.22)` (Polar Night), Saturation `0.85`.
*   **Technique:** "Split Toning" using a luminance pivot at `0.5`. Shadows get one color matrix, highlights another.

### Phase 2: Perceptual Extraction (`extraction.py`)
*   **Saliency Detection:**
    *   Algorithm: **Spectral Residual** (Hou & Zhang).
    *   Process: `FFT` -> `Log Spectrum` -> `Residual` -> `Inverse FFT`.
    *   Result: A heatmap of "where the eye looks".
*   **Clustering:**
    *   Algorithm: **Weighted K-Means** (k=8).
    *   Space: **Oklab** (Linear perceptual space).
    *   Filtering: Ignores pixels with L < 0.05 (Black) or L > 0.97 (White) unless the image is monochromatic.

### Phase 3: Harmonic Generation (`generator.py`)
*   **Harmonic Templates (Matsuda):**
    *   `i` (Identity), `V` (93.6°), `L`, `I` (Complementary), `T` (Triad), `Y` (Split Comp), `X`.
*   **Fitting:** The engine rotates these templates by 5° increments over the extracted hue wheel to find the "least cost" fit.
*   **Anchor:** The primary cluster center.
*   **Generated Colors:** Secondary/Tertiary colors are derived from the *ideal* template positions, not just the image, ensuring mathematical harmony.

### Phase 4: Constraint Solver (`solver.py`)
*   **Goal:** Accessibility (WCAG 2.1 AA/AAA).
*   **Method:** Binary Search on Lightness (L) in **Oklch**.
*   **Targets:**
    *   `bg`: Base lightness (e.g., 0.05 for Deep).
    *   `fg` (Text): Enforce **7:1** or **4.5:1** contrast against `bg`.
    *   `ui` (Buttons): Enforce **3:1** contrast.
*   **Gamut Mapping:** Uses `lch-chroma` reduction (Coloraide) to bring impossible colors (e.g., extremely bright saturated blue) back into sRGB without shifting Hue.

### Phase 5: Icon Tinting (`icons.py`)
*   **Alias System:** `resolve_icons.py` maps generic app IDs to specific icon names (e.g., `code` -> `visual-studio-code`) to prevent "missing icon" gaps.
*   **Pipeline:**
    1.  `magick ... -alpha extract`: Get mask.
    2.  `-morphology Erode Disk:1`: Slight thinness to preserve detail.
    3.  `-colorize 100`: Apply calculated `Primary` or `Accent` color.
    4.  `-compose DstIn`: Re-apply alpha.

### Phase 6: Orchestration (`daemon/orchestrator.py`)
*   **Mechanism:** Python `watchfiles` polling `~/.config/lis-os/config.d/` at 1Hz.
*   **Action:** Merges TOML fragments into a master JSON for **Astal** (The Bar) and generates GTK CSS.

---

## 6. Desktop Environment (Niri & Noctalia)

### A. Niri (Window Manager)
**Config:** `config.kdl` (Template generated by Magician)
*   **Visuals:**
    *   `focus-ring`: **OFF**. Focus is indicated by window opacity or shadow depth.
    *   `border`: **2px**. Colors: Active (`#cba6f7` Mauve), Inactive (`#45475a` Surface1).
    *   `shadows`: `softness 30`, `spread 5`, `offset x=0 y=5`, `color #00000007`. Very diffuse, "floating" look.
*   **Animation Physics:**
    *   `workspace-switch`: `spring damping-ratio=0.80 stiffness=523`. Very snappy/tight.
    *   `window-movement`: `spring damping-ratio=0.75 stiffness=323`. Slightly looser, more "organic".
*   **Layout:**
    *   `gaps`: 9px.
    *   `preset-column-widths`: 1/3, 1/2, 2/3, 1.0.
*   **Input:**
    *   `mouse`: Accel profile `flat`.
    *   `keyboard`: Layout `us`.

### B. Noctalia (Shell)
**Source:** Soft-fork of `noctalia-shell`.
**Modifications:**
*   **Matugen Strip:** The internal Rust-based material engine is stripped out.
*   **Injection Hook:** `AppThemeService.qml` is patched to execute:
    `bash -c "theme-engine [wallpaper_path]"`
    This hands control over to Magician whenever the wallpaper changes.
*   **Debloat:** `GitHubService` and `UpdateService` are commented out in `shell.qml` to prevent background network polling.

---

## 7. Userland & Applications

### A. Zsh & Shell
*   **Completion:** `fzf-tab` replaces the standard grid.
    *   **Preview:** Directories show `ls --color`, files show `less` (via `bat`).
    *   **Theming:** `FZF_DEFAULT_OPTS` are injected dynamically in `initContent` using Stylix/Magician colors.
*   **Aliases:**
    *   `man` -> `batman` (Bat-based manpager).
    *   `ls` -> `eza --icons`.
    *   `cat` -> `bat`.
    *   `grep` -> `rg`.

### B. WezTerm
*   **Config:** `wezterm.lua`.
*   **Integration:** Watches `~/.cache/wal/colors-wezterm.lua` for hot-reloading.
*   **UX:**
    *   `window_close_confirmation = 'NeverPrompt'`: Brutal efficiency.
    *   **Context Menu:** Right-click opens a custom Lua-defined menu (Copy, Paste, Splits, Kill Process).
    *   **Tabs:** Bottom bar, browser-style shortcuts (`Ctrl+T`, `Ctrl+W`).

### C. Antigravity (VSCode)
*   **Identity:** A wrapped VSCode/VSCodium build.
*   **Force X11:** `ELECTRON_OZONE_PLATFORM_HINT="x11"`.
    *   *Why:* Electron apps often have blurred fonts or missing decorations on Niri (Wayland) if scaling is used. This forces XWayland for crisp rendering.
*   **Theme Extension:**
    *   Instead of editing `settings.json` colors directly, it generates a valid **VSCode Extension** folder structure at `~/.antigravity/extensions/lis-theme/`.
    *   `package.json`: Defines a theme contribution "LisTheme".
    *   `themes/lis-theme.json`: Symlinked to the Magician output.

---

## 8. Maintenance & Tooling

### A. Custom Scripts
*   **`fr` (Fast Rebuild):**
    *   Checks for `.backup` collisions (Home Manager issue).
    *   Auto-stages git changes.
    *   Runs `nh os switch`.
    *   Validates Niri config.
    *   Restarts Noctalia.
*   **`clean-os`:**
    *   Runs `nh clean all --keep 3`.
    *   Runs `nix-store --optimise` (Hardlink deduplication).
*   **`mkRawDump`:**
    *   A context dumper for LLMs. Uses `git ls-files` and regex blacklists to generate a clean text dump of the codebase.

### B. Nix Helper (nh)
*   **Config:** `programs.nh`.
*   **Clean:** Auto-cleans generations older than 7 days, keeping last 5.

---

## 9. Arch Linux Reconstruction Guide

To restore **Lis-OS** functionality on Arch Linux, follow this exact sequence:

### Step 1: Base System
1.  **Repo:** Add `cachyos` repositories (Tier 1 priority).
2.  **Kernel:** Install `linux-cachyos` + `linux-cachyos-headers`.
3.  **Drivers:** `mesa-git` (from CachyOS), `amdgpu`, `vulkan-radeon-git`.
4.  **Boot:** GRUB with `grub-btrfs` enabled.

### Step 2: System Plumbing
1.  **Monitor:**
    *   Install `ddcutil`.
    *   Load kernel modules: `i2c-dev`, `ddcci`.
    *   Add Udev rule for `AMDGPU DM` -> `ddcci`.
2.  **Mouse:**
    *   Add Udev rule for `373b:10c9` (unbind usbhid).
3.  **Permissions:**
    *   Create Polkit rule for `org.corectrl.helper.init` (Wheel group).

### Step 3: The Engine (Migration)
1.  **Location:** `~/.local/bin/core/`.
2.  **Files:** Copy `mood.py`, `extraction.py`, `generator.py`, `solver.py`, `icons.py`, `magician.py`.
3.  **Dependencies:** `pip install --user pillow numpy opencv-python scikit-learn coloraide watchfiles textual`.
4.  **Daemon:** Create a systemd user service `lis-daemon.service` running `magician daemon`.

### Step 4: The Desktop
1.  **Niri:**
    *   Install `niri`.
    *   Install `xwayland-satellite` (Required for X11 apps like Antigravity).
    *   Copy `config.kdl` to `~/.config/niri/`.
2.  **Noctalia:**
    *   Clone source.
    *   Apply the patch: Find `Matugen` call in `AppThemeService.qml`, replace with `bash -c "magician set ..."`
    *   Build/Install.

### Step 5: Apps
1.  **WezTerm:** Copy `wezterm.lua`. Ensure `~/.cache/wal` exists.
2.  **Zsh:** Install `fzf-tab-git` (AUR). Source the init script in `.zshrc`.
3.  **Antigravity:** Use `code` or `vscodium`.
    *   Create the extension folder `~/.vscode/extensions/lis-theme`.
    *   Point Magician to generate the JSON there.

*Audit Complete. System state is fully mapped.*



---



## 10. Gap Analysis: Current DCLI vs. Lis-OS Reference



This section summarizes the fundamental differences between your current Arch Linux configuration (`dcli`) and the engineering depth of the original `Lis-os`.



### A. Presence vs. Behavior

*   **DCLI (Current):** Effectively manages the **presence** of software. It ensures `wezterm`, `noctalia-shell`, `yazi`, and `it87` are installed and that services like `coolercontrold` are active. It is a "Package List" model.

*   **Lis-OS (Original):** Managed the **behavior and integration** of software. It didn't just install WezTerm; it configured it to listen for color updates. It didn't just install Noctalia; it patched the source code to trigger a custom Python engine.



### B. The "Missing Brain" (The Magician Engine)

*   **The Gap:** Your current system has no **Theming Intelligence**. 

*   **Lis-OS Logic:** When you changed a wallpaper, `noctalia-shell` (patched) called `magician.py`. Magician used computer vision (`Spectral Residual Saliency`) to find the most "interesting" part of the image, calculated a mathematically harmonic palette using `Matsuda Templates`, and guaranteed text readability via `WCAG Oklch Solver`.

*   **Current State:** You have `python-pywal` installed, but the "Magician" logic (the 5+ custom Python scripts) is entirely absent from your declarative config. Your apps are currently static.



### C. Hardware Refinement (Udev & Kernel)

*   **The Gap:** Missing **Low-Level Plumbing**.

*   **Lis-OS Logic:** 

    *   **VXE Mouse:** Specifically unbound from fake keyboard drivers via Udev to prevent input lag/conflicts.

    *   **Display:** Automatically initialized `ddcci` via Udev so brightness control worked out-of-the-box.

    *   **WiFi:** Forced `aspm=off` to prevent MediaTek card crashes.

*   **Current State:** While you have the `it87` driver and `corectrl` kernel parameters, the specific Udev rules that make the hardware "smart" are missing from the `arch-config` modules.



### D. Deep Integration (The Connective Tissue)

*   **Terminal:** Lis-OS used a Lua-based hot-reload system in WezTerm. Your current WezTerm is likely using stock defaults.

*   **Shell:** Lis-OS used `fzf-tab` with dynamic palette injection. Your current Zsh is using standard completion.

*   **IDE:** Lis-OS used a custom VSCode extension generator to bypass the lack of native NixOS/Wayland theme support. Your current setup treats the IDE as a standard standalone app.



### E. Conclusion: The "System" vs. The "Collection"

*   **Lis-OS** was a **System**: Every part communicated with every other part (Wallpaper -> Engine -> Apps -> Hardware).

*   **Current DCLI** is a **Collection**: The apps are installed and the hardware is powered on, but they are currently working in isolation without the shared "brain" of the Magician engine.



*Resume complete. The architectural gap is now documented.*
