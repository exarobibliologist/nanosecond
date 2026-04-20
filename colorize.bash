#!/bin/bash

###################################
# LOOK! IT'S A RAINBOW OF COLORS! #
###################################
color() {
    # 1. Check for RGB (3 arguments)
    if [[ $# -eq 3 ]]; then
        printf "\e[38;2;%s;%s;%sm" "$1" "$2" "$3"
        return 0
    fi

    # 2. Check for Hex or ANSI (1 argument)
    if [[ $# -eq 1 ]]; then
        local val="${1//#/}" # Strip out '#' if present

        # Check if it's Hex (exactly 6 hex characters)
        if [[ "$val" =~ ^[0-9a-fA-F]{6}$ ]]; then
            printf "\e[38;2;%d;%d;%dm" "0x${val:0:2}" "0x${val:2:2}" "0x${val:4:2}"
            return 0
        fi

        # Check if it's ANSI (number between 0 and 255)
        if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -ge 0 ] && [ "$val" -le 255 ]; then
            printf "\e[38;5;%sm" "$val"
            return 0
        fi
    fi

    # Fail-fast: Invalid input
    return 1
}

bold() {
    # 1. Check for RGB (3 arguments)
    if [[ $# -eq 3 ]]; then
        printf "\e[1;38;2;%s;%s;%sm" "$1" "$2" "$3"
        return 0
    fi

    # 2. Check for Hex or ANSI (1 argument)
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

reset() { printf "\e[0m"; }              # Reset to default

function color_rainbow() {
    for i in {0..255}; do
        printf "\e[38;5;%sm color %s\e[0m\n" "$i" "$i"
    done | less -R
}

function bold_rainbow() {
    for i in {0..255}; do
        printf "\e[1;38;5;%sm bold %s\e[0m\n" "$i" "$i"
    done | less -R
}

function color_waterfall() {
    while : ; do
        for i in {0..255}; do
            # %s drops the variable $i into the ANSI code and the text string
            printf "\e[38;5;%sm Color%s\e[0m\n" "$i" "$i"
            sleep .1
        done
    done
}
