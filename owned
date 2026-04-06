#!/bin/bash

function owned() {
    # Fix 1 & 2: Check if input is empty, and use -e to support both files AND directories
    if [ -z "$1" ] || [ ! -e "$1" ]; then
        echo -e "$(color 196)Please input a valid file or directory name after command, like this: owned <filename>$(reset)"
        return 1
    fi

    # Fix 3: Store the target safely in a quoted variable to handle spaces
    local target="$1"

    select ownchoice in "Own the file/directory" "Change Access Permissions" "Exit"; do
        case "$ownchoice" in
            "Own the file/directory")
                echo -e "Target= $target\nIf this is not correct, end this process now. No changes will be made."
                pressanykey
                
                # Using your global $iamme variable, safely quoted
                sudo chown -R "$iamme:$iamme" "$target"
                
                echo -e "$(color 46)Ownership of '$target' transferred to $iamme.$(reset)"
                return 0
                ;;
                
            "Change Access Permissions")
                echo -e "$(color 8)-------------------------------------------------------------------------------------------------$(reset)"
                echo -e "$(color 8)|$(reset)       Owner                   $(color 8)|$(reset)       Group                   $(color 8)|$(reset)       Others                  $(color 8)|$(reset)"
                echo -e "$(color 8)|$(reset)$(color 1)(R)$(reset)ead, $(color 2)(W)$(reset)rite, $(color 3)(E)$(reset)xecute     $(color 8)|$(reset)$(color 1)(R)$(reset)ead, $(color 2)(W)$(reset)rite, $(color 3)(E)$(reset)xecute     $(color 8)|$(reset)$(color 1)(R)$(reset)ead, $(color 2)(W)$(reset)rite, $(color 3)(E)$(reset)xecute     $(color 8)|$(reset)"
                echo -e "$(color 8)-------------------------------------------------------------------------------------------------$(reset)"
                echo
                echo -e "$(color 1)0$(color 2)0$(color 3)0$(reset) = 0 (Completely locked)\n$(color 1)0$(color 2)0$(color 3)1$(reset) = 1 (Execute only)\n$(color 1)0$(color 2)1$(color 3)0$(reset) = 2 (Write only) \n$(color 1)0$(color 2)1$(color 3)1$(reset) = 3 (Write and execute)\n$(color 1)1$(color 2)0$(color 3)0$(reset) = 4 (Read only)\n$(color 1)1$(color 2)0$(color 3)1$(reset) = 5 (Read and execute)\n$(color 1)1$(color 2)1$(color 3)0$(reset) = 6 (Read and write)\n$(color 1)1$(color 2)1$(color 3)1$(reset) = 7 (Full access)"
                echo
                read -p "Enter permissions number desired (e.g., 755): " permnum
                
                # Fix 4: Strict input validation for octal numbers
                if [[ ! "$permnum" =~ ^[0-7]{3,4}$ ]]; then
                    echo -e "$(color 196)Invalid input! Permissions must be 3 or 4 digits using only numbers 0-7.$(reset)"
                    return 1
                fi
                
                pressanykey
                
                # Applying the validated permissions
                sudo chmod -R "$permnum" "$target"
                echo -e "$(color 46)Permissions of '$target' changed to $permnum.$(reset)"
                return 0
                ;;
                
            "Exit")
                return 0
                ;;
                
            *)
                echo -e "$(color 3)Invalid selection.$(reset)"
                ;;
        esac
    done
}