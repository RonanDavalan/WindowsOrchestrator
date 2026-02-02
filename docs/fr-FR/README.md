# WindowsOrchestrator 1.74

<p align="center">
  <img src="https://img.shields.io/badge/Version-v1.74-2ea44f" alt="Version">
  <img src="https://img.shields.io/badge/Licence-GPLv3-blue.svg" alt="Licence">
  <img src="https://img.shields.io/badge/Plateforme-Windows_10_|_11-0078D6" alt="OS supportés">
  <img src="https://img.shields.io/badge/Architecture-x86_|_x64_|_ARM64-blueviolet" alt="Architecture CPU">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Version PowerShell">
  <img src="https://img.shields.io/badge/Type-Portable_App-orange" alt="Sans installation">
</p>

[🇺🇸 English](../../README.md) | **🇫🇷 Français** | [🇩🇪 Deutsch](../de-DE/README.md) | [🇪🇸 Español](../es-ES/README.md)

## Description

**WindowsOrchestrator** est une solution d'automatisation PowerShell conçue pour transformer un poste de travail Windows standard en un système autonome (*kiosk* ou *appliance*).

🌐 **Site officiel** : [wo.davalan.fr](https://wo.davalan.fr/fr)

Il permet de configurer, de sécuriser et d'orchestrer le cycle de vie du système d'exploitation. Une fois paramétré, il assure que le poste démarre, ouvre une session et lance une application métier sans aucune intervention humaine, tout en gérant la maintenance quotidienne (sauvegarde, redémarrage).

## Cas d'usage et public cible

Par défaut, Windows est conçu pour une interaction humaine (écran de connexion, mises à jour, notifications). WindowsOrchestrator supprime ces frictions pour des usages dédiés :

*   **Affichage dynamique** : écrans publicitaires, panneaux d'information, menu boards.
*   **Bornes interactives** : billetterie, bornes de commande, guichets automatiques.
*   **PC industriels** : interfaces homme-machine (IHM), automates de contrôle sur ligne de production.
*   **Serveurs Windows** : lancement automatique d'applications nécessitant une session interactive persistante.

## Philosophie : Un orchestrateur modulaire

WindowsOrchestrator n'est pas un script de "durcissement" (*hardening*) rigide. C'est un outil flexible qui s'adapte à votre besoin.

*   **Flexibilité totale** : aucune configuration n'est forcée. Vous pouvez choisir de désactiver le démarrage rapide sans toucher à Windows Update, ou inversement.
*   **Responsabilité** : l'outil applique strictement ce que vous demandez. Il est conçu pour des environnements maîtrisés où la stabilité prime sur les mises à jour fonctionnelles constantes.
*   **Architecture multi-contextes** :
    *   **Standard** : laisse l'écran de connexion Windows (Logon UI). Lance l'application une fois l'utilisateur connecté manuellement.
    *   **Autologon** : ouvre automatiquement la session utilisateur et affiche le bureau.

## Philosophie technique : Approche native

L'orchestrateur privilégie la stabilité et l'utilisation des mécanismes natifs de Windows pour garantir la pérennité des configurations.

*   **Gestion de l'énergie "en dur"** : modification directe des plans d'alimentation AC/DC via `powercfg.exe`. Pas de simulation d'activité souris/clavier.
*   **Mises à jour via GPO** : utilisation des clés de registre `HKLM:\SOFTWARE\Policies` (méthode Entreprise) pour résister aux mécanismes d'auto-réparation de Windows Update.
*   **Stabilité par "Cold boot"** : désactivation possible du démarrage rapide (`HiberbootEnabled`) pour forcer un rechargement complet des pilotes et du noyau à chaque redémarrage.
*   **Sécurité des identifiants (LSA)** : en mode Autologon, le mot de passe n'est jamais stocké en clair. L'orchestrateur délègue le chiffrement à l'outil **Sysinternals Autologon**, qui stocke les identifiants dans les secrets LSA (*Local Security Authority*) de Windows.

## Capacités fonctionnelles

### Gestion de session (Autologon)
*   Configuration automatisée du registre Winlogon.
*   Intégration de l'outil officiel Microsoft Sysinternals Autologon.
*   Support natif des architectures x86, AMD64 et ARM64.
*   Téléchargement et lancement automatisés de l'outil pour la configuration des identifiants.

### Lancement automatique
*   Utilisation du **Planificateur de tâches** (déclencheur *AtLogon*) pour garantir le lancement avec les droits appropriés.
*   **Modes de lancement console** :
    *   *Standard* : utilise le terminal par défaut (ex : Windows Terminal).
    *   *Legacy* : force l'utilisation de `conhost.exe` pour la compatibilité des vieux scripts `.bat`.
*   **Launcher Dynamique** : Le script `LaunchApp.bat` lit désormais automatiquement le nom de l'application dans le `config.ini`. Plus aucune modification manuelle du script n'est nécessaire.
*   Option pour lancer l'application **minimisée** dans la barre des tâches.

### Sauvegarde de données
*   Module de sauvegarde intelligent exécuté avant le redémarrage.
*   **Logique différentielle** : copie uniquement les fichiers modifiés dans les dernières 24 heures.
*   **Support des fichiers appairés** : idéal pour les bases de données (ex : copie simultanée de `.db`, `.db-wal`, `.db-shm`).
*   **Politique de rétention** : purge automatique des archives dépassant une ancienneté définie (défaut : 30 jours).
*   **Surveillance Watchdog** : Vérifie activement que l'application est fermée avant de lancer la copie pour éviter toute corruption.

### Maintenance des logs (Log Trimming)
*   **Module de réduction** : Script autonome (`reducelog.ps1`) pour prévenir la saturation disque causée par des journaux applicatifs volumineux.
*   **Trimming intelligent** : Tronque les fichiers cibles pour ne conserver que les N dernières lignes (configurable).
*   **Support des Wildcards** : Accepte les motifs génériques (ex: `*.log`, `error_*.txt`) pour cibler dynamiquement plusieurs fichiers.
*   **Intégration sécurisée** : S'exécute pendant la fenêtre de maintenance, application fermée, avant la sauvegarde.

### Gestion de l'environnement système
*   **Windows Update** : blocage du service et désactivation du redémarrage forcé post-mise à jour.
*   **Fast Startup** : désactivation pour garantir des redémarrages propres.
*   **Alimentation** : désactivation de la veille machine (S3/S4) et de la veille écran.
*   **OneDrive** : trois politiques de gestion (`Block` par GPO, `Close` le processus, ou `Ignore`).

### Planification des tâches
*   **Fermeture application** : envoi de commandes de fermeture propre (ex : {ESC}{ESC}x{ENTER} via API) à une heure précise.
*   **Redémarrage système** : reboot complet planifié quotidiennement.
*   **Sauvegarde** : tâche indépendante, exécutée en parallèle de la fermeture.

### Intelligence Temporelle
*   **Calcul automatique des horaires manquants (Inférence)** : Si l'heure de sauvegarde ou de redémarrage n'est pas définie explicitement, le système les calcule intelligemment à partir de l'heure de fermeture (ex : sauvegarde 5 minutes après fermeture).
*   **Enchaînement logique des tâches (Fermeture -> Sauvegarde -> Redémarrage)** : Flux séquentiel "Effet Domino" garantissant l'ordre et la cohérence des opérations.

### Mode silencieux
*   Installation et désinstallation possibles sans fenêtres de console visibles (`-WindowStyle Hidden`).
*   **Splash screen** : interface graphique d'attente avec barre de progression pour rassurer l'utilisateur.
*   **Feedback** : notification finale par boîte de dialogue (`MessageBox`) indiquant le succès ou l'échec.

### Internationalisation et notifications
*   **i18n** : détection automatique de la langue système (support natif : `fr-FR`, `en-US`).
*   **Gotify** : module optionnel pour envoyer des rapports d'exécution (succès/erreurs) vers un serveur Gotify.

## Procédure de déploiement

### Prérequis
*   **OS** : Windows 10 ou Windows 11 (toutes éditions).
*   **Droits** : Accès administrateur requis (pour la modification HKLM et la création de tâches).
*   **PowerShell** : Version 5.1 ou supérieure.

### Installation

1.  Téléchargez et décompressez l'archive du projet.
2.  Exécutez le script **`Install.bat`** (acceptez la demande d'élévation de privilèges).
3.  L'**Assistant de configuration** (`firstconfig.ps1`) s'ouvre :
    *   Renseignez le chemin de l'application à lancer.
    *   Définissez les horaires du cycle quotidien (fermeture / sauvegarde / redémarrage).
    *   Activez l'Autologon si nécessaire.
    *   Dans l'onglet "Avancées", configurez la sauvegarde et le mode silencieux.
4.  Cliquez sur **"Enregistrer et fermer"**.
5.  L'installation automatique (`install.ps1`) prend le relais :
    *   Création des tâches planifiées.
    *   *Si Autologon activé* : téléchargement automatique de l'outil Sysinternals et ouverture de la fenêtre de configuration pour la saisie du mot de passe.

> **Note** : Si le mode Autologon est sélectionné avec `UseAutologonAssistant=true`, l'assistant tentera de télécharger l'outil. Si le poste n'a pas internet, une boîte de dialogue vous proposera de sélectionner le fichier `Autologon.zip` manuellement.

### Désinstallation

1.  Exécutez le script **`Uninstall.bat`**.
2.  Le script de nettoyage (`uninstall.ps1`) s'exécute :
    *   Suppression de toutes les tâches planifiées `WindowsOrchestrator-*`.
    *   Restauration des paramètres par défaut de Windows (Windows Update, Fast Startup, OneDrive).
    *   *Si Autologon détecté* : lancement de l'outil Autologon pour permettre une désactivation propre (nettoyage des secrets LSA).
    *   Affichage d'un rapport de fin d'opération.

> **Note** : Par sécurité, les fichiers de configuration (`config.ini`) et les journaux (`Logs/`) ne sont pas supprimés automatiquement.

## Configuration et observabilité

### Fichier de configuration (`config.ini`)
Généré à la racine du projet par l'assistant, il pilote l'ensemble du système.
*   `[SystemConfig]` : Paramètres vitaux (session, FastStartup, WindowsUpdate, OneDrive).
*   `[Process]` : Chemins de l'application, arguments, horaires, surveillance de processus.
*   `[DatabaseBackup]` : Activation, chemins source/destination, rétention.
*   `[Installation]` : Comportement de l'installeur (mode silencieux, URL Autologon, redémarrage fin d'installation).
*   `[Logging]` : Paramètres de rotation des journaux.
*   `[Gotify]` : Configuration des notifications push.

### Journalisation
L'orchestrateur génère des journaux détaillés pour chaque opération.
*   **Emplacement** : Dossier `Logs/` à la racine du projet.
*   **Fichiers** :
    *   `config_systeme_ps_log.txt` : Actions effectuées par le contexte SYSTEM (démarrage, tâches de fond).
    *   `config_utilisateur_log.txt` : Actions effectuées dans la session utilisateur (lancement app).
    *   `Invoke-DatabaseBackup_log.txt` : Rapport spécifique des sauvegardes.
*   **Rotation** : Conservation des 7 derniers fichiers (configurable) pour éviter la saturation disque.
*   **Repli** : Si le dossier `Logs/` est inaccessible, les erreurs critiques sont écrites dans `C:\ProgramData\StartupScriptLogs`.

### Tâches planifiées créées
L'installation enregistre les tâches suivantes dans le Planificateur Windows :
| Nom de la tâche | Contexte | Déclencheur | Action |
| :--- | :--- | :--- | :--- |
| `WindowsOrchestrator-SystemStartup` | SYSTEM | Démarrage système | Applique la config système (Power, Update...) |
| `WindowsOrchestrator-UserLogon` | Utilisateur | Ouverture de session | Lance l'application métier |
| `WindowsOrchestrator-SystemBackup` | SYSTEM | Heure planifiée | Exécute la sauvegarde des données |
| `WindowsOrchestrator-SystemScheduledReboot` | SYSTEM | Heure planifiée | Redémarre l'ordinateur |
| `WindowsOrchestrator-User-CloseApp` | Utilisateur | Heure planifiée | Ferme l'application proprement |

## Documentation

Pour aller plus loin, consultez les guides détaillés :

📘 **[Guide utilisateur](GUIDE_UTILISATEUR.md)**
*Destiné aux administrateurs système et techniciens de déploiement.*
Contient les procédures pas-à-pas, les captures d'écran de l'assistant et les guides de dépannage.

🛠️ **[Guide du développeur](GUIDE_DU_DEVELOPPEUR.md)**
*Destiné aux intégrateurs et auditeurs de sécurité.*
Détaille l'architecture interne, l'analyse du code, les mécanismes de sécurité LSA et la structure des modules.

## Conformité et sécurité

*   **Licence** : Ce projet est distribué sous licence **GPLv3**. Voir le fichier `LICENSE` pour plus de détails.
*   **Dépendances** :
    *   Le projet est autonome (*portable app*).
    *   L'activation de l'Autologon télécharge l'outil **Microsoft Sysinternals Autologon** (soumis à sa propre EULA, que l'utilisateur doit accepter lors de l'installation).
*   **Sécurité des données** :
    *   WindowsOrchestrator ne stocke **aucun mot de passe** en clair dans ses fichiers de configuration.
    *   Les privilèges sont cloisonnés : le script utilisateur ne peut pas modifier les paramètres système.

## Contribution et support

Ce projet est développé et partagé sur le temps libre.
*   **Bugs** : Si vous trouvez un bug technique, merci de le signaler via les **Issues** GitHub.
*   **Contributions** : Les *pull requests* sont les bienvenues pour améliorer l'outil.
