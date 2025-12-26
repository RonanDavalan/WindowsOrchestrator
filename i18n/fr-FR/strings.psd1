@{
    # ==============================================================================
    # FICHIER DE LANGUE : FRANÇAIS (FR-FR)
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 1. INTERFACE GRAPHIQUE (firstconfig.ps1)
    # ------------------------------------------------------------------------------

    # Titres & Navigation
    ConfigForm_Title = "Assistant de Configuration - WindowsOrchestrator"
    ConfigForm_Tab_Basic = "Basique"
    ConfigForm_Tab_Advanced = "Avancé"
    ConfigForm_SubTabMain = "Principal"
    ConfigForm_SubTabBackup = "Sauvegarde"
    ConfigForm_SubTabOtherAccount = "Options & Compte"

    # Groupe : Session Utilisateur
    ConfigForm_EnableSessionManagementCheckbox = "Activer l'ouverture de session automatique (Autologon)"
    ConfigForm_SecureAutologonModeDescription = "(Ouvre le bureau, puis verrouille immédiatement la session)"
    ConfigForm_BackgroundTaskModeDescription = "(Lance l'application de manière invisible, sans ouvrir de session)"
    ConfigForm_SessionEulaNote = "(En cochant, vous acceptez la licence de l'outil Microsoft Autologon)"
    ConfigForm_UseAutologonAssistantCheckbox = "Utiliser l'assistant pour configurer l'outil Autologon (si requis)"
    ConfigForm_AutoLoginUsernameLabel = "Identifiant pour l'Autologon (optionnel) :"

    # Groupe : Paramètres Windows
    ConfigForm_WindowsSettingsGroup = "Paramètres Windows"
    ConfigForm_DisableFastStartupCheckbox = "Désactiver le démarrage rapide de Windows"
    ConfigForm_DisableSleepCheckbox = "Désactiver la mise en veille automatique"
    ConfigForm_DisableScreenSleepCheckbox = "Désactiver la mise en veille de l'écran"
    ConfigForm_DisableWindowsUpdateCheckbox = "Bloquer le service Windows Update"
    ConfigForm_DisableAutoRebootCheckbox = "Désactiver le redémarrage automatique après mise à jour"

    # Groupe : OneDrive
    ConfigForm_OneDriveModeLabel = "Gestion de OneDrive :"
    ConfigForm_OneDriveMode_Block = "Bloquer (politique système)"
    ConfigForm_OneDriveMode_Close = "Fermer au démarrage"
    ConfigForm_OneDriveMode_Ignore = "Ne rien faire"

    # Groupe : Fermeture & Application
    # MISE A JOUR v1.73 : Intégration des clés ici pour éviter les doublons
    ConfigForm_Section_Closure = "Fermeture Planifiée de l'Application"
    ConfigForm_EnableScheduledCloseCheckbox = "Activer la fermeture planifiée"
    ConfigForm_CloseTimeLabel = "Heure de Fermeture (HH:MM) :"
    ConfigForm_CloseCommandLabel = "Commande de fermeture à exécuter :"
    ConfigForm_CloseArgumentsLabel = "Arguments pour la commande :"

    # MISE A JOUR v1.73
    ConfigForm_Section_Reboot = "Redémarrage et Cycle Quotidien"
    ConfigForm_EnableScheduledRebootCheckbox = "Activer le redémarrage quotidien"
    ConfigForm_RebootTimeLabel = "Heure du Redémarrage Planifié (HH:MM) :"

    ConfigForm_ProcessToLaunchLabel = "Application à Lancer :"
    ConfigForm_ProcessArgumentsLabel = "Arguments pour l'application :"
    ConfigForm_ProcessToMonitorLabel = "Nom du Processus à Surveiller (sans .exe) :"
    ConfigForm_StartProcessMinimizedCheckbox = "Lancer l'application principale réduite dans la barre des tâches"
    ConfigForm_LaunchConsoleModeLabel = "Mode de Lancement Console :"
    ConfigForm_LaunchConsoleMode_Standard = "Lancement Standard (recommandé)"
    ConfigForm_LaunchConsoleMode_Legacy = "Lancement Legacy (console héritée)"

    # Groupe : Sauvegarde
    ConfigForm_DatabaseBackupGroupTitle = "Sauvegarde des Bases de Données (Optionnel)"
    ConfigForm_EnableBackupCheckbox = "Activer la sauvegarde avant redémarrage"
    ConfigForm_BackupSourceLabel = "Dossier source des données :"
    ConfigForm_BackupDestinationLabel = "Dossier de destination de la sauvegarde :"
    ConfigForm_BackupTimeLabel = "Heure de la sauvegarde (HH:MM) :"
    ConfigForm_BackupKeepDaysLabel = "Durée de conservation des sauvegardes (en jours) :"

    # Groupe : Options Installation & Compte Cible
    ConfigForm_InstallOptionsGroup = "Options d'Installation"
    ConfigForm_SilentModeCheckbox = "Masquer les fenêtres de console pendant l'installation/désinstallation"
    ConfigForm_OtherAccountGroupTitle = "Personnaliser pour un Autre Utilisateur"
    ConfigForm_OtherAccountDescription = "Permet de spécifier un compte utilisateur alternatif pour l'exécution des tâches planifiées. Nécessite des privilèges d'administration pour la configuration inter-comptes."
    ConfigForm_OtherAccountUsernameLabel = "Nom du compte utilisateur à configurer :"

    # Boutons & Messages GUI
    ConfigForm_SaveButton = "Enregistrer et Fermer"
    ConfigForm_CancelButton = "Annuler"
    ConfigForm_SaveSuccessMessage = "Configuration enregistrée dans '{0}'"
    ConfigForm_SaveSuccess = "Configuration enregistrée avec succès !"
    ConfigForm_SaveSuccessCaption = "Succès"
    ConfigForm_ConfigWizardCancelled = "Assistant de configuration annulé."
    ConfigForm_PathError = "Impossible de déterminer les chemins du projet. Erreur: '{0}'. Le script va se fermer."
    ConfigForm_PathErrorCaption = "Erreur Critique Path"
    ConfigForm_ModelFileNotFoundError = "ERREUR: Le fichier modèle 'management\defaults\default_config.ini' est introuvable ET aucun 'config.ini' n'existe. Installation impossible."
    ConfigForm_ModelFileNotFoundCaption = "Fichier Modèle Manquant"
    ConfigForm_CopyError = "Impossible de créer le fichier 'config.ini' à partir du modèle. Erreur: '{0}'."
    ConfigForm_CopyErrorCaption = "Erreur de copie"
    ConfigForm_OverwritePrompt = "Un fichier de configuration 'config.ini' existe déjà.\n\nVoulez-vous le remplacer par le modèle par défaut ?\n\nATTENTION : Vos réglages actuels seront perdus."
    ConfigForm_OverwriteCaption = "Remplacer la configuration existante ?"
    ConfigForm_ResetSuccess = "Le fichier 'config.ini' a été réinitialisé avec les valeurs par défaut."
    ConfigForm_ResetSuccessCaption = "Réinitialisation Effectuée"
    ConfigForm_OverwriteError = "Impossible de remplacer 'config.ini' par le modèle. Erreur: '{0}'."
    ConfigForm_InvalidTimeFormat = "Le format des heures doit être HH:MM (ex: 03:55)."
    ConfigForm_InvalidTimeFormatCaption = "Format Invalide"
    ConfigForm_InvalidTimeLogic = "L'heure de fermeture doit être ANTÉRIEURE à l'heure du redémarrage planifié."
    ConfigForm_InvalidTimeLogicCaption = "Logique Temporelle Invalide"
    ConfigForm_AllSysOptimizedNote = "✔ Ces paramètres sont optimisés pour {0}. Il est recommandé de ne pas les modifier."

    # ------------------------------------------------------------------------------
    # 2. SCRIPT SYSTÈME (config_systeme.ps1)
    # ------------------------------------------------------------------------------

    # Logs Généraux
    Log_StartingScript = "Démarrage de '{0}' ('{1}')..."
    Log_CheckingNetwork = "Vérification de la connectivité réseau..."
    Log_NetworkDetected = "Connectivité réseau détectée."
    Log_NetworkRetry = "Réseau non disponible, nouvelle tentative dans 10s..."
    Log_NetworkFailed = "Réseau non établi. Gotify pourrait échouer."
    Log_ExecutingSystemActions = "Exécution des actions SYSTÈME configurées..."
    Log_SettingNotSpecified = "Le paramètre '{0}' n'est pas spécifié."
    Log_ScriptFinished = "'{0}' ('{1}') terminé."
    Log_ErrorsOccurred = "Des erreurs se sont produites durant l'exécution."
    Log_CapturedError = "ERREUR CAPTURÉE : '{0}'"
    Error_FatalScriptError = "ERREUR FATALE DU SCRIPT (bloc principal) : '{0}' \n'{1}'"
    System_ConfigCriticalError = "Échec critique : config.ini."

    # Gestion Utilisateur Cible
    Log_ReadRegistryForUser = "AutoLoginUsername non spécifié. Tentative de lecture de DefaultUserName depuis le Registre."
    Log_RegistryUserFound = "Utilisation de DefaultUserName du Registre comme utilisateur cible : '{0}'."
    Log_RegistryUserNotFound = "DefaultUserName du Registre non trouvé ou vide. Aucun utilisateur cible par défaut."
    Log_RegistryReadError = "Erreur lors de la lecture de DefaultUserName depuis le Registre : '{0}'"
    Log_ConfigUserFound = "Utilisation de AutoLoginUsername de config.ini comme utilisateur cible : '{0}'."

    # --- Actions : Paramètres Windows ---
    Log_DisablingFastStartup = "Cfg: Désactivation du démarrage rapide."
    Action_FastStartupDisabled = "- Le démarrage rapide de Windows est désactivé."
    Log_FastStartupAlreadyDisabled = "Le démarrage rapide de Windows est déjà désactivé."
    Action_FastStartupVerifiedDisabled = "- Le démarrage rapide de Windows est désactivé."

    Log_EnablingFastStartup = "Cfg: Activation du démarrage rapide."
    Action_FastStartupEnabled = "- Le démarrage rapide de Windows est activé."
    Log_FastStartupAlreadyEnabled = "Le démarrage rapide de Windows est déjà activé."
    Action_FastStartupVerifiedEnabled = "- Le démarrage rapide de Windows est activé."
    Error_DisableFastStartupFailed = "Échec de la désactivation du démarrage rapide : '{0}'"
    Error_EnableFastStartupFailed = "Échec de l'activation du démarrage rapide : '{0}'"

    Log_DisablingSleep = "Désactivation de la mise en veille de la machine..."
    Action_SleepDisabled = "- La mise en veille automatique est désactivée."
    Error_DisableSleepFailed = "Échec de la désactivation de la mise en veille automatique : '{0}'"

    Log_DisablingScreenSleep = "Désactivation de la mise en veille de l'écran..."
    Action_ScreenSleepDisabled = "- La mise en veille de l'écran est désactivée."
    Error_DisableScreenSleepFailed = "Échec de la désactivation de la mise en veille de l'écran : '{0}'"

    Log_DisablingUpdates = "Désactivation des mises à jour Windows..."
    Action_UpdatesDisabled = "- Le service Windows Update est bloqué."
    Log_EnablingUpdates = "Activation des mises à jour Windows..."
    Action_UpdatesEnabled = "- Le service Windows Update est actif."
    Error_UpdateMgmtFailed = "Échec de la gestion des mises à jour Windows : '{0}'"

    Log_DisablingAutoReboot = "Désactivation du redémarrage forcé par Windows Update..."
    Action_AutoRebootDisabled = "- Le redémarrage automatique après mise à jour est désactivé."
    Error_DisableAutoRebootFailed = "Échec de la désactivation du redémarrage automatique après mise à jour : '{0}'"

    # --- Actions : Session & OneDrive ---
    Log_EnablingAutoLogin = "Vérification/Activation de l'ouverture de session automatique..."
    Action_AutoAdminLogonEnabled = "- Ouverture de session automatique activée."
    Action_AutoLogonAutomatic = "- Ouverture de session automatique activée pour '{0}' (Mode : Autologon)."
    Action_AutoLogonSecure = "- Ouverture de session automatique activée pour '{0}' (Mode : Sécurisé)."
    Action_AutologonVerified = "- L'ouverture de session automatique est active."
    Action_DefaultUserNameSet = "Utilisateur par défaut défini sur : '{0}'."
    Log_AutoLoginUserUnknown = "Ouverture de session automatique activée mais l'utilisateur cible n'a pas pu être déterminé."
    Error_AutoLoginFailed = "Échec de la configuration de l'ouverture de session automatique : '{0}'"
    Error_AutoLoginUserUnknown = "Ouverture de session automatique activée mais l'utilisateur cible n'a pas pu être déterminé."
    Error_SecureAutoLoginFailed = "Échec de la configuration de la connexion sécurisée : '{0}'"
    Action_LockTaskConfigured = "Verrouillage de session unique configuré pour '{0}'."

    Log_DisablingAutoLogin = "Désactivation de l'ouverture de session automatique..."
    Action_AutoAdminLogonDisabled = "- L'ouverture de session automatique est désactivée."
    Error_DisableAutoLoginFailed = "Échec de la désactivation de l'ouverture de session automatique : '{0}'"

    Log_DisablingOneDrive = "Désactivation de OneDrive (politique)..."
    Log_EnablingOneDrive = "Activation/Maintien de OneDrive (politique)..."
    Action_OneDriveDisabled = "- OneDrive est désactivé (politique)."
    Action_OneDriveEnabled = "- OneDrive est autorisé."
    Action_OneDriveClosed = "- Processus OneDrive terminé."
    Action_OneDriveBlocked = "- OneDrive est bloqué (politique système) et le processus a été arrêté."
    Action_OneDriveAutostartRemoved = "- Démarrage automatique de OneDrive désactivé pour l'utilisateur '{0}'."
    Action_OneDriveIgnored = "- Politique de blocage OneDrive supprimée (mode Ignorer)."
    Error_DisableOneDriveFailed = "Échec de la désactivation de OneDrive : '{0}'"
    Error_EnableOneDriveFailed = "Échec de l'activation de OneDrive : '{0}'"
    Action_OneDriveClean = "- OneDrive est fermé et son démarrage est désactivé."

    # --- Actions : Planning (Futur) ---
    Log_ConfiguringReboot = "Configuration du redémarrage planifié à {0}..."
    Action_RebootScheduled = "- Redémarrage planifié à {0}."
    Error_RebootScheduleFailed = "Échec de la configuration de la tâche de redémarrage planifié ({0}) '{1}' : '{2}'."
    Log_RebootTaskRemoved = "Heure de redémarrage non spécifiée. Suppression de la tâche '{0}'."

    Action_BackupTaskConfigured = "- Sauvegarde des données planifiée à {0}."
    Error_BackupTaskFailed = "Échec de la configuration de la tâche de sauvegarde : '{0}'"
    System_BackupTaskDescription = "Orchestrator : Exécute la sauvegarde des données avant le redémarrage."
    System_BackupScriptNotFound = "Le script de sauvegarde dédié '{0}' est introuvable."

    # --- NOUVEAUX MESSAGES SYSTÈME V1.73 (Inférence) ---
    Log_System_BackupSynced = "- Heure de sauvegarde synchronisée avec la fermeture ({0}). Mode Watchdog activé."
    Log_System_RebootTaskSkipped = "- Redémarrage activé sans heure fixe. Tâche planifiée supprimée (sera géré par l'enchaînement)."
    Error_System_BackupNoTime = "Sauvegarde activée mais aucune heure définie ni heure de fermeture de référence. Tâche ignorée."

    # Gestion Processus Système (Tâche de fond)
    Log_System_NoProcessSpecified = "Aucune application à lancer spécifiée. Aucune action effectuée."
    Log_System_ProcessToMonitor = "Surveillance du nom de processus : '{0}'."
    Log_System_ProcessAlreadyRunning = "Le processus '{0}' (PID : {1}) est déjà en cours d'exécution. Aucune action nécessaire."
    Action_System_ProcessAlreadyRunning = "Le processus '{0}' est déjà en cours d'exécution (PID : {1})."
    Log_System_NoMonitor = "Aucun processus à surveiller spécifié. Saut de la vérification."
    Log_System_ProcessStarting = "Démarrage du processus en arrière-plan '{0}' via '{1}'..."
    Action_System_ProcessStarted = "- Processus en arrière-plan '{0}' démarré (via '{1}')."
    Error_System_ProcessManagementFailed = "Échec de la gestion du processus en arrière-plan '{0}' : '{1}'"
    Action_System_CloseTaskConfigured = "- Tâche d'arrêt du processus en arrière-plan configurée pour '{0}' à {1}."
    Error_System_CloseTaskFailed = "Échec de la création de la tâche d'arrêt du processus en arrière-plan : '{0}'"
    System_ProcessNotDefined = "L'application à lancer n'est pas définie pour le mode BackgroundTask (contexte SYSTEM sans interface graphique)."

    # ------------------------------------------------------------------------------
    # 3. SCRIPT UTILISATEUR (config_utilisateur.ps1)
    # ------------------------------------------------------------------------------
    Log_User_StartingScript = "Démarrage de '{0}' ('{1}') pour l'utilisateur '{2}'..."
    Log_User_ExecutingActions = "Exécution des actions configurées pour l'utilisateur '{0}'..."
    Log_User_CannotReadConfig = "Impossible de lire ou de parser '{0}'. Arrêt des configurations utilisateur."
    Log_User_ScriptFinished = "'{0}' ('{1}') pour l'utilisateur '{2}' terminé."

    Log_User_ManagingProcess = "Gestion du processus utilisateur (brut:'{0}', résolu:'{1}'). Méthode: '{2}'"
    Log_User_ProcessWithArgs = "Avec les arguments : '{0}'"
    Log_User_ProcessToMonitor = "Surveillance du nom de processus : '{0}'."
    Log_User_ProcessAlreadyRunning = "Le processus '{0}' (PID: {1}) est déjà en cours d'exécution pour l'utilisateur actuel. Aucune action nécessaire."
    Action_User_ProcessAlreadyRunning = "Le processus '{0}' est déjà en cours d'exécution (PID: {1})."
    Log_User_NoMonitor = "Aucun processus à surveiller spécifié. La vérification est ignorée."
    Log_User_NoProcessSpecified = "Aucun processus spécifié ou le chemin est vide."
    Log_User_BaseNameError = "Erreur lors de l'extraction du nom de base de '{0}' (direct)."
    Log_User_EmptyBaseName = "Le nom de base du processus à surveiller est vide."
    Log_User_WorkingDirFallback = "Le nom du processus '{0}' n'est pas un chemin de fichier; Dossier de travail défini sur '{1}' pour '{2}'."
    Log_User_WorkingDirNotFound = "Le répertoire de travail '{0}' est introuvable. Il ne sera pas défini."

    Log_User_ProcessStopping = "Le processus '{0}' (PID: {1}) est en cours d'exécution. Arrêt..."
    Action_User_ProcessStopped = "Processus '{0}' arrêté."
    Log_User_ProcessRestarting = "Redémarrage via '{0}': '{1}' avec les arguments: '{2}'"
    Action_User_ProcessRestarted = "- Processus '{0}' redémarré (via '{1}')."
    Log_User_ProcessStarting = "Processus '{0}' non trouvé. Démarrage via '{1}': '{2}' avec les arguments: '{3}'"
    Action_User_ProcessStarted = "- Processus '{0}' démarré."

    Error_User_LaunchMethodUnknown = "Méthode de lancement '{0}' non reconnue. Options: direct, powershell, cmd."
    Error_User_InterpreterNotFound = "Interpréteur '{0}' introuvable pour la méthode '{1}'."
    Error_User_ProcessManagementFailed = "Échec de la gestion du processus '{0}' (Méthode: '{1}', Chemin: '{2}', Args: '{3}'): '{4}'. StackTrace: '{5}'"
    Error_User_ExeNotFound = "Fichier exécutable pour le processus '{0}' (mode direct) INTROUVABLE."
    Error_User_FatalScriptError = "ERREUR FATALE DU SCRIPT UTILISATEUR '{0}': '{1}' \n'{2}'"
    Error_User_VarExpansionFailed = "Erreur lors de l'expansion des variables pour le processus '{0}': '{1}'"

    Action_User_CloseTaskConfigured = "- Fermeture de l'application prévue à {1}."
    Error_User_CloseTaskFailed = "Échec de la création de la tâche de fermeture de l'application '{0}' : '{1}'"

    # ------------------------------------------------------------------------------
    # 4. MODULE SAUVEGARDE (Invoke-DatabaseBackup.ps1)
    # ------------------------------------------------------------------------------
    Log_Backup_Starting = "Démarrage du processus de sauvegarde des bases de données..."
    Log_Backup_Disabled = "La sauvegarde de base de données est DÉSACTIVÉE dans config.ini. Ignoré."
    Log_Backup_PurgeStarting = "Début du nettoyage des anciennes sauvegardes (conservation des {0} derniers jours)..."
    Log_Backup_PurgingFile = "Purge de l'ancienne sauvegarde : '{0}'."
    Log_Backup_NoFilesToPurge = "Aucune ancienne sauvegarde à nettoyer."
    Log_Backup_RetentionPolicy = "Politique de rétention : {0} jour(s)."
    Log_Backup_NoFilesFound = "Aucun fichier modifié dans les dernières 24 heures trouvé pour la sauvegarde."
    Log_Backup_FilesFound = "{0} fichier(s) à sauvegarder trouvés (fichiers appairés inclus)."
    Log_Backup_CopyingFile = "Sauvegarde de '{0}' vers '{1}' réussie."
    Log_Backup_AlreadyRunning = "Sauvegarde déjà en cours (âge du verrou : {0} min). Ignoré."

    Action_Backup_Completed = "Sauvegarde de {0} fichier(s) terminée avec succès."
    Action_Backup_DestinationCreated = "Dossier de destination de la sauvegarde '{0}' créé."
    Action_Backup_PurgeCompleted = "Nettoyage de {0} ancienne(s) sauvegarde(s) terminé."

    Error_Backup_PathNotFound = "Le chemin source ou destination '{0}' pour la sauvegarde est introuvable. Opération annulée."
    Error_Backup_DestinationCreationFailed = "Échec de la création du dossier de destination '{0}' : '{1}'"
    Error_Backup_InsufficientPermissions = "Permissions insuffisantes pour écrire dans le dossier de sauvegarde : '{0}'"
    Error_Backup_InsufficientSpace = "Espace disque insuffisant. Requis : {0:N2} MB, Disponible : {1:N2} MB"
    Error_Backup_PurgeFailed = "Échec de la purge de l'ancienne sauvegarde '{0}' : '{1}'"
    Error_Backup_CopyFailed = "Échec de la sauvegarde du fichier '{0}' : '{1}'"
    Error_Backup_ProcessRunning = "ABANDON SAUVEGARDE : Le processus '{0}' est actif. Risque de corruption de données."
    Error_Backup_Critical = "ERREUR CRITIQUE lors du processus de sauvegarde : '{0}'"
    Backup_ConfigLoadError = "Impossible de lire config.ini"
    Backup_InitError = "Erreur critique d'initialisation : '{0}'"

    # --- NOUVEAUX MESSAGES WATCHDOG V1.73 ---
    Log_Backup_WatcherStarted = "Surveillance Watchdog démarrée pour le processus '{0}'."
    Log_Backup_ProcessClosed = "Processus '{0}' fermé avec succès."
    Log_Backup_TimeoutKill = "Processus '{0}' tué après timeout ({1}s)."
    Error_Backup_TimeoutNoKill = "Processus '{0}' toujours en cours après timeout ({1}s). Sauvegarde annulée."
    Log_Backup_ChainedReboot = "Redémarrage enchaîné initié après la fin de la sauvegarde."

    # ------------------------------------------------------------------------------
    # 5. INSTALLATION & DÉSINSTALLATION (install.ps1 / uninstall.ps1)
    # ------------------------------------------------------------------------------

    # Commun
    Install_ElevationWarning = "Échec de l'élévation des privilèges. Veuillez exécuter ce script en tant qu'administrateur."
    Uninstall_ElevationWarning = "Échec de l'élévation des privilèges. Veuillez exécuter ce script en tant qu'administrateur."
    Install_PressEnterToExit = "Appuyez sur Entrée pour quitter."
    Uninstall_PressEnterToExit = "Appuyez sur Entrée pour quitter."
    Install_PressEnterToClose = "Appuyez sur Entrée pour fermer cette fenêtre."
    Uninstall_PressEnterToClose = "Appuyez sur Entrée pour fermer cette fenêtre."
    Exit_AutoCloseMessage = "Cette fenêtre se fermera dans {0} secondes..."
    Install_RebootMessage = "Installation terminée. Le système va redémarrer dans {0} secondes pour appliquer la configuration."
    Uninstall_RebootMessage = "Désinstallation terminée. Le système va redémarrer dans {0} secondes pour nettoyer l'environnement."

    # Install - Initialisation
    Install_UnsupportedArchitectureError = "Architecture processeur non supportée : '{0}'"
    Install_ConfigIniNotFoundWarning = "config.ini non trouvé dans le répertoire parent présumé ('{0}')."
    Install_ProjectRootPrompt = "Veuillez entrer le chemin complet du répertoire racine des scripts WindowsOrchestrator (ex: C:\WindowsOrchestrator)"
    Install_InvalidProjectRootError = "Répertoire racine du projet invalide ou config.ini introuvable : '{0}'"
    Install_PathDeterminationError = "Erreur lors de la détermination des chemins initiaux : '{0}'"
    Install_MissingSystemFile = "Fichier système requis manquant : '{0}'"
    Install_MissingUserFile = "Fichier utilisateur requis manquant : '{0}'"
    Install_MissingFilesAborted = "Des fichiers de script principaux sont manquants dans '{0}'. Installation annulée. Appuyez sur Entrée pour quitter."
    Install_ProjectRootUsed = "Répertoire racine du projet utilisé : '{0}'"
    Install_UserTaskTarget = "La tâche utilisateur sera installée pour : '{0}'"
    Install_AutoLoginUserEmpty = "INFO : 'AutoLoginUsername' est vide. Remplissage avec l'utilisateur installateur..."
    Install_AutoLoginUserUpdated = "SUCCÈS : config.ini mis à jour avec 'AutoLoginUsername={0}'."
    Install_AutoLoginUserUpdateFailed = "AVERTISSEMENT : Échec de la mise à jour de 'AutoLoginUsername' dans config.ini : '{0}'"
    Install_LogPermissionsWarning = "AVERTISSEMENT : Impossible de créer ou de définir les permissions pour le dossier Logs. La journalisation pourrait échouer. Erreur : '{0}'"

    # Install - Assistant Autologon
    Install_AutologonAlreadyActive = "INFO : La connexion automatique Windows est déjà active. L'assistant n'est pas nécessaire."
    Install_DownloadingAutologon = "Téléchargement de l'outil Microsoft Autologon..."
    Install_AutologonDownloadFailed = "ERREUR : Échec du téléchargement de Autologon.zip. Vérifiez votre connexion internet."
    Install_ExtractingArchive = "Extraction de l'archive..."
    Install_AutologonFilesMissing = "Les fichiers requis ('{0}', Eula.txt) n'ont pas été trouvés après l'extraction."
    Install_AutologonExtractionFailed = "AVERTISSEMENT : Échec de la préparation de l'outil Autologon. L'archive téléchargée est peut-être corrompue."
    Install_AutologonDownloadFailedPrompt = "Le téléchargement a échoué. Souhaitez-vous rechercher le fichier Autologon.zip manuellement ?\n\nPage officielle : https://learn.microsoft.com/sysinternals/downloads/autologon"
    Install_AutologonUnsupportedArchitecture = "ERREUR : Architecture de processeur non supportée ('{0}'). Impossible de configurer Autologon."
    Install_EulaConsentMessage = "Acceptez-vous les termes de la licence de l'outil Autologon de Sysinternals ?"
    Install_EulaConsentCaption = "Consentement EULA requis"
    Install_PromptReviewEula = "Le Contrat de Licence Utilisateur Final (CLUF) de Microsoft va s'ouvrir dans le Bloc-notes. Veuillez le lire puis fermer la fenêtre pour continuer."
    Install_EulaConsentRefused = "Le consentement à la licence a été refusé par l'utilisateur. Configuration d'Autologon annulée."
    Install_EulaRejected = "Configuration d'Autologon annulée (EULA non accepté)."
    Install_PromptUseAutologonTool = "L'outil Autologon va maintenant s'ouvrir. Veuillez y saisir vos informations (Utilisateur, Domaine, Mot de passe) et cliquer sur 'Enable'."
    Install_AutologonSelectZipTitle = "Sélectionnez le fichier Autologon.zip téléchargé"
    Install_AutologonFileSelectedSuccess = "SUCCÈS : Le fichier local '{0}' va être utilisé."
    Install_AutologonSuccess = "SUCCÈS : L'outil Autologon a été exécuté. L'ouverture de session automatique devrait maintenant être configurée."
    Install_ContinueNoAutologon = "L'installation continue sans configurer Autologon."
    Install_AbortedByUser = "Installation annulée par l'utilisateur."
    Install_AutologonDownloadFailedCaption = "Échec de l'Assistant Autologon"
    Install_ConfirmContinueWithoutAutologon = "L'assistant Autologon a échoué. Voulez-vous continuer l'installation sans la connexion automatique ?"
    Install_AutologonManualDownloadPrompt = @"
Le téléchargement automatique de l'outil Autologon a échoué.

Vous pouvez le télécharger manuellement pour activer cette fonctionnalité.

1.  Ouvrez cette URL dans votre navigateur : https://learn.microsoft.com/sysinternals/downloads/autologon
2.  Téléchargez et extrayez 'Autologon.zip'.
3.  Placez tous les fichiers extraits (Autologon64.exe, etc.) dans le dossier suivant :
    {0}
4.  Relancez l'installation.

Voulez-vous continuer l'installation maintenant sans configurer Autologon ?
"@

    # Install - Mot de passe & Tâches
    Install_PasswordRequiredPrompt = "Le mode de session automatique est activé. Le mot de passe du compte '{0}' est REQUIS pour configurer la tâche planifiée de manière sécurisée."
    Install_PasswordSecurityInfo = "Ce mot de passe est transmis directement à l'API Windows et n'est JAMAIS stocké."
    Install_EnterPasswordPrompt = "Veuillez saisir le mot de passe pour le compte '{0}'"
    Install_PasswordIncorrect = "Mot de passe incorrect ou erreur de validation. Veuillez réessayer."
    Install_PasswordAttemptsRemaining = "Tentatives restantes : {0}."
    Install_PasswordEmptyToCancel = "(Laissez vide et appuyez sur Entrée pour annuler)"
    Install_PasswordMaxAttemptsReached = "Nombre maximal de tentatives atteint. Installation annulée."
    Install_StartConfiguringTasks = "Début de la configuration des tâches planifiées..."
    Install_CreatingSystemTask = "Création/Mise à jour de la tâche système '{0}'..."
    Install_SystemTaskDescription = "WindowsOrchestrator: Exécute le script de configuration système au démarrage."
    Install_SystemTaskConfiguredSuccess = "Tâche '{0}' configurée avec succès."
    Install_CreatingUserTask = "Création/Mise à jour de la tâche utilisateur '{0}' pour '{1}'..."
    Install_UserTaskDescription = "WindowsOrchestrator: Exécute le script de configuration utilisateur à l'ouverture de session."
    Install_MainTasksConfigured = "Tâches planifiées principales configurées."
    Install_DailyRebootTasksNote = "Les tâches pour le redémarrage quotidien et l'action de fermeture seront gérées par '{0}' lors de son exécution."
    Install_TaskCreationSuccess = "Tâches créées avec succès en utilisant les identifiants fournis."

    # Install - Exécution & Fin
    Install_AttemptingInitialLaunch = "Tentative de lancement initial des scripts de configuration..."
    Install_ExecutingSystemScript = "Exécution de config_systeme.ps1 pour appliquer les configurations système initiales..."
    Install_SystemScriptSuccess = "config_systeme.ps1 exécuté avec succès (code de sortie 0)."
    Install_SystemScriptWarning = "config_systeme.ps1 s'est terminé avec un code de sortie : {0}. Vérifiez les logs dans '{1}\Logs'."
    Install_SystemScriptError = "Erreur lors de l'exécution initiale de config_systeme.ps1 : '{0}'"
    Install_Trace = "Trace : '{0}'"
    Install_ExecutingUserScript = "Exécution de config_utilisateur.ps1 pour '{0}' pour appliquer les configurations utilisateur initiales..."
    Install_UserConfigLaunched = "SUCCÈS : Le script de configuration utilisateur a été lancé."
    Install_UserScriptSuccess = "config_utilisateur.ps1 exécuté avec succès pour '{0}' (code de sortie 0)."
    Install_UserScriptWarning = "config_utilisateur.ps1 pour '{0}' s'est terminé avec un code de sortie : '{1}'. Vérifiez les logs dans '{2}\Logs'."
    Install_UserScriptError = "Erreur lors de l'exécution initiale de config_utilisateur.ps1 pour '{0}': '{1}'"
    Install_InstallationCompleteSuccess = "Installation et lancement initial terminés !"
    Install_InstallationCompleteWithErrors = "Installation terminée avec des erreurs lors du lancement initial des scripts. Vérifiez les messages ci-dessus."
    Install_CriticalErrorDuringInstallation = "Une erreur critique est survenue durant l'installation : '{0}'"
    Install_SilentMode_CompletedSuccessfully = "Installation de WindowsOrchestrator terminée avec succès !\n\nTous les journaux ont été enregistrés dans le dossier Logs."
    Install_SilentMode_CompletedWithErrors = "Installation de WindowsOrchestrator terminée avec des erreurs.\n\nVeuillez consulter les fichiers journaux dans le dossier Logs pour plus de détails."

    # Uninstall
    Uninstall_StartMessage = "Début de la désinstallation complète de WindowsOrchestrator..."
    Uninstall_AutoLogonQuestion = "[QUESTION] WindowsOrchestrator a peut-être activé l'ouverture de session automatique (Autologon). Voulez-vous la désactiver maintenant ? (o/n)"
    Uninstall_RestoringSettings = "Restauration des principaux paramètres Windows..."
    Uninstall_WindowsUpdateReactivated = "- Mises à jour Windows et redémarrage automatique : Réactivés."
    Uninstall_WindowsUpdateError = "- ERREUR lors de la réactivation de Windows Update : '{0}'"
    Uninstall_FastStartupReactivated = "- Démarrage rapide de Windows : Réactivé (valeur par défaut)."
    Uninstall_FastStartupError = "- ERREUR lors de la réactivation du démarrage rapide : '{0}'"
    Uninstall_OneDriveReactivated = "- OneDrive : Réactivé (politique de blocage supprimée)."
    Uninstall_OneDriveError = "- ERREUR lors de la réactivation de OneDrive : '{0}'"
    Uninstall_DeletingScheduledTasks = "Suppression des tâches planifiées..."
    Uninstall_ProcessingTask = "Traitement de la tâche '{0}'..."
    Uninstall_TaskFoundAttemptingDeletion = " Trouvée. Tentative de suppression..."
    Uninstall_TaskSuccessfullyRemoved = " Supprimée avec succès."
    Uninstall_TaskDeletionFailed = " ÉCHEC de la suppression."
    Uninstall_TaskDeletionError = " ERREUR lors de la suppression."
    Uninstall_TaskErrorDetail = "   Détail: '{0}'"
    Uninstall_TaskNotFound = " Non trouvée."
    Uninstall_CompletionMessage = "Désinstallation terminée."
    Uninstall_TasksNotRemovedWarning = "Certaines tâches n'ont PAS pu être supprimées : '{0}'."
    Uninstall_CheckTaskScheduler = "Veuillez vérifier le Planificateur de Tâches."
    Uninstall_FilesNotDeletedNote = "Note : Les scripts et fichiers de configuration ne sont pas supprimés de votre disque."
    Uninstall_LSACleanAttempt = "INFO : Tentative de nettoyage complet des secrets LSA via Autologon.exe..."
    Uninstall_AutoLogonDisabled = "- Ouverture de session automatique : Désactivée (via l'outil Autologon)."
    Uninstall_AutoLogonDisableError = "- ERREUR lors de la tentative de désactivation de l'ouverture de session automatique : '{0}'"
    Uninstall_AutoLogonLeftAsIs = "- Ouverture de session automatique : Laissée en l'état (choix de l'utilisateur)."
    Uninstall_AutologonToolNotFound_Interactive = "[AVERTISSEMENT] L'outil Autologon.exe est introuvable. La désactivation automatique ne peut être effectuée. Si vous souhaitez désactiver la connexion automatique, veuillez le faire manuellement."
    Uninstall_AutologonDisablePrompt = "Veuillez cliquer sur 'Disable' dans la fenêtre de l'outil Autologon qui va s'ouvrir pour finaliser le nettoyage."
    Uninstall_AutologonNotActive = "INFO : L'ouverture de session automatique n'est pas active. Aucun nettoyage nécessaire."
    Uninstall_SilentMode_CompletedSuccessfully = "Désinstallation de WindowsOrchestrator terminée avec succès !\n\nTous les journaux ont été enregistrés dans le dossier Logs."
    Uninstall_SilentMode_CompletedWithErrors = "Désinstallation de WindowsOrchestrator terminée avec des erreurs.\n\nVeuillez consulter les fichiers journaux dans le dossier Logs pour plus de détails."

    # ------------------------------------------------------------------------------
    # 6. NOTIFICATIONS (Gotify) & COMMUNS
    # ------------------------------------------------------------------------------
    Gotify_MessageDate = "Exécuté le {0}."
    Gotify_SystemActionsHeader = "Actions SYSTÈME :"
    Gotify_NoSystemActions = "Aucune action SYSTÈME."
    Gotify_SystemErrorsHeader = "Erreurs SYSTÈME :"
    Gotify_UserActionsHeader = "Actions UTILISATEUR :"
    Gotify_NoUserActions = "Aucune action UTILISATEUR."
    Gotify_UserErrorsHeader = "Erreurs UTILISATEUR :"
    Error_LanguageFileLoad = "Une erreur critique est survenue lors du chargement des fichiers de langue : '{0}'"
    Error_InvalidConfigValue = "Valeur de configuration invalide pour [{0}]{1} : '{2}'. Type attendu '{3}'. La valeur par défaut/vide est utilisée."
    Install_SplashMessage = "Opération en cours, veuillez patienter..."

    # --- v1.73 Mode Pont ---
    Log_System_RebootBridgeScheduled = '- Redémarrage activé (Pont après Fermeture + {0} min : {1}).'
}
