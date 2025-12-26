#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script de configuration système automatisée pour Windows.
.DESCRIPTION
    Ce script lit les paramètres depuis un fichier config.ini, applique un ensemble de configurations au niveau du système
    (démarrage rapide, veille, connexion automatique, Windows Update, etc.), et journalise toutes ses actions.
    Il est conçu pour s'exécuter au démarrage du système et gère l'internationalisation de ses logs.
.EXAMPLE
    Ce script n'est pas conçu pour être lancé manuellement avec des paramètres. Il est exécuté par une tâche planifiée
    et tire toute sa configuration du fichier 'config.ini' situé dans le même répertoire.

    Pour l'exécuter pour un test :
    PS C:\Path\To\Scripts\> .\config_systeme.ps1
.NOTES
    Projet      : WindowsOrchestrator
    Version     : 1.73
    Licence     : GNU GPLv3

    --- CRÉDITS & RÔLES ---
    Ce projet est le fruit d'une collaboration hybride Humain-IA :

    Direction Produit & Spécifications  : Christophe Lévêque
    Architecte Principal & QA           : Ronan Davalan
    Architecte IA & Planification       : Google Gemini
    Développeur IA Principal            : Grok (xAI)
    Consultant Technique IA             : Claude (Anthropic)
#>


# --- Initialisation de l'Internationalisation (I18N) ---
$Global:lang = @{}
try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') {
        $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    else {
        try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop }
        catch { $PSScriptRoot = Get-Location }
    }
    
    $modulePath = Join-Path $PSScriptRoot "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"
    Import-Module $modulePath -Force
    
    $Global:lang = Set-OrchestratorLanguage -ScriptRoot $PSScriptRoot
} catch {
    $i18nLoadingError = $_.Exception.Message
}


# --- Configuration Globale et Initialisation des Logs ---
$ScriptIdentifier = "WindowsOrchestrator-System"
$ScriptInternalBuild = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $ScriptDir = $PSScriptRoot
    $ProjectRootDir = (Resolve-Path (Join-Path $ScriptDir "..\")).Path

    $TargetLogDir = Join-Path -Path $ProjectRootDir -ChildPath "Logs"
    # Assurer que le répertoire de log existe, au cas où le script est lancé manuellement
    if (-not (Test-Path $TargetLogDir -PathType Container)) {
        try { New-Item -Path $TargetLogDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null } catch {}
    }

    $BaseLogPathForRotationSystem = Join-Path -Path $TargetLogDir -ChildPath "config_systeme_ps_log"
    $BaseLogPathForRotationUser = Join-Path -Path $TargetLogDir -ChildPath "config_utilisateur_log"
$DefaultMaxLogs = 7

$tempConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$tempIniContent = Get-IniContent -FilePath $tempConfigFile
$rotationEnabledByConfig = $true
if ($null -ne $tempIniContent -and $tempIniContent.ContainsKey("Logging") -and $tempIniContent["Logging"].ContainsKey("EnableLogRotation")) {
    if ($tempIniContent["Logging"]["EnableLogRotation"].ToLower() -eq "false") {
        $rotationEnabledByConfig = $false
    }
}

if ($rotationEnabledByConfig) {
    Invoke-LogFileRotation -BaseLogPath $BaseLogPathForRotationSystem -LogExtension ".txt" -MaxLogsToKeep $DefaultMaxLogs
    Invoke-LogFileRotation -BaseLogPath $BaseLogPathForRotationUser -LogExtension ".txt" -MaxLogsToKeep $DefaultMaxLogs
}

    $Global:LogFile = Join-Path -Path $TargetLogDir -ChildPath "config_systeme_ps_log.txt"
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "..\config.ini"
$Global:ActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:ErreursRencontrees = [System.Collections.Generic.List[string]]::new()
$Global:Config = $null


# --- Corps Principal du Script ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) {
        $tsInitErr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        try {
            Add-Content -Path $LogFile -Value "$tsInitErr [ERROR] - Cannot read '$ConfigFile'. Halting." -Encoding UTF8
        } catch {
            # Impossible d'écrire dans le journal, mais le programme va s'arrêter juste après de toute façon.
        }
        throw $Global:lang.System_ConfigCriticalError
    }

    if ($i18nLoadingError) {
        Add-Error -DefaultErrorMessage "A critical error occurred while loading language files: $i18nLoadingError" -ErrorId "Error_LanguageFileLoad" -ErrorArgs $i18nLoadingError
    }

    Write-Log -DefaultMessage "Starting $ScriptIdentifier ($ScriptInternalBuild)..." -MessageId "Log_StartingScript" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild

    Write-Log -DefaultMessage "Executing configured SYSTEM actions..." -MessageId "Log_ExecutingSystemActions"

    # --- Détermination de l'utilisateur cible ---
    $targetUsernameForConfiguration = Get-ConfigValue -Section "SystemConfig" -Key "AutoLoginUsername"
    if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
        Write-Log -DefaultMessage "Target user defined by config.ini: {0}." -MessageId "Log_ConfigUserFound" -MessageArgs $targetUsernameForConfiguration -Level INFO
    } else {
        Write-Log -DefaultMessage "Target user is not specified in config.ini. User-specific actions might be limited." -MessageId "Log_RegistryUserNotFound" -Level WARN
    }

    # --- Configuration du Démarrage Rapide (Fast Startup) ---
    $disableFastStartup = Get-ConfigValue -Section "SystemConfig" -Key "DisableFastStartup" -Type ([bool])
    $powerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if ($disableFastStartup) {
        if ((Get-ItemProperty $powerRegPath -ErrorAction SilentlyContinue).HiberbootEnabled -ne 0) {
            try {
                Set-ItemProperty $powerRegPath HiberbootEnabled 0 -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "FastStartup disabled." -ActionId "Action_FastStartupDisabled"
            } catch {
                Add-Error -DefaultErrorMessage "Failed to disable FastStartup: $($_.Exception.Message)" -ErrorId "Error_DisableFastStartupFailed" -ErrorArgs $_.Exception.Message
            }
        } else {
            Add-Action -DefaultActionMessage "FastStartup verified (already disabled)." -ActionId "Action_FastStartupVerifiedDisabled"
        }
    }
    else {
        if ((Get-ItemProperty $powerRegPath -ErrorAction SilentlyContinue).HiberbootEnabled -ne 1) {
            try {
                Set-ItemProperty $powerRegPath HiberbootEnabled 1 -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "FastStartup enabled." -ActionId "Action_FastStartupEnabled"
            } catch {
                Add-Error -DefaultErrorMessage "Failed to enable FastStartup: $($_.Exception.Message)" -ErrorId "Error_EnableFastStartupFailed" -ErrorArgs $_.Exception.Message
            }
        } else {
            Add-Action -DefaultActionMessage "FastStartup verified (already enabled)." -ActionId "Action_FastStartupVerifiedEnabled"
        }
    }

    # --- Configuration de la Veille (Sleep) ---
    if (Get-ConfigValue "SystemConfig" "DisableSleep" -Type ([bool])) {
        try {
            powercfg /change standby-timeout-ac 0
            powercfg /change hibernate-timeout-ac 0
            Add-Action -DefaultActionMessage "Machine sleep (S3/S4) disabled." -ActionId "Action_SleepDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable machine sleep: $($_.Exception.Message)" -ErrorId "Error_DisableSleepFailed" -ErrorArgs $_.Exception.Message
        }
    }
    if (Get-ConfigValue "SystemConfig" "DisableScreenSleep" -Type ([bool])) {
        try {
            powercfg /change monitor-timeout-ac 0
            Add-Action -DefaultActionMessage "Screen sleep disabled." -ActionId "Action_ScreenSleepDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable screen sleep: $($_.Exception.Message)" -ErrorId "Error_DisableScreenSleepFailed" -ErrorArgs $_.Exception.Message
        }
    }

    # --- Configuration de Windows Update ---
    $wuPolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $wuService = "wuauserv"
    if (-not (Test-Path $wuPolicyKey)) {
        New-Item $wuPolicyKey -Force -ErrorAction Stop | Out-Null
    }
    if (Get-ConfigValue "SystemConfig" "DisableWindowsUpdate" -Type ([bool])) {
        try {
            Set-ItemProperty $wuPolicyKey NoAutoUpdate 1 -Type DWord -Force -ErrorAction Stop
            Get-Service $wuService -ErrorAction Stop | Set-Service -StartupType Disabled -PassThru -ErrorAction Stop | Stop-Service -Force -ErrorAction SilentlyContinue
            Add-Action -DefaultActionMessage "Win Updates disabled." -ActionId "Action_UpdatesDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to manage Win Updates: $($_.Exception.Message)" -ErrorId "Error_UpdateMgmtFailed" -ErrorArgs $_.Exception.Message
        }
    }
    else {
        try {
            Set-ItemProperty $wuPolicyKey NoAutoUpdate 0 -Type DWord -Force -ErrorAction Stop
            Get-Service $wuService -ErrorAction Stop | Set-Service -StartupType Automatic -PassThru -ErrorAction Stop | Start-Service -ErrorAction SilentlyContinue
            Add-Action -DefaultActionMessage "Win Updates enabled." -ActionId "Action_UpdatesEnabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to manage Win Updates: $($_.Exception.Message)" -ErrorId "Error_UpdateMgmtFailed" -ErrorArgs $_.Exception.Message
        }
    }
    if (Get-ConfigValue "SystemConfig" "DisableAutoReboot" -Type ([bool])) {
        try {
            Set-ItemProperty $wuPolicyKey NoAutoRebootWithLoggedOnUsers 1 -Type DWord -Force -ErrorAction Stop
            Add-Action -DefaultActionMessage "Auto-reboot (WU) disabled." -ActionId "Action_AutoRebootDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable auto-reboot: $($_.Exception.Message)" -ErrorId "Error_DisableAutoRebootFailed" -ErrorArgs $_.Exception.Message
        }
    }

    # --- Configuration de la Session (AutoLogin) ---
    $winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $sessionMode = Get-ConfigValue -Section "SystemConfig" -Key "SessionStartupMode" -DefaultValue "Standard"
    $lockTaskName = "WindowsOrchestrator-LockSessionAtLogon"

    # CORRECTION v1.73 : Suppression de -CaseSensitive pour robustesse
    switch ($sessionMode) {
        "Autologon" {
            if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
                $currentAutoAdminLogon = (Get-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -ErrorAction SilentlyContinue).AutoAdminLogon
                $currentDefaultUserName = (Get-ItemProperty -Path $winlogonKey -Name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
                
                # Application Forcee (State Enforcement)
                if ($currentAutoAdminLogon -ne "1") {
                    Set-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -Value "1" -Type String -Force -ErrorAction Stop
                    Add-Action -DefaultActionMessage "AutoLogon was disabled. Re-enabled by policy." -ActionId "Action_AutoAdminLogonEnabled"
                } else {
                    Add-Action -DefaultActionMessage "Autologon verified (enabled)." -ActionId "Action_AutologonVerified"
                }
            } else {
                Add-Error -DefaultErrorMessage "Autologon requested, but target user could not be determined." -ErrorId "Error_AutoLoginUserUnknown"
            }
            # Cleanup
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "WindowsOrchestrator-Lock" -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName $lockTaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
        default { # Standard
            # PRINCIPE DE NON-INGÉRENCE (Correction v1.73)
            # Si le mode est Standard, l'orchestrateur NE DOIT PAS toucher à la configuration Autologon existante.
            # Il se contente de supprimer la tâche de verrouillage (si elle existe) pour ne pas bloquer une session manuelle.
            
            Write-Log -DefaultMessage "Session mode is 'Standard'. Leaving Autologon registry keys untouched." -Level INFO
            
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "WindowsOrchestrator-Lock" -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName $lockTaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    # --- Configuration de OneDrive ---
    $oneDrivePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    $oneDriveMode = Get-ConfigValue -Section "SystemConfig" -Key "OneDriveManagementMode" -DefaultValue "Ignore"

    switch ($oneDriveMode) {
        "Block" {
            try {
                # 1. Application de la politique système (Toujours fait, donc toujours rapporté)
                if (-not (Test-Path $oneDrivePolicyKey)) { New-Item -Path $oneDrivePolicyKey -Force -ErrorAction Stop | Out-Null }
                Set-ItemProperty -Path $oneDrivePolicyKey -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force -ErrorAction Stop

                # 2. Nettoyage Registre Utilisateur (Prévention)
                if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
                    $userAccount = New-Object System.Security.Principal.NTAccount($targetUsernameForConfiguration)
                    $userSid = $userAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
                    $userRunKey = "Registry::HKEY_USERS\$userSid\Software\Microsoft\Windows\CurrentVersion\Run"
                    if (Test-Path $userRunKey) {
                        if (Get-ItemProperty -Path $userRunKey -Name "OneDrive" -ErrorAction SilentlyContinue) {
                            Remove-ItemProperty -Path $userRunKey -Name "OneDrive" -Force -ErrorAction Stop
                            Add-Action -DefaultActionMessage "- OneDrive auto-start disabled for user '{0}'." -ActionId "Action_OneDriveAutostartRemoved" -ActionArgs $targetUsernameForConfiguration
                        }
                    }
                }

                # 3. Arrêt du processus
                Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force

                # 4. Rapport d'état (Toujours affiché car la politique est active)
                Add-Action -DefaultActionMessage "- OneDrive is blocked (system policy)." -ActionId "Action_OneDriveBlocked"
            } catch {
                Add-Error -DefaultErrorMessage "Failed to block OneDrive: $($_.Exception.Message)" -ErrorId "Error_OneDriveBlockFailed" -ErrorArgs $_.Exception.Message
            }
        }
        "Close" {
            $actionPerformed = $false

            # 1. Nettoyage Registre Utilisateur (Prévention)
            if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
                $userAccount = New-Object System.Security.Principal.NTAccount($targetUsernameForConfiguration)
                $userSid = $userAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
                $userRunKey = "Registry::HKEY_USERS\$userSid\Software\Microsoft\Windows\CurrentVersion\Run"
                if (Test-Path $userRunKey) {
                    if (Get-ItemProperty -Path $userRunKey -Name "OneDrive" -ErrorAction SilentlyContinue) {
                        Remove-ItemProperty -Path $userRunKey -Name "OneDrive" -Force -ErrorAction Stop
                        Add-Action -DefaultActionMessage "- OneDrive auto-start disabled for user '{0}'." -ActionId "Action_OneDriveAutostartRemoved" -ActionArgs $targetUsernameForConfiguration
                        $actionPerformed = $true
                    }
                }
            }

            # 2. Nettoyage Processus (Action immédiate)
            try {
                $oneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
                if ($oneDriveProcess) {
                    $oneDriveProcess | Stop-Process -Force -ErrorAction Stop
                    Add-Action -DefaultActionMessage "- OneDrive process terminated." -ActionId "Action_OneDriveClosed"
                    $actionPerformed = $true
                }
            } catch {
                Add-Error -DefaultErrorMessage "Failed to close OneDrive process: $($_.Exception.Message)" -ErrorId "Error_OneDriveCloseFailed" -ErrorArgs $_.Exception.Message
            }

            # 3. Rapport d'état (Si aucune action n'était nécessaire, on confirme que c'est propre)
            if (-not $actionPerformed) {
                 Add-Action -DefaultActionMessage "- OneDrive is closed and clean." -ActionId "Action_OneDriveClean"
            }
        }
        default { # Corresponds to "Ignore"
            try {
                if (Test-Path $oneDrivePolicyKey) {
                    if (Get-ItemProperty -Path $oneDrivePolicyKey -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue) {
                        Remove-ItemProperty -Path $oneDrivePolicyKey -Name "DisableFileSyncNGSC" -Force -ErrorAction Stop
                        # On ne rapporte ceci que si on a effectivement supprimé la clé
                        Add-Action -DefaultActionMessage "- OneDrive blocking policy removed." -ActionId "Action_OneDriveIgnored"
                    }
                }
            } catch {
                 Add-Error -DefaultErrorMessage "Failed to remove OneDrive blocking policy: $($_.Exception.Message)" -ErrorId "Error_OneDriveUnblockFailed" -ErrorArgs $_.Exception.Message
            }
        }
    }

    # --- Configuration des Actions Fermeture ---
    $preRebootActionTime = Get-ConfigValue -Section "Process" -Key "ScheduledCloseTime"
    $sessionMode = Get-ConfigValue -Section "SystemConfig" -Key "SessionStartupMode" -DefaultValue "Standard"

    # Variables nécessaires pour la logique combinée Sauvegarde/Reboot
    $enableReboot = Get-ConfigValue -Section "Process" -Key "EnableScheduledReboot" -Type ([bool]) -DefaultValue $true
    $rebootTime = Get-ConfigValue -Section "Process" -Key "ScheduledRebootTime"

    # --- Configuration de l'Action Sauvegarde (Conformité Plan v1.73) ---
    $enableBackup = Get-ConfigValue -Section "DatabaseBackup" -Key "EnableBackup" -Type ([bool]) -DefaultValue $false
    $scheduledBackupTime = Get-ConfigValue -Section "DatabaseBackup" -Key "ScheduledBackupTime"

    # Paramètres de fermeture nécessaires à l'inférence
    $enableScheduledClose = Get-ConfigValue -Section "Process" -Key "EnableScheduledClose" -Type ([bool]) -DefaultValue $false
    $scheduledCloseTime = Get-ConfigValue -Section "Process" -Key "ScheduledCloseTime"

    $backupTaskName = "WindowsOrchestrator-SystemBackup"
    $finalBackupTime = $null
    $isInferred = $false

    if ($enableBackup -eq $true) {
        if (-not [string]::IsNullOrWhiteSpace($scheduledBackupTime)) {
            # Cas 1 : Heure explicite définie par l'utilisateur
            $finalBackupTime = $scheduledBackupTime
        }
        elseif ($enableScheduledClose -eq $true -and (-not [string]::IsNullOrWhiteSpace($scheduledCloseTime))) {
            # Cas 2 : Inférence temporelle (Plan v1.73, Section 3.1)
            $finalBackupTime = $scheduledCloseTime
            $isInferred = $true
        }
    }

    if (($enableBackup -eq $true -or ($enableReboot -eq $true -and [string]::IsNullOrWhiteSpace($rebootTime))) -and $null -ne $finalBackupTime) {
        try {
            $backupScriptPath = Join-Path -Path $ScriptDir -ChildPath "Invoke-DatabaseBackup.ps1"
            $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$backupScriptPath`"" -WorkingDirectory $ScriptDir
            $taskTrigger = New-ScheduledTaskTrigger -Daily -At $finalBackupTime
            $taskPrincipal = New-ScheduledTaskPrincipal -UserId "S-1-5-18" -LogonType ServiceAccount -RunLevel Highest
            $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew

            Register-ScheduledTask -TaskName $backupTaskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings -Description "Orchestrator: Performs data backup before reboot." -Force -ErrorAction Stop

            if ($isInferred) {
                Add-Action -DefaultActionMessage "Backup time synced with closure time ({0}). Watchdog mode activated." -ActionId "Log_System_BackupSynced" -ActionArgs $finalBackupTime
            } else {
                Add-Action -DefaultActionMessage "Backup task scheduled at '{0}'." -ActionId "Action_BackupTaskConfigured" -ActionArgs $finalBackupTime
            }
        }
        catch {
            Add-Error -DefaultErrorMessage "Failed to configure backup task: {0}" -ErrorId "Error_BackupTaskFailed" -ErrorArgs $_.Exception.Message
        }
    } else {
        # Nettoyage si désactivé ou configuration incomplète
        Unregister-ScheduledTask -TaskName $backupTaskName -Confirm:$false -ErrorAction SilentlyContinue
        if ($enableBackup -eq $true -and $null -eq $finalBackupTime) {
             Add-Error -DefaultErrorMessage "Backup enabled but no time defined nor reference closure time. Task skipped." -ErrorId "Error_System_BackupNoTime"
        }
    }

    # --- Configuration du Redémarrage Planifié ---
    $enableReboot = Get-ConfigValue -Section "Process" -Key "EnableScheduledReboot" -Type ([bool]) -DefaultValue $true
    $rebootTime = Get-ConfigValue -Section "Process" -Key "ScheduledRebootTime"
    $rebootTaskName = "WindowsOrchestrator-SystemScheduledReboot"

    # Variables pour vérifier les chaînons précédents (Logique Pont/Bridge)
    $enableBackup = Get-ConfigValue -Section "DatabaseBackup" -Key "EnableBackup" -Type ([bool])
    $enableClose = Get-ConfigValue -Section "Process" -Key "EnableScheduledClose" -Type ([bool])
    $scheduledCloseTime = Get-ConfigValue -Section "Process" -Key "ScheduledCloseTime"

    if (($enableReboot -eq $true) -and (-not [string]::IsNullOrWhiteSpace($rebootTime))) {
        # Cas A : Redémarrage planifié fixe (Indépendant)
        $rebootDesc = "Daily reboot by WindowsOrchestrator (Build: $ScriptInternalBuild)"
        $rebootAction = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 60 /c `"$rebootDesc`""
        $rebootTrigger = New-ScheduledTaskTrigger -Daily -At $rebootTime
        Register-ScheduledTask $rebootTaskName -Action $rebootAction -Trigger $rebootTrigger -Principal (New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Description $rebootDesc -Force
        Add-Action -DefaultActionMessage "Scheduled reboot at {0} (Task: {1})." -ActionId "Action_RebootScheduled" -ActionArgs $rebootTime, $rebootTaskName
    }
    elseif ($enableReboot -eq $true) {
        # Cas B : Enchaînement (Heure vide)

        if ($enableBackup -eq $true) {
            # Sous-cas B1 : Backup est ACTIF
            # C'est le script de Backup qui lancera le reboot à la fin. On ne crée PAS de tâche ici.
            Unregister-ScheduledTask $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
            Add-Action -DefaultActionMessage "Reboot enabled without fixed time. Scheduled task removed (will be handled by chaining)." -ActionId "Log_System_RebootTaskSkipped"
        }
        elseif ($enableClose -eq $true -and (-not [string]::IsNullOrWhiteSpace($scheduledCloseTime))) {
            # Sous-cas B2 : Backup est INACTIF, mais Fermeture est ACTIVE (Le Pont)
            # On crée la tâche de reboot synchronisée sur la fermeture + 5 min
            try {
                $closeSpan = [TimeSpan]::Parse($scheduledCloseTime)

                # Récupération du délai configurable (Défaut 5 min)
                $bridgeDelay = Get-ConfigValue -Section "Process" -Key "RebootBridgeDelay" -Type ([int]) -DefaultValue 5
                $buffer = [TimeSpan]::FromMinutes($bridgeDelay)

                # Calcul de l'heure
                $rebootTriggerTime = "{0:hh\:mm}" -f ($closeSpan.Add($buffer))

                $rebootDesc = "Daily reboot (Bridged) by WindowsOrchestrator"
                $rebootAction = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 60 /c `"$rebootDesc`""
                $rebootTrigger = New-ScheduledTaskTrigger -Daily -At $rebootTriggerTime
                Register-ScheduledTask $rebootTaskName -Action $rebootAction -Trigger $rebootTrigger -Principal (New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Description $rebootDesc -Force

                # Log avec i18n correct (Arguments : Délai, Heure)
                Add-Action -DefaultActionMessage "Reboot enabled (Bridged after Closure + $bridgeDelay min: $rebootTriggerTime)." -ActionId "Log_System_RebootBridgeScheduled" -ActionArgs $bridgeDelay, $rebootTriggerTime
            } catch {
                 Add-Error -DefaultErrorMessage "Failed to calculate inferred reboot time: {0}" -ErrorArgs $_.Exception.Message
            }
        }
        else {
            # Sous-cas B3 : Orphelin
            Unregister-ScheduledTask $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
            Add-Error -DefaultErrorMessage "Reboot enabled but no time set and no preceding task to chain from."
        }
    }
    else {
        # Cas C : Redémarrage désactivé
        Unregister-ScheduledTask $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }

} catch {
    # Si la configuration a été chargée avant que l'erreur ne survienne,
    # on enregistre une erreur détaillée en utilisant le système de journalisation normal.
    if ($null -ne $Global:Config) {
        Add-Error -DefaultErrorMessage "FATAL SCRIPT ERROR (main block): $($_.Exception.Message) `n$($_.ScriptStackTrace)" -ErrorId "Error_FatalScriptError" -ErrorArgs $_.Exception.Message, $_.ScriptStackTrace
    }
    # Si l'erreur s'est produite avant même que la configuration ne puisse être lue...
    else {
        $tsErr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errMsg = "$tsErr [FATAL SCRIPT ERROR - CONFIG NOT LOADED] - Error: $($_.Exception.Message)"
        # ...on tente une dernière fois d'écrire l'erreur dans un fichier de secours dédié.
        try {
            Add-Content -Path (Join-Path $TargetLogDir "config_systeme_ps_FATAL_ERROR.txt") -Value $errMsg -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Ultime recours, si même l'écriture du fichier d'erreur de secours échoue.
        }
    }
} finally {
    # --- Envoi de la notification Gotify (si configurée) ---
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]))) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"
        $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5

        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            # Vérification réseau rapide, juste avant l'envoi.
            $titleSuccessTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessSystem" -DefaultValue ("%COMPUTERNAME% " + $ScriptIdentifier + " OK")
            $titleErrorTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorSystem" -DefaultValue ("ERROR " + $ScriptIdentifier + " on %COMPUTERNAME%")

            $finalMessageTitle = if ($Global:ErreursRencontrees.Count -gt 0) {
                $titleErrorTemplate -replace "%COMPUTERNAME%", $env:COMPUTERNAME
            } else {
                $titleSuccessTemplate -replace "%COMPUTERNAME%", $env:COMPUTERNAME
            }

            $dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            $dateLineTemplate = if ($lang -and $lang.ContainsKey('Gotify_MessageDate')) { $lang.Gotify_MessageDate } else { "On {0}." }
            $messageBody = ($dateLineTemplate -f $dateStr) + "`n"

            if ($Global:ActionsEffectuees.Count -gt 0) {
                $actionsHeader = if ($lang -and $lang.ContainsKey('Gotify_SystemActionsHeader')) { $lang.Gotify_SystemActionsHeader } else { "SYSTEM Actions:" }
                $messageBody += "$actionsHeader`n" + ($Global:ActionsEffectuees -join "`n")
            } else {
                $noActionsMessage = if ($lang -and $lang.ContainsKey('Gotify_NoSystemActions')) { $lang.Gotify_NoSystemActions } else { "No SYSTEM actions." }
                $messageBody += $noActionsMessage
            }

            if ($Global:ErreursRencontrees.Count -gt 0) {
                $errorsHeader = if ($lang -and $lang.ContainsKey('Gotify_SystemErrorsHeader')) { $lang.Gotify_SystemErrorsHeader } else { "SYSTEM Errors:" }
                $messageBody += "`n`n$errorsHeader`n" + ($Global:ErreursRencontrees -join "`n")
            }

            $payload = @{
                message  = $messageBody
                title    = $finalMessageTitle
                priority = $gotifyPriority
            } | ConvertTo-Json -Depth 3 -Compress

            $fullUrl = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"

            try {
                Invoke-RestMethod -Uri $fullUrl -Method Post -Body $payload -ContentType "application/json; charset=utf-8" -TimeoutSec 30 -ErrorAction Stop
            }
            catch {
                Add-Error -DefaultErrorMessage "Gotify (IRM) failed: $($_.Exception.Message)"
            }
        } else {
            Add-Error -DefaultErrorMessage "Gotify params incomplete."
        }
    }

    Write-Log -DefaultMessage "{0} ({1}) finished." -MessageId "Log_ScriptFinished" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild
    if ($Global:ErreursRencontrees.Count -gt 0) {
        Write-Log -DefaultMessage "Errors occurred during execution." -MessageId "Log_ErrorsOccurred" -Level WARN
    }
}
