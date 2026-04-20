#! /bin/bash

# ==============================================================================
# USAGE: psa <search_term>
#
# DESCRIPTION:
#   "Process Search All"
#   Instantly searches all running processes on the system for a specific string.
#   Returns the Process ID (PID), TTY, Time, and Command name.
#   Includes dynamic tab-completion for currently running processes.
# ==============================================================================
function psa() {
    ps -A | grep "$1"
}

# ------------------------------------------------------------------------------
# TAB-COMPLETION HELPER FOR 'psa'
# ------------------------------------------------------------------------------
function _psa_completions() {
    # 1. Grab the current word the user is actively typing
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # 2. Generate a clean, alphabetized list of every running process name
    #    -A: All processes
    #    -o comm=: Output ONLY the command name (no PIDs or time data)
    #    sort -u: Sort alphabetically and remove duplicates
    local procs=$(ps -A -o comm= | sort -u)
    
    # 3. Use Bash's native 'compgen' tool to filter the process list 
    #    against whatever the user has typed so far
    COMPREPLY=( $(compgen -W "$procs" -- "$cur") )
}

# 4. Bind the helper function to the 'psa' command
complete -F _psa_completions psa