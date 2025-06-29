@echo off
CHCP 65001 > NUL
REM This script launches the configuration wizard, then the installer with elevated privileges.

cls
echo #############################################################
echo #    Installation Wizard - WindowsAutoConfig              #
echo #############################################################
echo.
echo --- Step 1 of 2: Configuration ---
echo.
echo Launching the graphical wizard. Please fill in the
echo required settings then click "Save".
echo If you wish to skip this step and use the existing config.ini,
echo you can close the wizard when it appears.
echo.
pause

REM Launching firstconfig.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0management\firstconfig.ps1"


echo.
echo Configuration finished via wizard (or skipped).
echo.
echo --- Step 2 of 2: System Task Installation ---
echo.
echo Starting the system task installation...
echo.
echo WARNING: A Windows security prompt (UAC) will
echo appear to request administrator rights.
echo Please click "Yes" to continue.
echo.
pause

REM Runs the PowerShell installation script, requesting admin rights.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0management\install.ps1\"' -Verb RunAs}"

echo.
echo The task installation process is complete.
echo Check the PowerShell installation script window for details and potential errors.
pause