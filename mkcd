#! /bin/bash

function mkcd()
{
# Check if directory name was provided
if [ -z "$1" ]; then
	echo "Usage: mkcd <directory name>"
	return 1
fi

# Create the directory and change to the newly created directory
mkdir -p "$1" && cd "$1"
}
