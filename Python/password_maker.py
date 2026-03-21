import secrets
import random
from pathlib import Path

def generate_memorable():
    """Pulls 4 random words from the system dictionary."""
    word_file = Path("/usr/share/dict/words")
    
    if not word_file.exists():
        print("Error: The dictionary file '/usr/share/dict/words' was not found on this system.")
        return

    try:
        with open(word_file, 'r', encoding='utf-8') as f:
            words = [word.strip() for word in f if word.strip() and "'" not in word]
        
        if not words:
            print("Error: Dictionary file is empty.")
            return

        print("\n--- Memorable Passwords ---")
        for _ in range(4):
            print(secrets.choice(words))
            
    except Exception as e:
        print(f"Error reading dictionary: {e}")

def generate_password_sheet():
    """Generates 14 batches of passwords using different character sets."""
    print("\n--- Large Password Sheet Generator ---")
    
    try:
        num = int(input("How many passwords per set? (Keep under 20 recommended): "))
        min_len = int(input("Minimum length of each password?: "))
        max_len = int(input("Maximum length?: "))
    except ValueError:
        print("Error: Please enter valid numbers.")
        return

    if min_len > max_len:
        print("Error: Minimum length cannot be greater than maximum length.")
        return
    if min_len < 1:
        print("Error: Length must be at least 1.")
        return

    # Ask for Guarantee Mode
    guarantee_input = input("Enable 'Guarantee Mode' (Ensures at least one char from each set)? [Y/n]: ").strip().lower()
    is_guarantee = guarantee_input != 'n'

    # If Guarantee Mode is on, the absolute minimum length must be 4 to support 
    # the "Numbers, Lowercase, Uppercase, Symbols" combination.
    if is_guarantee and min_len < 4:
        print("\nNotice: Minimum length increased to 4 to support Guarantee Mode requirements.")
        min_len = max(min_len, 4)
        max_len = max(max_len, 4)

    char_sets = {
        "Numbers": "1234567890",
        "Lowercase": "qwertyuiopasdfghjklzxcvbnm",
        "Uppercase": "QWERTYUIOPASDFGHJKLZXCVBNM",
        "Symbols": "!@#$%^&*();:<>/?",
    }

    combinations = [
        ("Numbers, Lowercase, Uppercase, Symbols", ["Numbers", "Lowercase", "Uppercase", "Symbols"]),
        ("Numbers, Lowercase, Symbols", ["Numbers", "Lowercase", "Symbols"]),
        ("Numbers, Lowercase, Uppercase", ["Numbers", "Lowercase", "Uppercase"]),
        ("Numbers, Symbols", ["Numbers", "Symbols"]),
        ("Numbers, Uppercase", ["Numbers", "Uppercase"]),
        ("Numbers, Lowercase", ["Numbers", "Lowercase"]),
        ("Numbers", ["Numbers"]),
        ("Lowercase, Uppercase, Symbols", ["Lowercase", "Uppercase", "Symbols"]),
        ("Lowercase, Symbols", ["Lowercase", "Symbols"]),
        ("Lowercase, Uppercase", ["Lowercase", "Uppercase"]),
        ("Lowercase", ["Lowercase"]),
        ("Uppercase, Symbols", ["Uppercase", "Symbols"]),
        ("Uppercase", ["Uppercase"]),
        ("Symbols", ["Symbols"])
    ]

    output_file = Path("password_sheet.txt")
    
    # We use SystemRandom for cryptographically secure shuffling
    secure_random = random.SystemRandom()
    
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            for label, sets in combinations:
                f.write(f"\n--- {label} ---\n")
                
                pool = "".join(char_sets[s] for s in sets)
                
                for _ in range(num):
                    length = random.randint(min_len, max_len)
                    
                    if is_guarantee:
                        # 1. Guarantee one character from each required set
                        chars = [secrets.choice(char_sets[s]) for s in sets]
                        
                        # 2. Fill the rest of the password length from the combined pool
                        chars += [secrets.choice(pool) for _ in range(length - len(sets))]
                        
                        # 3. Securely shuffle the list so the guaranteed chars aren't at the front
                        secure_random.shuffle(chars)
                        password = "".join(chars)
                    else:
                        # Standard fully random generation
                        password = "".join(secrets.choice(pool) for _ in range(length))
                        
                    f.write(f"{password}\n")
        
        print(f"\nSuccess! Generated {num * 14} passwords.")
        print(f"Saved to: {output_file.resolve()}")
        
    except Exception as e:
        print(f"Error writing to file: {e}")

def main():
    while True:
        print("\n" + "="*40)
        print("--- Ultimate Password Maker ---")
        print("="*40)
        print("  1. Memorable Passwords")
        print("  2. Large Password Sheet")
        print("  3. Exit")
        
        choice = input("\nChoose an option (1-3): ").strip()
        
        if choice == '1':
            generate_memorable()
        elif choice == '2':
            generate_password_sheet()
        elif choice == '3':
            print("Exiting. Keep those passwords safe!")
            break
        else:
            print("Invalid choice. Please enter 1, 2, or 3.")

if __name__ == "__main__":
    main()