#!/bin/bash

color() {
    # 1. Check for RGB Foreground + Background (6 arguments)
    if [[ $# -eq 6 ]]; then
        # \e[38;2;... is foreground, \e[48;2;... is background
        printf "\e[38;2;%s;%s;%sm\e[48;2;%s;%s;%sm" "$1" "$2" "$3" "$4" "$5" "$6"
        return 0
    fi

    # 2. Check for RGB Foreground only (3 arguments)
    if [[ $# -eq 3 ]]; then
        printf "\e[38;2;%s;%s;%sm" "$1" "$2" "$3"
        return 0
    fi

    # 3. Check for Hex/ANSI Foreground + Background (2 arguments)
    if [[ $# -eq 2 ]]; then
        local fg="${1//#/}"
        local bg="${2//#/}"

        # If both are Hex
        if [[ "$fg" =~ ^[0-9a-fA-F]{6}$ ]] && [[ "$bg" =~ ^[0-9a-fA-F]{6}$ ]]; then
            printf "\e[38;2;%d;%d;%dm\e[48;2;%d;%d;%dm" "0x${fg:0:2}" "0x${fg:2:2}" "0x${fg:4:2}" "0x${bg:0:2}" "0x${bg:2:2}" "0x${bg:4:2}"
            return 0
        fi

        # If both are ANSI
        if [[ "$fg" =~ ^[0-9]+$ ]] && [ "$fg" -ge 0 ] && [ "$fg" -le 255 ] && \
           [[ "$bg" =~ ^[0-9]+$ ]] && [ "$bg" -ge 0 ] && [ "$bg" -le 255 ]; then
            printf "\e[38;5;%sm\e[48;5;%sm" "$fg" "$bg"
            return 0
        fi
    fi

    # 4. Check for Hex or ANSI Foreground only (1 argument)
    if [[ $# -eq 1 ]]; then
        local val="${1//#/}" # Strip out '#' if present

        # Check if it's Hex
        if [[ "$val" =~ ^[0-9a-fA-F]{6}$ ]]; then
            printf "\e[38;2;%d;%d;%dm" "0x${val:0:2}" "0x${val:2:2}" "0x${val:4:2}"
            return 0
        fi

        # Check if it's ANSI
        if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -ge 0 ] && [ "$val" -le 255 ]; then
            printf "\e[38;5;%sm" "$val"
            return 0
        fi
    fi

    # Fail-fast: Invalid input
    return 1
}

bold() {
    # 1. Check for RGB Foreground + Background (6 arguments)
    if [[ $# -eq 6 ]]; then
        printf "\e[1;38;2;%s;%s;%sm\e[48;2;%s;%s;%sm" "$1" "$2" "$3" "$4" "$5" "$6"
        return 0
    fi

    # 2. Check for RGB Foreground only (3 arguments)
    if [[ $# -eq 3 ]]; then
        printf "\e[1;38;2;%s;%s;%sm" "$1" "$2" "$3"
        return 0
    fi

    # 3. Check for Hex/ANSI Foreground + Background (2 arguments)
    if [[ $# -eq 2 ]]; then
        local fg="${1//#/}"
        local bg="${2//#/}"

        if [[ "$fg" =~ ^[0-9a-fA-F]{6}$ ]] && [[ "$bg" =~ ^[0-9a-fA-F]{6}$ ]]; then
            printf "\e[1;38;2;%d;%d;%dm\e[48;2;%d;%d;%dm" "0x${fg:0:2}" "0x${fg:2:2}" "0x${fg:4:2}" "0x${bg:0:2}" "0x${bg:2:2}" "0x${bg:4:2}"
            return 0
        fi

        if [[ "$fg" =~ ^[0-9]+$ ]] && [ "$fg" -ge 0 ] && [ "$fg" -le 255 ] && \
           [[ "$bg" =~ ^[0-9]+$ ]] && [ "$bg" -ge 0 ] && [ "$bg" -le 255 ]; then
            printf "\e[1;38;5;%sm\e[48;5;%sm" "$fg" "$bg"
            return 0
        fi
    fi

    # 4. Check for Hex or ANSI Foreground only (1 argument)
    if [[ $# -eq 1 ]]; then
        local val="${1//#/}"

        if [[ "$val" =~ ^[0-9a-fA-F]{6}$ ]]; then
            printf "\e[1;38;2;%d;%d;%dm" "0x${val:0:2}" "0x${val:2:2}" "0x${val:4:2}"
            return 0
        fi

        if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -ge 0 ] && [ "$val" -le 255 ]; then
            printf "\e[1;38;5;%sm" "$val"
            return 0
        fi
    fi

    return 1
}

reset() {
    printf "\e[0m"
}
