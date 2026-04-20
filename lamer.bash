#!/bin/bash

lamer() {
    # Ensure the argument is provided
    if [ -z "$1" ]; then
        echo "No input file provided."
        return 1
    fi

    # Check if the input file exists and is a regular file
    if [ ! -f "$1" ]; then
        echo "'$1' is not a valid input file."
        return 1
    fi

    # Process based on file extension
    case "$1" in
        *.wav)
            lame -h -b 256 "$1" "${1}.mp3"
            ;;
        *.flac)
            flac -cd "$1" | lame -b 320 - "${1%.*}.mp3"
            ;;
        *)
            echo "Unsupported file type: '$1'"
            return 1
            ;;
    esac
}
