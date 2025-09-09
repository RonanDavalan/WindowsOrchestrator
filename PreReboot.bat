:: =================================================================================
:: SCRIPT DE LANCEMENT POUR CLOSE-APPBYTITLE.PS1
:: =================================================================================
::
:: DESCRIPTION:
:: Ce script batch sert de "lanceur" universel et fiable pour le script PowerShell
:: compagnon "Close-AppByTitle.ps1". Son but est de s'assurer que le script
:: PowerShell puisse s'exécuter correctement, quelles que soient les configurations
:: de sécurité de la machine cible.
::
:: UTILISATION:
:: Placez ce fichier .bat dans le MÊME répertoire que le fichier .ps1.
:: Exécutez ce .bat pour lancer l'opération de fermeture de l'application.
::
:: =================================================================================

:: La commande "@echo off" est une pratique standard qui nettoie l'affichage.
:: Elle empêche la console d'afficher chaque commande avant de l'exécuter,
:: rendant la sortie plus propre et lisible pour l'utilisateur.
@echo off

:: Le commentaire ci-dessous décrit l'action principale du script.
REM Lance le script PowerShell qui ferme l'application en la ciblant par son titre.

:: --- Explication détaillée de la commande ci-dessous ---
::
:: powershell.exe
::   L'exécutable qui lance une session PowerShell.
::
:: -NoProfile
::   Argument crucial pour la fiabilité. Il empêche PowerShell de charger des scripts
::   de profil utilisateur. Cela garantit un démarrage plus rapide et un environnement
::   d'exécution "propre", sans risque d'interférence avec d'éventuelles fonctions
::   ou alias personnalisés par l'utilisateur.
::
:: -ExecutionPolicy Bypass
::   C'est la clé pour rendre ce lanceur universel. Il contourne la politique d'exécution
::   de PowerShell pour cette seule session. Sans cela, le script pourrait être bloqué
::   sur des machines où la politique de sécurité est restrictive (ce qui est le cas par défaut).
::
:: -File "%~dp0Close-AppByTitle.ps1"
::   Indique à PowerShell d'exécuter le script spécifié.
::   - "%~dp0" est une variable spéciale dans les scripts batch qui se traduit par :
::     "le lecteur (d) et le chemin (p) du répertoire où se trouve ce script batch (%0)".
::   - En clair, cela signifie : "trouve le fichier 'Close-AppByTitle.ps1' qui est
::     situé dans le MÊME dossier que moi". Cela rend le duo de scripts
::     entièrement portable : vous pouvez déplacer le dossier n'importe où,
::     et le lanceur trouvera toujours son script PowerShell.
::
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Close-AppByTitle.ps1"
