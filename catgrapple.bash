#!/bin/bash

# Proper usage: catgrapple [FILE] [SEARCH TERM]
function catgrapple() {
    local file="$1"
    local search_term="${@:2}" # Captures all arguments from $2 onwards

    # Validation
    if [[ -z "$file" || -z "$search_term" ]]; then
        echo "Usage: catgrapple [FILE] [SEARCH TERM]"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found."
        return 1
    fi

    # Use 'grep -n' to get line numbers efficiently
    # The -F flag treats the search term as a literal string (better for complex commands)
    local lines
    lines=$(grep -niF "$search_term" "$file" | cut -d: -f1)

    if [[ -z "$lines" ]]; then
        echo "No matches found for '$search_term'."
        return 0
    fi

    for i in $lines; do
        echo "Opening match at line $i..."
        terminator -x nano "+$i" "$file"
        
        # Use /dev/tty to ensure 'read' works even if the script is piped
        read -p "Press Enter for next match (or Ctrl+C to stop)..." < /dev/tty
    done
}

# Proper usage: dirgrapple [DIRECTORY] [SEARCH TERM]
function dirgrapple() {
    local dir="$1"
    local search_term="${@:2}"

    # Validation
    if [[ -z "$dir" || -z "$search_term" ]]; then
        echo "Usage: dirgrapple [DIRECTORY] [SEARCH TERM]"
        return 1
    fi

    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory '$dir' not found."
        return 1
    fi

    # Step 1: Find all files containing the search term.
    # -r: recursive, -l: output only file paths, -F: literal, -I: ignore binary
    # --color=never is critical to prevent hidden ANSI codes from breaking paths
    local matching_files
    matching_files=$(grep -rlFI --color=never "$search_term" "$dir")

    if [[ -z "$matching_files" ]]; then
        echo "No matches found for '$search_term' in '$dir'."
        return 0
    fi

    # Step 2: Read each file path line by line to handle spaces gracefully
    while IFS= read -r file; do
        
        # Step 3: Match catgrapple's exact logic for extracting line numbers
        local lines
        lines=$(grep -niF --color=never "$search_term" "$file" | cut -d: -f1)

        for i in $lines; do
            echo "Opening match in '$file' at line $i..."
            terminator -x nano "+$i" "$file"
            
            # Use /dev/tty to ensure 'read' works even if the script is piped
            read -p "Press Enter for next match (or Ctrl+C to stop)..." < /dev/tty
        done
        
    done <<< "$matching_files"
}