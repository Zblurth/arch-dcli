# System Maintenance Cheat Sheet

Useful commands for managing this declarative Arch setup.

## 📦 DCLI (Declarative Package Manager)
The core tool for this system.
```bash
dcli sync           # Apply state from hosts/arch.yaml (installs/removes packages)
dcli find <query>   # Search for a package in repos
dcli repo push      # Push changes to the remote git repository
dcli clean          # Remove orphans and clean cache
dcli update         # Update system (pacman -Syu wrapper)
```

## 📸 Snapper (Snapshots & Rollbacks)
Btrfs snapshots for atomic recovery.
```bash
sudo snapper list             # List all snapshots
sudo snapper create -c number # Create a manual snapshot
sudo snapper rollback <id>    # Rollback to a specific snapshot ID
sudo snapper delete <id>      # Delete a snapshot
```

## 📋 Clipboard (Cliphist)
Manage clipboard history.
```bash
cliphist list | fzf           # Search clipboard history
cliphist list | head -n 10    # Show recent items
cliphist wipe                 # Clear entire clipboard history !
```

## 🖥️ Niri (Window Manager)
```bash
niri msg action quit          # Exit Niri (logout)
niri validate                 # Check config for syntax errors
```

## 🧹 Pacman / System
```bash
sudo pacman -Syu              # Standard system update
sudo pacman -Rns $(pacman -Qtdq) # Remove orphans (recursive)
sudo reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist # Update mirrors
journalctl -p 3 -xb           # Show current boot errors
systemctl list-units --failed # Show failed services
```

## � Cache & Log Cleaning
```bash
rm -rf ~/.cache/thumbnails/*       # Clear thumbnail cache
paccache -r                        # Keep only recent package versions (default 3)
sudo paccache -rk2                 # Keep only 2 recent versions (more aggressive)
sudo paccache -ruk0                # Remove cache of uninstalled packages
sudo journalctl --vacuum-time=2weeks # Limit logs to 2 weeks
sudo journalctl --vacuum-size=500M   # Limit logs to 500MB
```

## 🛠️ Troubleshooting & Fixes
```bash
# Update font cache (after installing new fonts)
fc-cache -fv

# Refresh keyring (if signature errors)
sudo pacman-key --init && sudo pacman-key --populate archlinux

# Verify broken packages
sudo pacman -Qkk

# Find broken symlinks in current dir
find . -type l ! -exec test -e {} \; -print
```

## 🔊 Audio (PipeWire/WirePlumber)
```bash
wpctl status                  # Check audio graph and devices
pactl info                    # Server information
pactl set-sink-volume @DEFAULT_SINK@ +5%  # Emergency volume up
systemctl --user restart wireplumber pipewire pipewire-pulse # Restart audio stack
```

## 🌐 Network & Bluetooth
```bash
# NetworkManager
nmcli device wifi list        # Scan for wifi
nmcli connection show         # List connections
nmtui                         # TUI for network management

# Bluetooth
bluetoothctl scan on          # Start scanning
bluetoothctl devices          # List found devices
bluetoothctl connect <MAC>    # Connect to device
```

## 📊 System Monitoring
```bash
btop                          # Resource monitor (if installed)
watch -n 1 "cat /proc/cpuinfo | grep 'MHz'" # CPU frequency
free -h                       # Memory usage
df -h                         # Disk usage
```
