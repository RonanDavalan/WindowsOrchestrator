@echo off
SETLOCAL EnableDelayedExpansion

REM ============================================================================
REM  LAUNCHER DYNAMIQUE - WINDOWSORCHESTRATOR v1.73
REM  Lit config.ini, nettoie les guillemets et lance l'exécutable.
REM ============================================================================

SET "SCRIPT_DIR=%~dp0"
SET "CONFIG_FILE=%SCRIPT_DIR%..\\config.ini"
REM APP_ROOT est le dossier parent de 'management'
SET "APP_ROOT=%SCRIPT_DIR%..\..\.."

IF NOT EXIST "%CONFIG_FILE%" (
    ECHO ERREUR: config.ini introuvable : %CONFIG_FILE%
    PAUSE & EXIT /B 1
)

SET "APP_NAME="
FOR /F "tokens=1,2 delims==" %%A IN ('findstr /I /B "ProcessToMonitor=" "%CONFIG_FILE%"') DO (
    SET "VALUE=%%B"
    REM Suppression des guillemets et des espaces
    SET "VALUE=!VALUE:\"=!"
    SET "APP_NAME=!VALUE: =!"
)

IF "%APP_NAME%"=="" (
    ECHO ERREUR: ProcessToMonitor non defini dans config.ini
    PAUSE & EXIT /B 1
)

SET "TARGET_EXE=%APP_ROOT%\\%APP_NAME%.exe"

IF EXIST "%TARGET_EXE%" (
    start "Lancement %APP_NAME%" /MIN /D "%APP_ROOT%" "%TARGET_EXE%" tf 00 W
) ELSE (
    ECHO ERREUR: Executable introuvable : %TARGET_EXE%
    PAUSE
)

ENDLOCAL
EXIT /B
