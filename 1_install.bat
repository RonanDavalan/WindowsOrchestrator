:: =================================================================================
:: INSTALLATION WIZARD - WINDOWSORCHESTRATOR
:: =================================================================================
::
:: DESCRIPTION:
:: This batch script guides the user through an installation process
:: in two steps: configuration via a graphical wizard, then the installation
:: of system tasks which requires elevated privileges (UAC).
::
:: =================================================================================

:: The "@echo off" command prevents the commands themselves from being displayed in the console.
@echo off

:: --- Console Preparation ---

:: The CHCP (Change Code Page) command prepares the console to correctly display
:: special characters and accents.
:: 65001 corresponds to the UTF-8 encoding, which is the modern and most compatible standard.
:: "> NUL" hides the confirmation message ("Active code page: 65001").
CHCP 65001 > NUL

:: CLS (Clear Screen) clears the console's content for a clean display.
CLS


:: --- Step 1: Configuration (via the graphical wizard) ---

ECHO #############################################################
ECHO #         Installation Wizard - WindowsOrchestrator         #
ECHO #############################################################
ECHO.
ECHO --- Step 1 of 2: Configuration ---
ECHO.
ECHO Launching the graphical wizard. Please fill in the
ECHO necessary parameters then click "Save".
ECHO If you wish to skip this step and use the existing
ECHO config.ini file, you can close the wizard.
ECHO.
:: PAUSE interrupts the script and waits for the user to press a key.
:: This is essential to ensure that the user has read the instructions.
PAUSE

:: Launching the first PowerShell script (firstconfig.ps1).
:: This script does not need administrator rights, so it can be launched directly.
:: - "%~dp0" is a magic variable that refers to the folder where this .bat script is located.
::   This ensures that the path to "management\firstconfig.ps1" is always correct.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0management\firstconfig.ps1"

ECHO.
ECHO Configuration finished (or skipped).
ECHO.
:: --- Step 2: Installation of System Tasks (with elevation) ---
ECHO --- Step 2 of 2: Installation of system tasks ---
ECHO.
ECHO Starting the installation...
ECHO.
ECHO WARNING: A Windows security window (UAC) will appear
ECHO to request administrator rights.
ECHO Please click "Yes" to continue.
ECHO.
PAUSE

:: --- THE ELEVATION MECHANISM ---
:: This is the most important part. We cannot request elevation directly
:: from a batch file. So we use a two-step trick:
:: 1. We store the full PowerShell command in an environment variable (PS_ARGS).
set "PS_ARGS=-NoProfile -ExecutionPolicy Bypass -File "%~dp0management\install.ps1""
:: 2. We launch a first instance of PowerShell (without admin rights) whose sole purpose
::    (-Command) is to launch a SECOND instance of PowerShell.
::    It is this second instance that we elevate using the "-Verb RunAs" parameter.
::    This is what triggers the display of the UAC prompt window.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList $env:PS_ARGS -Verb RunAs}"

ECHO.
ECHO The installation process is finished.
ECHO Check the PowerShell installation window for details.
PAUSE
