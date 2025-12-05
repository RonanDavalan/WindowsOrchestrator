@echo off
CLS
PUSHD "%~dp0"

REM 1. Configuration (Interface Graphique)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "management\firstconfig.ps1"

REM 2. Arret si annulation (Code 1)
IF ERRORLEVEL 1 GOTO :END_SCRIPT

REM 3. Lancement de l'installation (Via le Lanceur Intelligent)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "management\Launch-Install.ps1"

:END_SCRIPT
POPD
EXIT /B
