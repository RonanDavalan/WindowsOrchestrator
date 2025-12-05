@echo off
CLS
PUSHD "%~dp0"

REM Lancement du lanceur intelligent pour la desinstallation
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "management\Launch-Uninstall.ps1"

POPD
EXIT /B
