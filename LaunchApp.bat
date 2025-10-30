@echo off
REM Ce script est conçu pour être portable.
REM Il utilise sa propre position (%~dp0) pour trouver l'exécutable.

REM %~dp0 = Le dossier où se trouve ce script (.bat).
REM %~dp0.. = Le dossier PARENT de ce script.

REM On lance l'application en spécifiant son chemin relatif
REM ET son répertoire de travail relatif (/D) pour qu'elle trouve ses fichiers.
start "Lancement Allv023-05" /D "%~dp0.." "Allv023-05.exe" tb 00 W