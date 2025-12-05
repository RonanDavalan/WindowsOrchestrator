@{
    # ==============================================================================
    # LANGUAGE FILE : ENGLISH (EN-US)
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 1. GRAPHICAL INTERFACE (firstconfig.ps1)
    # ------------------------------------------------------------------------------

    # Titles & Navigation
    ConfigForm_Title = "Configuration Wizard - WindowsOrchestrator"
    ConfigForm_Tab_Basic = "Basic"
    ConfigForm_Tab_Advanced = "Advanced"
    ConfigForm_SubTabMain = "Main"
    ConfigForm_SubTabBackup = "Backup"
    ConfigForm_SubTabOtherAccount = "Options & Account"

    # Group: User Session
    ConfigForm_EnableSessionManagementCheckbox = "Enable automatic logon (Autologon)"
    ConfigForm_SecureAutologonModeDescription = "(Opens the desktop, then immediately locks the session)"
    ConfigForm_BackgroundTaskModeDescription = "(Launches the application invisibly, without opening a session)"
    ConfigForm_SessionEulaNote = "(By checking, you accept the license of the Microsoft Autologon tool)"
    ConfigForm_UseAutologonAssistantCheckbox = "Use the assistant to configure the Autologon tool (if required)"
    ConfigForm_AutoLoginUsernameLabel = "Username for Auto-Login (optional):"

    # Group: Windows Settings
    ConfigForm_WindowsSettingsGroup = "Windows Settings"
    ConfigForm_DisableFastStartupCheckbox = "Disable Windows Fast Startup"
    ConfigForm_DisableSleepCheckbox = "Disable automatic sleep"
    ConfigForm_DisableScreenSleepCheckbox = "Disable screen sleep"
    ConfigForm_DisableWindowsUpdateCheckbox = "Block Windows Update service"
    ConfigForm_DisableAutoRebootCheckbox = "Disable automatic reboot after update"

    # Group: OneDrive
    ConfigForm_OneDriveModeLabel = "OneDrive Management:"
    ConfigForm_OneDriveMode_Block = "Block (system policy)"
    ConfigForm_OneDriveMode_Close = "Close at startup"
    ConfigForm_OneDriveMode_Ignore = "Do nothing"

    # Group: Closure & Application
    ConfigForm_CloseAppGroupTitle = "Scheduled Application Closure"
    ConfigForm_CloseTimeLabel = "Closure Time (HH:MM):"
    ConfigForm_CloseCommandLabel = "Closure command to execute:"
    ConfigForm_CloseArgumentsLabel = "Arguments for the command:"

    ConfigForm_MainAppGroupTitle = "Main Application and Daily Cycle"
    ConfigForm_RebootTimeLabel = "Scheduled Reboot Time (HH:MM):"
    ConfigForm_ProcessToLaunchLabel = "Application to Launch:"
    ConfigForm_ProcessArgumentsLabel = "Arguments for the application:"
    ConfigForm_ProcessToMonitorLabel = "Process Name to Monitor (without .exe):"
    ConfigForm_StartProcessMinimizedCheckbox = "Launch the main application minimized to the taskbar"
    ConfigForm_LaunchConsoleModeLabel = "Console Launch Mode:"
    ConfigForm_LaunchConsoleMode_Standard = "Standard Launch (recommended)"
    ConfigForm_LaunchConsoleMode_Legacy = "Legacy Launch (legacy console)"

    # Group: Backup
    ConfigForm_DatabaseBackupGroupTitle = "Database Backup (Optional)"
    ConfigForm_EnableBackupCheckbox = "Enable backup before reboot"
    ConfigForm_BackupSourceLabel = "Data source folder:"
    ConfigForm_BackupDestinationLabel = "Backup destination folder:"
    ConfigForm_BackupTimeLabel = "Backup Time (HH:MM):"
    ConfigForm_BackupKeepDaysLabel = "Keep backups for (days):"

    # Group: Installation Options & Target Account
    ConfigForm_InstallOptionsGroup = "Installation Options"
    ConfigForm_SilentModeCheckbox = "Hide console windows during installation/uninstallation"
    ConfigForm_OtherAccountGroupTitle = "Customize for Another User"
    ConfigForm_OtherAccountDescription = "Allows specifying an alternative user account for scheduled task execution. Requires administrative privileges for cross-account configuration."
    ConfigForm_OtherAccountUsernameLabel = "User account name to configure:"

    # Buttons & GUI Messages
    ConfigForm_SaveButton = "Save and Close"
    ConfigForm_CancelButton = "Cancel"
    ConfigForm_SaveSuccessMessage = "Configuration saved in '{0}'"
    ConfigForm_SaveSuccess = "Configuration saved successfully!"
    ConfigForm_SaveSuccessCaption = "Success"
    ConfigForm_ConfigWizardCancelled = "Configuration wizard cancelled."
    ConfigForm_PathError = "Unable to determine project paths. Error: '{0}'. The script will close."
    ConfigForm_PathErrorCaption = "Critical Path Error"
    ConfigForm_ModelFileNotFoundError = "ERROR: The model file 'management\defaults\default_config.ini' is not found AND no 'config.ini' exists. Installation impossible."
    ConfigForm_ModelFileNotFoundCaption = "Missing Model File"
    ConfigForm_CopyError = "Unable to create the 'config.ini' file from the model. Error: '{0}'."
    ConfigForm_CopyErrorCaption = "Copy Error"
    ConfigForm_OverwritePrompt = "A configuration file 'config.ini' already exists.\n\nDo you want to replace it with the default model?\n\nATTENTION: Your current settings will be lost."
    ConfigForm_OverwriteCaption = "Replace existing configuration?"
    ConfigForm_ResetSuccess = "The 'config.ini' file has been reset with default values."
    ConfigForm_ResetSuccessCaption = "Reset Completed"
    ConfigForm_OverwriteError = "Unable to replace 'config.ini' with the model. Error: '{0}'."
    ConfigForm_InvalidTimeFormat = "Time format must be HH:MM (e.g., 03:55)."
    ConfigForm_InvalidTimeFormatCaption = "Invalid Format"
    ConfigForm_InvalidTimeLogic = "The closure time must be EARLIER than the scheduled reboot time."
    ConfigForm_InvalidTimeLogicCaption = "Invalid Time Logic"
    ConfigForm_AllSysOptimizedNote = "✔ These settings are optimized to ensure system stability and the proper functioning of your application. It is recommended not to modify them."

    # ------------------------------------------------------------------------------
    # 2. SYSTEM SCRIPT (config_systeme.ps1)
    # ------------------------------------------------------------------------------

    # General Logs
    Log_StartingScript = "Starting '{0}' ('{1}')..."
    Log_CheckingNetwork = "Checking network connectivity..."
    Log_NetworkDetected = "Network connectivity detected."
    Log_NetworkRetry = "Network not available, retrying in 10s..."
    Log_NetworkFailed = "Network not established. Gotify may fail."
    Log_ExecutingSystemActions = "Executing configured SYSTEM actions..."
    Log_SettingNotSpecified = "The parameter '{0}' is not specified."
    Log_ScriptFinished = "'{0}' ('{1}') finished."
    Log_ErrorsOccurred = "Errors occurred during execution."
    Log_CapturedError = "CAPTURED ERROR: '{0}'"
    Error_FatalScriptError = "FATAL SCRIPT ERROR (main block): '{0}' \n'{1}'"
    System_ConfigCriticalError = "Critical failure: config.ini."

    # Target User Management
    Log_ReadRegistryForUser = "AutoLoginUsername not specified. Attempting to read DefaultUserName from Registry."
    Log_RegistryUserFound = "Using DefaultUserName from Registry as target user: '{0}'."
    Log_RegistryUserNotFound = "DefaultUserName from Registry not found or empty. No default target user."
    Log_RegistryReadError = "Error reading DefaultUserName from Registry: '{0}'"
    Log_ConfigUserFound = "Using AutoLoginUsername from config.ini as target user: '{0}'."

    # --- Actions: Windows Settings ---
    Log_DisablingFastStartup = "Cfg: Disabling Fast Startup."
    Action_FastStartupDisabled = "- Windows Fast Startup is disabled."
    Log_FastStartupAlreadyDisabled = "Windows Fast Startup is already disabled."
    Action_FastStartupVerifiedDisabled = "- Windows Fast Startup is disabled."

    Log_EnablingFastStartup = "Cfg: Enabling Fast Startup."
    Action_FastStartupEnabled = "- Windows Fast Startup is enabled."
    Log_FastStartupAlreadyEnabled = "Windows Fast Startup is already enabled."
    Action_FastStartupVerifiedEnabled = "- Windows Fast Startup is enabled."
    Error_DisableFastStartupFailed = "Failed to disable Fast Startup: '{0}'"
    Error_EnableFastStartupFailed = "Failed to enable Fast Startup: '{0}'"
    Error_RegPathNotFound = "Registry path for power settings not found: '{0}'"

    Log_DisablingSleep = "Disabling machine sleep..."
    Action_SleepDisabled = "- Automatic sleep is disabled."
    Error_DisableSleepFailed = "Failed to disable automatic sleep: '{0}'"

    Log_DisablingScreenSleep = "Disabling screen sleep..."
    Action_ScreenSleepDisabled = "- Screen sleep is disabled."
    Error_DisableScreenSleepFailed = "Failed to disable screen sleep: '{0}'"

    Log_DisablingUpdates = "Disabling Windows Updates..."
    Action_UpdatesDisabled = "- Windows Update service is blocked."
    Log_EnablingUpdates = "Enabling Windows Updates..."
    Action_UpdatesEnabled = "- Windows Update service is active."
    Error_UpdateMgmtFailed = "Failed to manage Windows Updates: '{0}'"

    Log_DisablingAutoReboot = "Disabling forced reboot by Windows Update..."
    Action_AutoRebootDisabled = "- Automatic reboot after update is disabled."
    Error_DisableAutoRebootFailed = "Failed to disable automatic reboot after update: '{0}'"

    # --- Actions: Session & OneDrive ---
    Log_EnablingAutoLogin = "Verifying/Enabling automatic login..."
    Action_AutoAdminLogonEnabled = "- Automatic login enabled."
    Action_AutoLogonAutomatic = "- Automatic login enabled for '{0}' (Mode: Autologon)."
    Action_AutoLogonSecure = "- Automatic login enabled for '{0}' (Mode: Secure)."
    Action_AutologonVerified = "- Automatic login is active."
    Action_DefaultUserNameSet = "Default username set to: '{0}'."
    Log_AutoLoginUserUnknown = "Automatic login enabled but target user could not be determined."
    Error_AutoLoginFailed = "Failed to configure automatic login: '{0}'"
    Error_AutoLoginUserUnknown = "Automatic login enabled but target user could not be determined."
    Error_SecureAutoLoginFailed = "Failed to configure secure login: '{0}'"
    Action_LockTaskConfigured = "One-time session lock configured for '{0}'."

    Log_DisablingAutoLogin = "Disabling automatic login..."
    Action_AutoAdminLogonDisabled = "- Automatic login is disabled."
    Error_DisableAutoLoginFailed = "Failed to disable automatic login: '{0}'"

    Log_DisablingOneDrive = "Disabling OneDrive (policy)..."
    Log_EnablingOneDrive = "Enabling/Reallowing OneDrive (policy)..."
    Action_OneDriveDisabled = "- OneDrive is disabled (policy)."
    Action_OneDriveEnabled = "- OneDrive is allowed."
    Action_OneDriveClosed = "- OneDrive process terminated."
    Action_OneDriveBlocked = "- OneDrive is blocked (system policy) and process stopped."
    Action_OneDriveAutostartRemoved = "- OneDrive auto-start disabled for user '{0}'."
    Action_OneDriveIgnored = "- OneDrive blocking policy removed (Ignore mode)."
    Error_DisableOneDriveFailed = "Failed to disable OneDrive: '{0}'"
    Error_EnableOneDriveFailed = "Failed to enable OneDrive: '{0}'"
    Action_OneDriveClean = "- OneDrive is closed and auto-start is disabled."

    # --- Actions: Scheduling (Future) ---
    Log_ConfiguringReboot = "Configuring scheduled reboot at {0}..."
    Action_RebootScheduled = "- Scheduled reboot at {0}."
    Error_RebootScheduleFailed = "Failed to configure scheduled reboot task ({0}) '{1}': '{2}'."
    Log_RebootTaskRemoved = "Reboot time not specified. Removing task '{0}'."

    Action_BackupTaskConfigured = "- Scheduled data backup at {0}."
    Error_BackupTaskFailed = "Failed to configure backup task: '{0}'"
    System_BackupTaskDescription = "Orchestrator: Performs data backup before reboot."
    System_BackupScriptNotFound = "The dedicated backup script '{0}' is not found."

    # System Process Management (Background Task)
    Log_System_NoProcessSpecified = "No application to launch specified. No action taken."
    Log_System_ProcessToMonitor = "Monitoring process name: '{0}'."
    Log_System_ProcessAlreadyRunning = "The process '{0}' (PID: {1}) is already running. No action necessary."
    Action_System_ProcessAlreadyRunning = "The process '{0}' is already running (PID: {1})."
    Log_System_NoMonitor = "No process to monitor specified. Skipping check."
    Log_System_ProcessStarting = "Starting background process '{0}' via '{1}'..."
    Action_System_ProcessStarted = "- Background process '{0}' started (via '{1}')."
    Error_System_ProcessManagementFailed = "Failed to manage background process '{0}': '{1}'"
    Action_System_CloseTaskConfigured = "- Background process stop task configured for '{0}' at {1}."
    Error_System_CloseTaskFailed = "Failed to create background process stop task: '{0}'"
    System_ProcessNotDefined = "The application to be launched is not defined for BackgroundTask mode (SYSTEM context without graphical interface)."

    # ------------------------------------------------------------------------------
    # 3. USER SCRIPT (config_utilisateur.ps1)
    # ------------------------------------------------------------------------------
    Log_User_StartingScript = "Starting '{0}' ('{1}') for user '{2}'..."
    Log_User_ExecutingActions = "Executing configured actions for user '{0}'..."
    Log_User_CannotReadConfig = "Unable to read or parse '{0}'. Stopping user configurations."
    Log_User_ScriptFinished = "'{0}' ('{1}') for user '{2}' finished."

    Log_User_ManagingProcess = "Managing user process (raw:'{0}', resolved:'{1}'). Method: '{2}'"
    Log_User_ProcessWithArgs = "With arguments: '{0}'"
    Log_User_ProcessToMonitor = "Monitoring process name: '{0}'."
    Log_User_ProcessAlreadyRunning = "The process '{0}' (PID: {1}) is already running for the current user. No action necessary."
    Action_User_ProcessAlreadyRunning = "The process '{0}' is already running (PID: {1})."
    Log_User_NoMonitor = "No process to monitor specified. Check ignored."
    Log_User_NoProcessSpecified = "No process specified or path is empty."
    Log_User_BaseNameError = "Error extracting base name from '{0}' (direct)."
    Log_User_EmptyBaseName = "The process base name to monitor is empty."
    Log_User_WorkingDirFallback = "The process name '{0}' is not a file path; Working directory set to '{1}' for '{2}'."
    Log_User_WorkingDirNotFound = "Working directory '{0}' not found. It will not be set."

    Log_User_ProcessStopping = "The process '{0}' (PID: {1}) is running. Stopping..."
    Action_User_ProcessStopped = "Process '{0}' stopped."
    Log_User_ProcessRestarting = "Restarting via '{0}': '{1}' with arguments: '{2}'"
    Action_User_ProcessRestarted = "- Process '{0}' restarted (via '{1}')."
    Log_User_ProcessStarting = "Process '{0}' not found. Starting via '{1}': '{2}' with arguments: '{3}'"
    Action_User_ProcessStarted = "- Process '{0}' started."

    Error_User_LaunchMethodUnknown = "Launch method '{0}' not recognized. Options: direct, powershell, cmd."
    Error_User_InterpreterNotFound = "Interpreter '{0}' not found for method '{1}'."
    Error_User_ProcessManagementFailed = "Failed to manage process '{0}' (Method: '{1}', Path: '{2}', Args: '{3}'): '{4}'. StackTrace: '{5}'"
    Error_User_ExeNotFound = "Executable file for process '{0}' (direct mode) NOT FOUND."
    Error_User_FatalScriptError = "FATAL USER SCRIPT ERROR '{0}': '{1}' \n'{2}'"
    Error_User_VarExpansionFailed = "Error expanding variables for process '{0}': '{1}'"

    Action_User_CloseTaskConfigured = "- Application closure scheduled at {1}."
    Error_User_CloseTaskFailed = "Failed to create application closure task '{0}': '{1}'"

    # ------------------------------------------------------------------------------
    # 4. BACKUP MODULE (Invoke-DatabaseBackup.ps1)
    # ------------------------------------------------------------------------------
    Log_Backup_Starting = "Starting database backup process..."
    Log_Backup_Disabled = "Database backup is DISABLED in config.ini. Skipped."
    Log_Backup_PurgeStarting = "Starting cleanup of old backups (keeping last {0} days)..."
    Log_Backup_PurgingFile = "Purging old backup: '{0}'."
    Log_Backup_NoFilesToPurge = "No old backups to clean up."
    Log_Backup_RetentionPolicy = "Retention policy: {0} day(s)."
    Log_Backup_NoFilesFound = "No files modified in the last 24 hours found to back up."
    Log_Backup_FilesFound = "{0} file(s) to back up found (paired files included)."
    Log_Backup_CopyingFile = "Successfully backed up '{0}' to '{1}'."
    Log_Backup_AlreadyRunning = "Backup already running (lock age: {0} min). Skipped."

    Action_Backup_Completed = "Backup of {0} file(s) completed successfully."
    Action_Backup_DestinationCreated = "Backup destination folder '{0}' created."
    Action_Backup_PurgeCompleted = "Cleanup of {0} old backup(s) completed."

    Error_Backup_PathNotFound = "The backup source or destination path '{0}' was not found. Operation cancelled."
    Error_Backup_DestinationCreationFailed = "Failed to create backup destination folder '{0}': '{1}'"
    Error_Backup_InsufficientPermissions = "Insufficient permissions to write to backup destination: '{0}'"
    Error_Backup_InsufficientSpace = "Insufficient disk space. Required: {0:N2} MB, Available: {1:N2} MB"
    Error_Backup_PurgeFailed = "Failed to purge old backup '{0}': '{1}'"
    Error_Backup_CopyFailed = "Failed to back up file '{0}': '{1}'"
    Error_Backup_Critical = "CRITICAL ERROR during backup process: '{0}'"
    Backup_ConfigLoadError = "Could not read config.ini"
    Backup_InitError = "Critical initialization error: '{0}'"

    # ------------------------------------------------------------------------------
    # 5. INSTALLATION & UNINSTALLATION (install.ps1 / uninstall.ps1)
    # ------------------------------------------------------------------------------

    # Common
    Install_ElevationWarning = "Privilege elevation failed. Please run this script as an administrator."
    Uninstall_ElevationWarning = "Privilege elevation failed. Please run this script as an administrator."
    Install_PressEnterToExit = "Press Enter to exit."
    Uninstall_PressEnterToExit = "Press Enter to exit."
    Install_PressEnterToClose = "Press Enter to close this window."
    Uninstall_PressEnterToClose = "Press Enter to close this window."
    Exit_AutoCloseMessage = "This window will close in {0} seconds..."
    Install_RebootMessage = "Installation completed. The system will reboot in {0} seconds to apply the configuration."
    Uninstall_RebootMessage = "Uninstallation completed. The system will reboot in {0} seconds to clean the environment."

    # Install - Initialization
    Install_UnsupportedArchitectureError = "Unsupported processor architecture: '{0}'"
    Install_ConfigIniNotFoundWarning = "config.ini not found in the presumed parent directory ('{0}')."
    Install_ProjectRootPrompt = "Please enter the full path of the WindowsOrchestrator scripts root directory (e.g., C:\WindowsOrchestrator)"
    Install_InvalidProjectRootError = "Invalid project root directory or config.ini not found: '{0}'"
    Install_PathDeterminationError = "Error determining initial paths: '{0}'"
    Install_MissingSystemFile = "Required system file missing: '{0}'"
    Install_MissingUserFile = "Required user file missing: '{0}'"
    Install_MissingFilesAborted = "Main script files are missing in '{0}'. Installation cancelled. Press Enter to exit."
    Install_ProjectRootUsed = "Project root directory used: '{0}'"
    Install_UserTaskTarget = "The user task will be installed for: '{0}'"
    Install_AutoLoginUserEmpty = "INFO: 'AutoLoginUsername' is empty. Filling with installer user..."
    Install_AutoLoginUserUpdated = "SUCCESS: config.ini updated with 'AutoLoginUsername={0}'."
    Install_AutoLoginUserUpdateFailed = "WARNING: Failed to update 'AutoLoginUsername' in config.ini: '{0}'"
    Install_LogPermissionsWarning = "WARNING: Unable to create or set permissions for the Logs folder. Logging may fail. Error: '{0}'"

    # Install - Autologon Assistant
    Install_AutologonAlreadyActive = "INFO: Windows automatic login is already active. The assistant is not necessary."
    Install_DownloadingAutologon = "Downloading Microsoft Autologon tool..."
    Install_AutologonDownloadFailed = "ERROR: Failed to download Autologon.zip. Check your internet connection."
    Install_ExtractingArchive = "Extracting archive..."
    Install_AutologonFilesMissing = "Required files ('{0}', Eula.txt) not found after extraction."
    Install_AutologonExtractionFailed = "WARNING: Failed to prepare Autologon tool. The downloaded archive may be corrupted."
    Install_AutologonDownloadFailedPrompt = "Download failed. Do you want to locate the Autologon.zip file manually?\n\nOfficial page: https://learn.microsoft.com/sysinternals/downloads/autologon"
    Install_AutologonUnsupportedArchitecture = "ERROR: Unsupported processor architecture ('{0}'). Unable to configure Autologon."
    Install_EulaConsentMessage = "Do you accept the terms of the Autologon tool license from Sysinternals?"
    Install_EulaConsentCaption = "EULA Consent Required"
    Install_PromptReviewEula = "The Microsoft End User License Agreement (EULA) will open in Notepad. Please read it and then close the window to continue."
    Install_EulaConsentRefused = "License consent refused by user. Autologon configuration cancelled."
    Install_EulaRejected = "Autologon configuration cancelled (EULA not accepted)."
    Install_PromptUseAutologonTool = "The Autologon tool will now open. Please enter your information (User, Domain, Password) and click 'Enable'."
    Install_AutologonSelectZipTitle = "Select the downloaded Autologon.zip file"
    Install_AutologonFileSelectedSuccess = "SUCCESS: The local file '{0}' will be used."
    Install_AutologonSuccess = "SUCCESS: The Autologon tool has been executed. Automatic login should now be configured."
    Install_ContinueNoAutologon = "Installation continues without configuring Autologon."
    Install_AbortedByUser = "Installation cancelled by user."
    Install_AutologonDownloadFailedCaption = "Autologon Assistant Failed"
    Install_ConfirmContinueWithoutAutologon = "The Autologon assistant failed. Do you want to continue the installation without automatic login?"
    Install_AutologonManualDownloadPrompt = @"
The automatic download of the Autologon tool failed.

You can download it manually to enable this feature.

1.  Open this URL in your browser: https://learn.microsoft.com/sysinternals/downloads/autologon
2.  Download and extract 'Autologon.zip'.
3.  Place all extracted files (Autologon64.exe, etc.) in the following folder:
    {0}
4.  Relaunch the installation.

Do you want to continue the installation now without configuring Autologon?
"@

    # Install - Password & Tasks
    Install_PasswordRequiredPrompt = "Automatic session mode is enabled. The password for the '{0}' account is REQUIRED to securely configure the scheduled task."
    Install_PasswordSecurityInfo = "This password is passed directly to the Windows API and is NEVER stored."
    Install_EnterPasswordPrompt = "Please enter the password for the '{0}' account"
    Install_PasswordIncorrect = "Incorrect password or validation error. Please try again."
    Install_PasswordAttemptsRemaining = "Remaining attempts: {0}."
    Install_PasswordEmptyToCancel = "(Leave empty and press Enter to cancel)"
    Install_PasswordMaxAttemptsReached = "Maximum attempts reached. Installation cancelled."
    Install_StartConfiguringTasks = "Starting configuration of scheduled tasks..."
    Install_CreatingSystemTask = "Creating/Updating system task '{0}'..."
    Install_SystemTaskDescription = "WindowsOrchestrator: Executes the system configuration script at startup."
    Install_SystemTaskConfiguredSuccess = "Task '{0}' configured successfully."
    Install_CreatingUserTask = "Creating/Updating user task '{0}' for '{1}'..."
    Install_UserTaskDescription = "WindowsOrchestrator: Executes the user configuration script at logon."
    Install_MainTasksConfigured = "Main scheduled tasks configured."
    Install_DailyRebootTasksNote = "Tasks for daily reboot and closure action will be managed by '{0}' during its execution."
    Install_TaskCreationSuccess = "Tasks created successfully using the provided credentials."

    # Install - Execution & End
    Install_AttemptingInitialLaunch = "Attempting initial launch of configuration scripts..."
    Install_ExecutingSystemScript = "Executing config_systeme.ps1 to apply initial system configurations..."
    Install_SystemScriptSuccess = "config_systeme.ps1 executed successfully (exit code 0)."
    Install_SystemScriptWarning = "config_systeme.ps1 terminated with exit code: {0}. Check logs in '{1}\Logs'."
    Install_SystemScriptError = "Error during initial execution of config_systeme.ps1: '{0}'"
    Install_Trace = "Trace: '{0}'"
    Install_ExecutingUserScript = "Executing config_utilisateur.ps1 for '{0}' to apply initial user configurations..."
    Install_UserConfigLaunched = "SUCCESS: The user configuration script has been launched."
    Install_UserScriptSuccess = "config_utilisateur.ps1 executed successfully for '{0}' (exit code 0)."
    Install_UserScriptWarning = "config_utilisateur.ps1 for '{0}' terminated with exit code: {1}. Check logs in '{2}\Logs'."
    Install_UserScriptError = "Error during initial execution of config_utilisateur.ps1 for '{0}': '{1}'"
    Install_InstallationCompleteSuccess = "Installation and initial launch completed!"
    Install_InstallationCompleteWithErrors = "Installation completed with errors during initial script launch. Check the messages above."
    Install_CriticalErrorDuringInstallation = "A critical error occurred during installation: '{0}'"
    Install_SilentMode_CompletedSuccessfully = "WindowsOrchestrator installation completed successfully!\n\nAll logs have been saved to the Logs folder."
    Install_SilentMode_CompletedWithErrors = "WindowsOrchestrator installation completed with errors.\n\nPlease check the log files in the Logs folder for details."

    # Uninstall
    Uninstall_StartMessage = "Starting full uninstallation of WindowsOrchestrator..."
    Uninstall_AutoLogonQuestion = "[QUESTION] WindowsOrchestrator may have enabled automatic login (Autologon). Do you want to disable it now? (y/n)"
    Uninstall_RestoringSettings = "Restoring main Windows settings..."
    Uninstall_WindowsUpdateReactivated = "- Windows Updates and automatic reboot: Reactivated."
    Uninstall_WindowsUpdateError = "- ERROR reactivating Windows Update: '{0}'"
    Uninstall_FastStartupReactivated = "- Windows Fast Startup: Reactivated (default value)."
    Uninstall_FastStartupError = "- ERROR reactivating Fast Startup: '{0}'"
    Uninstall_OneDriveReactivated = "- OneDrive: Reactivated (blocking policy removed)."
    Uninstall_OneDriveError = "- ERROR reactivating OneDrive: '{0}'"
    Uninstall_DeletingScheduledTasks = "Deleting scheduled tasks..."
    Uninstall_ProcessingTask = "Processing task '{0}'..."
    Uninstall_TaskFoundAttemptingDeletion = " Found. Attempting deletion..."
    Uninstall_TaskSuccessfullyRemoved = " Successfully removed."
    Uninstall_TaskDeletionFailed = " DELETION FAILED."
    Uninstall_TaskDeletionError = " ERROR during deletion."
    Uninstall_TaskErrorDetail = "   Detail: '{0}'"
    Uninstall_TaskNotFound = " Not found."
    Uninstall_CompletionMessage = "Uninstallation completed."
    Uninstall_TasksNotRemovedWarning = "Some tasks could NOT be removed: '{0}'."
    Uninstall_CheckTaskScheduler = "Please check the Task Scheduler."
    Uninstall_FilesNotDeletedNote = "Note: Scripts and configuration files are not deleted from your disk."
    Uninstall_LSACleanAttempt = "INFO: Attempting full LSA secrets cleanup via Autologon.exe..."
    Uninstall_AutoLogonDisabled = "- Automatic login: Disabled (via Autologon tool)."
    Uninstall_AutoLogonDisableError = "- ERROR attempting to disable automatic login: '{0}'"
    Uninstall_AutoLogonLeftAsIs = "- Automatic login: Left as is (user's choice)."
    Uninstall_AutologonToolNotFound_Interactive = "[WARNING] Autologon.exe tool not found. Automatic disabling cannot be performed. If you wish to disable automatic login, please do so manually."
    Uninstall_AutologonDisablePrompt = "Please click 'Disable' in the Autologon tool window that will open to finalize the cleanup."
    Uninstall_AutologonNotActive = "INFO: Automatic login is not active. No cleanup needed."
    Uninstall_SilentMode_CompletedSuccessfully = "WindowsOrchestrator uninstallation completed successfully!\n\nAll logs have been saved to the Logs folder."
    Uninstall_SilentMode_CompletedWithErrors = "WindowsOrchestrator uninstallation completed with errors.\n\nPlease check the log files in the Logs folder for details."

    # ------------------------------------------------------------------------------
    # 6. NOTIFICATIONS (Gotify) & COMMONS
    # ------------------------------------------------------------------------------
    Gotify_MessageDate = "Executed on {0}."
    Gotify_SystemActionsHeader = "SYSTEM ACTIONS:"
    Gotify_NoSystemActions = "No SYSTEM actions."
    Gotify_SystemErrorsHeader = "SYSTEM ERRORS:"
    Gotify_UserActionsHeader = "USER ACTIONS:"
    Gotify_NoUserActions = "No USER actions."
    Gotify_UserErrorsHeader = "USER ERRORS:"
    Error_LanguageFileLoad = "A critical error occurred while loading language files: '{0}'"
    Error_InvalidConfigValue = "Invalid configuration value for [{0}]{1}: '{2}'. Expected type '{3}'. Default/empty value used."
    Install_SplashMessage = "Operation in progress, please wait..."
}
