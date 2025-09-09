@echo off
REM ============================================================================
REM SYNOPSIS
REM    Launches the uninstallation process for WindowsOrchestrator.
REM
REM DESCRIPTION
REM    This script serves as a simple and reliable entry point for the user.
REM    Its sole role is to launch the 'uninstall.ps1' PowerShell script, which
REM    contains all the uninstallation logic and handles its own request
REM    for Administrator rights (UAC).
REM
REM    The use of comments and messages in simple English (without
REM    accents) is intentional to ensure compatibility with
REM    the command interpreter (cmd.exe) regardless of the file's encoding.
REM
REM USAGE
REM    Double-click this file to start the uninstallation.
REM ============================================================================

REM The CLS command clears the screen for a clean display.
CLS

ECHO #############################################################
ECHO #          Uninstaller - WindowsOrchestrator              #
ECHO #############################################################
ECHO.
ECHO Starting the uninstallation...
ECHO.
ECHO A privilege elevation request (UAC) will appear.
ECHO Please accept it to continue.
ECHO.
PAUSE

REM --- Launching the PowerShell script ---

REM The uninstallation logic is entirely delegated to the PowerShell script.
REM It is the one that contains the self-elevation mechanism to request admin rights.

REM powershell.exe
REM    - Executes the PowerShell interpreter.
REM
REM -NoProfile
REM    - Ensures a fast startup and a predictable execution environment,
REM      by ignoring the user's personal profile scripts.
REM
REM -ExecutionPolicy Bypass
REM    - Guarantees that the script will run, even if the system's
REM      security policies are restrictive.
REM
REM -File "%~dp0management\uninstall.ps1"
REM    - Specifies the script to run. Using the %~dp0 variable
REM      (which represents the folder of this .bat) makes the path portable and reliable.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0management\uninstall.ps1"

ECHO.
ECHO The uninstallation script is finished.
PAUSE
