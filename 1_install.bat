@echo off
REM Sets the code page to support international characters
CHCP 1252 > NUL
CLS

REM --- Language argument handling ---
SET "LANG_ARG="
IF /I "%~1" == "-l" SET "LANG_ARG=%~2"
REM --- End of block ---

ECHO #############################################################
ECHO #           Installation Wizard - WindowsAutoConfig         #
ECHO #############################################################
ECHO.
ECHO --- Step 1 of 2: Configuration ---
ECHO.
ECHO Launching the graphical wizard. Please fill in the required
ECHO parameters and then click "Save".
ECHO If you wish to skip this step and use the existing config.ini,
ECHO you can close the wizard when it appears.
ECHO.
PAUSE

REM Launch firstconfig.ps1, passing the language argument if defined
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0management\firstconfig.ps1" "%LANG_ARG%"

ECHO.
ECHO Configuration finished via wizard (or skipped).
ECHO.
ECHO --- Step 2 of 2: System Task Installation ---
ECHO.
ECHO Starting the installation of system tasks...
ECHO.
ECHO WARNING: A Windows security prompt (UAC) will appear
ECHO to request administrator rights.
ECHO Please click "Yes" to continue.
ECHO.
PAUSE

REM Launch the PowerShell installation script, requesting admin rights.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0management\install.ps1\"' -Verb RunAs}"

ECHO.
ECHO The task installation process is complete.
ECHO Check the PowerShell installation window for details and potential errors.
PAUSE