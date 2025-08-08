@echo off
REM Sets the code page to support international characters
CHCP 1252 > NUL
CLS

REM --- Language argument handling ---
SET "LANG_ARG="
IF /I "%~1" == "-l" SET "LANG_ARG=%~2"
REM --- End of block ---

ECHO #############################################################
ECHO #          Uninstaller - WindowsAutoConfig                #
ECHO #############################################################
ECHO.
ECHO Starting the uninstallation of AllSysConfig...
ECHO.
ECHO A privilege elevation prompt (UAC) will appear. Please accept it.
ECHO.
PAUSE

REM This batch file now ONLY calls the PowerShell script.
REM The PowerShell script itself will handle the elevation request.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0management\uninstall.ps1" -LanguageOverride "%LANG_ARG%"

ECHO.
ECHO The uninstallation script has finished.
PAUSE