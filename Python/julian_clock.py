import time
import os
import sys
from datetime import datetime

def clear_screen():
    """Clears the terminal screen cross-platform."""
    os.system('cls' if os.name == 'nt' else 'clear')

def julian_time_clock():
    base_date = datetime(1968, 5, 24)
    base_mjd = 40000

    # 1. Clear the screen ONCE and print the static header
    clear_screen()
    print("--- Realtime Terminal Clock ---")

    try:
        while True:
            now = datetime.now()
            midnight_today = now.replace(hour=0, minute=0, second=0, microsecond=0)
            
            days_since_base = (midnight_today - base_date).days
            current_julian_day = base_mjd + days_since_base
            
            seconds_since_midnight = (now - midnight_today).total_seconds()
            fraction_of_day = seconds_since_midnight / 86400.0
            
            local_mjd = current_julian_day + fraction_of_day
            
            # 2. Print the dynamic lines
            # Note: \033[K is an ANSI code that means "erase to the end of the line"
            # It ensures no ghost characters are left behind if a line gets shorter
            print(f"Standard Gregorian Date:\033[K")
            print(f"{now.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}\033[K")
            print(f"\033[K")
            print(f"Local Modified Julian:\033[K")
            print(f"{local_mjd:.9f}\033[K")
            print(f"\033[K")
            
            # Use end="" on the last line so it doesn't create an extra newline
            print(f"(Press Ctrl+C to exit)\033[K", end="") 
            
            # 3. The Magic Move: Tell the cursor to go UP 6 lines for the next loop
            # \033[6F moves the cursor up 6 lines to the start of the "Standard Gregorian Date" line
            print("\033[6F", end="", flush=True)
            
            time.sleep(0.05)
            
    except KeyboardInterrupt:
        # 4. Push the cursor safely below our clock text before exiting so the bash prompt doesn't overwrite it
        print("\n" * 6)
        print("Clock stopped. Have a great day!")

if __name__ == "__main__":
    julian_time_clock()