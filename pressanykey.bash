#!/bin/bash

function pressanykey () {
    # Save the current terminal settings
    local oldstty=$(stty -g)
    
    # Set a trap to restore terminal settings if the user hits Ctrl+C
    trap 'stty "$oldstty"; echo -e "\nAborted."; return 1' SIGINT

    stty -icanon -echo min 0 time 0

    # Spinner array
    local arr=(
    "$(color 1)- - - - - - - - - - $(color 2)PRESS ANY KEY$(color 1) - - - - - - - - - -$(reset)"
    "$(color 2)/ / / / / / / / / / $(color 3)PRESS ANY KEY$(color 2) \\ \\ \\ \\ \\ \\ \\ \\ \\ \\$(reset)"
    "$(color 3)| | | | | | | | | | $(color 4)PRESS ANY KEY$(color 3) | | | | | | | | | |$(reset)"
    "$(color 4)\\ \\ \\ \\ \\ \\ \\ \\ \\ \\ $(color 1)PRESS ANY KEY$(color 4) / / / / / / / / / /$(reset)"
    )
    
    while :; do
        for c in "${arr[@]}"; do
            echo -en "\r $c "
            
            # read -t 0.1 handles the 0.1 second frame delay AND listens for the key simultaneously
            if read -t 0.1 -n 1; then
                # Restore the terminal settings
                stty "$oldstty"
                # Remove the trap so it doesn't affect the rest of your scripts
                trap - SIGINT
                echo -e "\n"
                return 0
            fi
        done
    done
}