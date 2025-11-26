# NEST App - Build APK Script
# Run this after Android Studio is installed

Write-Host "Building NEST App APK..." -ForegroundColor Green
Write-Host ""

# Navigate to project
Set-Location "d:\vs\anti\near_basket"

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
d:/vs/anti/flutter/bin/flutter.bat clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
d:/vs/anti/flutter/bin/flutter.bat pub get

# Build APK
Write-Host "Building release APK..." -ForegroundColor Yellow
d:/vs/anti/flutter/bin/flutter.bat build apk --release

Write-Host ""
Write-Host "✓ Build Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your APK is located at:" -ForegroundColor Cyan
Write-Host "d:\vs\anti\near_basket\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
Write-Host "Transfer this file to your phone and install it!" -ForegroundColor Green
