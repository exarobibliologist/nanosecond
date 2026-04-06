#!/bin/bash

function forcefsck() {
    # 1. Identify the Root Disk Type
    # We look for '0' (HDD) or '1' (SSD) in the queue rotational attribute
    local root_drive=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
    local drive_name=$(basename "$root_drive")
    local is_ssd=$(cat /sys/block/$drive_name/queue/rotational 2>/dev/null)

    # 2. Visual Warning & Hardware Info
    echo -e "\033[1;33m--- HARDWARE PRE-CHECK ---\033[0m"
    if [[ "$is_ssd" == "0" ]]; then
        echo -e "Drive: \033[1;32mSSD detected.\033[0m (Scan will be very fast)"
    else
        echo -e "Drive: \033[1;34mHDD detected.\033[0m (Scan may take some time)"
    fi
    
    echo -e "\n\033[1;31mCRITICAL: SYSTEM WILL REBOOT IMMEDIATELY.\033[0m"
    read -p "Continue? (y/N): " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "Aborted."; return 1; }

    # 3. Triggering the Check
    echo "Flagging filesystem for repair..."
    
    # Legacy flag
    sudo touch /forcefsck 2>/dev/null
    
    # Modern systemd flag (creates a file that systemd-fsck looks for)
    sudo touch /run/systemd/generator/etc/fstab.d/forcefsck 2>/dev/null 
    
    # 4. Immediate Reboot
    echo "Rebooting..."
    sudo shutdown -r now
}