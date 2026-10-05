@echo off
echo ========================================================
echo   Clearing Flutter process locks and build directory
echo ========================================================
echo.

echo 1. Terminating background Dart and Flutter processes...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM flutter.bat /T 2>nul
timeout /t 1 /nobreak >nul

echo 2. Removing locked build and ephemeral folders...
if exist "build" rmdir /s /q "build" 2>nul
if exist "windows\flutter\ephemeral" rmdir /s /q "windows\flutter\ephemeral" 2>nul
if exist "macos\Flutter\ephemeral" rmdir /s /q "macos\Flutter\ephemeral" 2>nul
if exist "ios\Flutter\ephemeral" rmdir /s /q "ios\Flutter\ephemeral" 2>nul
if exist ".dart_tool" rmdir /s /q ".dart_tool" 2>nul

echo 3. Restoring dependencies...
call flutter pub get

echo.
echo ========================================================
echo   Success! Locks cleared. You can run 'flutter run -d chrome' now.
echo ========================================================
