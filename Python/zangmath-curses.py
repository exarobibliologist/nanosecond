import curses
import math

# XP conversion rates
zangmenu = {
    "BOOKS/BONES/CHESTS/STATUES": 10000,
    "EVERBURNING/PHIAL/STAR": 5000,
    "RODS": 4000,
    "OIL": 2000,
    "STAFF/WAND": 400,
    "RINGS/AMULETS": 125,
    "WEAPONS": 100,
    "SCROLLS/FOOD/SHROOMS/POTIONS": 50,
    "TOTAL ARMOR": 20,
    "TURNS OF LIGHT": 15,
    "MONEY": 10,
}

def main(stdscr):
    # Setup terminal UI settings
    curses.curs_set(1)  # Show the cursor
    stdscr.keypad(True) # Enable Arrow Keys
    
    # Define our form fields
    items = ["Current XP"] + list(zangmenu.keys())
    values = [""] * len(items)
    
    current_row = 0
    current_button = 0  # 0 for Calculate, 1 for Clear
    result_msg = []

    # The Main UI Loop
    while True:
        stdscr.clear()
        
        # --- Header ---
        stdscr.addstr(0, 2, "=== ZANG XP CALCULATOR ===", curses.A_BOLD)
        stdscr.addstr(1, 2, "Arrows: Navigate | Enter: Select/Type | Ctrl+C: Quit")

        # --- Draw Entry Fields ---
        for idx, item in enumerate(items):
            y = 3 + idx
            label = f"{item}:"
            
            # Highlight the currently selected row
            if idx == current_row:
                stdscr.addstr(y, 2, f"{label:<32} [ {values[idx]:<10} ]", curses.A_REVERSE)
            else:
                stdscr.addstr(y, 2, f"{label:<32} [ {values[idx]:<10} ]")

        # --- Draw Calculate & Clear Buttons ---
        calc_y = 3 + len(items) + 1
        calc_text = "[ CALCULATE ]"
        clear_text = "[ CLEAR ]"

        if current_row == len(items):
            if current_button == 0:
                stdscr.addstr(calc_y, 2, calc_text, curses.A_REVERSE)
                stdscr.addstr(calc_y, 2 + len(calc_text) + 2, clear_text)
            else:
                stdscr.addstr(calc_y, 2, calc_text)
                stdscr.addstr(calc_y, 2 + len(calc_text) + 2, clear_text, curses.A_REVERSE)
        else:
            stdscr.addstr(calc_y, 2, calc_text)
            stdscr.addstr(calc_y, 2 + len(calc_text) + 2, clear_text)

        # --- Draw Results ---
        if result_msg:
            for r_idx, line in enumerate(result_msg):
                stdscr.addstr(calc_y + 2 + r_idx, 2, line, curses.A_BOLD)

        stdscr.refresh()

        # --- Handle User Input ---
        try:
            key = stdscr.getch()
        except KeyboardInterrupt:
            break # Exit on Ctrl+C

        # Navigation
        if key == curses.KEY_UP:
            current_row = max(0, current_row - 1)
        elif key == curses.KEY_DOWN:
            current_row = min(len(items), current_row + 1)
        elif key == curses.KEY_LEFT and current_row == len(items):
            current_button = 0  # Select Calculate
        elif key == curses.KEY_RIGHT and current_row == len(items):
            current_button = 1  # Select Clear
        
        # Deleting text (handles different terminal backspace codes)
        elif key in (curses.KEY_BACKSPACE, 127, 8):
            if current_row < len(items) and len(values[current_row]) > 0:
                values[current_row] = values[current_row][:-1]
        
        # Pressing Enter
        elif key in (curses.KEY_ENTER, 10, 13):
            if current_row == len(items):
                if current_button == 0:
                    # --- Math Logic ---
                    try:
                        xp = float(values[0]) if values[0] else 0.0
                        calc = 0.0 # Prevent crash if no items are entered
                        
                        for i, (name, factor) in enumerate(zangmenu.items()):
                            count_str = values[i+1] # +1 because values[0] is Current XP
                            if count_str.isdigit():
                                count = int(count_str)
                                for _ in range(count):
                                    calc = math.exp(math.log(1 * factor) / 15)
                                    xp = min(xp + factor, xp * calc)
                        
                        result_msg = [
                            f"Conversion Amount: {round(calc, 2)}",
                            f"Final XP:          {round(xp, 2)}",
                            "",
                            "(Arrow up to change values or right to clear)"
                        ]
                    except ValueError:
                        result_msg = ["Error: Invalid XP Number"]
                
                elif current_button == 1:
                    # --- Clear Logic ---
                    values = [""] * len(items)
                    result_msg = ["All fields cleared! Ready for new input."]
                    # Optionally jump cursor back to the top field:
                    current_row = 0 
            else:
                # If they hit enter on a text field, just move down
                current_row += 1
                
        # Typing Numbers
        elif 32 <= key <= 126:
            if current_row < len(items):
                char = chr(key)
                # Only allow digits (and a decimal point for XP)
                if char.isdigit() or (char == '.' and current_row == 0):
                    values[current_row] += char

if __name__ == "__main__":
    # wrapper() safely initializes the terminal and restores it if the script crashes
    curses.wrapper(main)