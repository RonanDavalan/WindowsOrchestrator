# WindowsAutoConfig ⚙️

[🇺🇸 English](README.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md)

**Votre pilote automatique pour postes de travail Windows dédiés. Configurez une fois, et laissez le système s'autogérer en toute fiabilité.**

![Licence](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![Version PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Statut](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Support](https://img.shields.io/badge/Support-11_Langues-orange.svg)![Contributions](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 Notre Mission

Imaginez un poste Windows parfaitement fiable et autonome. Une machine que vous configurez une seule fois pour sa mission — qu'il s'agisse de piloter un objet connecté, d'animer un panneau d'affichage ou de servir de poste de supervision — et que vous pouvez ensuite oublier. Un système qui assure que votre application reste **opérationnelle en permanence**, sans interruption.

C'est l'objectif que **WindowsAutoConfig** vous aide à atteindre. Le défi est qu'un PC Windows standard n'est pas nativement conçu pour cette endurance. Il est pensé pour l'interaction humaine : il se met en veille pour économiser l'énergie, installe des mises à jour quand il le juge bon, et ne redémarre pas automatiquement une application après un redémarrage.

**WindowsAutoConfig** est la solution : un ensemble de scripts qui agit comme un superviseur intelligent et permanent. Il transforme n'importe quel PC en un automate fiable, garantissant que votre application critique est toujours opérationnelle, sans intervention manuelle.

### Au-delà de l'interface : un contrôle direct du système

WindowsAutoConfig agit comme un panneau de contrôle avancé, rendant accessibles des configurations puissantes qui ne sont pas disponibles ou sont difficiles à gérer via l'interface standard de Windows.

*   **Maîtrise Complète de Windows Update :** Au lieu de simplement "mettre en pause" les mises à jour, le script modifie les stratégies système pour stopper le mécanisme automatique, vous redonnant la main sur le moment où les mises à jour sont installées.
*   **Configuration Fiable de l'Alimentation :** Le script ne se contente pas de régler la mise en veille sur "Jamais", il s'assure que ce réglage est réappliqué à chaque démarrage, rendant votre configuration résistante à tout changement indésirable.
*   **Accès aux Paramètres Administrateur :** Des fonctionnalités comme la désactivation de OneDrive via une politique système sont des actions normalement réservées à l'Éditeur de Stratégie de Groupe (indisponible sur Windows Famille). Le script les rend accessibles à tous.

## ✨ Fonctionnalités Clés
*   **Assistant de Configuration Graphique :** Pas besoin d'éditer de fichiers pour les réglages de base.
*   **Support Multilingue Complet :** Interface et journaux disponibles en 11 langues, avec détection automatique de la langue du système.
*   **Gestion de l'Alimentation :** Désactivez la mise en veille de la machine, de l'écran, et le démarrage rapide de Windows pour une stabilité maximale.
*   **Connexion Automatique (Auto-Login) :** Gère l'auto-login, y compris en synergie avec l'outil **Sysinternals AutoLogon** pour une gestion sécurisée du mot de passe.
*   **Contrôle de Windows Update :** Empêchez les mises à jour et les redémarrages forcés de perturber votre application.
*   **Gestionnaire de Processus :** Lance, surveille et relance automatiquement votre application principale à chaque session.
*   **Redémarrage Quotidien Planifié :** Programmez un redémarrage quotidien pour maintenir la fraîcheur du système.
*   **Action Pré-Redémarrage :** Exécutez un script personnalisé (sauvegarde, nettoyage...) avant le redémarrage planifié.
*   **Journalisation Détaillée :** Toutes les actions sont enregistrées dans des fichiers journaux pour un diagnostic facile.
*   **Notifications (Optionnel) :** Envoyez des rapports de statut via Gotify.

---

## 🎯 Public Cible et Bonnes Pratiques

Ce projet est conçu pour transformer un PC en un automate fiable, idéal pour des cas d'usage où la machine est dédiée à une seule application (serveur pour un objet connecté (IoT), affichage dynamique, poste de supervision, etc.). Ce n'est pas recommandé pour un ordinateur de bureautique ou un usage quotidien.

*   **Mises à Jour Majeures de Windows :** Pour les mises à jour importantes (ex: passage de Windows 10 à 11), la procédure la plus sûre est de **désinstaller** WindowsAutoConfig avant la mise à jour, puis de le **réinstaller** après.
*   **Environnements d'Entreprise :** Si votre ordinateur est dans un domaine géré par des stratégies de groupe (GPO), consultez votre service informatique pour vous assurer que les modifications apportées par ce script ne sont pas en conflit avec les politiques de votre organisation.

---

## 🚀 Installation et Prise en Main

**Note sur la langue :** Les scripts de lancement (`1_install.bat` et `2_uninstall.bat`) affichent leurs instructions en **anglais**. Ceci est normal. Ces fichiers agissent comme de simples lanceurs. Dès que l'assistant graphique ou les scripts PowerShell prennent le relais, l'interface s'adaptera automatiquement à la langue de votre système d'exploitation.

Mettre en place **WindowsAutoConfig** est un processus simple et guidé.

1.  **Téléchargez** ou clonez le projet sur l'ordinateur à configurer.
2.  Exécutez `1_install.bat`. Le script vous guidera à travers deux étapes :
    *   **Étape 1 : Configuration via l'Assistant Graphique.**
        Réglez les options selon vos besoins. Les plus importantes sont généralement l'identifiant pour la connexion automatique et l'application à lancer. Cliquez sur `Enregistrer` pour sauvegarder.
    *   **Étape 2 : Installation des Tâches Système.**
        Le script vous demandera une confirmation pour continuer. Une fenêtre de sécurité Windows (UAC) s'ouvrira. **Vous devez l'accepter** pour permettre au script de créer les tâches planifiées nécessaires.
3.  C'est terminé ! Au prochain redémarrage, vos configurations seront appliquées.

---

## 🔧 Configuration
Vous pouvez ajuster les paramètres à tout moment de deux manières :

### 1. Assistant Graphique (Méthode simple)
Relancez `1_install.bat` pour ouvrir à nouveau l'interface de configuration. Modifiez vos réglages et enregistrez.

### 2. Fichier `config.ini` (Méthode avancée)
Ouvrez `config.ini` avec un éditeur de texte pour un contrôle granulaire.

#### Note Importante sur l'Auto-Login et les Mots de Passe
Pour des raisons de sécurité, **WindowsAutoConfig ne gère et ne stocke jamais les mots de passe en clair.** Voici comment configurer l'auto-login de manière efficace et sécurisée :

*   **Scénario 1 : Le compte utilisateur n'a pas de mot de passe.**
    Indiquez simplement le nom d'utilisateur dans l'assistant graphique ou dans `AutoLoginUsername` du fichier `config.ini`.

*   **Scénario 2 : Le compte utilisateur a un mot de passe (Méthode recommandée).**
    1.  Téléchargez l'outil officiel **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** de Microsoft (lien de téléchargement direct).
    2.  Lancez AutoLogon et renseignez le nom d'utilisateur, le domaine et le mot de passe. Cet outil stockera le mot de passe de manière sécurisée dans le Registre.
    3.  Dans la configuration de **WindowsAutoConfig**, vous pouvez maintenant laisser le champ `AutoLoginUsername` vide (le script détectera l'utilisateur configuré par AutoLogon en lisant la clé de Registre correspondante) ou le renseigner pour être certain. Notre script s'assurera que la clé de Registre `AutoAdminLogon` est bien activée pour finaliser la configuration.

#### Configuration Avancée : `PreRebootActionCommand`
Cette fonctionnalité puissante vous permet d'exécuter un script avant le redémarrage quotidien. Le chemin d'accès peut être :
- **Absolu :** `C:\Scripts\mon_backup.bat`
- **Relatif au projet :** `PreReboot.bat` (le script cherchera ce fichier à la racine du projet).
- **Utilisant `%USERPROFILE%` :** `%USERPROFILE%\Desktop\cleanup.ps1` (le script remplacera intelligemment `%USERPROFILE%` par le chemin du profil de l'utilisateur de l'Auto-Login).

---

## 📂 Structure du Projet
```
WindowsAutoConfig/
├── 1_install.bat                # Point d'entrée pour l'installation et la configuration
├── 2_uninstall.bat              # Point d'entrée pour la désinstallation
├── config.ini                   # Fichier de configuration central
├── config_systeme.ps1           # Script principal pour les réglages machine (démarrage)
├── config_utilisateur.ps1       # Script principal pour la gestion du processus utilisateur (login)
├── LaunchApp.bat                # (Exemple) Lanceur portable pour votre application principale
├── PreReboot.bat                # Exemple de script pour l'action pré-redémarrage
├── Logs/                        # (Créé automatiquement) Contient les fichiers journaux
├── i18n/                        # Contient tous les fichiers de traduction
│   ├── en-US/strings.psd1
│   └── ... (autres langues)
└── management/
    ├── defaults/default_config.ini # Modèle de configuration initial
    ├── tools/                   # Outils de diagnostic
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # Le code de l'assistant de configuration graphique
    ├── install.ps1              # Le script technique d'installation des tâches
    └── uninstall.ps1            # Le script technique de suppression des tâches
```

---

## ⚙️ Fonctionnement Détaillé
Le cœur de **WindowsAutoConfig** repose sur le Planificateur de Tâches de Windows :

1.  **Au Démarrage de Windows**
    *   La tâche `WindowsAutoConfig_SystemStartup` s'exécute avec les droits `SYSTÈME`.
    *   Le script `config_systeme.ps1` lit `config.ini` et applique toutes les configurations machine. Il gère également la création/mise à jour des tâches de redémarrage.

2.  **À l'Ouverture de Session Utilisateur**
    *   La tâche `WindowsAutoConfig_UserLogon` s'exécute.
    *   Le script `config_utilisateur.ps1` lit la section `[Process]` de `config.ini` et s'assure que votre application principale est bien lancée. Si elle tournait déjà, elle est d'abord arrêtée puis relancée proprement.

3.  **Au Quotidien (Si configuré)**
    *   La tâche `WindowsAutoConfig_PreRebootAction` exécute votre script de sauvegarde/nettoyage.
    *   Quelques minutes plus tard, la tâche `WindowsAutoConfig_ScheduledReboot` redémarre l'ordinateur.

---

### 🛠️ Outils de Diagnostic et de Développement

Le projet inclut des scripts utiles pour vous aider à configurer et à maintenir le projet.

*   **`management/tools/Find-WindowInfo.ps1`**: Si vous ne connaissez pas le titre exact de la fenêtre d'une application (pour le configurer dans `Close-AppByTitle.ps1` par exemple), exécutez ce script. Il listera toutes les fenêtres visibles et le nom de leur processus, vous aidant à trouver l'information précise.
*   **`Fix-Encoding.ps1`**: Si vous modifiez les scripts, cet outil s'assure qu'ils sont enregistrés avec le bon encodage (UTF-8 with BOM) pour une compatibilité parfaite avec PowerShell 5.1 et les caractères internationaux.

---

## 📄 Journalisation (Logging)
Pour un dépannage facile, tout est enregistré.
*   **Emplacement :** Dans le sous-dossier `Logs/`.
*   **Fichiers :** `config_systeme_ps_log.txt` et `config_utilisateur_log.txt`.
*   **Rotation :** Les anciens journaux sont automatiquement archivés pour éviter qu'ils ne deviennent trop volumineux.

---

## 🗑️ Désinstallation
Pour retirer le système :
1.  Exécutez `2_uninstall.bat`.
2.  **Acceptez la demande de privilèges (UAC)**.
3.  Le script supprimera proprement toutes les tâches planifiées et restaurera les principaux paramètres système.

**Note sur la réversibilité :** La désinstallation ne se contente pas de supprimer les tâches planifiées. Elle restaure également les principaux paramètres système à leur état par défaut pour vous rendre un système propre :
*   Les mises à jour Windows sont réactivées.
*   Le Démarrage Rapide est réactivé.
*   La politique de blocage de OneDrive est supprimée.
*   Le script vous proposera de désactiver la connexion automatique.

Votre système redevient ainsi un poste de travail standard, sans modifications résiduuelles.

---

## ❤️ Licence et Contributions
Ce projet est distribué sous la licence **GPLv3**. Le texte complet est disponible dans le fichier `LICENSE`.

Les contributions, que ce soit sous forme de rapports de bugs, de suggestions d'amélioration ou de "pull requests", sont les bienvenues.