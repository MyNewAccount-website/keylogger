@echo off
set "SCRIPT_PATH=%TEMP%\main.py"

powershell -NoProfile -WindowStyle Hidden -Command ^
    "Start-Process python -ArgumentList '\"%SCRIPT_PATH%\"' -WindowStyle Hidden"
exit