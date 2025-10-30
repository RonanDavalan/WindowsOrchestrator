# L'orchestrateur de Windows

[🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

**Votre pilote automatique pour les postes de travail Windows dédiés. Configurez une fois, et laissez le système se gérer de manière fiable.**

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Visitez la page d'accueil officielle pour une présentation complète !</strong></a>
</p>

![Licence](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![Version PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Statut](https://img.shields.io/badge/Status-Opérationnel-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Support](https://img.shields.io/badge/Support-11_Langues-orange.svg)![Contributions](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## Notre Mission

Imaginez un poste de travail Windows parfaitement fiable et autonome. Une machine que vous configurez une fois pour sa mission et que vous pouvez ensuite oublier. Un système qui garantit que votre application reste **opérationnelle en permanence**, sans interruption.

C'est l'objectif que **L'orchestrateur de Windows** vous aide à atteindre. Le défi est qu'un PC Windows standard n'est pas nativement conçu pour cette endurance. Il est conçu pour l'interaction humaine : il se met en veille, installe les mises à jour quand il le juge approprié, et ne redémarre pas automatiquement une application après un redémarrage.

**L'orchestrateur de Windows** est la solution : un ensemble de scripts qui agit comme un superviseur intelligent et permanent. Il transforme n'importe quel PC en un automate fiable, garantissant que votre application critique est toujours opérationnelle, sans intervention manuelle.



Nous avons été confrontés non pas à un, mais à deux types de défaillances systémiques :

#### 1. La Défaillance Abrupte : La Panne Inattendue

Le scénario est simple : une machine configurée pour l'accès à distance et une coupure de courant nocturne. Même avec un BIOS configuré pour le redémarrage automatique, la mission échoue. Windows redémarre mais reste sur l'écran de connexion ; l'application critique n'est pas relancée, la session n'est pas ouverte. Le système est inaccessible.

#### 2. La Dégradation Lente : Instabilité à Long Terme

Plus insidieux encore est le comportement de Windows au fil du temps. Conçu comme un OS interactif, il n'est pas optimisé pour les processus fonctionnant sans interruption. Progressivement, des fuites de mémoire et une dégradation des performances apparaissent, rendant le système instable et nécessitant un redémarrage manuel.

### La Réponse : Une Couche de Fiabilité Native

Face à ces défis, les utilitaires tiers se sont avérés insuffisants. Nous avons donc pris la décision d'**architecturer notre propre couche de résilience système.**

L'orchestrateur de Windows agit comme un pilote automatique qui prend le contrôle de l'OS pour :

- **Assurer la Récupération Automatique :** Après une défaillance, il garantit l'ouverture de session et le redémarrage de votre application principale.
- **Garantir la Maintenance Préventive :** Il permet de planifier un redémarrage quotidien contrôlé avec l'exécution de scripts personnalisés au préalable.
- **Protéger l'Application** des interruptions intempestives de Windows (mises à jour, mode veille...).

L'orchestrateur de Windows est l'outil essentiel pour quiconque a besoin qu'un poste de travail Windows reste **fiable, stable et opérationnel sans surveillance continue.**

---

## Cas d'Utilisation Typiques

*   **Affichage Dynamique :** Assurer que le logiciel d'affichage fonctionne 24h/24 et 7j/7 sur un écran public.
*   **Serveurs Domestiques et IoT :** Contrôler un serveur Plex, une passerelle Home Assistant ou un objet connecté depuis un PC Windows.
*   **Stations de Supervision :** Garder une application de surveillance (caméras, journaux réseau) toujours active.
*   **Kiosques Interactifs :** Assurer que l'application du kiosque redémarre automatiquement après chaque redémarrage.
*   **Automatisation Légère :** Exécuter des scripts ou des processus en continu pour des tâches d'exploration de données ou de test.

---

## Fonctionnalités Clés

*   **Assistant de Configuration Graphique :** Pas besoin d'éditer des fichiers pour les réglages de base.
*   **Support Multilingue Complet :** Interface et journaux disponibles en 11 langues, avec détection automatique de la langue du système.
*   **Gestion de l'Alimentation :** Désactiver la mise en veille de la machine, la mise en veille de l'affichage et le démarrage rapide de Windows pour une stabilité maximale.
*   **Connexion Automatique (Auto-Login) :** Gère la connexion automatique, y compris en synergie avec l'outil **Sysinternals AutoLogon** pour une gestion sécurisée des mots de passe.
*   **Contrôle des Mises à Jour Windows :** Empêcher les mises à jour et les redémarrages forcés de perturber votre application.
*   **Gestionnaire de Processus :** Lance, surveille et relance automatiquement votre application principale à chaque session.
*   **Redémarrage Quotidien Planifié :** Planifier un redémarrage quotidien pour maintenir la fraîcheur du système.
*   **Action Pré-Redémarrage :** Exécuter un script personnalisé (sauvegarde, nettoyage...) avant le redémarrage planifié.
*   **Journalisation Détaillée :** Toutes les actions sont enregistrées dans des fichiers journaux pour un diagnostic facile.
*   **Notifications (Optionnel) :** Envoyer des rapports de statut via Gotify.

---

## Public Cible et Bonnes Pratiques

Ce projet est conçu pour transformer un PC en un automate fiable, idéal pour les cas d'utilisation où la machine est dédiée à une seule application (serveur pour un appareil IoT, affichage dynamique, station de surveillance, etc.). Il n'est pas recommandé pour un ordinateur de bureau à usage général ou quotidien.

*   **Mises à Jour Majeures de Windows :** Pour les mises à jour importantes (par exemple, la mise à niveau de Windows 10 vers 11), la procédure la plus sûre consiste à **désinstaller** L'orchestrateur de Windows avant la mise à jour, puis à le **réinstaller** après.
*   **Environnements d'Entreprise :** Si votre ordinateur se trouve dans un domaine d'entreprise géré par des Objets de Stratégie de Groupe (GPO), vérifiez auprès de votre service informatique que les modifications apportées par ce script n'entrent pas en conflit avec les politiques de votre organisation.

---

## Installation et Premiers Pas

**Note sur la Langue :** Les scripts de lancement (`1_install.bat` et `2_uninstall.bat`) affichent leurs instructions en **anglais**. C'est normal. Ces fichiers agissent comme de simples lanceurs. Dès que l'assistant graphique ou les scripts PowerShell prennent le relais, l'interface s'adaptera automatiquement à la langue de votre système d'exploitation.

La configuration de **L'orchestrateur de Windows** est un processus simple et guidé.

1.  **Téléchargez** ou clonez le projet sur l'ordinateur à configurer.
2.  Exécutez `1_install.bat`. Le script vous guidera à travers deux étapes :
    *   **Étape 1 : Configuration via l'Assistant Graphique.**
        Ajustez les options selon vos besoins. Les plus importantes sont généralement le nom d'utilisateur pour la connexion automatique et l'application à lancer. Cliquez sur `Enregistrer` pour sauvegarder.
        
        ![Assistant de Configuration](assets/screenshot-wizard.png)
        
    *   **Étape 2 : Installation des Tâches Système.**
        Le script demandera une confirmation pour continuer. Une fenêtre de sécurité Windows (UAC) s'ouvrira. **Vous devez l'accepter** pour permettre au script de créer les tâches planifiées nécessaires.
3.  C'est tout ! Lors du prochain redémarrage, vos configurations seront appliquées.

---

## Configuration
Vous pouvez ajuster les paramètres à tout moment de deux manières :

### 1. Assistant Graphique (Méthode simple)
Réexécutez `1_install.bat` pour rouvrir l'interface de configuration. Modifiez vos paramètres et enregistrez.

### 2. Fichier `config.ini` (Méthode avancée)
Ouvrez `config.ini` avec un éditeur de texte pour un contrôle granulaire.

#### Note Importante sur la Connexion Automatique et les Mots de Passe
Pour des raisons de sécurité, **L'orchestrateur de Windows ne gère ni ne stocke jamais les mots de passe en texte clair.** Voici comment configurer la connexion automatique de manière efficace et sécurisée :

*   **Scénario 1 : Le compte utilisateur n'a pas de mot de passe.**
    Entrez simplement le nom d'utilisateur dans l'assistant graphique ou dans `AutoLoginUsername` dans le fichier `config.ini`.

*   **Scénario 2 : Le compte utilisateur a un mot de passe (Méthode recommandée).**
    1.  Téléchargez l'outil officiel **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** de Microsoft (lien de téléchargement direct).
    2.  Lancez AutoLogon et entrez le nom d'utilisateur, le domaine et le mot de passe. Cet outil stockera le mot de passe de manière sécurisée dans le Registre.
    3.  Dans la configuration de **L'orchestrateur de Windows**, vous pouvez maintenant laisser le champ `AutoLoginUsername` vide (le script détectera l'utilisateur configuré par AutoLogon en lisant la clé de Registre correspondante) ou le remplir pour être sûr. Notre script s'assurera que la clé de Registre `AutoAdminLogon` est correctement activée pour finaliser la configuration.

#### Configuration Avancée : `PreRebootActionCommand`
Cette fonctionnalité puissante vous permet d'exécuter un script avant le redémarrage quotidien. Le chemin peut être :
- **Absolu :** `C:\Scripts\my_backup.bat`
- **Relatif au projet :** `PreReboot.bat` (le script recherchera ce fichier à la racine du projet).
- **Utilisation de `%USERPROFILE%` :** `%USERPROFILE%\Desktop\cleanup.ps1` (le script remplacera intelligemment `%USERPROFILE%` par le chemin du profil de l'utilisateur de connexion automatique).

---

## Structure du Projet
```
WindowsOrchestrator/
├── 1_install.bat                # Point d'entrée pour l'installation et la configuration
├── 2_uninstall.bat              # Point d'entrée pour la désinstallation
├── config.ini                   # Fichier de configuration central
├── config_systeme.ps1           # Script principal pour les paramètres de la machine (s'exécute au démarrage)
├── config_utilisateur.ps1       # Script principal pour la gestion des processus utilisateur (s'exécute à la connexion)
├── LaunchApp.bat                # (Exemple) Lanceur portable pour votre application principale
├── PreReboot.bat                # Exemple de script pour l'action de pré-redémarrage
├── Logs/                        # (Créé automatiquement) Contient les fichiers journaux
├── i18n/                        # Contient tous les fichiers de traduction
│   ├── en-US/strings.psd1
│   └── ... (autres langues)
└── management/
    ├── defaults/default_config.ini # Modèle de configuration initiale
    ├── tools/                   # Outils de diagnostic
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # Le code de l'assistant de configuration graphique
    ├── install.ps1              # Le script technique pour l'installation des tâches
    └── uninstall.ps1            # Le script technique pour la suppression des tâches
```

---

## Fonctionnement Détaillé
Le cœur de **L'orchestrateur de Windows** repose sur le Planificateur de Tâches Windows :

1.  **Au Démarrage de Windows**
    *   La tâche `WindowsOrchestrator_SystemStartup` s'exécute avec les privilèges `SYSTEM`.
    *   Le script `config_systeme.ps1` lit `config.ini` et applique toutes les configurations de la machine. Il gère également la création/mise à jour des tâches de redémarrage.

2.  **À la Connexion de l'Utilisateur**
    *   La tâche `WindowsOrchestrator_UserLogon` s'exécute.
    *   Le script `config_utilisateur.ps1` lit la section `[Process]` de `config.ini` et s'assure que votre application principale est correctement lancée. Si elle était déjà en cours d'exécution, elle est d'abord arrêtée puis relancée proprement.

3.  **Quotidiennement (Si configuré)**
    *   La tâche `WindowsOrchestrator_PreRebootAction` exécute votre script de sauvegarde/nettoyage.
    *   Quelques minutes plus tard, la tâche `WindowsOrchestrator_ScheduledReboot` redémarre l'ordinateur.

---

### Outils de Diagnostic et de Développement

Le projet comprend des scripts utiles pour vous aider à configurer et à maintenir le projet.

*   **`management/tools/Find-WindowInfo.ps1`** : Si vous ne connaissez pas le titre exact de la fenêtre d'une application (par exemple, pour la configurer dans `Close-AppByTitle.ps1`), exécutez ce script. Il listera toutes les fenêtres visibles et leurs noms de processus, vous aidant à trouver l'information précise.
*   **`Fix-Encoding.ps1`** : Si vous modifiez les scripts, cet outil garantit qu'ils sont enregistrés avec le bon encodage (UTF-8 avec BOM) pour une compatibilité parfaite avec PowerShell 5.1 et les caractères internationaux.

---

## Journalisation
Pour faciliter le dépannage, tout est journalisé.
*   **Emplacement :** Dans le sous-dossier `Logs/`.
*   **Fichiers :** `config_systeme_ps_log.txt` et `config_utilisateur_log.txt`.
*   **Rotation :** Les anciens journaux sont automatiquement archivés pour éviter qu'ils ne deviennent trop volumineux.

---

## Désinstallation
Pour supprimer le système :
1.  Exécutez `2_uninstall.bat`.
2.  **Acceptez la demande de privilège (UAC)**.
3.  Le script supprimera proprement toutes les tâches planifiées et restaurera les principaux paramètres du système.

**Note sur la Réversibilité :** La désinstallation ne se contente pas de supprimer les tâches planifiées. Elle restaure également les principaux paramètres du système à leur état par défaut pour vous offrir un système propre :
*   Les mises à jour Windows sont réactivées.
*   Le démarrage rapide est réactivé.
*   La politique bloquant OneDrive est supprimée.
*   Le script proposera de désactiver la connexion automatique.

Votre système redevient ainsi un poste de travail standard, sans modifications résiduelles.

---

## Licence et Contributions
Ce projet est distribué sous la licence **GPLv3**. Le texte intégral est disponible dans le fichier `LICENSE`.

Les contributions, qu'il s'agisse de rapports de bogues, de suggestions d'amélioration ou de requêtes de tirage, sont les bienvenues.