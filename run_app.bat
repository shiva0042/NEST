@echo off
echo ===================================================
echo   Setting up Near Basket Application
echo ===================================================
echo.

echo [1/2] Installing dependencies (including shared_preferences)...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo Error installing dependencies. Please ensure Flutter is installed and in your PATH.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/2] Launching App in Chrome...
echo Note: If Chrome is not found, try 'flutter run -d edge' manually.
call flutter run -d chrome

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo App failed to launch. Trying Web Server mode...
    call flutter run -d web-server
)

pause
