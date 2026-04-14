import sys

def cmyk_to_rgb(c, m, y, k):
    """Converts CMYK (0.0 - 1.0) to RGB (0 - 255)."""
    r = round(255 * (1 - c) * (1 - k))
    g = round(255 * (1 - m) * (1 - k))
    b = round(255 * (1 - y) * (1 - k))
    return (r, g, b)

def rgb_to_ansi(r, g, b):
    """Maps an RGB value to the nearest xterm-256 color code."""
    # Snaps an RGB component (0-255) to the 6x6x6 color cube index (0-5)
    def snap(val):
        if val < 48: return 0
        if val < 115: return 1
        if val < 155: return 2
        if val < 195: return 3
        if val < 235: return 4
        return 5
        
    # Formula for ANSI 256 color code from 0-5 coordinate indices
    return 16 + (36 * snap(r)) + (6 * snap(g)) + snap(b)

# --- Example Usage ---
if __name__ == "__main__":
    # Test an RGB Color (e.g., a vibrant purple)
    r, g, b = 155, 89, 182
    
    ansi_256 = rgb_to_ansi(r, g, b)
    
    print(f"Target RGB: ({r}, {g}, {b})")
    
    # 24-bit TrueColor (Exact match, supported by most modern terminals)
    print(f"\033[38;2;{r};{g};{b}m████ This is TrueColor (Exact Match)\033[0m")
    
    # 8-bit ANSI 256 (Closest approximation)
    print(f"\033[38;5;{ansi_256}m████ This is ANSI 256 (Code: {ansi_256})\033[0m")