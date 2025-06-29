@echo off
CHCP 65001 > NUL
REM This script launches the PowerShell uninstallation script, requesting administrator rights.
echo Launching the uninstallation of AllSysConfig...
echo An elevation of privileges request (UAC) will appear. Please accept it.

REM Command to re-launch the PowerShell script with admin rights
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \""%~dp0management\uninstall.ps1\""' -Verb RunAs}"

echo.
echo The uninstallation script is complete.
pause