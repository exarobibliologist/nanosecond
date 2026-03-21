#!/bin/bash

# Local Modified Julian Date Clock
# This realtime clock converts the current local date to Modified JD and displays both in realtime.				

function juliantime-original()
{
	# Infinite loop for real-time conversion
	while true
	do
		# Fetch EVERYTHING inside the loop so midnight rollovers are caught!
		todayis=$(date +"%F")
		hourtime=$(date +"%H")
		minutetime=$(date +"%M")
		secondtime=$(date +"%S.%N" | head -c10)

		# Compute Julian Day dynamically inside the loop
		let julian=($(date +%s -d $todayis)-$(date +%s -d 1968-05-24))/86400+40000

		# Compute Julian time as a float
		juliantime=$(echo "scale=9; ($hourtime / 24) + ($minutetime / 1440) + ($secondtime / 86400) + $julian" | bc -l)

		# Clear the screen and display results
		clear
		echo "Standard Gregorian Date"
		echo "$todayis $hourtime:$minutetime:$secondtime"
		echo "Local Modified Julian"
		echo "$juliantime"

		# Sleep for a fraction of a second (20fps refresh rate to save CPU)
		sleep 0.05
	done
}

function juliantime()
{
python3 ~/GIT/nanosecond/Python/julian_clock.py
}