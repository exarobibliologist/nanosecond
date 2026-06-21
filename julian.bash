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

function juliantime-stardate()
{
    local epoch hr min sec tz_offset tz_sign tz_hours tz_mins tz_sec
    local local_epoch julian seconds_today fraction fraction_str

    # Fetch current time data and timezone offset in a single built-in call
    # %s = UNIX epoch, %H = Hour, %M = Minute, %S = Second, %z = Timezone (e.g., -0400)
    printf -v now '%(%s %H %M %S %z)T' -1
    read -r epoch hr min sec tz_offset <<< "$now"

    # Force base-10 to prevent BASH from interpreting 08 or 09 as invalid octal numbers
    hr=$((10#$hr))
    min=$((10#$min))
    sec=$((10#$sec))

    # Convert timezone offset to seconds (e.g., -0400 -> 14400 seconds)
    tz_sign=${tz_offset:0:1}
    tz_hours=${tz_offset:1:2}
    tz_mins=${tz_offset:3:2}
    tz_sec=$(( 10#$tz_hours * 3600 + 10#$tz_mins * 60 ))

    # Calculate "Local" UNIX epoch by applying the timezone offset
    # This ensures the Julian day rolls over precisely at local midnight
    if [[ "$tz_sign" == "-" ]]; then
        local_epoch=$(( epoch - tz_sec ))
    else
        local_epoch=$(( epoch + tz_sec ))
    fi

    # MJD 40587 is exactly Jan 1, 1970. 
    # Dividing the local epoch by 86400 gives us days since then.
    julian=$(( (local_epoch / 86400) + 40587 ))

    # Calculate fractional day based on current local time
    seconds_today=$(( hr * 3600 + min * 60 + sec ))
    
    # Scale up by 1 billion to calculate exactly 9 decimal places using integer math
    fraction=$(( seconds_today * 1000000000 / 86400 ))

    # Zero-pad the fraction to ensure it correctly displays all 9 digits
    printf -v fraction_str "%09d" "$fraction"

    # Export directly to the global variable for PS1
    CURRENT_STARDATE="SD ${julian}.${fraction_str}"
}

function juliantime()
{
python3 ~/GIT/nanosecond/Python/julian_clock.py
}