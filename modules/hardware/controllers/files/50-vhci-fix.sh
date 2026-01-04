#!/bin/bash
# Location: /usr/lib/systemd/system-sleep/50-vhci-fix.sh
# Purpose: Unload vhci_hcd to prevent suspend failures on Linux systems
# utilizing virtual USB devices (InputPlumber).

MODULE="vhci_hcd"
SERVICE="inputplumber.service"

case "$1" in
    pre)
        # Phase: PRE-SUSPEND
        echo "System suspending. Stopping dependent services and unloading $MODULE..." | systemd-cat -t vhci-fix
        
        # 1. Stop the user-space consumer of the module
        if systemctl is-active --quiet "$SERVICE"; then
            systemctl stop "$SERVICE"
            echo "Stopped $SERVICE." | systemd-cat -t vhci-fix
        fi
        
        # 2. Wait briefly for file descriptors to release
        sleep 0.5
        
        # 3. Unload the module
        if modprobe -r "$MODULE"; then
            echo "Module $MODULE unloaded successfully." | systemd-cat -t vhci-fix
        else
            echo "ERROR: Failed to unload $MODULE. Forcing removal." | systemd-cat -t vhci-fix
            rmmod -f "$MODULE"
        fi
        ;;
    post)
        # Phase: POST-RESUME
        echo "System resuming. Reloading $MODULE..." | systemd-cat -t vhci-fix
        
        # 1. Reload the module
        modprobe "$MODULE"
        
        # 2. Allow kernel to initialize the bus
        sleep 1
        
        # 3. Restart the service
        systemctl start "$SERVICE"
        echo "Restarted $SERVICE." | systemd-cat -t vhci-fix
        ;;
esac