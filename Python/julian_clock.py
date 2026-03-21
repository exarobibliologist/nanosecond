import time
import os
from datetime import datetime

def clear_screen():
    """Clears the terminal screen cross-platform."""
    os.system('cls' if os.name == 'nt' else 'clear')

def julian_time_clock():
    # Your baseline date (MJD 40000 is exactly May 24, 1968)
    base_date = datetime(1968, 5, 24)
    base_mjd = 40000

    try:
        while True:
            # Grab the exact current local time
            now = datetime.now()
            
            # Find the midnight that started the current day
            midnight_today = now.replace(hour=0, minute=0, second=0, microsecond=0)
            
            # Calculate how many full days have passed since May 24, 1968
            days_since_base = (midnight_today - base_date).days
            current_julian_day = base_mjd + days_since_base
            
            # Calculate the exact fraction of the current day
            seconds_since_midnight = (now - midnight_today).total_seconds()
            fraction_of_day = seconds_since_midnight / 86400.0
            
            # Combine them for the final Local Modified Julian Date
            local_mjd = current_julian_day + fraction_of_day
            
            # Format and display
            clear_screen()
            print("--- Realtime Terminal Clock ---")
            print("Standard Gregorian Date:")
            # Slicing [:-3] gives us milliseconds instead of microseconds
            print(now.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]) 
            print("\nLocal Modified Julian:")
            print(f"{local_mjd:.9f}")
            print("\n(Press Ctrl+C to exit)")
            
            # Refresh rate (0.05 seconds = 20 frames per second)
            time.sleep(0.05)
            
    except KeyboardInterrupt:
        # Graceful exit when you press Ctrl+C
        clear_screen()
        print("Clock stopped. Have a great day!")

if __name__ == "__main__":
    julian_time_clock()