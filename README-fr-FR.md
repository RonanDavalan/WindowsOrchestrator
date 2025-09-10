# **L'Orchestrateur de Windows**

<p align="center">
  <img src="https://img.shields.io/badge/Licence-GPLv3-blue.svg" alt="Licence">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Version PowerShell">
  <img src="https://img.shields.io/badge/Support-11_Langues-orange.svg" alt="Support multilingue">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="OS Supportés">
</p>

[🇺🇸 English](README.md) | **🇫🇷 Français** | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

---

Ce projet automatise un poste de travail Windows pour qu'une application puisse y fonctionner sans surveillance.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Visitez la page d'accueil officielle pour une présentation complète !</strong></a>
</p>

Après un redémarrage imprévu (dû à une coupure de courant ou un incident), ce projet se charge d'ouvrir la session Windows et de relancer automatiquement votre application, assurant ainsi la continuité de son service. Il permet également de planifier des redémarrages quotidiens pour maintenir la stabilité du système.

Toutes les actions sont pilotées par un fichier de configuration unique, créé lors de l'installation.

### **Installation**

1.  **Prérequis (pour la connexion automatique) :** Si vous souhaitez que la session Windows s'ouvre toute seule, utilisez au préalable l'outil **[Sysinternals AutoLogon](https://learn.microsoft.com/fr-fr/sysinternals/downloads/autologon)** pour enregistrer le mot de passe. C'est la seule configuration externe nécessaire.
2.  **Lancement :** Exécutez **`1_install.bat`**. Un assistant graphique vous guidera pour créer votre fichier de configuration. L'installation se poursuivra ensuite et demandera une autorisation d'administrateur (UAC).

### **Utilisation**

Une fois installé, le projet est autonome. Pour modifier la configuration (changer l'application à lancer, l'heure de redémarrage...), il suffit d'éditer le fichier `config.ini` situé dans le répertoire du projet.

### **Désinstallation**

Exécutez **`2_uninstall.bat`**. Le script supprimera toute l'automatisation et restaurera les principaux paramètres de Windows à leurs valeurs par défaut.

*   **Note importante :** Les seuls paramètres non restaurés sont ceux liés à la gestion de l'alimentation (`powercfg`).
*   Le répertoire du projet avec tous ses fichiers reste sur votre disque et peut être supprimé manuellement.

### **Documentation Technique**

Pour une description détaillée de l'architecture, de chaque script et de toutes les options de configuration, veuillez consulter la documentation de référence.

➡️ **[Consulter la Documentation Technique Détaillée](./docs/fr-FR/GUIDE_DU_DEVELOPPEUR.md)**

---
**Licence** : Ce projet est distribué sous la licence GPLv3. Voir le fichier `LICENSE`.
