import hashlib
import datetime
import random
import string
import re
from pathlib import Path

def get_file_hash(file_path, algorithm='md5'):
    """Calculates the MD5 or SHA256 checksum of a file efficiently."""
    hasher = hashlib.md5() if algorithm == 'md5' else hashlib.sha256()
    try:
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hasher.update(chunk)
        return hasher.hexdigest()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def sanitize_filename(file_path):
    """Replicates your bash script's character stripping, but safely."""
    name = file_path.stem 
    ext = file_path.suffix.lower() 

    name = name.replace('JAG', '_')
    name = name.replace('&', '_and_')

    for char in ['-', '(', ')', '[', ']', '%', ' ']:
        name = name.replace(char, '_')

    # Clean up duplicate underscores
    name = re.sub(r'_+', '_', name).strip('_')

    return f"{name}{ext}"

def generate_new_name(file_path, action):
    """Routes the file to the correct renaming logic based on the chosen action."""
    if action == '1': # MD5
        h = get_file_hash(file_path, 'md5')
        return f"{h}{file_path.suffix.lower()}" if h else None
    elif action == '2': # SHA256
        h = get_file_hash(file_path, 'sha256')
        return f"{h}{file_path.suffix.lower()}" if h else None
    elif action == '3': # Random
        rand_str = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
        return f"{rand_str}{file_path.suffix.lower()}"
    elif action == '4': # Sanitize
        return sanitize_filename(file_path)
    return None

def process_file(file_path, action, is_dry_run=False, log_file=None):
    """Handles the actual renaming, collision checks, and logging."""
    file_path = Path(file_path)
    if not file_path.is_file():
        return

    new_filename = generate_new_name(file_path, action)
    if not new_filename:
        return

    new_file_path = file_path.with_name(new_filename)

    if file_path == new_file_path:
        print(f"Skipped: '{file_path.name}' requires no changes.")
        return

    if new_file_path.exists():
        print(f"Conflict: Cannot rename '{file_path.name}'. '{new_filename}' already exists.")
        return

    if is_dry_run:
        print(f"[DRY RUN] {file_path.name} -> {new_filename}")
        if log_file:
            log_file.write(f"[DRY RUN] {file_path.name} -> {new_filename}\n")
    else:
        try:
            file_path.rename(new_file_path)
            print(f"Renamed: {file_path.name} -> {new_filename}")
            if log_file:
                log_file.write(f"{file_path.name} -> {new_filename}\n")
        except Exception as e:
            print(f"Error renaming {file_path.name}: {e}")

def main():
    while True:
        print("\n" + "="*40)
        print("--- Super Interactive File Renamer ---")
        print("="*40)
        
        # Action Menu
        print("\nActions:")
        print("  1. Rename Files to MD5 Hash")
        print("  2. Rename Files to SHA256 Hash")
        print("  3. Rename to Random 8-character string")
        print("  4. Strip Useless Characters (Sanitize)")
        print("  5. Exit")
        
        action = input("\nChoose an action (1-5): ").strip()
        
        if action == '5':
            print("Exiting. Have a great day!")
            break # Breaks the while loop and ends the script
            
        if action not in ['1', '2', '3', '4']:
            print("Invalid choice. Please try again.")
            continue # Goes back to the start of the while loop

        # Extension Prompt
        print("\n(Tip: Type '*' to target all files in the directory)")
        ext = input("What file extension do you want to target? (e.g., .png, mp3, *): ").strip()
        if not ext:
            print("Error: You must provide a file extension.")
            continue
        if not ext.startswith('.') and ext != '*':
            ext = '.' + ext

        # Folder Prompt
        folder_input = input("What folder location? (Press Enter for current directory): ").strip()
        folder_path = Path(folder_input) if folder_input else Path.cwd()
        
        if not folder_path.is_dir():
            print(f"Error: The directory '{folder_path}' does not exist.")
            continue

        # Single vs Batch
        while True:
            mode = input("Rename [A]ll matching files or [O]ne specific file? (A/O): ").strip().lower()
            if mode in ['a', 'o']:
                break

        # Safety Prompts
        is_dry_run = input("Enable 'Dry Run' mode? [y/N]: ").strip().lower() == 'y'
        create_log = input("Create a text log of these changes? [Y/n]: ").strip().lower() != 'n'

        if is_dry_run:
            print("\n*** DRY RUN MODE ACTIVE - NO FILES WILL BE CHANGED ***")

        # Logging Setup
        log_file_obj = None
        if create_log:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            log_path = folder_path / f"rename_log_{timestamp}.txt"
            try:
                log_file_obj = open(log_path, 'w', encoding='utf-8')
                log_file_obj.write(f"--- Rename Log ({timestamp}) ---\n")
                log_file_obj.write("-" * 40 + "\n")
            except Exception as e:
                print(f"Warning: Could not create log file: {e}")

        # Execution
        if mode == 'o':
            filename = input("What is the specific filename? (e.g., image.png): ").strip()
            specific_file_path = folder_path / filename
            if specific_file_path.exists():
                process_file(specific_file_path, action, is_dry_run, log_file_obj)
            else:
                print(f"Error: The file '{filename}' was not found.")

        elif mode == 'a':
            search_pattern = f"*{ext}" if ext != '*' else "*"
            matching_files = [f for f in folder_path.glob(search_pattern) if f.is_file()]
            
            if not matching_files:
                print(f"No files found matching '{search_pattern}'.")
            else:
                print(f"\nFound {len(matching_files)} file(s). Processing...")
                for file_path in matching_files:
                    process_file(file_path, action, is_dry_run, log_file_obj)
                
        if log_file_obj:
            log_file_obj.close()
            print(f"\nLog file saved to: {log_path}")

        print("\nTask complete! Returning to main menu...")

if __name__ == "__main__":
    main()