@echo off
set FLUTTER_BIN=d:\vs\anti\flutter_sdk\bin\flutter.bat

echo ===================================================
echo   Running Near Basket with Local Flutter SDK
echo ===================================================
echo.

if not exist "%FLUTTER_BIN%" (
    echo Flutter SDK not found at %FLUTTER_BIN%
    echo Please insure the SDK was cloned correctly.
    echo Trying to use global 'flutter' command...
    set FLUTTER_BIN=flutter
)

echo [1/3] Cleaning build...
call "%FLUTTER_BIN%" clean

echo.
echo [2/3] Getting dependencies...
call "%FLUTTER_BIN%" pub get

echo.
echo [3/3] Launching Web Server...
echo.
echo Please wait for the application to compile...
echo When ready, it will show a link like http://localhost:PORT
echo.
call "%FLUTTER_BIN%" run -d web-server --web-port=8080

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Launch failed on port 8080. Trying random port...
    call "%FLUTTER_BIN%" run -d web-server --web-port=0
)

pause
