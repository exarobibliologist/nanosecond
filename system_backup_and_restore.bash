#!/bin/bash

# Backup List: Creates a backup of all installed packages into a file (packages.txt by default or custom path if specified).
# Reinstall Backup: Reinstalls the packages from the packages_list.txt file. If the list contains i386 packages, it will ensure the i386 architecture is added and updated.

function system_backup_and_restore() {
    # 1. Define the file path ONCE at the top so both options share it
    local file="${1:-./packages.txt}"

    echo "Make a backup list of programs installed, or reinstall from a backup list?"
    select packagelist in "Backup List" "Reinstall Backup" "Exit"; do
        case "$packagelist" in
            "Backup List")
                # Check for apt-mark
                if ! command -v apt-mark &> /dev/null; then
                    echo -e "$(color 196)Error: apt-mark not found. Ensure you are on a Debian-based system.$(reset)"
                    return 1
                fi
                
                echo "Backing up manually installed packages to $file..."
                
                # Use apt-mark showmanual instead of dpkg-query to avoid dependency hell
                apt-mark showmanual > "$file"
                
                echo -e "$(color 46)Package backup completed and saved to $file.$(reset)"
                return 0
                ;;
                
            "Reinstall Backup")
                # Use the variable $file instead of hardcoding "packages.txt"
                if [ ! -f "$file" ]; then
                    echo -e "$(color 196)Error: $file not found. Please ensure the backup file is available.$(reset)"
                    return 1
                fi
                
                # Ensure i386 architecture is supported, if necessary
                if grep -q "i386" "$file"; then
                    echo -e "$(color 3)Found i386. Enabling i386 architecture...$(reset)"
                    sudo dpkg --add-architecture i386
                    sudo apt update
                fi
                
                echo "Preparing to reinstall packages from $file..."
                
                # Convert the text file into a single line of packages
                local package_list=$(tr '\n' ' ' < "$file")
                
                # Install everything at once (100x faster than a while loop)
                sudo apt install -y $package_list
                
                echo -e "$(color 46)Reinstallation completed.$(reset)"
                return 0
                ;;
                
            "Exit")
                return 0
                ;;
                
            *)
                echo -e "$(color 3)Invalid selection, please choose 'Backup List' or 'Reinstall Backup'.$(reset)"
                ;;
        esac
    done
}