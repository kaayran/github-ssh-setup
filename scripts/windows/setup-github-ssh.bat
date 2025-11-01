@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   GitHub SSH Setup Wizard (Windows)
echo ========================================
echo.

REM Get account name
set /p ACCOUNT_NAME="Enter account name (e.g., personal, work): "
if "!ACCOUNT_NAME!"=="" (
    echo Error: Account name is required.
    exit /b 1
)

REM Get email
set /p EMAIL="Enter your email address: "
if "!EMAIL!"=="" (
    echo Error: Email is required.
    exit /b 1
)

REM Get host name (optional)
set /p HOST_NAME="Enter host name for SSH config (default: github-%ACCOUNT_NAME%): "
if "!HOST_NAME!"=="" (
    set HOST_NAME=github-%ACCOUNT_NAME%
)

echo.
echo ========================================
echo   Step 1: Generating SSH Key
echo ========================================
echo.

REM Call setup-ssh-key script
call "%~dp0setup-ssh-key.bat" %ACCOUNT_NAME% "%EMAIL%"

if errorlevel 1 (
    echo.
    echo Setup failed at key generation step.
    exit /b 1
)

echo.
echo ========================================
echo   Step 2: Copying Public Key
echo ========================================
echo.

REM Copy public key
call "%~dp0copy-public-key.bat" %ACCOUNT_NAME%

echo.
echo ========================================
echo   Step 3: Updating SSH Config
echo ========================================
echo.

REM Update SSH config
call "%~dp0update-ssh-config.bat" %ACCOUNT_NAME% %HOST_NAME%

if errorlevel 1 (
    echo.
    echo Setup failed at config update step.
    exit /b 1
)

echo.
echo ========================================
echo   Next Steps (Manual)
echo ========================================
echo.
echo 1. Go to GitHub: https://github.com/settings/keys
echo 2. Click "New SSH key"
echo 3. Paste the public key (already in clipboard)
echo 4. Give it a title and save
echo.
echo After adding the key to GitHub, test the connection:
echo   scripts\windows\test-ssh-connection.bat %HOST_NAME%
echo.
echo When cloning repositories, use:
echo   git clone git@%HOST_NAME%:username/repo.git
echo.

endlocal

