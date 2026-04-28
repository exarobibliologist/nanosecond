#!/bin/bash

function ps1_edit() {
    local THEME_DIR="$HOME/GIT/nanosecond/ps1_themes"
    local ACTIVE_THEME="$HOME/.active_ps1"

    # Check if the directory exists and has files
    if [ ! -d "$THEME_DIR" ] || [ -z "$(ls -A "$THEME_DIR"/*.ps1 2>/dev/null)" ]; then
        echo -e "\n$(color 196)No themes found in $THEME_DIR!$(reset)"
        return 1
    fi

    # Load all themes into an array
    local themes=("$THEME_DIR"/*.ps1)
    
    echo -e "\n=== Interactive PS1 Editor ==="
    echo "Select a theme to edit:"
    
    # Print a clean, numbered list of available themes
    for i in "${!themes[@]}"; do
        local theme_name=$(basename "${themes[$i]}" .ps1)
        echo "  $((i + 1))) $theme_name"
    done

    echo ""
    read -e -r -p "Enter theme number (or 0 to cancel): " choice

    if [[ "$choice" == "0" ]] || [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#themes[@]}" ]; then
        echo "Exited without changes."
        return 0
    fi

    # Retrieve the selected file
    local selected_file="${themes[$((choice-1))]}"
    local theme_name=$(basename "$selected_file" .ps1)
    
    # Hunt down the actual PS1 declaration, ignoring comments or empty lines
    local raw_line=$(grep -E '^(export )?PS1=' "$selected_file" | head -n 1)

    # Catch the error if the file is completely broken or empty
    if [ -z "$raw_line" ]; then
        echo -e "\n$(color 196)Error: Could not find a PS1 declaration in $theme_name$(reset)"
        sleep 2
    return 1
    fi

# Extract only the content between the first and last double quote
local current_ps1="${raw_line#*\"}"
current_ps1="${current_ps1%\"*}"

	# Extract only the content between the first and last double quote
	local current_ps1="${raw_line#*\"}"
	current_ps1="${current_ps1%\"*}"
	echo -e "\n$(color 46)Loaded: $theme_name$(reset)"

		# --- Generate Live Preview & Edit Loop ---
		while true; do
		printf "\n%sCurrent Code:%s %s\n" "$(color 8)" "$(reset)" "${current_ps1}"
		printf "%sLive Preview:%s\n%s\n" "$(color 8)" "$(reset)" "${current_ps1@P}"

		echo ""
		read -e -r -p "Would you like to edit this code? (Y/n): " edit_choice

		# Default to Yes if they just press Enter
		if [[ "$edit_choice" =~ ^[Nn] ]]; then
			break
		fi

		echo -e "\n$(color 3)Make your changes and press Enter:$(reset)"

		# The -i flag pre-fills the prompt with the extracted PS1 string!
		read -e -r -p "> " -i "$current_ps1" current_ps1
		done

    # ==========================================
    # FINALIZE AND SAVE
    # ==========================================
	printf "\n%s=== Final Edited Theme ===%s\n" "$(color 46)" "$(reset)"
	printf "%sCode:%s    export PS1=\"%s\"\n" "$(color 8)" "$(reset)" "${current_ps1}"
	printf "%sPreview:%s\n%s\n\n" "$(color 8)" "$(reset)" "${current_ps1@P}"

    read -e -r -p "Save changes to $theme_name.ps1? (Y/n): " save_choice
    local file_saved=false
    
    if [[ ! "$save_choice" =~ ^[Nn] ]]; then
        echo "export PS1=\"${current_ps1}\"" > "$selected_file"
        echo -e "$(color 46)Saved successfully to $selected_file$(reset)\n"
        file_saved=true
    fi

    read -e -r -p "Apply this theme to your current session right now? (Y/n): " apply_choice
    if [[ ! "$apply_choice" =~ ^[Nn] ]]; then
        
        if [ "$file_saved" = true ]; then
            # If saved, create a symlink exactly like ps1_select does
            ln -sf "$selected_file" "$ACTIVE_THEME"
        else
            # If they just wanted to apply it without saving to the nanosecond repo, 
            # write it directly into the active file
            echo "export PS1=\"${current_ps1}\"" > "$ACTIVE_THEME"
        fi
        
        # Source the active theme so it updates the current terminal screen immediately
        source "$ACTIVE_THEME"
        echo -e "$(color 46)Theme applied and set as active!$(reset)"
    fi
}
