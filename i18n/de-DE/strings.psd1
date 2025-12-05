@{
    # ==============================================================================
    # SPRACHDATEI : DEUTSCH (DE-DE)
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 1. GRAFISCHE BENUTZEROBERFLÄCHE (firstconfig.ps1)
    # ------------------------------------------------------------------------------

    # Titel & Navigation
    ConfigForm_Title = "Konfigurationsassistent - WindowsOrchestrator"
    ConfigForm_Tab_Basic = "Grundlagen"
    ConfigForm_Tab_Advanced = "Erweitert"
    ConfigForm_SubTabMain = "Haupt"
    ConfigForm_SubTabBackup = "Sicherung"
    ConfigForm_SubTabOtherAccount = "Optionen & Konto"

    # Gruppe : Benutzersitzung
    ConfigForm_EnableSessionManagementCheckbox = "Automatische Anmeldung aktivieren (Autologon)"
    ConfigForm_SecureAutologonModeDescription = "(Öffnet den Desktop und sperrt die Sitzung sofort)"
    ConfigForm_BackgroundTaskModeDescription = "(Startet die Anwendung unsichtbar im Hintergrund ohne grafische Sitzung)"
    ConfigForm_SessionEulaNote = "(Durch Aktivieren akzeptieren Sie die Lizenz des Microsoft Autologon-Tools)"
    ConfigForm_UseAutologonAssistantCheckbox = "Assistenten zum Konfigurieren des Autologon-Tools verwenden (falls erforderlich)"
    ConfigForm_AutoLoginUsernameLabel = "Benutzername für Autologon (optional) :"

    # Gruppe : Windows-Einstellungen
    ConfigForm_WindowsSettingsGroup = "Windows-Einstellungen"
    ConfigForm_DisableFastStartupCheckbox = "Schnellstart von Windows deaktivieren"
    ConfigForm_DisableSleepCheckbox = "Automatischen Energiesparmodus deaktivieren"
    ConfigForm_DisableScreenSleepCheckbox = "Automatischen Bildschirmschoner deaktivieren"
    ConfigForm_DisableWindowsUpdateCheckbox = "Windows Update-Dienst blockieren"
    ConfigForm_DisableAutoRebootCheckbox = "Automatischen Neustart nach Update deaktivieren"

    # Gruppe : OneDrive
    ConfigForm_OneDriveModeLabel = "OneDrive-Verwaltung :"
    ConfigForm_OneDriveMode_Block = "Blockieren (Systemrichtlinie)"
    ConfigForm_OneDriveMode_Close = "Beim Start schließen"
    ConfigForm_OneDriveMode_Ignore = "Nichts tun"

    # Gruppe : Geplante Schließung & Anwendung
    ConfigForm_CloseAppGroupTitle = "Geplante Anwendungsschließung"
    ConfigForm_CloseTimeLabel = "Schließzeit (HH:MM) :"
    ConfigForm_CloseCommandLabel = "Ausführender Schließbefehl :"
    ConfigForm_CloseArgumentsLabel = "Argumente für den Befehl :"

    ConfigForm_MainAppGroupTitle = "Hauptanwendung und Täglicher Zyklus"
    ConfigForm_RebootTimeLabel = "Geplante Neustartzeit (HH:MM) :"
    ConfigForm_ProcessToLaunchLabel = "Zu startende Anwendung :"
    ConfigForm_ProcessArgumentsLabel = "Argumente für die Anwendung :"
    ConfigForm_ProcessToMonitorLabel = "Zu überwachender Prozessname (ohne .exe) :"
    ConfigForm_StartProcessMinimizedCheckbox = "Hauptanwendung minimiert in der Taskleiste starten"
    ConfigForm_LaunchConsoleModeLabel = "Konsolenstartmodus :"
    ConfigForm_LaunchConsoleMode_Standard = "Standardstart (empfohlen)"
    ConfigForm_LaunchConsoleMode_Legacy = "Legacy-Start (veraltete Konsole)"

    # Gruppe : Sicherung
    ConfigForm_DatabaseBackupGroupTitle = "Datenbanksicherung (Optional)"
    ConfigForm_EnableBackupCheckbox = "Sicherung vor Neustart aktivieren"
    ConfigForm_BackupSourceLabel = "Quelldatenordner :"
    ConfigForm_BackupDestinationLabel = "Sicherungszielordner :"
    ConfigForm_BackupTimeLabel = "Sicherungszeit (HH:MM) :"
    ConfigForm_BackupKeepDaysLabel = "Aufbewahrungsdauer der Sicherungen (in Tagen) :"

    # Gruppe : Installationsoptionen & Zielkonto
    ConfigForm_InstallOptionsGroup = "Installationsoptionen"
    ConfigForm_SilentModeCheckbox = "Konsolenfenster während Installation/Deinstallation ausblenden"
    ConfigForm_OtherAccountGroupTitle = "Für einen anderen Benutzer anpassen"
    ConfigForm_OtherAccountDescription = "Ermöglicht die Angabe eines alternativen Benutzerkontos für die Ausführung geplanter Aufgaben. Erfordert Administratorrechte für kontoübergreifende Konfiguration."
    ConfigForm_OtherAccountUsernameLabel = "Zu konfigurierender Benutzerkontoname :"

    # Schaltflächen & GUI-Nachrichten
    ConfigForm_SaveButton = "Speichern und Schließen"
    ConfigForm_CancelButton = "Abbrechen"
    ConfigForm_SaveSuccessMessage = "Konfiguration in '{0}' gespeichert"
    ConfigForm_SaveSuccess = "Konfiguration erfolgreich gespeichert!"
    ConfigForm_SaveSuccessCaption = "Erfolg"
    ConfigForm_ConfigWizardCancelled = "Konfigurationsassistent abgebrochen."
    ConfigForm_PathError = "Projektpfade konnten nicht bestimmt werden. Fehler: '{0}'. Das Skript wird beendet."
    ConfigForm_PathErrorCaption = "Kritischer Pfadfehler"
    ConfigForm_ModelFileNotFoundError = "FEHLER: Die Modelldatei 'management\defaults\default_config.ini' ist NICHT VORHANDEN und keine 'config.ini' existiert. Installation unmöglich."
    ConfigForm_ModelFileNotFoundCaption = "Modelldatei fehlt"
    ConfigForm_CopyError = "Die Datei 'config.ini' konnte nicht aus der Vorlage erstellt werden. Fehler: '{0}'."
    ConfigForm_CopyErrorCaption = "Kopierfehler"
    ConfigForm_OverwritePrompt = "Eine Konfigurationsdatei 'config.ini' existiert bereits.\n\nMöchten Sie sie durch die Standardvorlage ersetzen?\n\nACHTUNG: Ihre aktuellen Einstellungen gehen verloren."
    ConfigForm_OverwriteCaption = "Vorhandene Konfiguration ersetzen?"
    ConfigForm_ResetSuccess = "Die Datei 'config.ini' wurde mit den Standardwerten zurückgesetzt."
    ConfigForm_ResetSuccessCaption = "Zurücksetzung durchgeführt"
    ConfigForm_OverwriteError = "'config.ini' konnte nicht durch die Vorlage ersetzt werden. Fehler: '{0}'."
    ConfigForm_InvalidTimeFormat = "Das Zeitformat muss HH:MM sein (z.B. 03:55)."
    ConfigForm_InvalidTimeFormatCaption = "Ungültiges Format"
    ConfigForm_InvalidTimeLogic = "Die Schließzeit muss VOR der geplanten Neustartzeit liegen."
    ConfigForm_InvalidTimeLogicCaption = "Ungültige Zeitlogik"
    ConfigForm_AllSysOptimizedNote = "✔ Diese Einstellungen sind für die Systemstabilität und den reibungslosen Betrieb Ihrer Anwendung optimiert. Es wird empfohlen, sie nicht zu ändern."

    # ------------------------------------------------------------------------------
    # 2. SYSTEMSKRIPT (config_systeme.ps1)
    # ------------------------------------------------------------------------------

    # Allgemeine Protokolle
    Log_StartingScript = "Starte '{0}' ('{1}')..."
    Log_CheckingNetwork = "Netzwerkverbindung prüfen..."
    Log_NetworkDetected = "Netzwerkverbindung erkannt."
    Log_NetworkRetry = "Netzwerk nicht verfügbar, neuer Versuch in 10s..."
    Log_NetworkFailed = "Netzwerk nicht hergestellt. Gotify könnte fehlschlagen."
    Log_ExecutingSystemActions = "Ausführung der konfigurierten SYSTEM-Aktionen..."
    Log_SettingNotSpecified = "Der Parameter '{0}' ist nicht angegeben."
    Log_ScriptFinished = "'{0}' ('{1}') beendet."
    Log_ErrorsOccurred = "Während der Ausführung sind Fehler aufgetreten."
    Log_CapturedError = "ERFASSTER FEHLER: '{0}'"
    Error_FatalScriptError = "SKRIPT-FATALFEHLER (Hauptblock): '{0}' \n'{1}'"
    System_ConfigCriticalError = "Kritischer Fehler: config.ini."

    # Zielbenutzer-Verwaltung
    Log_ReadRegistryForUser = "AutoLoginUsername nicht angegeben. Versuche, DefaultUserName aus der Registry zu lesen."
    Log_RegistryUserFound = "Verwende DefaultUserName aus Registry als Zielbenutzer: '{0}'."
    Log_RegistryUserNotFound = "DefaultUserName aus Registry nicht gefunden oder leer. Kein Standardzielbenutzer."
    Log_RegistryReadError = "Fehler beim Lesen von DefaultUserName aus Registry: '{0}'"
    Log_ConfigUserFound = "Verwende AutoLoginUsername aus config.ini als Zielbenutzer: '{0}'."

    # --- Aktionen: Windows-Einstellungen ---
    Log_DisablingFastStartup = "Cfg: Schnellstart deaktivieren."
    Action_FastStartupDisabled = "- Schnellstart von Windows ist deaktiviert."
    Log_FastStartupAlreadyDisabled = "Schnellstart von Windows ist bereits deaktiviert."
    Action_FastStartupVerifiedDisabled = "- Schnellstart von Windows ist deaktiviert."
    Log_EnablingFastStartup = "Cfg: Schnellstart aktivieren."
    Action_FastStartupEnabled = "- Schnellstart von Windows ist aktiviert."
    Log_FastStartupAlreadyEnabled = "Schnellstart von Windows ist bereits aktiviert."
    Action_FastStartupVerifiedEnabled = "- Schnellstart von Windows ist aktiviert."
    Error_DisableFastStartupFailed = "Fehler beim Deaktivieren des Schnellstarts: '{0}'"
    Error_EnableFastStartupFailed = "Fehler beim Aktivieren des Schnellstarts: '{0}'"

    Log_DisablingSleep = "Automatischen Energiesparmodus deaktivieren..."
    Action_SleepDisabled = "- Automatischer Energiesparmodus ist deaktiviert."
    Error_DisableSleepFailed = "Fehler beim Deaktivieren des automatischen Energiesparmodus: '{0}'"

    Log_DisablingScreenSleep = "Bildschirmschoner deaktivieren..."
    Action_ScreenSleepDisabled = "- Bildschirmschoner ist deaktiviert."
    Error_DisableScreenSleepFailed = "Fehler beim Deaktivieren des Bildschirmschoners: '{0}'"

    Log_DisablingUpdates = "Windows-Updates deaktivieren..."
    Action_UpdatesDisabled = "- Windows Update-Dienst ist blockiert."
    Log_EnablingUpdates = "Windows-Updates aktivieren..."
    Action_UpdatesEnabled = "- Windows Update-Dienst ist aktiv."
    Error_UpdateMgmtFailed = "Fehler bei der Update-Verwaltung: '{0}'"

    Log_DisablingAutoReboot = "Automatischen Neustart nach Windows Update deaktivieren..."
    Action_AutoRebootDisabled = "- Automatischer Neustart nach Update ist deaktiviert."
    Error_DisableAutoRebootFailed = "Fehler beim Deaktivieren des automatischen Neustarts nach Update: '{0}'"

    # --- Aktionen: Sitzung & OneDrive ---
    Log_EnablingAutoLogin = "Automatische Anmeldung prüfen/aktivieren..."
    Action_AutoAdminLogonEnabled = "- Automatische Anmeldung aktiviert."
    Action_AutoLogonAutomatic = "- Automatische Anmeldung für '{0}' aktiviert (Modus: Autologon)."
    Action_AutoLogonSecure = "- Automatische Anmeldung für '{0}' aktiviert (Modus: Sicher)."
    Action_AutologonVerified = "- Automatische Anmeldung ist aktiv."
    Action_DefaultUserNameSet = "Standardbenutzername gesetzt auf: '{0}'."
    Log_AutoLoginUserUnknown = "Automatische Anmeldung aktiviert, aber Zielbenutzer konnte nicht bestimmt werden."
    Error_AutoLoginFailed = "Fehler bei der Konfiguration der automatischen Anmeldung: '{0}'"
    Error_AutoLoginUserUnknown = "Automatische Anmeldung aktiviert, aber Zielbenutzer konnte nicht bestimmt werden."
    Error_SecureAutoLoginFailed = "Fehler bei der Konfiguration der sicheren Anmeldung: '{0}'"
    Action_LockTaskConfigured = "Einmalige Sitzungssperre für '{0}' konfiguriert."

    Log_DisablingAutoLogin = "Automatische Anmeldung deaktivieren..."
    Action_AutoAdminLogonDisabled = "- Automatische Anmeldung ist deaktiviert."
    Error_DisableAutoLoginFailed = "Fehler beim Deaktivieren der automatischen Anmeldung: '{0}'"

    Log_DisablingOneDrive = "OneDrive deaktivieren (Richtlinie)..."
    Log_EnablingOneDrive = "OneDrive aktivieren/wiederherstellen (Richtlinie)..."
    Action_OneDriveDisabled = "- OneDrive ist deaktiviert (Richtlinie)."
    Action_OneDriveEnabled = "- OneDrive ist erlaubt."
    Action_OneDriveClosed = "- OneDrive-Prozess beendet."
    Action_OneDriveBlocked = "- OneDrive ist blockiert (Systemrichtlinie) und Prozess wurde gestoppt."
    Action_OneDriveAutostartRemoved = "- Autostart von OneDrive für Benutzer '{0}' deaktiviert."
    Action_OneDriveIgnored = "- OneDrive-Blockierungsrichtlinie entfernt (Ignorieren-Modus)."
    Error_DisableOneDriveFailed = "Fehler beim Deaktivieren von OneDrive: '{0}'"
    Error_EnableOneDriveFailed = "Fehler beim Aktivieren von OneDrive: '{0}'"
    Action_OneDriveClean = "- OneDrive ist geschlossen und Autostart deaktiviert."

    # --- Aktionen: Planung (Zukunft) ---
    Log_ConfiguringReboot = "Geplanten Neustart um {0} konfigurieren..."
    Action_RebootScheduled = "- Neustart um {0} geplant."
    Error_RebootScheduleFailed = "Fehler bei der Konfiguration der geplanten Neustartaufgabe ({0}) '{1}': '{2}'."
    Log_RebootTaskRemoved = "Keine Neustartzeit angegeben. Aufgabe '{0}' entfernen."
    Action_BackupTaskConfigured = "- Datensicherung um {0} geplant."
    Error_BackupTaskFailed = "Fehler bei der Konfiguration der Sicherungsaufgabe: '{0}'"
    System_BackupTaskDescription = "Orchestrator: Führt Datensicherung vor Neustart aus."
    System_BackupScriptNotFound = "Dediziertes Sicherungsskript '{0}' nicht gefunden."

    # Prozessverwaltung System (Hintergrundaufgabe)
    Log_System_NoProcessSpecified = "Keine zu startende Anwendung angegeben. Keine Aktion ausgeführt."
    Log_System_ProcessToMonitor = "Überwachung des Prozessnamens: '{0}'."
    Log_System_ProcessAlreadyRunning = "Prozess '{0}' (PID: {1}) läuft bereits. Keine Aktion erforderlich."
    Action_System_ProcessAlreadyRunning = "Prozess '{0}' läuft bereits (PID: {1})."
    Log_System_NoMonitor = "Kein zu überwachender Prozess angegeben. Überprüfung übersprungen."
    Log_System_ProcessStarting = "Hintergrundprozess '{0}' über '{1}' starten..."
    Action_System_ProcessStarted = "- Hintergrundprozess '{0}' gestartet (über '{1}')."
    Error_System_ProcessManagementFailed = "Fehler bei der Verwaltung des Hintergrundprozesses '{0}': '{1}'"
    Action_System_CloseTaskConfigured = "- Stoppaufgabe für Hintergrundprozess '{0}' um {1} konfiguriert."
    Error_System_CloseTaskFailed = "Fehler bei der Erstellung der Stoppaufgabe für Hintergrundprozess: '{0}'"
    System_ProcessNotDefined = "Die zu startende Anwendung ist für den BackgroundTask-Modus nicht definiert (SYSTEM-Kontext ohne grafische Sitzung)."

    # ------------------------------------------------------------------------------
    # 3. BENUTZERSKRIPT (config_utilisateur.ps1)
    # ------------------------------------------------------------------------------
    Log_User_StartingScript = "Starte '{0}' ('{1}') für Benutzer '{2}'..."
    Log_User_ExecutingActions = "Ausführung der konfigurierten Aktionen für Benutzer '{0}'..."
    Log_User_CannotReadConfig = "'{0}' kann nicht gelesen oder geparst werden. Benutzerkonfigurationen übersprungen."
    Log_User_ScriptFinished = "'{0}' ('{1}') für Benutzer '{2}' beendet."

    Log_User_ManagingProcess = "Benutzerprozessverwaltung (roh:'{0}', aufgelöst:'{1}'). Methode: '{2}'"
    Log_User_ProcessWithArgs = "Mit Argumenten: '{0}'"
    Log_User_ProcessToMonitor = "Überwachung des Prozessnamens: '{0}'."
    Log_User_ProcessAlreadyRunning = "Prozess '{0}' (PID: {1}) läuft bereits für aktuellen Benutzer. Keine Aktion erforderlich."
    Action_User_ProcessAlreadyRunning = "Prozess '{0}' läuft bereits (PID: {1})."
    Log_User_NoMonitor = "Kein zu überwachender Prozess angegeben. Überprüfung übersprungen."
    Log_User_NoProcessSpecified = "Kein Prozess angegeben oder Pfad leer."
    Log_User_BaseNameError = "Fehler beim Extrahieren des Basisnamens von '{0}' (direkt)."
    Log_User_EmptyBaseName = "Der Basisname des zu überwachenden Prozesses ist leer."
    Log_User_WorkingDirFallback = "Prozessname '{0}' ist kein Dateipfad; Arbeitsverzeichnis für '{1}' auf '{2}' gesetzt."
    Log_User_WorkingDirNotFound = "Arbeitsverzeichnis '{0}' nicht gefunden. Wird nicht gesetzt."
    Log_User_ProcessStopping = "Prozess '{0}' (PID: {1}) läuft. Stoppen..."
    Action_User_ProcessStopped = "Prozess '{0}' gestoppt."
    Log_User_ProcessRestarting = "Neustart über '{0}': '{1}' mit Argumenten: '{2}'"
    Action_User_ProcessRestarted = "- Prozess '{0}' neugestartet (über '{1}')."
    Log_User_ProcessStarting = "Prozess '{0}' nicht gefunden. Start über '{1}': '{2}' mit Argumenten: '{3}'"
    Action_User_ProcessStarted = "- Prozess '{0}' gestartet."
    Error_User_LaunchMethodUnknown = "Unbekannte Startmethode '{0}'. Optionen: direct, powershell, cmd."
    Error_User_InterpreterNotFound = "Interpreter '{0}' für Methode '{1}' nicht gefunden."
    Error_User_ProcessManagementFailed = "Fehler bei der Prozessverwaltung '{0}' (Methode: '{1}', Pfad: '{2}', Args: '{3}'): '{4}'. StackTrace: '{5}'"
    Error_User_ExeNotFound = "Ausführbare Datei für Prozess '{0}' (direkter Modus) NICHT GEFUNDEN."
    Error_User_FatalScriptError = "FATALER BENUTZERSKRIPT-FEHLER '{0}': '{1}' \n'{2}'"
    Error_User_VarExpansionFailed = "Fehler bei der Variablenerweiterung für Prozess '{0}': '{1}'"
    Action_User_CloseTaskConfigured = "- Anwendungsschließung um {1} geplant."
    Error_User_CloseTaskFailed = "Fehler bei der Erstellung der Anwendungsschließungsaufgabe '{0}': '{1}'"

    # ------------------------------------------------------------------------------
    # 4. SICHERUNGSMODUL (Invoke-DatabaseBackup.ps1)
    # ------------------------------------------------------------------------------
    Log_Backup_Starting = "Starte Datenbanksicherungsprozess..."
    Log_Backup_Disabled = "Datenbanksicherung ist in config.ini DEAKTIVIERT. Übersprungen."
    Log_Backup_PurgeStarting = "Beginn der Bereinigung alter Sicherungen (Aufbewahrung der letzten {0} Tage)..."
    Log_Backup_PurgingFile = "Alte Sicherung löschen: '{0}'."
    Log_Backup_NoFilesToPurge = "Keine alten Sicherungen zu bereinigen."
    Log_Backup_RetentionPolicy = "Aufbewahrungsrichtlinie: {0} Tag(e)."
    Log_Backup_NoFilesFound = "Keine geänderten Dateien in den letzten 24 Stunden für Sicherung gefunden."
    Log_Backup_FilesFound = "{0} Datei(en) zur Sicherung gefunden (gepaarte Dateien eingeschlossen)."
    Log_Backup_CopyingFile = "Sicherung von '{0}' nach '{1}' erfolgreich."
    Log_Backup_AlreadyRunning = "Sicherung läuft bereits (Alter der Sperre: {0} Min). Übersprungen."
    Action_Backup_Completed = "Sicherung von {0} Datei(en) erfolgreich abgeschlossen."
    Action_Backup_DestinationCreated = "Sicherungszielordner '{0}' erstellt."
    Action_Backup_PurgeCompleted = "Bereinigung von {0} alter Sicherung(en) abgeschlossen."
    Error_Backup_PathNotFound = "Quell- oder Zielpfad '{0}' für Sicherung nicht gefunden. Vorgang abgebrochen."
    Error_Backup_DestinationCreationFailed = "Fehler bei der Erstellung des Zielordners '{0}': '{1}'"
    Error_Backup_InsufficientPermissions = "Unzureichende Berechtigungen zum Schreiben in Sicherungsordner: '{0}'"
    Error_Backup_InsufficientSpace = "Unzureichender Speicherplatz. Erforderlich: {0:N2} MB, Verfügbar: {1:N2} MB"
    Error_Backup_PurgeFailed = "Fehler bei der Bereinigung der alten Sicherung '{0}': '{1}'"
    Error_Backup_CopyFailed = "Fehler bei der Sicherung der Datei '{0}': '{1}'"
    Error_Backup_Critical = "KRITISCHER FEHLER beim Sicherungsprozess: '{0}'"
    Backup_ConfigLoadError = "config.ini kann nicht gelesen werden"
    Backup_InitError = "Kritischer Initialisierungsfehler: '{0}'"

    # ------------------------------------------------------------------------------
    # 5. INSTALLATION & DEINSTALLATION (install.ps1 / uninstall.ps1)
    # ------------------------------------------------------------------------------
    # Gemeinsam
    Install_ElevationWarning = "Erhöhung der Berechtigungen fehlgeschlagen. Bitte führen Sie dieses Skript als Administrator aus."
    Uninstall_ElevationWarning = "Erhöhung der Berechtigungen fehlgeschlagen. Bitte führen Sie dieses Skript als Administrator aus."
    Install_PressEnterToExit = "Drücken Sie Enter, um zu beenden."
    Uninstall_PressEnterToExit = "Drücken Sie Enter, um zu beenden."
    Install_PressEnterToClose = "Drücken Sie Enter, um dieses Fenster zu schließen."
    Uninstall_PressEnterToClose = "Drücken Sie Enter, um dieses Fenster zu schließen."
    Exit_AutoCloseMessage = "Dieses Fenster schließt sich in {0} Sekunden..."
    Install_RebootMessage = "Installation abgeschlossen. Das System startet in {0} Sekunden neu, um die Konfiguration anzuwenden."
    Uninstall_RebootMessage = "Deinstallation abgeschlossen. Das System startet in {0} Sekunden neu, um die Umgebung zu bereinigen."

    # Install - Initialisierung
    Install_UnsupportedArchitectureError = "Nicht unterstützte Prozessorarchitektur: '{0}'"
    Install_ConfigIniNotFoundWarning = "config.ini nicht im vermuteten übergeordneten Verzeichnis gefunden ('{0}')."
    Install_ProjectRootPrompt = "Bitte geben Sie den vollständigen Pfad des WindowsOrchestrator-Skriptstammverzeichnisses ein (z.B. C:\WindowsOrchestrator)"
    Install_InvalidProjectRootError = "Ungültiges Projektstammverzeichnis oder config.ini nicht gefunden: '{0}'"
    Install_PathDeterminationError = "Fehler bei der anfänglichen Pfadbestimmung: '{0}'"
    Install_MissingSystemFile = "Erforderliche Systemdatei fehlt: '{0}'"
    Install_MissingUserFile = "Erforderliche Benutzerdatei fehlt: '{0}'"
    Install_MissingFilesAborted = "Hauptskriptdateien fehlen in '{0}'. Installation abgebrochen. Drücken Sie Enter, um zu beenden."
    Install_ProjectRootUsed = "Verwendetes Projektstammverzeichnis: '{0}'"
    Install_UserTaskTarget = "Benutzeraufgabe wird für installiert: '{0}'"
    Install_AutoLoginUserEmpty = "INFO: 'AutoLoginUsername' ist leer. Mit Installationsbenutzer füllen..."
    Install_AutoLoginUserUpdated = "ERFOLG: config.ini mit 'AutoLoginUsername={0}' aktualisiert."
    Install_AutoLoginUserUpdateFailed = "WARNUNG: Fehler bei der Aktualisierung von 'AutoLoginUsername' in config.ini: '{0}'"
    Install_LogPermissionsWarning = "WARNUNG: Ordner Logs konnte nicht erstellt oder Berechtigungen gesetzt werden. Protokollierung könnte fehlschlagen. Fehler: '{0}'"

    # Install - Autologon-Assistent
    Install_AutologonAlreadyActive = "INFO: Automatische Windows-Anmeldung ist bereits aktiv. Assistent nicht erforderlich."
    Install_DownloadingAutologon = "Microsoft Autologon-Tool herunterladen..."
    Install_AutologonDownloadFailed = "FEHLER: Herunterladen von Autologon.zip fehlgeschlagen. Überprüfen Sie Ihre Internetverbindung."
    Install_ExtractingArchive = "Archiv extrahieren..."
    Install_AutologonFilesMissing = "Erforderliche Dateien ('{0}', Eula.txt) nach Extraktion nicht gefunden."
    Install_AutologonExtractionFailed = "WARNUNG: Vorbereitung des Autologon-Tools fehlgeschlagen. Das heruntergeladene Archiv könnte beschädigt sein."
    Install_AutologonDownloadFailedPrompt = "Herunterladen fehlgeschlagen. Möchten Sie die Datei Autologon.zip manuell suchen?\n\nOffizielle Seite: https://learn.microsoft.com/sysinternals/downloads/autologon"
    Install_AutologonUnsupportedArchitecture = "FEHLER: Nicht unterstützte Prozessorarchitektur ('{0}'). Autologon kann nicht konfiguriert werden."
    Install_EulaConsentMessage = "Akzeptieren Sie die Lizenzbedingungen des Sysinternals Autologon-Tools?"
    Install_EulaConsentCaption = "EULA-Zustimmung erforderlich"
    Install_PromptReviewEula = "Der Microsoft Endbenutzer-Lizenzvertrag (EULA) wird im Editor geöffnet. Bitte lesen Sie ihn und schließen Sie das Fenster, um fortzufahren."
    Install_EulaConsentRefused = "Lizenzannahme vom Benutzer verweigert. Autologon-Konfiguration abgebrochen."
    Install_EulaRejected = "Autologon-Konfiguration abgebrochen (EULA nicht akzeptiert)."
    Install_PromptUseAutologonTool = "Das Autologon-Tool wird nun geöffnet. Bitte geben Sie Ihre Informationen ein (Benutzer, Domäne, Passwort) und klicken Sie auf 'Enable'."
    Install_AutologonSelectZipTitle = "Wählen Sie die heruntergeladene Autologon.zip-Datei aus"
    Install_AutologonFileSelectedSuccess = "ERFOLG: Lokale Datei '{0}' wird verwendet."
    Install_AutologonSuccess = "ERFOLG: Autologon-Tool wurde ausgeführt. Automatische Anmeldung sollte nun konfiguriert sein."
    Install_ContinueNoAutologon = "Installation ohne Autologon-Konfiguration fortsetzen."
    Install_AbortedByUser = "Installation vom Benutzer abgebrochen."
    Install_AutologonDownloadFailedCaption = "Autologon-Assistent fehlgeschlagen"
    Install_ConfirmContinueWithoutAutologon = "Autologon-Assistent fehlgeschlagen. Möchten Sie die Installation ohne automatische Anmeldung fortsetzen?"
    Install_AutologonManualDownloadPrompt = @"
Das automatische Herunterladen des Autologon-Tools ist fehlgeschlagen.

Sie können es manuell herunterladen, um diese Funktion zu aktivieren.

1. Öffnen Sie diese URL in Ihrem Browser: https://learn.microsoft.com/sysinternals/downloads/autologon
2. Laden Sie 'Autologon.zip' herunter und extrahieren Sie es.
3. Platzieren Sie alle extrahierten Dateien (Autologon64.exe usw.) in den folgenden Ordner:
   {0}
4. Starten Sie die Installation erneut.

Möchten Sie die Installation jetzt ohne Autologon-Konfiguration fortsetzen?
"@

    # Install - Passwort & Aufgaben
    Install_PasswordRequiredPrompt = "Der automatische Sitzungsmodus ist aktiviert. Das Passwort für Konto '{0}' ist ERFORDERLICH, um die geplante Aufgabe sicher zu konfigurieren."
    Install_PasswordSecurityInfo = "Dieses Passwort wird direkt an die Windows-API übergeben und wird NIEMALS gespeichert."
    Install_EnterPasswordPrompt = "Bitte geben Sie das Passwort für Konto '{0}' ein"
    Install_PasswordIncorrect = "Passwort falsch oder Validierungsfehler. Bitte versuchen Sie es erneut."
    Install_PasswordAttemptsRemaining = "Verbleibende Versuche: {0}."
    Install_PasswordEmptyToCancel = "(Leer lassen und Enter drücken, um abzubrechen)"
    Install_PasswordMaxAttemptsReached = "Maximale Anzahl von Versuchen erreicht. Installation abgebrochen."
    Install_StartConfiguringTasks = "Beginn der Konfiguration geplanter Aufgaben..."
    Install_CreatingSystemTask = "Systemaufgabe '{0}' erstellen/aktualisieren..."
    Install_SystemTaskDescription = "WindowsOrchestrator: Führt Systemkonfigurationsskript beim Start aus."
    Install_SystemTaskConfiguredSuccess = "Aufgabe '{0}' erfolgreich konfiguriert."
    Install_CreatingUserTask = "Benutzeraufgabe '{0}' für '{1}' erstellen/aktualisieren..."
    Install_UserTaskDescription = "WindowsOrchestrator: Führt Benutzerkonfigurationsskript bei Anmeldung aus."
    Install_MainTasksConfigured = "Hauptgeplante Aufgaben konfiguriert."
    Install_DailyRebootTasksNote = "Aufgaben für täglichen Neustart und Schließaktion werden von '{0}' bei Ausführung verwaltet."
    Install_TaskCreationSuccess = "Aufgaben erfolgreich mit bereitgestellten Anmeldedaten erstellt."
    Install_AttemptingInitialLaunch = "Versuch des anfänglichen Starts der Konfigurationsskripte..."
    Install_ExecutingSystemScript = "Systemskript config_systeme.ps1 ausführen, um anfängliche Systemkonfigurationen anzuwenden..."
    Install_SystemScriptSuccess = "config_systeme.ps1 erfolgreich ausgeführt (Exit-Code 0)."
    Install_SystemScriptWarning = "config_systeme.ps1 beendet mit Exit-Code: {0}. Überprüfen Sie Logs in '{1}\Logs'."
    Install_SystemScriptError = "Fehler beim anfänglichen Ausführen von config_systeme.ps1: '{0}'"
    Install_Trace = "Trace: '{0}'"
    Install_ExecutingUserScript = "Benutzerkonfigurationsskript config_utilisateur.ps1 für '{0}' ausführen, um anfängliche Benutzerkonfigurationen anzuwenden..."
    Install_UserConfigLaunched = "ERFOLG: Benutzerkonfigurationsskript wurde gestartet."
    Install_UserScriptSuccess = "config_utilisateur.ps1 für '{0}' erfolgreich ausgeführt (Exit-Code 0)."
    Install_UserScriptWarning = "config_utilisateur.ps1 für '{0}' beendet mit Exit-Code: {1}. Überprüfen Sie Logs in '{2}\Logs'."
    Install_UserScriptError = "Fehler beim anfänglichen Ausführen von config_utilisateur.ps1 für '{0}': '{1}'"
    Install_InstallationCompleteSuccess = "Installation und anfänglicher Start abgeschlossen!"
    Install_InstallationCompleteWithErrors = "Installation abgeschlossen mit Fehlern beim anfänglichen Start der Skripte. Überprüfen Sie oben genannte Nachrichten."
    Install_CriticalErrorDuringInstallation = "Ein kritischer Fehler ist während der Installation aufgetreten: '{0}'"
    Install_SilentMode_CompletedSuccessfully = "Installation von WindowsOrchestrator erfolgreich abgeschlossen!\n\nAlle Logs wurden im Logs-Ordner gespeichert."
    Install_SilentMode_CompletedWithErrors = "Installation von WindowsOrchestrator abgeschlossen mit Fehlern.\n\nBitte konsultieren Sie die Logdateien im Logs-Ordner für weitere Details."

    # Deinstall
    Uninstall_StartMessage = "Beginn der vollständigen Deinstallation von WindowsOrchestrator..."
    Uninstall_AutoLogonQuestion = "[FRAGE] WindowsOrchestrator hat möglicherweise die automatische Anmeldung (Autologon) aktiviert. Möchten Sie sie jetzt deaktivieren? (j/n)"
    Uninstall_RestoringSettings = "Wiederherstellung der wichtigsten Windows-Einstellungen..."
    Uninstall_WindowsUpdateReactivated = "- Windows-Updates und automatischer Neustart: Reaktiviert."
    Uninstall_WindowsUpdateError = "- FEHLER beim Reaktivieren von Windows Update: '{0}'"
    Uninstall_FastStartupReactivated = "- Windows-Schnellstart: Reaktiviert (Standardwert)."
    Uninstall_FastStartupError = "- FEHLER beim Reaktivieren des Schnellstarts: '{0}'"
    Uninstall_OneDriveReactivated = "- OneDrive: Reaktiviert (Blockierungsrichtlinie entfernt)."
    Uninstall_OneDriveError = "- FEHLER beim Reaktivieren von OneDrive: '{0}'"
    Uninstall_DeletingScheduledTasks = "Geplante Aufgaben löschen..."
    Uninstall_ProcessingTask = "Aufgabe '{0}' verarbeiten..."
    Uninstall_TaskFoundAttemptingDeletion = " Gefunden. Löschversuch..."
    Uninstall_TaskSuccessfullyRemoved = " Erfolgreich entfernt."
    Uninstall_TaskDeletionFailed = " LÖSCHEN FEHLGESCHLAGEN."
    Uninstall_TaskDeletionError = " FEHLER beim Löschen."
    Uninstall_TaskErrorDetail = "   Detail: '{0}'"
    Uninstall_TaskNotFound = " Nicht gefunden."
    Uninstall_CompletionMessage = "Deinstallation abgeschlossen."
    Uninstall_TasksNotRemovedWarning = "Einige Aufgaben konnten NICHT entfernt werden: '{0}'."
    Uninstall_CheckTaskScheduler = "Bitte überprüfen Sie den Aufgabenplaner."
    Uninstall_FilesNotDeletedNote = "Hinweis: Skripte und Konfigurationsdateien werden nicht von Ihrer Festplatte gelöscht."
    Uninstall_LSACleanAttempt = "INFO: Vollständige Bereinigung der LSA-Geheimnisse über Autologon.exe versuchen..."
    Uninstall_AutoLogonDisabled = "- Automatische Anmeldung: Deaktiviert (über Autologon-Tool)."
    Uninstall_AutoLogonDisableError = "- FEHLER beim Versuch, die automatische Anmeldung zu deaktivieren: '{0}'"
    Uninstall_AutoLogonLeftAsIs = "- Automatische Anmeldung: Unverändert (Benutzerwahl)."
    Uninstall_AutologonToolNotFound_Interactive = "[WARNUNG] Autologon.exe-Tool nicht gefunden. Automatische Deaktivierung kann nicht durchgeführt werden. Wenn Sie die automatische Anmeldung deaktivieren möchten, tun Sie dies bitte manuell."
    Uninstall_AutologonDisablePrompt = "Bitte klicken Sie auf 'Disable' im sich öffnenden Autologon-Tool-Fenster, um die Bereinigung abzuschließen."
    Uninstall_AutologonNotActive = "INFO: Automatische Anmeldung ist nicht aktiv. Keine Bereinigung erforderlich."
    Uninstall_SilentMode_CompletedSuccessfully = "Deinstallation von WindowsOrchestrator erfolgreich abgeschlossen!\n\nAlle Logs wurden im Logs-Ordner gespeichert."
    Uninstall_SilentMode_CompletedWithErrors = "Deinstallation von WindowsOrchestrator abgeschlossen mit Fehlern.\n\nBitte konsultieren Sie die Logdateien im Logs-Ordner für weitere Details."

    # ------------------------------------------------------------------------------
    # 6. BENACHRICHTIGUNGEN (Gotify) & GEMEINSAM
    # ------------------------------------------------------------------------------
    Gotify_MessageDate = "Ausgeführt am {0}."
    Gotify_SystemActionsHeader = "SYSTEM-AKTIONEN:"
    Gotify_NoSystemActions = "Keine SYSTEM-Aktionen."
    Gotify_SystemErrorsHeader = "SYSTEM-FEHLER:"
    Gotify_UserActionsHeader = "BENUTZER-AKTIONEN:"
    Gotify_NoUserActions = "Keine BENUTZER-Aktionen."
    Gotify_UserErrorsHeader = "BENUTZER-FEHLER:"
    Error_LanguageFileLoad = "Ein kritischer Fehler ist beim Laden der Sprachdateien aufgetreten: '{0}'"
    Error_InvalidConfigValue = "Ungültiger Konfigurationswert für [{0}]{1}: '{2}'. Typ erwartet '{3}'. Standardwert/leerer Wert verwendet."
    Install_SplashMessage = "Vorgang läuft, bitte warten..."
}
