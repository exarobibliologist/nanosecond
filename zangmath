#!/bin/bash

function zangmath() {
	echo -e "What's the Current XP?\n"
	read xp
	# Define menu options and conversion factors
	declare -A zangmenu=(
		["BOOKS/BONES"]=100000
		["EVERBURNING/PHIAL/STAR"]=50000
		["RODS/STAFF/WAND/JEWELERY"]=12500
		["WEAPONS/ARMOR"]=10000
		["OIL FLASKS/TORCHES/LANTERNS"]=7500
		["SCROLLS"]=5000
		["FOOD/POTIONS"]=1000
		["MONEY"]=1
	)

	# Display menu
	PS3="Select an option: "
	select key in "${!zangmenu[@]}" "QUIT"; do
		if [[ "$key" == "QUIT" || -z "$key" ]]; then
			echo "Exiting."
			return
		elif [[ -n "${zangmenu[$key]}" ]]; then
			echo "How many are you converting?"
			read gimme

			# Retrieve conversion factor
			factor=${zangmenu[$key]}

			# Calculate possible results using bc
			calc1=$(echo "scale=9; e(l($gimme * $factor) / 15)" | bc -l)
			calc2=$(echo "$xp + ($gimme * $factor)" | bc -l)
			calc3=$(echo "scale=9; $xp * e(l($gimme * $factor) / 15)" | bc -l)

			# Find the smallest result
			smallest=$(printf "%s\n" "$calc2" "$calc3" | sort -n | head -1)

			clear
			echo -e "$calc1"
			echo -e "\nLowest Value = $smallest"
			return
		else
			echo "Invalid selection. Please choose again."
		fi
	done
}
