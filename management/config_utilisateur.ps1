#Requires -Version 5.1

<#
.SYNOPSIS
    Script de configuration utilisateur automatisée.
.DESCRIPTION
    Ce script, destiné à s'exécuter à l'ouverture de session d'un utilisateur, lit les paramètres depuis
    un fichier config.ini. Sa tâche principale est de gérer un processus applicatif spécifique à l'utilisateur
    (le relancer si nécessaire) et de journaliser ses actions dans la langue configurée.
.EXAMPLE
    Ce script est conçu pour être exécuté par une tâche planifiée au logon de l'utilisateur. Il ne prend pas
    de paramètres en ligne de commande.

    Pour l'exécuter manuellement pour un test :
    PS C:\Path\To\Scripts\> .\config_utilisateur.ps1
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
$ScriptIdentifier = "WindowsOrchestrator-User"
$ScriptInternalBuild = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $ScriptDir = $PSScriptRoot
    $ProjectRootDir = (Resolve-Path (Join-Path $ScriptDir "..\")).Path

    $TargetLogDir = Join-Path -Path $ProjectRootDir -ChildPath "Logs"
    # Assurer que le répertoire de log existe
    if (-not (Test-Path $TargetLogDir -PathType Container)) {
        try { New-Item -Path $TargetLogDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null } catch {}
    }

    $Global:LogFile = Join-Path -Path $TargetLogDir -ChildPath "config_utilisateur_log.txt"
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "..\config.ini"
$Global:ActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:ErreursRencontrees = [System.Collections.Generic.List[string]]::new()
$Global:Config = $null


# --- Corps Principal du Script ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) {
        Write-Log -DefaultMessage "Could not read or parse '{0}'. Halting user configurations." -MessageId "Log_User_CannotReadConfig" -MessageArgs $ConfigFile -Level ERROR
        throw "Critical failure: Could not load config.ini for user script."
    }

    if ($i18nLoadingError) {
        Add-Error -DefaultErrorMessage "A critical error occurred while loading language files: $i18nLoadingError" -ErrorId "Error_LanguageFileLoad" -ErrorArgs $i18nLoadingError
    }

    Write-Log -DefaultMessage "Starting {0} ({1}) for user '{2}'..." -MessageId "Log_User_StartingScript" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild, $env:USERNAME
    Write-Log -DefaultMessage "Executing configured actions for user '{0}'..." -MessageId "Log_User_ExecutingActions" -MessageArgs $env:USERNAME

    $sessionMode = Get-ConfigValue -Section "SystemConfig" -Key "SessionStartupMode" -DefaultValue "Standard"

    # --- Gestion de OneDrive (au niveau utilisateur pour effet immédiat) ---
    $oneDriveModeUser = Get-ConfigValue -Section "SystemConfig" -Key "OneDriveManagementMode" -DefaultValue "Ignore"

    if ($oneDriveModeUser -in ("Block", "Close")) {
        try {
            $oneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
            if ($oneDriveProcess) {
                $oneDriveProcess | Stop-Process -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "OneDrive process terminated (user session check)." -ActionId "Action_OneDriveClosed"
            }
        } catch {
            Add-Error -DefaultErrorMessage "Failed to close OneDrive process during user logon: $($_.Exception.Message)" -ErrorId "Error_OneDriveCloseFailed" -ErrorArgs $_.Exception.Message
        }
    }

if ($sessionMode -in ("Standard", "Autologon")) {
    # --- Gestion du processus spécifié ---
    $processToLaunch = (Get-ConfigValue -Section "Process" -Key "ProcessToLaunch").Trim('"')
    $processArguments = Get-ConfigValue -Section "Process" -Key "ProcessArguments"
    $processToMonitor = (Get-ConfigValue -Section "Process" -Key "ProcessToMonitor").Trim('"')

    if ([string]::IsNullOrWhiteSpace($processToLaunch)) {
        Write-Log -DefaultMessage "No ProcessToLaunch specified in [Process] section. No action taken." -MessageId "Log_User_NoProcessSpecified"
    } else {
        $isAlreadyRunning = $false
        if (-not [string]::IsNullOrWhiteSpace($processToMonitor)) {
            Write-Log -DefaultMessage "Monitoring for process name: '{0}'." -MessageId "Log_User_ProcessToMonitor" -MessageArgs $processToMonitor
            $runningProcess = Get-Process -Name $processToMonitor -ErrorAction SilentlyContinue | Where-Object {
                try {
                    $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue
                    if ($proc) {
                        $ownerInfo = Invoke-CimMethod -InputObject $proc -MethodName GetOwner -ErrorAction SilentlyContinue
                        return ($ownerInfo.User -eq $env:USERNAME)
                    }
                } catch {}
                return $false
            } | Select-Object -First 1

            if ($runningProcess) {
                $isAlreadyRunning = $true
                Write-Log -DefaultMessage "Process '{0}' (PID: {1}) is already running for current user. No action needed." -MessageId "Log_User_ProcessAlreadyRunning" -MessageArgs $processToMonitor, $runningProcess.Id
                Add-Action -DefaultActionMessage "Process '{0}' is already running (PID: {1})." -ActionId "Action_User_ProcessAlreadyRunning" -ActionArgs $processToMonitor, $runningProcess.Id
            }
        } else {
              Write-Log -DefaultMessage "ProcessToMonitor is not specified. Skipping check for running process." -MessageId "Log_User_NoMonitor"
        }

        if (-not $isAlreadyRunning) {
            Start-OrchestratorProcess -ProcessToLaunch $processToLaunch `
                                      -ProcessArguments $processArguments `
                                      -ProcessToMonitor $processToMonitor `
                                      -ScriptDir $ScriptDir `
                                      -Context "User"
        }
    }
}


if ($sessionMode -in ("Standard", "Autologon")) {
    # --- Création de la tâche de fermeture de l'application ---
    $enableClose = Get-ConfigValue -Section "Process" -Key "EnableScheduledClose" -Type ([bool]) -DefaultValue $true
    $preRebootCloseTime = Get-ConfigValue -Section "Process" -Key "ScheduledCloseTime"
    $closeAppUserTaskName = "WindowsOrchestrator-User-CloseApp"

    if (($enableClose -eq $true) -and (-not [string]::IsNullOrWhiteSpace($preRebootCloseTime))) {
        try {
            $closeScriptPath = Join-Path -Path $ScriptDir -ChildPath "Close-AppByTitle.ps1"
            $closeAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$closeScriptPath`"" -WorkingDirectory $ScriptDir
            $closeTrigger = New-ScheduledTaskTrigger -Daily -At $preRebootCloseTime
            $closePrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
            $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
            Register-ScheduledTask -TaskName $closeAppUserTaskName -Action $closeAction -Trigger $closeTrigger -Principal $closePrincipal -Settings $taskSettings -Description "Orchestrator: Closes the main application before reboot." -Force -ErrorAction Stop
            Add-Action -DefaultActionMessage "User close task configured for '{0}' at {1}." -ActionId "Action_User_CloseTaskConfigured" -ActionArgs $closeAppUserTaskName, $preRebootCloseTime
        } catch {
            Add-Error -DefaultErrorMessage "Failed to create user close task: {0}" -ErrorId "Error_User_CloseTaskFailed" -ErrorArgs $_.Exception.Message
        }
    } else {
        Unregister-ScheduledTask -TaskName $closeAppUserTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }
}


} catch {
    if ($null -ne $Global:Config) {
        Add-Error -DefaultErrorMessage "FATAL USER SCRIPT ERROR '{0}': {1} `n{2}" -ErrorId "Error_User_FatalScriptError" -ErrorArgs $env:USERNAME, $_.Exception.Message, $_.ScriptStackTrace
    } else {
        $timestampError = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errorMsg = "$timestampError [FATAL SCRIPT USER ERROR - CONFIG NOT LOADED] - Error: $($_.Exception.Message)"
        try {
            Add-Content -Path (Join-Path $TargetLogDir "config_utilisateur_FATAL_ERROR.txt") -Value $errorMsg -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Ultime recours, impossible d'écrire le fichier d'erreur.
        }
    }
} finally {
    # --- Envoi de la notification Gotify (si configurée) ---
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]))) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"
        $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5

        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            $titleSuccessTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessUser" -DefaultValue ("%COMPUTERNAME% %USERNAME% " + $ScriptIdentifier + " OK")
            $titleErrorTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorUser" -DefaultValue ("ERROR " + $ScriptIdentifier + " %USERNAME% on %COMPUTERNAME%")

            $finalMessageTitleUser = if ($Global:ErreursRencontrees.Count -gt 0) {
                $titleErrorTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            } else {
                $titleSuccessTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            }

            $dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            $dateLineTemplate = if ($lang -and $lang.ContainsKey('Gotify_MessageDate')) { $lang.Gotify_MessageDate } else { "On {0}." }
            $messageBodyUser = ($dateLineTemplate -f $dateStr) + "`n"

            if ($Global:ActionsEffectuees.Count -gt 0) {
                $actionsHeader = if ($lang -and $lang.ContainsKey('Gotify_UserActionsHeader')) { $lang.Gotify_UserActionsHeader } else { "USER Actions:" }
                $messageBodyUser += "$actionsHeader`n" + ($Global:ActionsEffectuees -join "`n")
            } else {
                $noActionsMessage = if ($lang -and $lang.ContainsKey('Gotify_NoUserActions')) { $lang.Gotify_NoUserActions } else { "No USER actions." }
                $messageBodyUser += $noActionsMessage
            }

            if ($Global:ErreursRencontrees.Count -gt 0) {
                $errorsHeader = if ($lang -and $lang.ContainsKey('Gotify_UserErrorsHeader')) { $lang.Gotify_UserErrorsHeader } else { "USER Errors:" }
                $messageBodyUser += "`n`n$errorsHeader`n" + ($Global:ErreursRencontrees -join "`n")
            }

            $payloadUser = @{
                message  = $messageBodyUser
                title    = $finalMessageTitleUser
                priority = $gotifyPriority
            } | ConvertTo-Json -Depth 3 -Compress

            $fullUrlUser = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"

            try {
                Invoke-RestMethod -Uri $fullUrlUser -Method Post -Body $payloadUser -ContentType "application/json; charset=utf-8" -TimeoutSec 30 -ErrorAction Stop
            }
            catch {
                Add-Error -DefaultErrorMessage "Gotify notification (IRM) failed: $($_.Exception.Message)"
            }
        } else {
            Add-Error -DefaultErrorMessage "Gotify parameters are incomplete in config.ini for user script."
        }
    }

    Write-Log -DefaultMessage "{0} ({1}) for '{2}' finished." -MessageId "Log_User_ScriptFinished" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild, $env:USERNAME
    if ($Global:ErreursRencontrees.Count -gt 0) {
        Write-Log -DefaultMessage "Errors occurred during execution." -MessageId "Log_ErrorsOccurred" -Level WARN
    }
}
