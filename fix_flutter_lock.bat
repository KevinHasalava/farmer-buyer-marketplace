@echo off
echo ========================================================
echo   Clearing Flutter process locks and build directory
echo ========================================================
echo.

echo 1. Terminating background Dart processes...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM flutter.bat /T 2>nul
timeout /t 1 /nobreak >nul

echo 2. Removing build folder...
if exist "build" (
    rmdir /s /q "build" 2>nul
    if exist "build" (
        powershell -Command "Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue"
    )
)

echo.
echo ========================================================
echo   Success! Locks cleared. You can run 'flutter run' now.
echo ========================================================
