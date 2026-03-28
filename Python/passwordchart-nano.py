#!/usr/bin/env python3
import hashlib
import random
import string

def generate_seed(phrase: str) -> int:
    """Generate a consistent integer seed based on an MD5 hash of the phrase."""
    md5_hash = hashlib.md5(phrase.encode()).digest()
    return int.from_bytes(md5_hash[:4], 'big')

def generate_chart(seed: int) -> dict:
    """Generate the character mapping chart based on the seed."""
    random.seed(seed)
    characters = string.ascii_letters + string.digits + string.punctuation
    
    chart = {}
    for label in string.ascii_uppercase + string.digits:
        chart[label] = "".join(random.choices(characters, k=random.randint(2, 4)))
    
    return chart

def main():
    print("\n--- Password Chart Generator ---")
    
    # 1. Prompt for the passphrase (seed)
    passphrase = input("Enter chart selection phrase: ")
    if not passphrase.strip():
        print("Error: Phrase cannot be empty.")
        # Added input here so it doesn't instantly close on an error in Windows
        input("\nPress Enter to exit...")
        return

    # Generate the underlying chart
    seed = generate_seed(passphrase)
    chart = generate_chart(seed)

    # 2. Prompt for the word to encode
    input_text = input("Enter the phrase you want encoded: ")
    if not input_text.strip():
        print("Error: Input phrase cannot be empty.")
        input("\nPress Enter to exit...")
        return

    # 3. Encrypt the text
    encrypted_text = ''.join(chart.get(char, char) for char in input_text.upper())

# 4. Output the result
    print("\nYour encrypted password is:")
    print(f"{encrypted_text}\n")
    
# 5. The Windows Fix: Pause before exiting
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()