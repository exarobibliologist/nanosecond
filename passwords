#!/bin/bash

function passwords() {
    echo -e "Which password utility would you like to run?\n"
    
    local options=(
        "Password Maker"
        "Password Chart"
        "Exit"
    )

    PS3="Please select an option: "
    select choice in "${options[@]}"; do
        case "$choice" in
            "Password Maker")
                python3 ~/GIT/nanosecond/Python/password_maker.py
                return 0
                ;;
            "Password Chart")
                python3 ~/GIT/nanosecond/Python/passwordchart-nano.py
                return 0
                ;;
            "Exit")
                return 0
                ;;
            *)
                echo -e "Invalid selection, please try again."
                ;;
        esac
    done
}