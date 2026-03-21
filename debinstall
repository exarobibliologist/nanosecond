#!/bin/bash

# Proper usage: debinstall [FILE]
# This will take care of installing a troublesome .deb file by resolving anything that makes it hang.

function debinstall() {
    # Check if a file was actually provided
    if [ -z "$1" ]; then
        echo "Usage: debinstall [file.deb]"
        return 1
    fi

    # Using quotes around $1 protects against filenames with spaces
    sudo dpkg -i "$1"
    
    # Adding -y automatically says "yes" to fixing the broken dependencies
    sudo apt install -f -y
}

# The Magic: Tell Bash to autocomplete files, but filter ONLY for .deb extensions
complete -f -X '!*.deb' debinstall