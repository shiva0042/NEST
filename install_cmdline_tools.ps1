# Script to download and install Android cmdline-tools
# Run this if Android Studio SDK Manager method doesn't work

$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools"
$latestPath = "$cmdlineToolsPath\latest"

Write-Host "Installing Android SDK Command-Line Tools..." -ForegroundColor Green
Write-Host ""

# Check if SDK exists
if (-not (Test-Path $sdkPath)) {
    Write-Host "Error: Android SDK not found at $sdkPath" -ForegroundColor Red
    Write-Host "Please install Android Studio first!" -ForegroundColor Yellow
    exit 1
}

Write-Host "SDK Path: $sdkPath" -ForegroundColor Cyan
Write-Host ""

# Download URL for cmdline-tools (Windows)
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zipFile = "$env:TEMP\cmdline-tools.zip"

Write-Host "Downloading cmdline-tools..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "✓ Download complete" -ForegroundColor Green
}
catch {
    Write-Host "Error downloading: $_" -ForegroundColor Red
    exit 1
}

# Extract
Write-Host "Extracting..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile -DestinationPath $cmdlineToolsPath -Force
    
    # Move cmdline-tools\cmdline-tools to cmdline-tools\latest
    if (Test-Path "$cmdlineToolsPath\cmdline-tools") {
        if (Test-Path $latestPath) {
            Remove-Item $latestPath -Recurse -Force
        }
        Move-Item "$cmdlineToolsPath\cmdline-tools" $latestPath
        Write-Host "✓ Extraction complete" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error extracting: $_" -ForegroundColor Red
    exit 1
}

# Cleanup
Remove-Item $zipFile -Force

Write-Host ""
Write-Host "✓ Command-line tools installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "  d:/vs/anti/flutter/bin/flutter.bat doctor --android-licenses" -ForegroundColor White
Write-Host ""
