#!/bin/bash

##########################
# SOME ALIAS DEFINITIONS #
##########################

# ------------------------------------------------------------------------------
# SYSTEM & NETWORK DIAGNOSTICS
# ------------------------------------------------------------------------------
alias speedtest='speedtest-cli --secure'
alias ports='netstat -tulanp'
alias mem='free -m -h'            # Displays memory in human-readable format

# ------------------------------------------------------------------------------
# DIRECTORY NAVIGATION
# ------------------------------------------------------------------------------
alias .1='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'

# ------------------------------------------------------------------------------
# FILE SYSTEM & DISK MANAGEMENT
# ------------------------------------------------------------------------------
alias dus='du -shc * | sort -hr'  # Incredibly useful for finding space hogs
alias disks='sudo fdisk -l'
alias mkdir='mkdir -pv' # Make directories recursively and tell you what it did
alias path='echo -e ${PATH//:/\\n}' #Prints system path into a clean, readable, vertical list
#alias less='more -spd'            # Overrides 'less' to use the 'more' pager 

# ------------------------------------------------------------------------------
# SAFETY NETS (Interactive Prompts)
# ------------------------------------------------------------------------------
# Forces confirmation before overwriting or deleting files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ------------------------------------------------------------------------------
# TEXT & CALCULATION FORMATTING
# ------------------------------------------------------------------------------
alias grep='grep --colour=always'
alias bc='bc -l'                  # Pre-loads the standard math library

# ------------------------------------------------------------------------------
# FUN QOL STUFF
# ------------------------------------------------------------------------------
alias make_it_so='sudo !!' #Forgot to type 'sudo' before a command? Just type 'make_it_so' and it runs the last command as root!