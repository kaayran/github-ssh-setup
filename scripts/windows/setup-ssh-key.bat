@echo off
setlocal enabledelayedexpansion

REM Check if SSH directory exists, create if not
if not exist "%USERPROFILE%\.ssh" (
    echo Creating .ssh directory...
    mkdir "%USERPROFILE%\.ssh"
)

REM Get account name (from parameter or prompt)
if not "%~1"=="" (
    set ACCOUNT_NAME=%~1
) else (
    set /p ACCOUNT_NAME="Enter account name (e.g., personal, work): "
)

if "!ACCOUNT_NAME!"=="" (
    echo Error: Account name is required.
    exit /b 1
)

REM Get email (from parameter or prompt)
if not "%~2"=="" (
    set EMAIL=%~2
) else (
    set /p EMAIL="Enter your email address: "
)

if "!EMAIL!"=="" (
    echo Error: Email is required.
    exit /b 1
)

REM Generate key filename
set KEY_NAME=id_ed25519_%ACCOUNT_NAME%
set KEY_PATH=%USERPROFILE%\.ssh\%KEY_NAME%

REM Check if key already exists
if exist "%KEY_PATH%" (
    echo.
    echo Warning: Key file already exists: %KEY_PATH%
    set /p OVERWRITE="Do you want to overwrite it? (y/N): "
    if /i not "!OVERWRITE!"=="y" (
        echo Cancelled.
        exit /b 0
    )
)

REM Generate SSH key
echo.
echo Generating SSH key...
ssh-keygen -t ed25519 -C "%EMAIL%" -f "%KEY_PATH%" -N ""

if errorlevel 1 (
    echo.
    echo Error: Failed to generate SSH key.
    exit /b 1
)

echo.
echo SSH key generated successfully!
echo.
echo Key location: %KEY_PATH%
echo Public key: %KEY_PATH%.pub
echo.
echo Next steps:
echo 1. Copy your public key: scripts\windows\copy-public-key.bat %ACCOUNT_NAME%
echo 2. Add it to GitHub: Settings ^> SSH and GPG keys ^> New SSH key
echo 3. Update SSH config: scripts\windows\update-ssh-config.bat %ACCOUNT_NAME%
echo.

endlocal

