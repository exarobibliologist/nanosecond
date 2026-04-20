#!/bin/bash

function rebash() {
    clear
    echo -e "Run Update BEFORE Upgrade"
    
    # PS3 defines the prompt string for the select menu
    local PS3="Select a main menu option: "
    
    select rebashchoice in "Reset BASH" "Update Menu" "Upgrade/Remove/Purge Menu" "Maintenance Menu" "Exit"; do
        case "$rebashchoice" in
            "Reset BASH")
                clear
                source ~/.bashrc || return
                return
                ;;
            "Update Menu")
                local PS3="Select an Update option: "
                select updatechoice in "Update Sources" "NetSelect Best Source" "Back"; do
                    case "$updatechoice" in
                        "Update Sources")
                            sudo apt update || return
                            return
                            ;;
                        "NetSelect Best Source")
                            cd ~/GIT || return
                            # Hide the error output if sources.list doesn't exist yet
                            if ls "sources.list" 2>/dev/null; then
                                echo "Removing old sources"
                                rm sources.list
                            else
                                echo "Old sources.list not found"
                            fi
                            echo "Creating new sources list"
                            sudo netselect-apt -sn
                            return
                            ;;
                        "Back") 
                            break 
                            ;; # Breaks the sub-menu loop and goes back to main menu
                    esac
                done
                # Reset the main prompt text after returning from a sub-menu
                PS3="Select a main menu option: "
                ;;
            "Upgrade/Remove/Purge Menu")
                local PS3="Select an Upgrade option: "
                # Added "Purge a Package" right next to "Autoremove Unrequired"
                select upgradechoice in "List Upgrades" "List Upgrades with Detail" "Run Safe-Upgrade" "Run Full-Upgrade" "Autoremove Unrequired" "Purge a Package" "Back"; do
                    case "$upgradechoice" in
                        "List Upgrades")
                            apt list --upgradable 2>/dev/null | cut -d/ -f1 | sort | column
                            return
                            ;;
                        "List Upgrades with Detail")
                            sudo apt list --upgradable
                            return
                            ;;
                        "Run Safe-Upgrade")
                            sudo apt upgrade || return
                            return
                            ;;
                        "Run Full-Upgrade")
                            sudo apt full-upgrade || return
                            return
                            ;;
                        "Autoremove Unrequired")
                            sudo apt autoremove || return
                            return
                            ;;
                        "Purge a Package")
                            echo -e "\n"
                            # The -e flag enables Readline, allowing tab-completion inside the prompt!
                            read -e -p "Enter package to purge (Use TAB to auto-complete!): " pkg_to_purge
                            if [ -n "$pkg_to_purge" ]; then
                                sudo apt purge "$pkg_to_purge"
                                sudo apt autoremove --purge -y
                            fi
                            return
                            ;;
                        "Back") 
                            break 
                            ;;
                    esac
                done
                PS3="Select a main menu option: "
                ;;
            "Maintenance Menu")
                local PS3="Select a Maintenance option: "
                # Removed "Purge a Package" from this menu array
                select maintchoice in "Make USB" "Clean Package Cache" "APT History" "Edit APT Preferences" "Edit Sources" "Install Build Dependencies" "Add Keys" "Back"; do
                    case "$maintchoice" in
						"Make USB")
							makeusb
							return
							;;
                        "Clean Package Cache")
                            echo -e "\n--- Clearing Outdated Local Packages ---"
                            sudo apt autoclean -y
                            echo -e "\n--- Nuking Entire Package Cache ---"
                            sudo apt clean -y
                            return
                            ;;
                        "APT History")
                            local PS3="View History of: "
                            select history_choice in "Installed Programs" "Upgraded Programs" "Removed Programs" "Back"; do
                                case "$history_choice" in
                                    "Installed Programs")
                                        view_dpkg_log "installed"
                                        return
                                        ;;
                                    "Upgraded Programs")
                                        view_dpkg_log "upgrade"
                                        return
                                        ;;
                                    "Removed Programs")
                                        view_dpkg_log "remove"
                                        return
                                        ;;
                                    "Back")
                                        break
                                        ;;
                                esac
                            done
                            PS3="Select a Maintenance option: "
                            ;;
                        "Edit APT Preferences")
                            echo "Tweaking APT Preferences can lead to system instability. Be careful out there!"
                            pressanykey
                            sudo nano /etc/apt/preferences
                            return
                            ;;
                        "Edit Sources")
                            echo "Tweaking sources can lead to system instability. Be careful out there!"
                            pressanykey
                            sudo nano /etc/apt/sources.list
                            return
                            ;;
                        "Install Build Dependencies")
                            sudo aptitude install debhelper devscripts build-essential
                            return
                            ;;
                        "Add Keys")
                            echo "This script MUST be run as root. You will be prompted for your password later."
                            local PS3="Would you like to add an 8-digit key or a keyfile? "
                            select key_choice in "8-Digit Key" "Keyfile" "Back"; do
                                case "$key_choice" in
                                    "8-Digit Key")
                                        read -e -p "Enter the pub key: " key
                                        read -e -p "Enter the keyserver URL: " keyserver
                                        sudo apt-key adv --keyserver "$keyserver" --recv-keys "$key"
                                        return
                                        ;;
                                    "Keyfile")
                                        read -e -p "Enter the URL to the keyfile: " url
                                        wget "$url" -O- | sudo apt-key add -
                                        return
                                        ;;
                                    "Back")
                                        break
                                        ;;
                                esac
                            done
                            PS3="Select a Maintenance option: "
                            ;;
                        "Back") 
                            break 
                            ;;
                    esac
                done
                PS3="Select a main menu option: "
                ;;
            "Exit")
                echo "Exiting rebash."
                return
                ;;
            *)
                echo "Invalid choice. Please pick a number from the list."
                ;;
        esac
    done
}
