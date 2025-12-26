@{
    # ==============================================================================
    # SPRACHDATEI : DEUTSCH (DE-DE)
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 1. GRAFISCHE OBERFLÄCHE (firstconfig.ps1)
    # ------------------------------------------------------------------------------

    # Titel & Navigation
    ConfigForm_Title = "Konfigurationsassistent - WindowsOrchestrator"
    ConfigForm_Tab_Basic = "Basis"
    ConfigForm_Tab_Advanced = "Erweitert"
    ConfigForm_SubTabMain = "Hauptmenü"
    ConfigForm_SubTabBackup = "Datensicherung"
    ConfigForm_SubTabOtherAccount = "Optionen & Konto"

    # Gruppe: Benutzersitzung
    ConfigForm_EnableSessionManagementCheckbox = "Automatische Sitzungsanmeldung aktivieren (Autologon)"
    ConfigForm_SecureAutologonModeDescription = "(Öffnet den Desktop und sperrt die Sitzung sofort wieder)"
    ConfigForm_BackgroundTaskModeDescription = "(Startet die Anwendung unsichtbar, ohne eine Sitzung zu öffnen)"
    ConfigForm_SessionEulaNote = "(Durch Aktivieren akzeptieren Sie die Lizenz des Microsoft Autologon-Tools)"
    ConfigForm_UseAutologonAssistantCheckbox = "Assistenten zur Konfiguration von Autologon verwenden (falls erforderlich)"
    ConfigForm_AutoLoginUsernameLabel = "Benutzername für Autologon (optional):"

    # Gruppe: Windows-Einstellungen
    ConfigForm_WindowsSettingsGroup = "Windows-Einstellungen"
    ConfigForm_DisableFastStartupCheckbox = "Windows-Schnellstart deaktivieren"
    ConfigForm_DisableSleepCheckbox = "Automatischen Energiesparmodus deaktivieren"
    ConfigForm_DisableScreenSleepCheckbox = "Ausschalten des Bildschirms deaktivieren"
    ConfigForm_DisableWindowsUpdateCheckbox = "Windows Update-Dienst blockieren"
    ConfigForm_DisableAutoRebootCheckbox = "Automatischen Neustart nach Updates deaktivieren"

    # Gruppe: OneDrive
    ConfigForm_OneDriveModeLabel = "OneDrive-Verwaltung:"
    ConfigForm_OneDriveMode_Block = "Blockieren (Systemrichtlinie)"
    ConfigForm_OneDriveMode_Close = "Beim Start schließen"
    ConfigForm_OneDriveMode_Ignore = "Nichts unternehmen"

    # Gruppe: Beendigung & Anwendung
    ConfigForm_Section_Closure = "Geplante Anwendungsbeendigung"
    ConfigForm_EnableScheduledCloseCheckbox = "Geplante Beendigung aktivieren"
    ConfigForm_CloseTimeLabel = "Zeitpunkt der Beendigung (HH:MM):"
    ConfigForm_CloseCommandLabel = "Befehl zum Beenden:"
    ConfigForm_CloseArgumentsLabel = "Argumente für den Befehl:"

    ConfigForm_Section_Reboot = "Neustart und täglicher Zyklus"
    ConfigForm_EnableScheduledRebootCheckbox = "Täglichen Neustart aktivieren"
    ConfigForm_RebootTimeLabel = "Geplante Neustartzeit (HH:MM):"

    ConfigForm_ProcessToLaunchLabel = "Zu startende Anwendung:"
    ConfigForm_ProcessArgumentsLabel = "Argumente für die Anwendung:"
    ConfigForm_ProcessToMonitorLabel = "Zu überwachender Prozessname (ohne .exe):"
    ConfigForm_StartProcessMinimizedCheckbox = "Hauptanwendung minimiert in der Taskleiste starten"
    ConfigForm_LaunchConsoleModeLabel = "Konsolen-Startmodus:"
    ConfigForm_LaunchConsoleMode_Standard = "Standardstart (empfohlen)"
    ConfigForm_LaunchConsoleMode_Legacy = "Legacy-Start (alte Konsole)"

    # Gruppe: Datensicherung
    ConfigForm_DatabaseBackupGroupTitle = "Datenbanksicherung (Optional)"
    ConfigForm_EnableBackupCheckbox = "Sicherung vor dem Neustart aktivieren"
    ConfigForm_BackupSourceLabel = "Datenquellordner:"
    ConfigForm_BackupDestinationLabel = "Zielordner der Sicherung:"
    ConfigForm_BackupTimeLabel = "Sicherungszeitpunkt (HH:MM):"
    ConfigForm_BackupKeepDaysLabel = "Aufbewahrungsfrist (in Tagen):"

    # Gruppe: Installationsoptionen & Zielkonto
    ConfigForm_InstallOptionsGroup = "Installationsoptionen"
    ConfigForm_SilentModeCheckbox = "Konsolenfenster während der Installation/Deinstallation ausblenden"
    ConfigForm_OtherAccountGroupTitle = "Für anderen Benutzer anpassen"
    ConfigForm_OtherAccountDescription = "Ermöglicht die Angabe eines alternativen Benutzerkontos für die Ausführung geplanter Aufgaben. Erfordert Administratorrechte für die kontoübergreifende Konfiguration."
    ConfigForm_OtherAccountUsernameLabel = "Name des zu konfigurierenden Benutzerkontos:"

    # Schaltflächen & GUI-Nachrichten
    ConfigForm_SaveButton = "Speichern und Schließen"
    ConfigForm_CancelButton = "Abbrechen"
    ConfigForm_SaveSuccessMessage = "Konfiguration gespeichert in '{0}'"
    ConfigForm_SaveSuccess = "Konfiguration erfolgreich gespeichert!"
    ConfigForm_SaveSuccessCaption = "Erfolg"
    ConfigForm_ConfigWizardCancelled = "Konfigurationsassistent abgebrochen."
    ConfigForm_PathError = "Projektpfade konnten nicht ermittelt werden. Fehler: '{0}'. Das Skript wird beendet."
    ConfigForm_PathErrorCaption = "Kritischer Pfadfehler"
    ConfigForm_ModelFileNotFoundError = "FEHLER: Die Vorlagendatei 'management\defaults\default_config.ini' wurde nicht gefunden UND es existiert keine 'config.ini'. Installation unmöglich."
    ConfigForm_ModelFileNotFoundCaption = "Fehlende Vorlagendatei"
    ConfigForm_CopyError = "Die Datei 'config.ini' konnte nicht aus der Vorlage erstellt werden. Fehler: '{0}'."
    ConfigForm_CopyErrorCaption = "Kopierfehler"
    ConfigForm_OverwritePrompt = "Eine Konfigurationsdatei 'config.ini' existiert bereits.\n\nMöchten Sie diese durch die Standardvorlage ersetzen?\n\nWARNUNG: Ihre aktuellen Einstellungen gehen verloren."
    ConfigForm_OverwriteCaption = "Bestehende Konfiguration ersetzen?"
    ConfigForm_ResetSuccess = "Die Datei 'config.ini' wurde auf die Standardwerte zurückgesetzt."
    ConfigForm_ResetSuccessCaption = "Zurücksetzung durchgeführt"
    ConfigForm_OverwriteError = "Die 'config.ini' konnte nicht durch die Vorlage ersetzt werden. Fehler: '{0}'."
    ConfigForm_InvalidTimeFormat = "Das Zeitformat muss HH:MM sein (z. B. 03:55)."
    ConfigForm_InvalidTimeFormatCaption = "Ungültiges Format"
    ConfigForm_InvalidTimeLogic = "Die Beendigungszeit muss VOR der geplanten Neustartzeit liegen."
    ConfigForm_InvalidTimeLogicCaption = "Ungültige Zeitlogik"
    ConfigForm_AllSysOptimizedNote = "✔ Diese Einstellungen sind für {0} optimiert. Es wird empfohlen, sie nicht zu ändern."

    # ------------------------------------------------------------------------------
    # 2. SYSTEM-SKRIPT (config_systeme.ps1)
    # ------------------------------------------------------------------------------

    # Allgemeine Protokolle
    Log_StartingScript = "Starte '{0}' ('{1}')..."
    Log_CheckingNetwork = "Netzwerkverbindung wird geprüft..."
    Log_NetworkDetected = "Netzwerkverbindung erkannt."
    Log_NetworkRetry = "Netzwerk nicht verfügbar, erneuter Versuch in 10s..."
    Log_NetworkFailed = "Netzwerk nicht hergestellt. Gotify könnte fehlschlagen."
    Log_ExecutingSystemActions = "Führe konfigurierte SYSTEM-Aktionen aus..."
    Log_SettingNotSpecified = "Der Parameter '{0}' ist nicht angegeben."
    Log_ScriptFinished = "'{0}' ('{1}') beendet."
    Log_ErrorsOccurred = "Während der Ausführung sind Fehler aufgetreten."
    Log_CapturedError = "ERFASSTER FEHLER: '{0}'"
    Error_FatalScriptError = "KRITISCHER SKRIPTFEHLER (Hauptblock): '{0}' \n'{1}'"
    System_ConfigCriticalError = "Kritischer Fehler: config.ini."

    # Zielbenutzer-Verwaltung
    Log_ReadRegistryForUser = "AutoLoginUsername nicht angegeben. Versuche DefaultUserName aus der Registry zu lesen."
    Log_RegistryUserFound = "Verwende Registry DefaultUserName als Zielbenutzer: '{0}'."
    Log_RegistryUserNotFound = "Registry DefaultUserName nicht gefunden oder leer. Kein Standard-Zielbenutzer."
    Log_RegistryReadError = "Fehler beim Lesen von DefaultUserName aus der Registry: '{0}'"
    Log_ConfigUserFound = "Verwende AutoLoginUsername aus der config.ini als Zielbenutzer: '{0}'."

    # --- Aktionen: Windows-Einstellungen ---
    Log_DisablingFastStartup = "Cfg: Deaktiviere Schnellstart."
    Action_FastStartupDisabled = "- Der Windows-Schnellstart ist deaktiviert."
    Log_FastStartupAlreadyDisabled = "Der Windows-Schnellstart ist bereits deaktiviert."
    Action_FastStartupVerifiedDisabled = "- Der Windows-Schnellstart ist deaktiviert."

    Log_EnablingFastStartup = "Cfg: Aktiviere Schnellstart."
    Action_FastStartupEnabled = "- Der Windows-Schnellstart ist aktiviert."
    Log_FastStartupAlreadyEnabled = "Der Windows-Schnellstart ist bereits aktiviert."
    Action_FastStartupVerifiedEnabled = "- Der Windows-Schnellstart ist aktiviert."
    Error_DisableFastStartupFailed = "Schnellstart konnte nicht deaktiviert werden: '{0}'"
    Error_EnableFastStartupFailed = "Schnellstart konnte nicht aktiviert werden: '{0}'"

    Log_DisablingSleep = "Deaktiviere Energiesparmodus der Maschine..."
    Action_SleepDisabled = "- Der automatische Energiesparmodus ist deaktiviert."
    Error_DisableSleepFailed = "Automatischer Energiesparmodus konnte nicht deaktiviert werden: '{0}'"

    Log_DisablingScreenSleep = "Deaktiviere Ausschalten des Bildschirms..."
    Action_ScreenSleepDisabled = "- Das Ausschalten des Bildschirms ist deaktiviert."
    Error_DisableScreenSleepFailed = "Bildschirmschoner/Ausschalten konnte nicht deaktiviert werden: '{0}'"

    Log_DisablingUpdates = "Deaktiviere Windows-Updates..."
    Action_UpdatesDisabled = "- Der Windows Update-Dienst ist blockiert."
    Log_EnablingUpdates = "Aktiviere Windows-Updates..."
    Action_UpdatesEnabled = "- Der Windows Update-Dienst ist aktiv."
    Error_UpdateMgmtFailed = "Fehler bei der Windows Update-Verwaltung: '{0}'"

    Log_DisablingAutoReboot = "Deaktiviere erzwungenen Neustart durch Windows Update..."
    Action_AutoRebootDisabled = "- Der automatische Neustart nach Updates ist deaktiviert."
    Error_DisableAutoRebootFailed = "Automatischer Neustart nach Update konnte nicht deaktiviert werden: '{0}'"

    # --- Aktionen: Sitzung & OneDrive ---
    Log_EnablingAutoLogin = "Prüfe/Aktiviere automatische Sitzungsanmeldung..."
    Action_AutoAdminLogonEnabled = "- Automatische Sitzungsanmeldung aktiviert."
    Action_AutoLogonAutomatic = "- Automatische Sitzungsanmeldung für '{0}' aktiviert (Modus: Autologon)."
    Action_AutoLogonSecure = "- Automatische Sitzungsanmeldung für '{0}' aktiviert (Modus: Sicher)."
    Action_AutologonVerified = "- Die automatische Sitzungsanmeldung ist aktiv."
    Action_DefaultUserNameSet = "Standardbenutzer festgelegt auf: '{0}'."
    Log_AutoLoginUserUnknown = "Automatische Sitzungsanmeldung aktiviert, aber der Zielbenutzer konnte nicht ermittelt werden."
    Error_AutoLoginFailed = "Automatische Sitzungsanmeldung konnte nicht konfiguriert werden: '{0}'"
    Error_AutoLoginUserUnknown = "Automatische Sitzungsanmeldung aktiviert, aber der Zielbenutzer konnte nicht ermittelt werden."
    Error_SecureAutoLoginFailed = "Sichere Anmeldung konnte nicht konfiguriert werden: '{0}'"
    Action_LockTaskConfigured = "Einzelsitzungssperre für '{0}' konfiguriert."

    Log_DisablingAutoLogin = "Deaktiviere automatische Sitzungsanmeldung..."
    Action_AutoAdminLogonDisabled = "- Die automatische Sitzungsanmeldung ist deaktiviert."
    Error_DisableAutoLoginFailed = "Automatische Sitzungsanmeldung konnte nicht deaktiviert werden: '{0}'"

    Log_DisablingOneDrive = "Deaktiviere OneDrive (Richtlinie)..."
    Log_EnablingOneDrive = "Aktiviere/Erhalte OneDrive (Richtlinie)..."
    Action_OneDriveDisabled = "- OneDrive ist deaktiviert (Richtlinie)."
    Action_OneDriveEnabled = "- OneDrive ist erlaubt."
    Action_OneDriveClosed = "- OneDrive-Prozess wurde beendet."
    Action_OneDriveBlocked = "- OneDrive ist blockiert (Systemrichtlinie) und der Prozess wurde gestoppt."
    Action_OneDriveAutostartRemoved = "- OneDrive-Autostart für Benutzer '{0}' deaktiviert."
    Action_OneDriveIgnored = "- OneDrive-Blockierungsrichtlinie entfernt (Ignorieren-Modus)."
    Error_DisableOneDriveFailed = "OneDrive konnte nicht deaktiviert werden: '{0}'"
    Error_EnableOneDriveFailed = "OneDrive konnte nicht aktiviert werden: '{0}'"
    Action_OneDriveClean = "- OneDrive ist geschlossen und der Autostart deaktiviert."

    # --- Aktionen: Zeitplanung ---
    Log_ConfiguringReboot = "Konfiguriere geplanten Neustart um {0} Uhr..."
    Action_RebootScheduled = "- Neustart geplant um {0} Uhr."
    Error_RebootScheduleFailed = "Geplante Neustart-Aufgabe ({0}) '{1}' konnte nicht konfiguriert werden: '{2}'."
    Log_RebootTaskRemoved = "Neustartzeit nicht angegeben. Entferne Aufgabe '{0}'."

    Action_BackupTaskConfigured = "- Datensicherung geplant um {0} Uhr."
    Error_BackupTaskFailed = "Sicherungsaufgabe konnte nicht konfiguriert werden: '{0}'"
    System_BackupTaskDescription = "Orchestrator: Führt Datensicherung vor dem Neustart aus."
    System_BackupScriptNotFound = "Das dedizierte Sicherungsskript '{0}' wurde nicht gefunden."

    # --- v1.73 Neue Systemnachrichten (Inferenz) ---
    Log_System_BackupSynced = "- Sicherungszeit mit Beendigungszeit synchronisiert ({0}). Watchdog-Modus aktiviert."
    Log_System_RebootTaskSkipped = "- Neustart ohne feste Zeit aktiviert. Geplante Aufgabe entfernt (wird durch Verkettung gesteuert)."
    Error_System_BackupNoTime = "Sicherung aktiviert, aber keine Zeit oder Referenz-Beendigungszeit definiert. Aufgabe übersprungen."

    # Systemprozess-Verwaltung (Hintergrundaufgabe)
    Log_System_NoProcessSpecified = "Keine zu startende Anwendung angegeben. Keine Aktion durchgeführt."
    Log_System_ProcessToMonitor = "Überwache Prozessname: '{0}'."
    Log_System_ProcessAlreadyRunning = "Der Prozess '{0}' (PID: {1}) läuft bereits. Keine Aktion erforderlich."
    Action_System_ProcessAlreadyRunning = "Der Prozess '{0}' läuft bereits (PID: {1})."
    Log_System_NoMonitor = "Kein zu überwachender Prozess angegeben. Prüfung wird übersprungen."
    Log_System_ProcessStarting = "Starte Hintergrundprozess '{0}' über '{1}'..."
    Action_System_ProcessStarted = "- Hintergrundprozess '{0}' gestartet (über '{1}')."
    Error_System_ProcessManagementFailed = "Hintergrundprozess '{0}' konnte nicht verwaltet werden: '{1}'"
    Action_System_CloseTaskConfigured = "- Beendigungsaufgabe für Hintergrundprozess konfiguriert für '{0}' um {1} Uhr."
    Error_System_CloseTaskFailed = "Beendigungsaufgabe für Hintergrundprozess konnte nicht erstellt werden: '{0}'"
    System_ProcessNotDefined = "Die zu startende Anwendung ist für den BackgroundTask-Modus nicht definiert (SYSTEM-Kontext ohne grafische Oberfläche)."

    # ------------------------------------------------------------------------------
    # 3. BENUTZER-SKRIPT (config_utilisateur.ps1)
    # ------------------------------------------------------------------------------
    Log_User_StartingScript = "Starte '{0}' ('{1}') für Benutzer '{2}'..."
    Log_User_ExecutingActions = "Führe konfigurierte Aktionen für Benutzer '{0}' aus..."
    Log_User_CannotReadConfig = "Die Datei '{0}' konnte nicht gelesen oder verarbeitet werden. Beende Benutzerkonfigurationen."
    Log_User_ScriptFinished = "'{0}' ('{1}') für Benutzer '{2}' beendet."

    Log_User_ManagingProcess = "Verwalte Benutzerprozess (roh: '{0}', aufgelöst: '{1}'). Methode: '{2}'"
    Log_User_ProcessWithArgs = "Mit Argumenten: '{0}'"
    Log_User_ProcessToMonitor = "Überwache Prozessname: '{0}'."
    Log_User_ProcessAlreadyRunning = "Der Prozess '{0}' (PID: {1}) läuft bereits für den aktuellen Benutzer. Keine Aktion erforderlich."
    Action_User_ProcessAlreadyRunning = "Der Prozess '{0}' läuft bereits (PID: {1})."
    Log_User_NoMonitor = "Kein zu überwachender Prozess angegeben. Prüfung wird ignoriert."
    Log_User_NoProcessSpecified = "Kein Prozess angegeben oder Pfad ist leer."
    Log_User_BaseNameError = "Fehler beim Extrahieren des Basisnamens von '{0}' (direkt)."
    Log_User_EmptyBaseName = "Der Basisname des zu überwachenden Prozesses ist leer."
    Log_User_WorkingDirFallback = "Der Prozessname '{0}' ist kein Dateipfad; Arbeitsverzeichnis auf '{1}' für '{2}' festgelegt."
    Log_User_WorkingDirNotFound = "Arbeitsverzeichnis '{0}' nicht gefunden. Es wird nicht festgelegt."

    Log_User_ProcessStopping = "Der Prozess '{0}' (PID: {1}) läuft. Beende..."
    Action_User_ProcessStopped = "Prozess '{0}' gestoppt."
    Log_User_ProcessRestarting = "Neustart über '{0}': '{1}' mit Argumenten: '{2}'"
    Action_User_ProcessRestarted = "- Prozess '{0}' neu gestartet (über '{1}')."
    Log_User_ProcessStarting = "Prozess '{0}' nicht gefunden. Starte über '{1}': '{2}' mit Argumenten: '{3}'"
    Action_User_ProcessStarted = "- Prozess '{0}' gestartet."

    Error_User_LaunchMethodUnknown = "Startmethode '{0}' nicht erkannt. Optionen: direct, powershell, cmd."
    Error_User_InterpreterNotFound = "Interpreter '{0}' für Methode '{1}' nicht gefunden."
    Error_User_ProcessManagementFailed = "Prozess '{0}' konnte nicht verwaltet werden (Methode: '{1}', Pfad: '{2}', Args: '{3}'): '{4}'. StackTrace: '{5}'"
    Error_User_ExeNotFound = "Ausführbare Datei für Prozess '{0}' (Direktmodus) NICHT GEFUNDEN."
    Error_User_FatalScriptError = "KRITISCHER FEHLER IM BENUTZERSKRIPT '{0}': '{1}' \n'{2}'"
    Error_User_VarExpansionFailed = "Fehler bei der Variablenerweiterung für Prozess '{0}': '{1}'"

    Action_User_CloseTaskConfigured = "- Anwendungsbeendigung geplant um {1} Uhr."
    Error_User_CloseTaskFailed = "Beendigungsaufgabe '{0}' konnte nicht erstellt werden: '{1}'"

    # ------------------------------------------------------------------------------
    # 4. SICHERUNGSMODUL (Invoke-DatabaseBackup.ps1)
    # ------------------------------------------------------------------------------
    Log_Backup_Starting = "Starte Datenbanksicherungsprozess..."
    Log_Backup_Disabled = "Datenbanksicherung ist in der config.ini DEAKTIVIERT. Ignoriert."
    Log_Backup_PurgeStarting = "Starte Bereinigung alter Backups (behalte die letzten {0} Tage)..."
    Log_Backup_PurgingFile = "Lösche altes Backup: '{0}'."
    Log_Backup_NoFilesToPurge = "Keine alten Backups zur Bereinigung gefunden."
    Log_Backup_RetentionPolicy = "Aufbewahrungsrichtlinie: {0} Tag(e)."
    Log_Backup_NoFilesFound = "Keine in den letzten 24 Stunden geänderten Dateien zur Sicherung gefunden."
    Log_Backup_FilesFound = "{0} Datei(en) zur Sicherung gefunden (einschließlich verknüpfter Dateien)."
    Log_Backup_CopyingFile = "Sicherung von '{0}' nach '{1}' erfolgreich."
    Log_Backup_AlreadyRunning = "Sicherung läuft bereits (Sperrungsalter: {0} Min). Ignoriert."

    Action_Backup_Completed = "Sicherung von {0} Datei(en) erfolgreich abgeschlossen."
    Action_Backup_DestinationCreated = "Sicherungszielordner '{0}' wurde erstellt."
    Action_Backup_PurgeCompleted = "Bereinigung von {0} alten Backups abgeschlossen."

    Error_Backup_PathNotFound = "Quell- oder Zielpfad '{0}' für die Sicherung wurde nicht gefunden. Vorgang abgebrochen."
    Error_Backup_DestinationCreationFailed = "Zielordner '{0}' konnte nicht erstellt werden: '{1}'"
    Error_Backup_InsufficientPermissions = "Unzureichende Berechtigungen zum Schreiben in den Sicherungsordner: '{0}'"
    Error_Backup_InsufficientSpace = "Unzureichender Speicherplatz. Erforderlich: {0:N2} MB, Verfügbar: {1:N2} MB"
    Error_Backup_PurgeFailed = "Altes Backup '{0}' konnte nicht gelöscht werden: '{1}'"
    Error_Backup_CopyFailed = "Datei '{0}' konnte nicht gesichert werden: '{1}'"
    Error_Backup_ProcessRunning = "SICHERUNG ABGEBROCHEN: Prozess '{0}' ist aktiv. Risiko von Datenkorruption."
    Error_Backup_Critical = "KRITISCHER FEHLER während des Sicherungsprozesses: '{0}'"
    Backup_ConfigLoadError = "config.ini konnte nicht gelesen werden."
    Backup_InitError = "Kritischer Initialisierungsfehler: '{0}'"

    # --- v1.73 Watchdog-Nachrichten ---
    Log_Backup_WatcherStarted = "Watchdog-Überwachung für Prozess '{0}' gestartet."
    Log_Backup_ProcessClosed = "Prozess '{0}' erfolgreich geschlossen."
    Log_Backup_TimeoutKill = "Prozess '{0}' nach Zeitüberschreitung ({1}s) zwangsweise beendet."
    Error_Backup_TimeoutNoKill = "Prozess '{0}' läuft nach Zeitüberschreitung ({1}s) immer noch. Sicherung abgebrochen."
    Log_Backup_ChainedReboot = "Verketteter Neustart nach Abschluss der Sicherung eingeleitet."

    # ------------------------------------------------------------------------------
    # 5. INSTALLATION & DEINSTALLATION (install.ps1 / uninstall.ps1)
    # ------------------------------------------------------------------------------

    # Allgemein
    Install_ElevationWarning = "Privilegieneskalation fehlgeschlagen. Bitte führen Sie dieses Skript als Administrator aus."
    Uninstall_ElevationWarning = "Privilegieneskalation fehlgeschlagen. Bitte führen Sie dieses Skript als Administrator aus."
    Install_PressEnterToExit = "Drücken Sie die Eingabetaste zum Beenden."
    Uninstall_PressEnterToExit = "Drücken Sie die Eingabetaste zum Beenden."
    Install_PressEnterToClose = "Drücken Sie die Eingabetaste, um dieses Fenster zu schließen."
    Uninstall_PressEnterToClose = "Drücken Sie die Eingabetaste, um dieses Fenster zu schließen."
    Exit_AutoCloseMessage = "Dieses Fenster schließt sich in {0} Sekunden..."
    Install_RebootMessage = "Installation abgeschlossen. Das System wird in {0} Sekunden neu gestartet, um die Konfiguration anzuwenden."
    Uninstall_RebootMessage = "Deinstallation abgeschlossen. Das System wird in {0} Sekunden neu gestartet, um die Umgebung zu bereinigen."

    # Installation - Initialisierung
    Install_UnsupportedArchitectureError = "Nicht unterstützte Prozessorarchitektur: '{0}'"
    Install_ConfigIniNotFoundWarning = "config.ini wurde im vermuteten übergeordneten Verzeichnis ('{0}') nicht gefunden."
    Install_ProjectRootPrompt = "Bitte geben Sie den vollständigen Pfad zum Stammverzeichnis der WindowsOrchestrator-Skripte an (z. B.: C:\WindowsOrchestrator)"
    Install_InvalidProjectRootError = "Ungültiges Projektstammverzeichnis oder config.ini nicht gefunden: '{0}'"
    Install_PathDeterminationError = "Fehler bei der anfänglichen Pfadermittlung: '{0}'"
    Install_MissingSystemFile = "Erforderliche Systemdatei fehlt: '{0}'"
    Install_MissingUserFile = "Erforderliche Benutzerdatei fehlt: '{0}'"
    Install_MissingFilesAborted = "Hauptskriptdateien fehlen in '{0}'. Installation abgebrochen. Drücken Sie die Eingabetaste zum Beenden."
    Install_ProjectRootUsed = "Verwendetes Projektstammverzeichnis: '{0}'"
    Install_UserTaskTarget = "Die Benutzeraufgabe wird installiert für: '{0}'"
    Install_AutoLoginUserEmpty = "INFO: 'AutoLoginUsername' ist leer. Wird mit dem Installationsbenutzer ausgefüllt..."
    Install_AutoLoginUserUpdated = "ERFOLG: config.ini aktualisiert mit 'AutoLoginUsername={0}'."
    Install_AutoLoginUserUpdateFailed = "WARNUNG: 'AutoLoginUsername' in der config.ini konnte nicht aktualisiert werden: '{0}'"
    Install_LogPermissionsWarning = "WARNUNG: Berechtigungen für den Logs-Ordner konnten nicht erstellt oder festgelegt werden. Protokollierung könnte fehlschlagen. Fehler: '{0}'"

    # Installation - Autologon-Assistent
    Install_AutologonAlreadyActive = "INFO: Automatische Windows-Anmeldung ist bereits aktiv. Assistent nicht erforderlich."
    Install_DownloadingAutologon = "Lade Microsoft Autologon-Tool herunter..."
    Install_AutologonDownloadFailed = "FEHLER: Download von Autologon.zip fehlgeschlagen. Überprüfen Sie Ihre Internetverbindung."
    Install_ExtractingArchive = "Extrahiere Archiv..."
    Install_AutologonFilesMissing = "Erforderliche Dateien ('{0}', Eula.txt) nach der Extraktion nicht gefunden."
    Install_AutologonExtractionFailed = "WARNUNG: Vorbereitung des Autologon-Tools fehlgeschlagen. Das heruntergeladene Archiv ist möglicherweise beschädigt."
    Install_AutologonDownloadFailedPrompt = "Download fehlgeschlagen. Möchten Sie die Datei Autologon.zip manuell suchen?\n\nOffizielle Seite: https://learn.microsoft.com/sysinternals/downloads/autologon"
    Install_AutologonUnsupportedArchitecture = "FEHLER: Nicht unterstützte Prozessorarchitektur ('{0}'). Autologon kann nicht konfiguriert werden."
    Install_EulaConsentMessage = "Akzeptieren Sie die Lizenzbedingungen des Sysinternals Autologon-Tools?"
    Install_EulaConsentCaption = "EULA-Zustimmung erforderlich"
    Install_PromptReviewEula = "Der Microsoft-Endbenutzer-Lizenzvertrag (EULA) wird im Editor geöffnet. Bitte lesen Sie ihn durch und schließen Sie das Fenster, um fortzufahren."
    Install_EulaConsentRefused = "Lizenzzustimmung vom Benutzer verweigert. Autologon-Konfiguration abgebrochen."
    Install_EulaRejected = "Autologon-Konfiguration abgebrochen (EULA nicht akzeptiert)."
    Install_PromptUseAutologonTool = "Das Autologon-Tool wird nun geöffnet. Bitte geben Sie Ihre Informationen (Benutzer, Domäne, Passwort) ein und klicken Sie auf 'Enable'."
    Install_AutologonSelectZipTitle = "Wählen Sie die heruntergeladene Autologon.zip Datei aus"
    Install_AutologonFileSelectedSuccess = "ERFOLG: Lokale Datei '{0}' wird verwendet."
    Install_AutologonSuccess = "ERFOLG: Autologon-Tool ausgeführt. Die automatische Sitzungsanmeldung sollte nun konfiguriert sein."
    Install_ContinueNoAutologon = "Installation wird ohne Konfiguration von Autologon fortgesetzt."
    Install_AbortedByUser = "Installation durch Benutzer abgebrochen."
    Install_AutologonDownloadFailedCaption = "Fehler im Autologon-Assistenten"
    Install_ConfirmContinueWithoutAutologon = "Autologon-Assistent fehlgeschlagen. Möchten Sie die Installation ohne automatische Anmeldung fortsetzen?"
    Install_AutologonManualDownloadPrompt = @"
Der automatische Download des Autologon-Tools ist fehlgeschlagen.

Sie können es manuell herunterladen, um diese Funktion zu aktivieren.

1.  Öffnen Sie diese URL im Browser: https://learn.microsoft.com/sysinternals/downloads/autologon
2.  Laden Sie 'Autologon.zip' herunter und extrahieren Sie es.
3.  Legen Sie alle extrahierten Dateien (Autologon64.exe usw.) in folgenden Ordner:
    {0}
4.  Starten Sie die Installation neu.

Möchten Sie die Installation jetzt ohne Konfiguration von Autologon fortsetzen?
"@

    # Installation - Passwort & Aufgaben
    Install_PasswordRequiredPrompt = "Der Modus für automatische Sitzungen ist aktiviert. Das Passwort für das Konto '{0}' ist ERFORDERLICH, um die geplante Aufgabe sicher zu konfigurieren."
    Install_PasswordSecurityInfo = "Dieses Passwort wird direkt an die Windows-API übergeben und NIEMALS gespeichert."
    Install_EnterPasswordPrompt = "Bitte geben Sie das Passwort für das Konto '{0}' ein"
    Install_PasswordIncorrect = "Falsches Passwort oder Validierungsfehler. Bitte versuchen Sie es erneut."
    Install_PasswordAttemptsRemaining = "Verbleibende Versuche: {0}."
    Install_PasswordEmptyToCancel = "(Leer lassen und Eingabetaste drücken zum Abbrechen)"
    Install_PasswordMaxAttemptsReached = "Maximale Anzahl an Versuchen erreicht. Installation abgebrochen."
    Install_StartConfiguringTasks = "Starte Konfiguration der geplanten Aufgaben..."
    Install_CreatingSystemTask = "Erstelle/Aktualisiere Systemaufgabe '{0}'..."
    Install_SystemTaskDescription = "WindowsOrchestrator: Führt das Systemkonfigurationsskript beim Start aus."
    Install_SystemTaskConfiguredSuccess = "Aufgabe '{0}' erfolgreich konfiguriert."
    Install_CreatingUserTask = "Erstelle/Aktualisiere Benutzeraufgabe '{0}' für '{1}'..."
    Install_UserTaskDescription = "WindowsOrchestrator: Führt das Benutzerkonfigurationsskript bei der Sitzungsanmeldung aus."
    Install_MainTasksConfigured = "Hauptaufgaben konfiguriert."
    Install_DailyRebootTasksNote = "Aufgaben für den täglichen Neustart und die Beendigung werden von '{0}' während der Ausführung verwaltet."
    Install_TaskCreationSuccess = "Aufgaben wurden erfolgreich mit den angegebenen Anmeldedaten erstellt."

    # Installation - Ausführung & Ende
    Install_AttemptingInitialLaunch = "Versuche ersten Start der Konfigurationsskripte..."
    Install_ExecutingSystemScript = "Führe config_systeme.ps1 aus, um die ersten Systemkonfigurationen anzuwenden..."
    Install_SystemScriptSuccess = "config_systeme.ps1 erfolgreich ausgeführt (Exit-Code 0)."
    Install_SystemScriptWarning = "config_systeme.ps1 wurde mit Exit-Code {0} beendet. Überprüfen Sie die Protokolle in '{1}\Logs'."
    Install_SystemScriptError = "Fehler bei der ersten Ausführung von config_systeme.ps1: '{0}'"
    Install_Trace = "Trace: '{0}'"
    Install_ExecutingUserScript = "Führe config_utilisateur.ps1 für '{0}' aus, um die ersten Benutzerkonfigurationen anzuwenden..."
    Install_UserConfigLaunched = "ERFOLG: Benutzerkonfigurationsskript gestartet."
    Install_UserScriptSuccess = "config_utilisateur.ps1 erfolgreich für '{0}' ausgeführt (Exit-Code 0)."
    Install_UserScriptWarning = "config_utilisateur.ps1 für '{0}' wurde mit Exit-Code '{1}' beendet. Überprüfen Sie die Protokolle in '{2}\Logs'."
    Install_UserScriptError = "Fehler bei der ersten Ausführung von config_utilisateur.ps1 für '{0}': '{1}'"
    Install_InstallationCompleteSuccess = "Installation und Erststart abgeschlossen!"
    Install_InstallationCompleteWithErrors = "Installation mit Fehlern beim ersten Skriptstart abgeschlossen. Überprüfen Sie die obigen Nachrichten."
    Install_CriticalErrorDuringInstallation = "Ein kritischer Fehler ist während der Installation aufgetreten: '{0}'"
    Install_SilentMode_CompletedSuccessfully = "WindowsOrchestrator-Installation erfolgreich abgeschlossen!\n\nAlle Protokolle wurden im Ordner 'Logs' gespeichert."
    Install_SilentMode_CompletedWithErrors = "WindowsOrchestrator-Installation mit Fehlern abgeschlossen.\n\nBitte überprüfen Sie die Protokolldateien im Ordner 'Logs' für weitere Details."

    # Deinstallation
    Uninstall_StartMessage = "Starte vollständige Deinstallation von WindowsOrchestrator..."
    Uninstall_AutoLogonQuestion = "[FRAGE] WindowsOrchestrator hat möglicherweise die automatische Sitzungsanmeldung (Autologon) aktiviert. Möchten Sie diese jetzt deaktivieren? (j/n)"
    Uninstall_RestoringSettings = "Stelle wichtigste Windows-Einstellungen wieder her..."
    Uninstall_WindowsUpdateReactivated = "- Windows-Updates und automatischer Neustart: Reaktiviert."
    Uninstall_WindowsUpdateError = "- FEHLER bei der Reaktivierung von Windows Update: '{0}'"
    Uninstall_FastStartupReactivated = "- Windows-Schnellstart: Reaktiviert (Standardwert)."
    Uninstall_FastStartupError = "- FEHLER bei der Reaktivierung des Schnellstarts: '{0}'"
    Uninstall_OneDriveReactivated = "- OneDrive: Reaktiviert (Blockierungsrichtlinie entfernt)."
    Uninstall_OneDriveError = "- FEHLER bei der Reaktivierung von OneDrive: '{0}'"
    Uninstall_DeletingScheduledTasks = "Lösche geplante Aufgaben..."
    Uninstall_ProcessingTask = "Verarbeite Aufgabe '{0}'..."
    Uninstall_TaskFoundAttemptingDeletion = " Gefunden. Versuche Löschung..."
    Uninstall_TaskSuccessfullyRemoved = " Erfolgreich entfernt."
    Uninstall_TaskDeletionFailed = " LÖSCHUNG FEHLGESCHLAGEN."
    Uninstall_TaskDeletionError = " FEHLER beim Löschen."
    Uninstall_TaskErrorDetail = "   Detail: '{0}'"
    Uninstall_TaskNotFound = " Nicht gefunden."
    Uninstall_CompletionMessage = "Deinstallation abgeschlossen."
    Uninstall_TasksNotRemovedWarning = "Einige Aufgaben konnten NICHT entfernt werden: '{0}'."
    Uninstall_CheckTaskScheduler = "Bitte überprüfen Sie die Aufgabenplanung."
    Uninstall_FilesNotDeletedNote = "Hinweis: Skripte und Konfigurationsdateien werden nicht von Ihrer Festplatte gelöscht."
    Uninstall_LSACleanAttempt = "INFO: Versuche vollständige Bereinigung der LSA-Geheimnisse über Autologon.exe..."
    Uninstall_AutoLogonDisabled = "- Automatische Sitzungsanmeldung: Deaktiviert (über Autologon-Tool)."
    Uninstall_AutoLogonDisableError = "- FEHLER beim Versuch, die automatische Sitzungsanmeldung zu deaktivieren: '{0}'"
    Uninstall_AutoLogonLeftAsIs = "- Automatische Sitzungsanmeldung: Beibehalten (Benutzerentscheidung)."
    Uninstall_AutologonToolNotFound_Interactive = "[WARNUNG] Autologon.exe Tool nicht gefunden. Automatische Deaktivierung kann nicht durchgeführt werden. Wenn Sie die automatische Anmeldung deaktivieren möchten, tun Sie dies bitte manuell."
    Uninstall_AutologonDisablePrompt = "Bitte klicken Sie im sich öffnenden Fenster des Autologon-Tools auf 'Disable', um die Bereinigung abzuschließen."
    Uninstall_AutologonNotActive = "INFO: Automatische Sitzungsanmeldung ist nicht aktiv. Keine Bereinigung erforderlich."
    Uninstall_SilentMode_CompletedSuccessfully = "WindowsOrchestrator-Deinstallation erfolgreich abgeschlossen!\n\nAlle Protokolle wurden im Ordner 'Logs' gespeichert."
    Uninstall_SilentMode_CompletedWithErrors = "WindowsOrchestrator-Deinstallation mit Fehlern abgeschlossen.\n\nBitte überprüfen Sie die Protokolldateien im Ordner 'Logs' für weitere Details."

    # ------------------------------------------------------------------------------
    # 6. BENACHRICHTIGUNGEN (Gotify) & ALLGEMEINES
    # ------------------------------------------------------------------------------
    Gotify_MessageDate = "Ausgeführt am {0}."
    Gotify_SystemActionsHeader = "SYSTEM-Aktionen:"
    Gotify_NoSystemActions = "Keine SYSTEM-Aktionen."
    Gotify_SystemErrorsHeader = "SYSTEM-Fehler:"
    Gotify_UserActionsHeader = "BENUTZER-Aktionen:"
    Gotify_NoUserActions = "Keine BENUTZER-Aktionen."
    Gotify_UserErrorsHeader = "BENUTZER-Fehler:"
    Error_LanguageFileLoad = "Ein kritischer Fehler ist beim Laden der Sprachdateien aufgetreten: '{0}'"
    Error_InvalidConfigValue = "Ungültiger Konfigurationswert für [{0}]{1}: '{2}'. Erwarteter Typ '{3}'. Standard/leerer Wert wird verwendet."
    Install_SplashMessage = "Vorgang läuft, bitte warten..."

    # --- v1.73 Überbrückungsmodus ---
    Log_System_RebootBridgeScheduled = '- Neustart aktiviert (Überbrückung nach Schließung + {0} Min: {1}).'
}
