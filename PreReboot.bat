@echo off

REM Lance le script PowerShell qui ferme l'application en la ciblant par son titre.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Close-AppByTitle.ps1"
