@echo off
setlocal enabledelayedexpansion

REM Define log file
set LOGFILE=install_log.txt

echo ===================================================== > "%LOGFILE%"
echo Software Installation Log - %DATE% %TIME% >> "%LOGFILE%"
echo ===================================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

REM Check if the software list file exists
if not exist "software_list.txt" (
    echo [ERROR] software_list.txt does not exist!
    echo Please create the file and run the script again.
    echo [ERROR] software_list.txt missing - %DATE% %TIME% >> "%LOGFILE%"
    exit /b 1
)

REM Read software list line by line and install each software
for /f "usebackq tokens=*" %%a in ("software_list.txt") do (
    echo.
    echo =====================================================
    echo Checking software: %%a
    echo =====================================================

    REM Actually check if the software is installed by parsing output
    set "found="
    for /f "skip=1 tokens=* delims=" %%i in ('winget list --id %%a 2^>nul') do (
        echo %%i | findstr /i "%%a" >nul
        if not errorlevel 1 set found=1
    )

    if defined found (
        echo [SKIP] %%a is already installed.
        echo [SKIP] %%a already installed - %DATE% %TIME% >> "%LOGFILE%"
    ) else (
        echo Installing %%a ...
        echo Installing %%a - %DATE% %TIME% >> "%LOGFILE%"
        winget install -e --id %%a --accept-source-agreements --accept-package-agreements >> "%LOGFILE%" 2>&1
        if errorlevel 1 (
            echo [ERROR] Failed to install %%a
            echo [ERROR] %%a failed - %DATE% %TIME% >> "%LOGFILE%"
        ) else (
            echo [SUCCESS] Installed %%a successfully
            echo [SUCCESS] %%a installed - %DATE% %TIME% >> "%LOGFILE%"
        )
    )
)

echo.
echo =====================================================
echo All installations attempted. Please review messages above.
echo Log saved to %LOGFILE%
echo =====================================================
pause
