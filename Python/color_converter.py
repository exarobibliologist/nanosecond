import sys

def rgb_to_ansi(r, g, b):
    """Maps an RGB value to the nearest xterm-256 color code."""
    def snap(val):
        if val < 48: return 0
        if val < 115: return 1
        if val < 155: return 2
        if val < 195: return 3
        if val < 235: return 4
        return 5
        
    return 16 + (36 * snap(r)) + (6 * snap(g)) + snap(b)

if __name__ == "__main__":
    # 1. Check if the user provided exactly 3 arguments (R, G, B)
    # sys.argv[0] is the script name, so we expect 4 items total.
    if len(sys.argv) != 4:
        print("Usage: python3 colorize.py <R> <G> <B>")
        print("Example: python3 colorize.py 155 89 182")
        sys.exit(1)
        
    # 2. Try to convert the inputs to integers
    try:
        r = int(sys.argv[1])
        g = int(sys.argv[2])
        b = int(sys.argv[3])
    except ValueError:
        print("Error: RGB values must be numbers.")
        sys.exit(1)
        
    # 3. Constrain the numbers between 0 and 255 just to be safe
    r, g, b = [max(0, min(255, val)) for val in (r, g, b)]
    
    # 4. Do the math and print the output
    ansi_256 = rgb_to_ansi(r, g, b)
    
    print(f"Target RGB: ({r}, {g}, {b})")
    print(f"\033[38;2;{r};{g};{b}m████ This is TrueColor (Exact Match)\033[0m")
    print(f"\033[38;5;{ansi_256}m████ This is ANSI 256 (Code: {ansi_256})\033[0m")