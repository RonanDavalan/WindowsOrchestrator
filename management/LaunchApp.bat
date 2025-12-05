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
REM            LaunchApp.bat  <-- CE SCRIPT
REM
REM USAGE
REM    Ce script est appelé par l'orchestrateur Windows.
REM
REM NOTES
REM    Auteur: Ronan Davalan
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
REM   tb : Lance l'application sur le module "Tableau de Bord" principal.
REM   00 : Identifiant du site ou de la station de travail (ex: "00" pour le site principal).
REM   W  : Spécifie le mode d'affichage ou de fonctionnement (ex: "W" pour Windowed/Fenêtré).


REM --- GESTION DU DÉMARRAGE MINIMISÉ ---
REM Le paramètre /MIN ci-dessous demande à Windows de lancer l'application
REM directement dans la barre des tâches, sans afficher sa fenêtre principale.
REM
REM Pour que l'application s'ouvre normalement (fenêtre visible),
REM il suffit de **supprimer /MIN** de la ligne de commande ci-dessous.


REM --- EXÉCUTION ---
REM CORRECTION : Les chemins ont été ajustés pour refléter que ce script est à la racine du projet
REM et que l'application se trouve dans un sous-dossier, assurant que le répertoire de travail est correct.
rem  start "Lancement Allv023-05" /MIN /D "%~dp0..\.." "%~dp0..\..\Allv023-05.exe" tb 00 W

IF EXIST "%~dp0..\..\..\MyApp.exe" (
    start "Lancement MyApp" /MIN /D "%~dp0..\..\.." "%~dp0..\..\..\MyApp.exe"
) ELSE (
    ECHO ERREUR : L'exécutable est introuvable dans le dossier parent.
    PAUSE
)

exit
