#!/bin/bash

# ==============================================================================
# USAGE: apt-search <search_term>
#
# DESCRIPTION:
#   Searches for available Debian/Ubuntu packages using both aptitude and apt-cache.
#   Includes dynamic tab-completion for known package names.
# ==============================================================================
function apt-search() {
    # 1. Check if a search term was actually provided
    if [ -z "$1" ]; then
        echo "Usage: apt-search [search_term]"
        return 1
    fi

    # 2. Run the searches with clear visual dividers
    echo -e "\n--- Aptitude Search Results ---"
    aptitude search "$1" | more -spd
    
    pressanykey
    
    echo -e "\n--- Apt-Cache Search Results ---"
    apt-cache search "$1" | more -spd
}

# ==============================================================================
# USAGE: apt-show <package_name>
#
# DESCRIPTION:
#   Displays incredibly deep diagnostic info for a specific package, including
#   version policies, dependencies, and reverse dependencies.
#   Includes dynamic tab-completion for known package names.
# ==============================================================================
function apt-show() {
    # 1. Check if a package name was actually provided
    if [ -z "$1" ]; then
        echo "Usage: apt-show [package]"
        return 1
    fi

    # 2. Run the deep-dive diagnostic commands
    echo -e "\n--- Package Info & Versions ---"
    apt-cache showpkg "$1"
    
    pressanykey
    
    echo -e "\n--- Install Policy ---"
    apt-cache policy "$1"
    
    pressanykey
    
    echo -e "\n--- Forward Dependencies ---"
    apt-cache depends "$1"
    
    pressanykey
    
    echo -e "\n--- Reverse Dependencies ---"
    apt-cache rdepends "$1"
}

# ------------------------------------------------------------------------------
# TAB-COMPLETION BINDINGS
# ------------------------------------------------------------------------------
# Instead of relying on internal bash-completion functions that load lazily,
# we use a lightning-fast custom completer using 'apt-cache pkgnames'.

_custom_apt_complete() {
    # Capture the current word being typed
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Generate the completion reply by asking apt-cache for packages starting with $cur
    COMPREPLY=( $(apt-cache pkgnames "$cur" 2>/dev/null) )
}

# Bind our custom function to your aliases
complete -F _custom_apt_complete apt-show apt-search