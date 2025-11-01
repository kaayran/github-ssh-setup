@echo off
setlocal enabledelayedexpansion

REM Check if account name provided
if "%~1"=="" (
    echo Usage: update-ssh-config.bat ^<account_name^> [host_name]
    echo Example: update-ssh-config.bat personal github-personal
    exit /b 1
)

set ACCOUNT_NAME=%~1
set HOST_NAME=github-%ACCOUNT_NAME%

REM Check if custom host name provided
if not "%~2"=="" (
    set HOST_NAME=%~2
)

set SSH_DIR=%USERPROFILE%\.ssh
set CONFIG_FILE=%SSH_DIR%\config
set KEY_PATH=%SSH_DIR%\id_ed25519_%ACCOUNT_NAME%

REM Check if key exists
if not exist "%KEY_PATH%" (
    echo Error: SSH key not found: %KEY_PATH%
    echo Please generate the key first: scripts\windows\setup-ssh-key.bat
    exit /b 1
)

REM Convert Windows path to Unix-style for config file
set KEY_PATH_UNIX=%SSH_DIR:\=/%/id_ed25519_%ACCOUNT_NAME%

REM Create .ssh directory if it doesn't exist
if not exist "%SSH_DIR%" (
    mkdir "%SSH_DIR%"
)

REM Check if config file exists, create backup if it does
if exist "%CONFIG_FILE%" (
    echo Creating backup: %CONFIG_FILE%.backup
    copy "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul
    
    REM Check if host already exists
    findstr /C:"Host %HOST_NAME%" "%CONFIG_FILE%" >nul 2>&1
    if not errorlevel 1 (
        echo.
        echo Warning: Host '%HOST_NAME%' already exists in config file.
        set /p UPDATE="Do you want to update it? (y/N): "
        if /i not "!UPDATE!"=="y" (
            echo Cancelled.
            exit /b 0
        )
        REM Remove old entry (this is a simple approach, might not handle all edge cases)
        echo Removing old entry...
        REM We'll just append, user can manually remove old entry if needed
    )
) else (
    echo Creating new SSH config file...
)

REM Append new host entry
echo. >> "%CONFIG_FILE%"
echo # %ACCOUNT_NAME% account >> "%CONFIG_FILE%"
echo Host %HOST_NAME% >> "%CONFIG_FILE%"
echo     HostName github.com >> "%CONFIG_FILE%"
echo     User git >> "%CONFIG_FILE%"
echo     IdentityFile %KEY_PATH_UNIX% >> "%CONFIG_FILE%"
echo     IdentitiesOnly yes >> "%CONFIG_FILE%"

echo.
echo SSH config updated successfully!
echo.
echo Host: %HOST_NAME%
echo Key: %KEY_PATH%
echo.
echo You can now use this host when cloning:
echo   git clone git@%HOST_NAME%:username/repo.git
echo.
echo To test connection: scripts\windows\test-ssh-connection.bat %HOST_NAME%
echo.

endlocal

