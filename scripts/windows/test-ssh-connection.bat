@echo off
setlocal enabledelayedexpansion

REM Check if host name provided
if "%~1"=="" (
    echo Usage: test-ssh-connection.bat ^<host_name^>
    echo Example: test-ssh-connection.bat github-personal
    echo.
    echo Testing all configured hosts...
    echo.
    set CONFIG_FILE=%USERPROFILE%\.ssh\config
    if exist "%CONFIG_FILE%" (
        REM Extract all Host entries from config
        for /f "tokens=2" %%h in ('findstr /R /C:"^Host " "%CONFIG_FILE%"') do (
            call :test_host %%h
        )
    ) else (
        echo No SSH config file found.
        echo Please run: scripts\windows\update-ssh-config.bat
    )
    exit /b 0
)

set HOST_NAME=%~1
call :test_host %HOST_NAME%
exit /b 0

:test_host
set TEST_HOST=%~1
echo Testing connection to %TEST_HOST%...

REM Capture output to temp file and check for success message
set TEMP_FILE=%TEMP%\ssh_test_%RANDOM%.txt
ssh -T git@%TEST_HOST% >"%TEMP_FILE%" 2>&1

REM Show the output
type "%TEMP_FILE%"

REM Check for success messages (GitHub returns exit code 1 even on success)
findstr /I "successfully authenticated" "%TEMP_FILE%" >nul
if not errorlevel 1 (
    echo.
    echo Connection successful!
    echo.
    del "%TEMP_FILE%" >nul 2>&1
    exit /b 0
)

findstr /I "does not provide shell access" "%TEMP_FILE%" >nul
if not errorlevel 1 (
    echo.
    echo Connection successful!
    echo.
    del "%TEMP_FILE%" >nul 2>&1
    exit /b 0
)

REM If we get here, connection failed
echo.
echo Connection failed or key not added to GitHub yet.
echo.
del "%TEMP_FILE%" >nul 2>&1
exit /b 0

endlocal

