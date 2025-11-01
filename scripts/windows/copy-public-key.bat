@echo off
setlocal enabledelayedexpansion

REM Check if account name provided
if "%~1"=="" (
    echo Usage: copy-public-key.bat ^<account_name^>
    echo Example: copy-public-key.bat personal
    exit /b 1
)

set ACCOUNT_NAME=%~1
set KEY_PATH=%USERPROFILE%\.ssh\id_ed25519_%ACCOUNT_NAME%.pub

REM Check if key exists
if not exist "%KEY_PATH%" (
    echo Error: Public key not found: %KEY_PATH%
    echo.
    echo Available keys:
    dir /b "%USERPROFILE%\.ssh\*.pub" 2>nul
    exit /b 1
)

REM Copy to clipboard
type "%KEY_PATH%" | clip

echo.
echo Public key copied to clipboard!
echo.
echo Key content:
type "%KEY_PATH%"
echo.
echo.
echo Next step: Go to GitHub ^> Settings ^> SSH and GPG keys ^> New SSH key
echo Paste the key and save it.
echo.

endlocal

