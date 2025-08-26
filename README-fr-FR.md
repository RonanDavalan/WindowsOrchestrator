# L'orchestrateur de Windows

[🇺🇸 English](README.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

L'orchestrateur de Windows est un ensemble de scripts qui utilise les Tâches Planifiées de Windows pour exécuter des scripts PowerShell (`.ps1`). Un assistant graphique (`firstconfig.ps1`) permet à l'utilisateur de générer un fichier de configuration `config.ini`. Les scripts principaux (`config_systeme.ps1`, `config_utilisateur.ps1`) lisent ce fichier pour effectuer des actions spécifiques :
*   Modification de clés du Registre Windows.
*   Exécution de commandes système (`powercfg`, `shutdown`).
*   Gestion de services Windows (changement du type de démarrage et arrêt du service `wuauserv`).
*   Démarrage ou arrêt de processus applicatifs définis par l'utilisateur.
*   Envoi de requêtes HTTP POST vers un service de notification Gotify via la commande `Invoke-RestMethod`.

Les scripts détectent la langue du système d'exploitation de l'utilisateur et chargent les chaînes de caractères (pour les logs, l'interface graphique et les notifications) depuis les fichiers `.psd1` situés dans le répertoire `i18n`.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Visitez la page d'accueil officielle pour une présentation complète !</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Licence-GPLv3-blue.svg" alt="Licence">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Version PowerShell">
  <img src="https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg" alt="Statut">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="OS">
  <img src="https://img.shields.io/badge/Support-11_Langues-orange.svg" alt="Support">
  <img src="https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg" alt="Contributions">
</p>

---

## Actions des Scripts

Le script `1_install.bat` exécute `management\install.ps1`, qui crée deux Tâches Planifiées principales.
*   La première, **`WindowsOrchestrator-SystemStartup`**, exécute `config_systeme.ps1` au démarrage de Windows.
*   La seconde, **`WindowsOrchestrator-UserLogon`**, exécute `config_utilisateur.ps1` à l'ouverture de session de l'utilisateur.

En fonction des paramètres du fichier `config.ini`, les scripts exécutent les actions suivantes :

*   **Gestion de la connexion automatique :**
    *   `Action du script :` Le script écrit la valeur `1` dans la clé de Registre `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon`.
    *   `Action de l'utilisateur :` Pour que cette fonction soit opérationnelle, l'utilisateur doit au préalable enregistrer le mot de passe dans le Registre. Le script ne gère pas cette information. L'utilitaire **Sysinternals AutoLogon** est un outil externe qui peut effectuer cette action.

*   **Modification des paramètres d'alimentation :**
    *   Exécute les commandes `powercfg /change standby-timeout-ac 0` et `powercfg /change hibernate-timeout-ac 0` pour désactiver la mise en veille.
    *   Exécute la commande `powercfg /change monitor-timeout-ac 0` pour désactiver la mise en veille de l'écran.
    *   Écrit la valeur `0` dans la clé de Registre `HiberbootEnabled` pour désactiver le Démarrage Rapide.

*   **Gestion des Mises à jour Windows :**
    *   Écrit la valeur `1` dans les clés de Registre `NoAutoUpdate` et `NoAutoRebootWithLoggedOnUsers`.
    *   Change le type de démarrage du service Windows `wuauserv` en `Disabled` et exécute la commande `Stop-Service` sur celui-ci.

*   **Planification d'un redémarrage quotidien :**
    *   Crée une Tâche Planifiée nommée `WindowsOrchestrator-SystemScheduledReboot` qui exécute `shutdown.exe /r /f /t 60` à l'heure définie.
    *   Crée une Tâche Planifiée nommée `WindowsOrchestrator-SystemPreRebootAction` qui exécute une commande définie par l'utilisateur avant le redémarrage.

*   **Journalisation des actions :**
    *   Écrit des lignes horodatées dans des fichiers `.txt` situés dans le dossier `Logs`.
    *   Une fonction `Rotate-LogFile` renomme et archive les fichiers journaux existants. Le nombre de fichiers à conserver est défini par les clés `MaxSystemLogsToKeep` et `MaxUserLogsToKeep` dans `config.ini`.

*   **Envoi de notifications Gotify :**
    *   Si la clé `EnableGotify` est sur `true` dans `config.ini`, les scripts envoient une requête HTTP POST à l'URL spécifiée.
    *   La requête contient une charge utile JSON avec un titre et un message. Le message est une liste des actions effectuées et des erreurs rencontrées.

## Prérequis

- **Système d'exploitation** : Windows 10 ou Windows 11. Le code source contient la directive `#Requires -Version 5.1` pour les scripts PowerShell.
- **Droits** : L'utilisateur doit accepter les demandes d'élévation de privilèges (UAC) lors de l'exécution de `1_install.bat` et `2_uninstall.bat`. Cette action est nécessaire pour autoriser les scripts à créer des tâches planifiées et à modifier les clés de Registre au niveau système.
- **Connexion Automatique (Auto-Login)** : Si l'utilisateur active cette option, il doit utiliser un outil externe comme **Microsoft Sysinternals AutoLogon** pour enregistrer son mot de passe dans le Registre.

## Installation et Première Configuration

L'utilisateur exécute le fichier **`1_install.bat`**.

1.  **Configuration (`firstconfig.ps1`)**
    *   Le script `management\firstconfig.ps1` s'exécute et affiche une interface graphique.
    *   Si le fichier `config.ini` n'existe pas, il est créé à partir du modèle `management\defaults\default_config.ini`.
    *   S'il existe, le script demande à l'utilisateur s'il souhaite le remplacer par le modèle.
    *   L'utilisateur saisit les paramètres. En cliquant sur "Enregistrer et Fermer", le script écrit les valeurs dans `config.ini`.

2.  **Installation des Tâches (`install.ps1`)**
    *   Après la fermeture de l'assistant, `1_install.bat` exécute `management\install.ps1` en demandant une élévation de privilèges.
    *   Le script `install.ps1` crée les deux Tâches Planifiées :
        *   **`WindowsOrchestrator-SystemStartup`** : Exécute `config_systeme.ps1` au démarrage de Windows avec le compte `NT AUTHORITY\SYSTEM`.
        *   **`WindowsOrchestrator-UserLogon`** : Exécute `config_utilisateur.ps1` à l'ouverture de session de l'utilisateur qui a lancé l'installation.
    *   Pour appliquer la configuration sans attendre un redémarrage, `install.ps1` exécute `config_systeme.ps1` puis `config_utilisateur.ps1` une seule fois à la fin du processus.

## Utilisation et Configuration Post-Installation

Toute modification de la configuration après l'installation se fait via le fichier `config.ini`.

### 1. Modification Manuelle du fichier `config.ini`

*   **Action de l'utilisateur :** L'utilisateur ouvre le fichier `config.ini` avec un éditeur de texte et modifie les valeurs souhaitées.
*   **Action des scripts :**
    *   Les modifications de la section `[SystemConfig]` sont lues et appliquées par `config_systeme.ps1` **au prochain redémarrage de l'ordinateur**.
    *   Les modifications de la section `[Process]` sont lues et appliquées par `config_utilisateur.ps1` **à la prochaine ouverture de session de l'utilisateur**.

### 2. Utilisation de l'Assistant Graphique

*   **Action de l'utilisateur :** L'utilisateur exécute à nouveau `1_install.bat`. L'interface graphique s'ouvre, pré-remplie avec les valeurs actuelles de `config.ini`. L'utilisateur modifie les paramètres et clique sur "Enregistrer et Fermer".
*   **Action du script :** Le script `firstconfig.ps1` écrit les nouvelles valeurs dans `config.ini`.
*   **Contexte d'utilisation :** Après la fermeture de l'assistant, l'invite de commandes propose de continuer vers l'installation des tâches. L'utilisateur peut fermer cette fenêtre pour ne mettre à jour que la configuration.

## Désinstallation

L'utilisateur exécute le fichier **`2_uninstall.bat`**. Ce dernier exécute `management\uninstall.ps1` après une demande d'élévation de privilèges (UAC).

Le script `uninstall.ps1` effectue les actions suivantes :

1.  **Connexion Automatique :** Le script affiche une invite demandant si la connexion automatique doit être désactivée. Si l'utilisateur répond `o` (oui), le script écrit la valeur `0` dans la clé de Registre `AutoAdminLogon`.
2.  **Restauration de certains paramètres système :**
    *   **Mises à jour :** Il positionne la valeur de Registre `NoAutoUpdate` à `0` et configure le type de démarrage du service `wuauserv` sur `Automatic`.
    *   **Démarrage Rapide :** Il positionne la valeur de Registre `HiberbootEnabled` à `1`.
    *   **OneDrive :** Il supprime la valeur de Registre `DisableFileSyncNGSC`.
3.  **Suppression des Tâches Planifiées :** Le script recherche et supprime les tâches `WindowsOrchestrator-SystemStartup`, `WindowsOrchestrator-UserLogon`, `WindowsOrchestrator-SystemScheduledReboot`, et `WindowsOrchestrator-SystemPreRebootAction`.

### Note sur la Restauration des Paramètres

**Le script de désinstallation ne restaure pas les paramètres d'alimentation** qui ont été modifiés par la commande `powercfg`.
*   **Conséquence pour l'utilisateur :** Si la mise en veille de la machine ou de l'écran a été désactivée par les scripts, elle le restera après la désinstallation.
*   **Action requise de l'utilisateur :** Pour réactiver la mise en veille, l'utilisateur doit reconfigurer manuellement ces options dans les "Paramètres d'alimentation et de mise en veille" de Windows.

Le processus de désinstallation **ne supprime aucun fichier**. Le répertoire du projet et son contenu restent sur le disque.

## Structure du Projet

```
WindowsOrchestrator/
├── 1_install.bat                # Exécute la configuration graphique puis l'installation des tâches.
├── 2_uninstall.bat              # Exécute le script de désinstallation.
├── Close-App.bat                # Exécute le script PowerShell Close-AppByTitle.ps1.
├── Close-AppByTitle.ps1         # Script qui trouve une fenêtre par son titre et lui envoie une séquence de touches.
├── config.ini                   # Fichier de configuration lu par les scripts principaux.
├── config_systeme.ps1           # Script pour les paramètres machine, exécuté au démarrage.
├── config_utilisateur.ps1       # Script pour la gestion de processus, exécuté à la connexion.
├── Fix-Encoding.ps1             # Outil pour convertir les fichiers de script en encodage UTF-8 with BOM.
├── LaunchApp.bat                # Script batch d'exemple pour lancer une application externe.
├── List-VisibleWindows.ps1      # Utilitaire qui liste les fenêtres visibles et leurs processus.
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # Fichier de chaînes de caractères pour l'anglais.
│   └── ... (autres langues)
└── management/
    ├── firstconfig.ps1          # Affiche l'assistant de configuration graphique.
    ├── install.ps1              # Crée les tâches planifiées et exécute les scripts une fois.
    ├── uninstall.ps1            # Supprime les tâches et restaure les paramètres système.
    └── defaults/
        └── default_config.ini   # Modèle pour créer le fichier config.ini initial.
```

## Principes Techniques

*   **Commandes Natives** : Le projet utilise exclusivement des commandes natives de Windows et PowerShell. Aucune dépendence externe n'est à installer.
*   **Bibliothèques Système** : Les interactions avancées avec le système s'appuient uniquement sur des bibliothèques intégrées à Windows (ex: `user32.dll`).

## Description des Fichiers Clés

### `1_install.bat`
Ce fichier batch est le point d'entrée du processus d'installation. Il exécute `management\firstconfig.ps1` pour la configuration, puis exécute `management\install.ps1` avec des privilèges élevés.

### `2_uninstall.bat`
Ce fichier batch est le point d'entrée de la désinstallation. Il exécute `management\uninstall.ps1` avec des privilèges élevés.

### `config.ini`
C'est le fichier de configuration central. Il contient les instructions (clés et valeurs) qui sont lues par les scripts `config_systeme.ps1` et `config_utilisateur.ps1` pour déterminer quelles actions effectuer.

### `config_systeme.ps1`
Exécuté au démarrage de l'ordinateur par une Tâche Planifiée, ce script lit la section `[SystemConfig]` du fichier `config.ini`. Il applique les paramètres en modifiant le Registre Windows, en exécutant des commandes système (`powercfg`), et en gérant des services (`wuauserv`).

### `config_utilisateur.ps1`
Exécuté à l'ouverture de session de l'utilisateur par une Tâche Planifiée, ce script lit la section `[Process]` du fichier `config.ini`. Son rôle est d'arrêter toute instance existante du processus cible, puis de le redémarrer en utilisant les paramètres fournis.

### `management\firstconfig.ps1`
Ce script PowerShell affiche l'interface graphique qui permet de lire et d'écrire les paramètres dans le fichier `config.ini`.

### `management\install.ps1`
Ce script contient la logique de création des Tâches Planifiées `WindowsOrchestrator-SystemStartup` et `WindowsOrchestrator-UserLogon`.

### `management\uninstall.ps1`
Ce script contient la logique de suppression des Tâches Planifiées et de restauration des clés de Registre système à leurs valeurs par défaut.

## Gestion par les Tâches Planifiées

L'automatisation repose sur le Planificateur de Tâches de Windows (`taskschd.msc`). Les tâches suivantes sont créées par les scripts :

*   **`WindowsOrchestrator-SystemStartup`** : Se déclenche au démarrage du PC et exécute `config_systeme.ps1`.
*   **`WindowsOrchestrator-UserLogon`** : Se déclenche à l'ouverture de session et exécute `config_utilisateur.ps1`.
*   **`WindowsOrchestrator-SystemScheduledReboot`** : Créée par `config_systeme.ps1` si `ScheduledRebootTime` est défini dans `config.ini`.
*   **`WindowsOrchestrator-SystemPreRebootAction`** : Créée par `config_systeme.ps1` si `PreRebootActionCommand` est défini dans `config.ini`.

**Important** : Supprimer ces tâches manuellement via le planificateur de tâches stoppe l'automatisation mais ne restaure pas les paramètres système. L'utilisateur doit impérativement utiliser `2_uninstall.bat` pour une désinstallation complète et contrôlée.

## Licence et Contributions

Ce projet est distribué sous la licence **GPLv3**. Le texte intégral est disponible dans le fichier `LICENSE`.

Les contributions, qu'il s'agisse de rapports de bogues, de suggestions d'amélioration ou de requêtes de tirage, sont les bienvenues.
