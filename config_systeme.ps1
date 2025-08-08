#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script de configuration SYSTEME automatisee pour Windows.
.DESCRIPTION
    Lit les parametres depuis config.ini, applique les configurations SYSTEME, et journalise ses actions dans la langue de l'OS.
    Cette version restaure la logique de résolution de chemin critique pour l'action pré-redémarrage.
.NOTES
    Auteur: Ronan Davalan & Gemini
    Version: i18n - Corrigée
#>

# --- START I18N BLOCK ---
$lang = @{}
try {
    # Détermination robuste du répertoire du script
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition } 
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }
    
    $i18nPath = Join-Path $PSScriptRoot "i18n"
    
    # Charge les chaînes de caractères pour la langue de l'OS actuelle.
    # N'échoue pas si le fichier de langue est introuvable (le script utilisera les messages par défaut en anglais).
    $lang = Import-LocalizedData -BindingVariable 'lang' -BaseDirectory $i18nPath -FileName "strings.psd1" -ErrorAction SilentlyContinue

} catch {
    # Cette erreur est capturée pour être journalisée plus tard, une fois les logs initialisés.
    $i18nLoadingError = $_.Exception.Message
}
# --- END I18N BLOCK ---


#region CORE FUNCTIONS
function Rotate-LogFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$BaseLogPath,
        [Parameter(Mandatory=$true)][string]$LogExtension = ".txt",
        [Parameter(Mandatory=$true)][int]$MaxLogsToKeep = 7
    )
    if ($MaxLogsToKeep -lt 1) { return }
    $oldestArchiveIndex = if ($MaxLogsToKeep -eq 1) { 1 } else { $MaxLogsToKeep - 1 }
    $oldestArchive = "$($BaseLogPath).$($oldestArchiveIndex)$LogExtension"
    if (Test-Path $oldestArchive) { Remove-Item $oldestArchive -ErrorAction SilentlyContinue }
    if ($MaxLogsToKeep -gt 1) {
        for ($i = $MaxLogsToKeep - 2; $i -ge 1; $i--) {
            $currentArchive = "$($BaseLogPath).$i$LogExtension"; $nextArchive = "$($BaseLogPath).$($i + 1)$LogExtension"
            if (Test-Path $currentArchive) {
                if (Test-Path $nextArchive) { Remove-Item $nextArchive -Force -ErrorAction SilentlyContinue }
                Rename-Item $currentArchive $nextArchive -ErrorAction SilentlyContinue
            }
        }
    }
    $currentLogFileToArchive = "$BaseLogPath$LogExtension"; $firstArchive = "$($BaseLogPath).1$LogExtension"
    if (Test-Path $currentLogFileToArchive) {
        if (Test-Path $firstArchive) { Remove-Item $firstArchive -Force -ErrorAction SilentlyContinue }
        Rename-Item $currentLogFileToArchive $firstArchive -ErrorAction SilentlyContinue
    }
}

function Get-IniContent {
    [CmdletBinding()] param ([Parameter(Mandatory=$true)][string]$FilePath)
    $ini = @{}; $currentSection = ""
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) { return $null }
    try {
        Get-Content $FilePath -Encoding UTF8 -ErrorAction Stop | ForEach-Object {
            $line = $_.Trim()
            if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#") -or $line.StartsWith(";")) { return }
            if ($line -match "^\[(.+)\]$") { $currentSection = $matches[1].Trim(); $ini[$currentSection] = @{} }
            elseif ($line -match "^([^=]+)=(.*)") {
                if ($currentSection) {
                    $key = $matches[1].Trim(); $value = $matches[2].Trim()
                    $ini[$currentSection][$key] = $value
                }
            }
        }
    } catch { return $null }
    return $ini
}
#endregion


#region GLOBAL CONFIG & EARLY LOGS SETUP
$ScriptIdentifier = "AllSysConfig-System"
$ScriptInternalBuild = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$ScriptDir = $PSScriptRoot

$TargetLogDir = Join-Path -Path $ScriptDir -ChildPath "Logs"
$LogDirToUse = $ScriptDir
if (Test-Path $TargetLogDir -PathType Container) { $LogDirToUse = $TargetLogDir }
else { try { New-Item -Path $TargetLogDir -ItemType Directory -Force -ErrorAction Stop | Out-Null; $LogDirToUse = $TargetLogDir } catch {} }

$BaseLogPathForRotationSystem = Join-Path -Path $LogDirToUse -ChildPath "config_systeme_ps_log"
$BaseLogPathForRotationUser = Join-Path -Path $LogDirToUse -ChildPath "config_utilisateur_log"
$DefaultMaxLogs = 7

$tempConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$tempIniContent = Get-IniContent -FilePath $tempConfigFile
$rotationEnabledByConfig = $true
if ($null -ne $tempIniContent -and $tempIniContent.ContainsKey("Logging") -and $tempIniContent["Logging"].ContainsKey("EnableLogRotation")) {
    if ($tempIniContent["Logging"]["EnableLogRotation"].ToLower() -eq "false") { $rotationEnabledByConfig = $false }
}
if ($rotationEnabledByConfig) {
    Rotate-LogFile -BaseLogPath $BaseLogPathForRotationSystem -LogExtension ".txt" -MaxLogsToKeep $DefaultMaxLogs
    Rotate-LogFile -BaseLogPath $BaseLogPathForRotationUser -LogExtension ".txt" -MaxLogsToKeep $DefaultMaxLogs
}

$LogFile = Join-Path -Path $LogDirToUse -ChildPath "config_systeme_ps_log.txt"
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$Global:ActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:ErreursRencontrees = [System.Collections.Generic.List[string]]::new()
$Global:Config = $null
#endregion


#region UTILITY FUNCTIONS
function Write-Log {
    [CmdletBinding()]
    param (
        [string]$DefaultMessage, 
        [string]$MessageId, 
        [object[]]$MessageArgs, 
        [ValidateSet("INFO","WARN","ERROR","DEBUG")][string]$Level="INFO", 
        [switch]$NoConsole
    )
    process {
        $formattedMessage = if ($lang -and $lang.ContainsKey($MessageId)) { try { $lang[$MessageId] -f $MessageArgs } catch { $DefaultMessage } } else { $DefaultMessage }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] - $formattedMessage"
        
        $LogParentDir = Split-Path $LogFile -Parent
        if (-not (Test-Path -Path $LogParentDir -PathType Container)) { try { New-Item -Path $LogParentDir -ItemType Directory -Force -ErrorAction Stop | Out-Null } catch {}}
        
        try { 
            Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8 -ErrorAction Stop
        }
        catch {
            $fallbackLogDir = "C:\ProgramData\StartupScriptLogs"
            if (-not (Test-Path $fallbackLogDir)) { try { New-Item $fallbackLogDir -ItemType Directory -Force -EA Stop | Out-Null } catch {}}
            $fallbackLogFile = Join-Path $fallbackLogDir "config_systeme_ps_FATAL_LOG_ERROR.txt"
            $fallbackMessage = "$timestamp [FATAL_LOG_ERROR] - Could not write to '$LogFile': $($_.Exception.Message). Original: $logEntry"
            Write-Host $fallbackMessage -ForegroundColor Red; try { Add-Content $fallbackLogFile $fallbackMessage -Encoding UTF8 -EA Stop } catch {}
        }

        if (-not $NoConsole -and ($Host.Name -eq "ConsoleHost" -or $PSEdition -eq "Core")) { Write-Host $logEntry }
    }
}

function Add-Action {
    param([string]$DefaultActionMessage, [string]$ActionId, [object[]]$ActionArgs)
    $formattedMessage = if ($lang -and $lang.ContainsKey($ActionId)) { try { $lang[$ActionId] -f $ActionArgs } catch { $DefaultActionMessage } } else { $DefaultActionMessage }
    $Global:ActionsEffectuees.Add($formattedMessage)
    Write-Log -DefaultMessage "ACTION: $formattedMessage" -Level "INFO" -NoConsole
}

function Add-Error {
    [CmdletBinding()]
    param ([string]$DefaultErrorMessage, [string]$ErrorId, [object[]]$ErrorArgs)
    
    $formattedMessage = if ($lang -and $lang.ContainsKey($ErrorId)) { try { $lang[$ErrorId] -f $ErrorArgs } catch { $DefaultErrorMessage } } else { $DefaultErrorMessage }
    
    $detailedErrorMessage = $formattedMessage
    if ([string]::IsNullOrWhiteSpace($detailedErrorMessage)) {
        if ($global:Error.Count -gt 0) { 
            $lastError = $global:Error[0]
            $detailedErrorMessage = "Unspecified PowerShell error: $($lastError.Exception.Message) - Stack: $($lastError.ScriptStackTrace)"
        } else { 
            $detailedErrorMessage = "Unspecified error and no PowerShell error info."
        }
    }
    $Global:ErreursRencontrees.Add($detailedErrorMessage)
    Write-Log -DefaultMessage "CAPTURED ERROR: $detailedErrorMessage" -MessageId "Log_CapturedError" -MessageArgs $detailedErrorMessage -Level "ERROR"
}

function Get-ConfigValue {
    param([string]$Section, [string]$Key, [object]$DefaultValue=$null, [System.Type]$Type=([string]), [bool]$KeyMustExist=$false)
    $value = $null; $keyExists = $false; if ($null -ne $Global:Config) { $keyExists = $Global:Config.ContainsKey($Section) -and $Global:Config[$Section].ContainsKey($Key); if ($keyExists) { $value = $Global:Config[$Section][$Key] } }
    if ($KeyMustExist -and (-not $keyExists)) { return [pscustomobject]@{ Undefined = $true } }
    if (-not $keyExists) { if ($null -ne $DefaultValue) { return $DefaultValue }; if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null }
    if ([string]::IsNullOrWhiteSpace($value) -and $Type -eq ([bool])) { if ($null -ne $DefaultValue) { return $DefaultValue }; return $false }
    try { return [System.Convert]::ChangeType($value, $Type) }
    catch { 
        Add-Error -DefaultErrorMessage "Invalid config value for [$($Section)]$($Key): '$value'. Expected type '$($Type.Name)'. Default/empty value used." -ErrorId "Error_InvalidConfigValue" -ErrorArgs $Section, $Key, $value, $Type.Name
        if ($null -ne $DefaultValue) { return $DefaultValue }; if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null 
    }
}
#endregion


# --- SCRIPT MAIN BODY ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) { 
        $tsInitErr = Get-Date -F "yyyy-MM-dd HH:mm:ss"
        try { Add-Content -Path $LogFile -Value "$tsInitErr [ERROR] - Cannot read '$ConfigFile'. Halting." -Encoding UTF8 } catch {}
        throw "Critical failure: config.ini."
    }

    if ($i18nLoadingError) { Add-Error -DefaultErrorMessage "A critical error occurred while loading language files: $i18nLoadingError" -ErrorId "Error_LanguageFileLoad" -ErrorArgs $i18nLoadingError }

    Write-Log -DefaultMessage "Starting $ScriptIdentifier ($ScriptInternalBuild)..." -MessageId "Log_StartingScript" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild
    $networkReady = $false; Write-Log -DefaultMessage "Checking network connectivity..." -MessageId "Log_CheckingNetwork"; for ($i = 0; $i -lt 6; $i++) { if (Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue) { Write-Log -DefaultMessage "Network connectivity detected." -MessageId "Log_NetworkDetected"; $networkReady = $true; break }; if ($i -lt 5) { Write-Log -DefaultMessage "Network unavailable, retrying in 10s..." -MessageId "Log_NetworkRetry"; Start-Sleep -Seconds 10 }}; if (-not $networkReady) { Write-Log -DefaultMessage "Network not established. Gotify may fail." -MessageId "Log_NetworkFailed" -Level "WARN" }
    Write-Log -DefaultMessage "Executing configured SYSTEM actions..." -MessageId "Log_ExecutingSystemActions"

    $targetUsernameForConfiguration = Get-ConfigValue -Section "SystemConfig" -Key "AutoLoginUsername"
    if ([string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
        Write-Log -DefaultMessage "AutoLoginUsername not specified. Attempting to read DefaultUserName from Registry." -MessageId "Log_ReadRegistryForUser" -Level INFO
        try {
            $regDefaultUser = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
            if (-not [string]::IsNullOrWhiteSpace($regDefaultUser)) {
                $targetUsernameForConfiguration = $regDefaultUser
                Write-Log -DefaultMessage "Using Registry DefaultUserName as target user: {0}." -MessageId "Log_RegistryUserFound" -MessageArgs $targetUsernameForConfiguration -Level INFO
            } else { Write-Log -DefaultMessage "Registry DefaultUserName not found or empty. No default target user." -MessageId "Log_RegistryUserNotFound" -Level WARN }
        } catch { Write-Log -DefaultMessage "Error reading DefaultUserName from Registry: {0}" -MessageId "Log_RegistryReadError" -MessageArgs $_.Exception.Message -Level WARN }
    } else { Write-Log -DefaultMessage "Using AutoLoginUsername from config.ini as target user: {0}." -MessageId "Log_ConfigUserFound" -MessageArgs $targetUsernameForConfiguration -Level INFO }

    $disableFastStartup = Get-ConfigValue -Section "SystemConfig" -Key "DisableFastStartup" -Type ([bool])
    $powerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if($disableFastStartup){ if((Get-ItemProperty $powerRegPath -ErrorAction SilentlyContinue).HiberbootEnabled -ne 0){ try{Set-ItemProperty $powerRegPath HiberbootEnabled 0 -Force -EA Stop;Add-Action -DefaultActionMessage "FastStartup disabled." -ActionId "Action_FastStartupDisabled"}catch{Add-Error -DefaultErrorMessage "Failed to disable FastStartup: $($_.Exception.Message)" -ErrorId "Error_DisableFastStartupFailed" -ErrorArgs $_.Exception.Message} } else { Add-Action -DefaultActionMessage "FastStartup verified (already disabled)." -ActionId "Action_FastStartupVerifiedDisabled" } }
    else { if((Get-ItemProperty $powerRegPath -ErrorAction SilentlyContinue).HiberbootEnabled -ne 1){ try{Set-ItemProperty $powerRegPath HiberbootEnabled 1 -Force -EA Stop;Add-Action -DefaultActionMessage "FastStartup enabled." -ActionId "Action_FastStartupEnabled"}catch{Add-Error -DefaultErrorMessage "Failed to enable FastStartup: $($_.Exception.Message)" -ErrorId "Error_EnableFastStartupFailed" -ErrorArgs $_.Exception.Message} } else { Add-Action -DefaultActionMessage "FastStartup verified (already enabled)." -ActionId "Action_FastStartupVerifiedEnabled" } }

    if (Get-ConfigValue "SystemConfig" "DisableSleep" -Type ([bool])) { try { powercfg /change standby-timeout-ac 0; powercfg /change hibernate-timeout-ac 0; Add-Action -DefaultActionMessage "Machine sleep (S3/S4) disabled." -ActionId "Action_SleepDisabled" } catch { Add-Error -DefaultErrorMessage "Failed to disable machine sleep: $($_.Exception.Message)" -ErrorId "Error_DisableSleepFailed" -ErrorArgs $_.Exception.Message }}
    if (Get-ConfigValue "SystemConfig" "DisableScreenSleep" -Type ([bool])) { try { powercfg /change monitor-timeout-ac 0; Add-Action -DefaultActionMessage "Screen sleep disabled." -ActionId "Action_ScreenSleepDisabled" } catch { Add-Error -DefaultErrorMessage "Failed to disable screen sleep: $($_.Exception.Message)" -ErrorId "Error_DisableScreenSleepFailed" -ErrorArgs $_.Exception.Message }}

    $winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    if (Get-ConfigValue "SystemConfig" "EnableAutoLogin" -Type ([bool])) { if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) { try { Set-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -Value "1" -Type String -Force -EA Stop; Add-Action -DefaultActionMessage "AutoAdminLogon enabled." -ActionId "Action_AutoAdminLogonEnabled"; Set-ItemProperty -Path $winlogonKey -Name DefaultUserName -Value $targetUsernameForConfiguration -Type String -Force -EA Stop; Add-Action -DefaultActionMessage "DefaultUserName set to: {0}." -ActionId "Action_DefaultUserNameSet" -ActionArgs $targetUsernameForConfiguration } catch { Add-Error -DefaultErrorMessage "Failed to configure AutoLogin: $($_.Exception.Message)" -ErrorId "Error_AutoLoginFailed" -ErrorArgs $_.Exception.Message }} else { Add-Error -DefaultErrorMessage "AutoLogin enabled but target user could not be determined." -ErrorId "Error_AutoLoginUserUnknown"} }
    else { try { Set-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -Value "0" -Type String -Force -EA Stop; Add-Action -DefaultActionMessage "AutoAdminLogon disabled." -ActionId "Action_AutoAdminLogonDisabled" } catch { Add-Error -DefaultErrorMessage "Failed to disable AutoAdminLogon: $($_.Exception.Message)" -ErrorId "Error_DisableAutoLoginFailed" -ErrorArgs $_.Exception.Message }}

    $wuPolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; $wuService = "wuauserv"
    if(-not(Test-Path $wuPolicyKey)){New-Item $wuPolicyKey -Force -EA Stop|Out-Null}
    if(Get-ConfigValue "SystemConfig" "DisableWindowsUpdate" -Type ([bool])){ try{Set-ItemProperty $wuPolicyKey NoAutoUpdate 1 -Type DWord -Force -EA Stop; Get-Service $wuService -EA Stop|Set-Service -StartupType Disabled -PassThru -EA Stop|Stop-Service -Force -EA SilentlyContinue; Add-Action -DefaultActionMessage "Win Updates disabled." -ActionId "Action_UpdatesDisabled"}catch{Add-Error -DefaultErrorMessage "Failed to manage Win Updates: $($_.Exception.Message)" -ErrorId "Error_UpdateMgmtFailed" -ErrorArgs $_.Exception.Message} }
    else{ try{Set-ItemProperty $wuPolicyKey NoAutoUpdate 0 -Type DWord -Force -EA Stop; Get-Service $wuService -EA Stop|Set-Service -StartupType Automatic -PassThru -EA Stop|Start-Service -EA SilentlyContinue; Add-Action -DefaultActionMessage "Win Updates enabled." -ActionId "Action_UpdatesEnabled"}catch{Add-Error -DefaultErrorMessage "Failed to manage Win Updates: $($_.Exception.Message)" -ErrorId "Error_UpdateMgmtFailed" -ErrorArgs $_.Exception.Message} }
    if(Get-ConfigValue "SystemConfig" "DisableAutoReboot" -Type ([bool])){ try{Set-ItemProperty $wuPolicyKey NoAutoRebootWithLoggedOnUsers 1 -Type DWord -Force -EA Stop; Add-Action -DefaultActionMessage "Auto-reboot (WU) disabled." -ActionId "Action_AutoRebootDisabled"}catch{Add-Error -DefaultErrorMessage "Failed to disable auto-reboot: $($_.Exception.Message)" -ErrorId "Error_DisableAutoRebootFailed" -ErrorArgs $_.Exception.Message}}

    $rebootTime = Get-ConfigValue "SystemConfig" "ScheduledRebootTime"
    $rebootTaskName = "AllSys_SystemScheduledReboot"
    if (-not [string]::IsNullOrWhiteSpace($rebootTime)) {
        $rebootDesc = "Daily reboot by AllSysConfig (Build: $ScriptInternalBuild)"
        $rebootAction = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 60 /c `"$rebootDesc`""
        $rebootTrigger = New-ScheduledTaskTrigger -Daily -At $rebootTime;
        Register-ScheduledTask $rebootTaskName -Action $rebootAction -Trigger $rebootTrigger -Principal (New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Description $rebootDesc -Force
        Add-Action -DefaultActionMessage "Scheduled reboot at {0} (Task: {1})." -ActionId "Action_RebootScheduled" -ActionArgs $rebootTime, $rebootTaskName
    } else { Unregister-ScheduledTask $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue }
    
    # --- Configurer l'action préparatoire avant redémarrage (AVEC LOGIQUE DE CHEMIN CORRIGÉE) ---
    $preRebootActionTime = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionTime"
    $preRebootCmdFromFile = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionCommand"
    $preRebootArgsFromFile = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionArguments"
    $preRebootLaunchMethod = (Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionLaunchMethod" -DefaultValue "direct").ToLower()
    $preRebootTaskName = "AllSys_SystemPreRebootAction"

    if ((-not [string]::IsNullOrWhiteSpace($preRebootActionTime)) -and (-not [string]::IsNullOrWhiteSpace($preRebootCmdFromFile))) {
        
        $programToExecute = $preRebootCmdFromFile.Trim('"')

        if ($programToExecute -match "%USERPROFILE%") {
            if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
                try {
                    $userAccount = New-Object System.Security.Principal.NTAccount($targetUsernameForConfiguration)
                    $userSid = $userAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
                    $userProfilePathTarget = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSid" -Name ProfileImagePath -ErrorAction Stop).ProfileImagePath
                    if ($userProfilePathTarget) { $programToExecute = $programToExecute -replace "%USERPROFILE%", [regex]::Escape($userProfilePathTarget) }
                } catch { Add-Error -DefaultErrorMessage "Could not determine profile path for '$targetUsernameForConfiguration' for PreRebootAction." }
            } else { Add-Error -DefaultErrorMessage "%USERPROFILE% detected in PreRebootActionCommand, but target user could not be determined." }
        }

        if (($programToExecute -notmatch '^[a-zA-Z]:\\') -and ($programToExecute -notmatch '^\\\\') -and ($programToExecute -notmatch '^%') -and (-not (Get-Command $programToExecute -CommandType Application,ExternalScript -ErrorAction SilentlyContinue))) {
            $potentialPath = Join-Path -Path $ScriptDir -ChildPath $programToExecute -Resolve -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $potentialPath -PathType Leaf) { $programToExecute = $potentialPath }
        }

        $programToExecute = [System.Environment]::ExpandEnvironmentVariables($programToExecute)

        $exeForTaskScheduler = ""; $argumentStringForTaskScheduler = ""; $workingDirectoryForTask = ""
        if (Test-Path -LiteralPath $programToExecute -PathType Leaf) { $workingDirectoryForTask = Split-Path -Path $programToExecute -Parent }

        switch ($preRebootLaunchMethod) {
            "direct"     { $exeForTaskScheduler = $programToExecute; $argumentStringForTaskScheduler = $preRebootArgsFromFile }
            "powershell" { $exeForTaskScheduler = "powershell.exe"; $argumentStringForTaskScheduler = "-NoProfile -ExecutionPolicy Bypass -Command `"& `"$programToExecute`" $preRebootArgsFromFile`"" }
            "cmd"        { $exeForTaskScheduler = "cmd.exe"; $argumentStringForTaskScheduler = "/c `"`"$programToExecute`" $preRebootArgsFromFile`"" }
            default      { Add-Error -DefaultErrorMessage "Invalid PreRebootActionLaunchMethod: '$preRebootLaunchMethod'." }
        }
        
        if ($exeForTaskScheduler -and ( (Test-Path -LiteralPath $programToExecute -PathType Leaf) -or (Get-Command $programToExecute -ErrorAction SilentlyContinue) ) ) {
            try {
                $taskAction = New-ScheduledTaskAction -Execute $exeForTaskScheduler -Argument $argumentStringForTaskScheduler -WorkingDirectory $workingDirectoryForTask
                $taskTrigger = New-ScheduledTaskTrigger -Daily -At $preRebootActionTime
                $principalUserForPreReboot = if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) { $targetUsernameForConfiguration } else { "NT AUTHORITY\System" }
                $principalLogonType = if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) { "Interactive" } else { "ServiceAccount" }
                $taskPrincipal = New-ScheduledTaskPrincipal -UserId $principalUserForPreReboot -LogonType $principalLogonType -RunLevel Highest
                
                Unregister-ScheduledTask -TaskName $preRebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
                Register-ScheduledTask -TaskName $preRebootTaskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Description "Pre-reboot action by AllSysConfig" -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "Pre-reboot action at '{0}' configured (Task: {1})." -ActionId "Action_PreRebootConfigured" -ActionArgs $preRebootActionTime, $preRebootTaskName
            } catch { Add-Error -DefaultErrorMessage "Failed to create/update pre-reboot task '$preRebootTaskName': $($_.Exception.Message)" }
        } else { Add-Error -DefaultErrorMessage "Pre-reboot command '$programToExecute' could not be found or resolved." }

    } else { Unregister-ScheduledTask -TaskName $preRebootTaskName -Confirm:$false -ErrorAction SilentlyContinue }

    # --- Manage OneDrive ---
    $oneDrivePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if(Get-ConfigValue -Section "SystemConfig" -Key "DisableOneDrive" -Type ([bool])){ if(-not(Test-Path $oneDrivePolicyKey)){New-Item -Path $oneDrivePolicyKey -Force|Out-Null}; Set-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Value 1 -Force; Add-Action -DefaultActionMessage "OneDrive disabled (policy)." -ActionId "Action_OneDriveDisabled" }
    else { if(Test-Path $oneDrivePolicyKey){Remove-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Force -ErrorAction SilentlyContinue}; Add-Action -DefaultActionMessage "OneDrive allowed (policy)." -ActionId "Action_OneDriveEnabled" }

} catch {
    if ($null -ne $Global:Config) { Add-Error -DefaultErrorMessage "FATAL SCRIPT ERROR (main block): $($_.Exception.Message) `n$($_.ScriptStackTrace)" -ErrorId "Error_FatalScriptError" -ErrorArgs $_.Exception.Message, $_.ScriptStackTrace }
    else { $tsErr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $errMsg = "$tsErr [FATAL SCRIPT ERROR - CONFIG NOT LOADED] - Error: $($_.Exception.Message)"; try { Add-Content -Path (Join-Path $LogDirToUse "config_systeme_ps_FATAL_ERROR.txt") -Value $errMsg -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}; }
} finally {
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]))) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"; $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"; $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5
        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            if($networkReady){
                $titleSuccessTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessSystem" -DefaultValue ("%COMPUTERNAME% " + $ScriptIdentifier + " OK")
                $titleErrorTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorSystem" -DefaultValue ("ERROR " + $ScriptIdentifier + " on %COMPUTERNAME%")
                $finalMessageTitle = if($Global:ErreursRencontrees.Count -gt 0){$titleErrorTemplate -replace "%COMPUTERNAME%",$env:COMPUTERNAME}else{$titleSuccessTemplate -replace "%COMPUTERNAME%",$env:COMPUTERNAME}
                $messageBody = "On $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n"
                if($Global:ActionsEffectuees.Count -gt 0){$messageBody += "SYSTEM Actions:`n" + ($Global:ActionsEffectuees -join "`n")}else{$messageBody += "No SYSTEM actions."}
                if($Global:ErreursRencontrees.Count -gt 0){$messageBody += "`n`nSYSTEM Errors:`n" + ($Global:ErreursRencontrees -join "`n")}
                $payload = @{message=$messageBody; title=$finalMessageTitle; priority=$gotifyPriority} | ConvertTo-Json -Depth 3 -Compress
                $fullUrl = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"
                try { Invoke-RestMethod -Uri $fullUrl -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop; }
                catch {Add-Error -DefaultErrorMessage "Gotify (IRM) failed: $($_.Exception.Message)" }
            } else { Add-Error -DefaultErrorMessage "Network unavailable for Gotify (system)." }
        } else {Add-Error -DefaultErrorMessage "Gotify params incomplete." }
    }

    Write-Log -DefaultMessage "{0} ({1}) finished." -MessageId "Log_ScriptFinished" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild
    if ($Global:ErreursRencontrees.Count -gt 0) { Write-Log -DefaultMessage "Errors occurred during execution." -MessageId "Log_ErrorsOccurred" -Level WARN }
}