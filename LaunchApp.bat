@echo off
REM ============================================================================
REM SYNOPSIS
REM    Lance l'application "Allv023-05" de manière portable.
REM
REM DESCRIPTION
REM    Ce script de lancement est conçu pour être placé dans un sous-dossier
REM    à côté de l'exécutable principal. Il garantit que l'application
REM    démarre avec le bon répertoire de travail, lui permettant ainsi de trouver
REM    ses fichiers de configuration, DLLs, et autres ressources nécessaires.
REM
REM    Structure de dossiers attendue :
REM    \Application\
REM        Allv023-05.exe
REM        (autres fichiers de l'app)
REM        \Scripts\
REM            lancer_application.bat  <-- CE SCRIPT
REM
REM USAGE
REM    Double-cliquez simplement sur ce fichier .bat pour lancer l'application.
REM
REM NOTES
REM    Auteur: [Votre Nom]
REM ============================================================================

REM --- EXPLICATION DES VARIABLES ET PARAMÈTRES ---

REM La variable %~dp0 représente le chemin complet du dossier où se trouve
REM ce script (.bat). C'est la clé de la portabilité.
REM Exemple : C:\Users\Moi\Desktop\Application\Scripts\

REM En ajoutant '..', on remonte au dossier PARENT.
REM Exemple : C:\Users\Moi\Desktop\Application\

REM Le paramètre /D de la commande START est crucial. Il définit le "répertoire
REM de travail". Sans cela, l'application pourrait ne pas trouver ses propres
REM fichiers si le script est lancé depuis un autre emplacement.


REM --- PARAMÈTRES DE L'APPLICATION (Allv023-05.exe) ---
REM Les arguments passés à l'exécutable sont :
REM   tb : [Description du paramètre 'tb']
REM   00 : [Description du paramètre '00']
REM   W  : [Description du paramètre 'W']


REM --- EXÉCUTION ---
start "Lancement Allv023-05" /D "%~dp0.." "%~dp0..\..\Allv023-05.exe" tb 00 W
