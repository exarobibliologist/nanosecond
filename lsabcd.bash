#!/bin/bash

# ==============================================================================
# lsa: The "Alphabetical / Extension" View
# Outputs in columns, shows hidden files, sorts by extension, and keeps 
# directories stacked neatly at the top.
# ==============================================================================
function lsa() {
    ls -hCAgGuX --group-directories-first --color=always
}

# ==============================================================================
# lsb: The "Big" View (Size)
# Outputs in a vertical list, sorted strictly by file size (largest at the top).
# Great for hunting down space hogs.
# ==============================================================================
function lsb() {
    ls -lhSgG --color=always
}

# ==============================================================================
# lsc: The "Chronological" View (Time)
# Outputs in a vertical list, sorted by modification time (newest at the top).
# Perfect for answering "what file did I just download/edit?"
# ==============================================================================
function lsc() {
    ls -lhtgG --color=always
}

# ==============================================================================
# lsd: The "Directory" View
# Filters out all files and ONLY shows folders. 
# (The 2>/dev/null suppresses errors if you run it in a folder with no sub-folders)
# ==============================================================================
function lsd() {
    ls -d */ -hCA --color=always 2>/dev/null
}