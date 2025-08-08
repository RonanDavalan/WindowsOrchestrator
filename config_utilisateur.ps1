#Requires -Version 5.1

<#
.SYNOPSIS
    Script de configuration UTILISATEUR automatisee.
.DESCRIPTION
    Lit les parametres depuis config.ini, gère un processus applicatif défini et journalise ses actions dans la langue de l'OS.
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


#region GLOBAL CONFIG
$ScriptIdentifierUser = "AllSysConfig-User"
$ScriptInternalBuildUser = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$ScriptDir = $PSScriptRoot

$TargetLogDirUser = Join-Path -Path $ScriptDir -ChildPath "Logs"
$LogDirToUseUser = $ScriptDir
if (Test-Path $TargetLogDirUser -PathType Container) { $LogDirToUseUser = $TargetLogDirUser } 
else { try { New-Item -Path $TargetLogDirUser -ItemType Directory -Force -ErrorAction Stop | Out-Null; $LogDirToUseUser = $TargetLogDirUser } catch {} }

$LogFileUser = Join-Path -Path $LogDirToUseUser -ChildPath "config_utilisateur_log.txt"
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$Global:UserActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:UserErreursRencontrees = [System.Collections.Generic.List[string]]::new()
$Global:Config = $null
#endregion


#region UTILITY FUNCTIONS
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

function Write-UserLog {
    [CmdletBinding()]
    param (
        [string]$DefaultMessage, 
        [string]$MessageId, 
        [object[]]$MessageArgs, 
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")][string]$Level = "INFO", 
        [switch]$NoConsole
    )
    process {
        $formattedMessage = if ($lang -and $lang.ContainsKey($MessageId)) { try { $lang[$MessageId] -f $MessageArgs } catch { $DefaultMessage } } else { $DefaultMessage }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp [$Level] [UserScript:$($env:USERNAME)] - $formattedMessage"

        $LogParentDirUser = Split-Path $LogFileUser -Parent
        if (-not (Test-Path -Path $LogParentDirUser -PathType Container)) { try { New-Item -Path $LogParentDirUser -ItemType Directory -Force -ErrorAction Stop | Out-Null } catch {} }

        try { 
            Add-Content -Path $LogFileUser -Value $logEntry -Encoding UTF8 -ErrorAction Stop 
        }
        catch {
            $fallbackLogDir = "C:\ProgramData\StartupScriptLogs"; if (-not (Test-Path -Path $fallbackLogDir)) { try { New-Item -Path $fallbackLogDir -ItemType Directory -Force -EA Stop | Out-Null } catch {} }
            $fallbackLogFile = Join-Path -Path $fallbackLogDir -ChildPath "config_utilisateur_FATAL_LOG_ERROR.txt"
            $fallbackMessage = "$timestamp [FATAL_USER_LOG_ERROR] - Could not write to '$LogFileUser': $($_.Exception.Message). Original: $logEntry"
            Write-Host $fallbackMessage -ForegroundColor Red; try { Add-Content -Path $fallbackLogFile -Value $fallbackMessage -Encoding UTF8 -ErrorAction Stop } catch {}
        }
        if (-not $NoConsole -and ($Host.Name -eq "ConsoleHost" -or $PSEdition -eq "Core")) { Write-Host $logEntry }
    }
}

function Add-UserAction {
    param([string]$DefaultActionMessage, [string]$ActionId, [object[]]$ActionArgs)
    $formattedMessage = if ($lang -and $lang.ContainsKey($ActionId)) { try { $lang[$ActionId] -f $ActionArgs } catch { $DefaultActionMessage } } else { $DefaultActionMessage }
    $Global:UserActionsEffectuees.Add($formattedMessage)
    Write-UserLog -DefaultMessage "ACTION: $formattedMessage" -Level "INFO" -NoConsole
}

function Add-UserError {
    [CmdletBinding()]
    param ([string]$DefaultErrorMessage, [string]$ErrorId, [object[]]$ErrorArgs)
    $formattedMessage = if ($lang -and $lang.ContainsKey($ErrorId)) { try { $lang[$ErrorId] -f $ErrorArgs } catch { $DefaultErrorMessage } } else { $DefaultErrorMessage }
    $detailedErrorMessage = $formattedMessage
    if ([string]::IsNullOrWhiteSpace($detailedErrorMessage)) {
        if ($global:Error.Count -gt 0) { 
            $lastError = $global:Error[0]
            $detailedErrorMessage = "Unspecified user error. PowerShell: $($lastError.Exception.Message) - StackTrace: $($lastError.ScriptStackTrace)"
        } else { 
            $detailedErrorMessage = "Unspecified user error, and no additional PowerShell error information available."
        }
    }
    $Global:UserErreursRencontrees.Add($detailedErrorMessage)
    Write-UserLog -DefaultMessage "CAPTURED ERROR: $detailedErrorMessage" -MessageId "Log_CapturedError" -MessageArgs $detailedErrorMessage -Level "ERROR"
}

function Get-ConfigValue {
    param(
        [string]$Section,
        [string]$Key,
        [object]$DefaultValue = $null,
        [System.Type]$Type = ([string]),
        [bool]$KeyMustExist = $false
    )
    $value = $null; $keyExists = $false
    if ($null -ne $Global:Config) {
         $keyExists = $Global:Config.ContainsKey($Section) -and $Global:Config[$Section].ContainsKey($Key)
         if ($keyExists) { $value = $Global:Config[$Section][$Key] }
    }
    if ($KeyMustExist -and (-not $keyExists)) { return [pscustomobject]@{ Undefined = $true } }
    if (-not $keyExists) {
        if ($null -ne $DefaultValue) { return $DefaultValue }
        if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null
    }
    if ([string]::IsNullOrWhiteSpace($value) -and $Type -eq ([bool])) { if ($null -ne $DefaultValue) { return $DefaultValue }; return $false }
    try { return [System.Convert]::ChangeType($value, $Type) }
    catch {
        Add-UserError -DefaultErrorMessage "Invalid config value for [$($Section)]$($Key): '$value'. Expected type '$($Type.Name)'. Default/empty value used." -ErrorId "Error_InvalidConfigValue" -ErrorArgs $Section, $Key, $value, $Type.Name
        if ($null -ne $DefaultValue) { return $DefaultValue }
        if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null
    }
}
#endregion


# --- SCRIPT MAIN BODY ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) {
         Write-UserLog -DefaultMessage "Could not read or parse '{0}'. Halting user configurations." -MessageId "Log_User_CannotReadConfig" -MessageArgs $ConfigFile -Level ERROR
         throw "Critical failure: Could not load config.ini for user script."
    }

    if ($i18nLoadingError) { Add-UserError -DefaultErrorMessage "A critical error occurred while loading language files: $i18nLoadingError" -ErrorId "Error_LanguageFileLoad" -ErrorArgs $i18nLoadingError }

    Write-UserLog -DefaultMessage "Starting {0} ({1}) for user '{2}'..." -MessageId "Log_User_StartingScript" -MessageArgs $ScriptIdentifierUser, $ScriptInternalBuildUser, $env:USERNAME
    Write-UserLog -DefaultMessage "Executing configured actions for user '{0}'..." -MessageId "Log_User_ExecutingActions" -MessageArgs $env:USERNAME

    # --- Gérer le processus spécifié ---
    $processNameToManageRaw = Get-ConfigValue -Section "Process" -Key "ProcessName"
    $processNameToManageExpanded = ""
    if (-not [string]::IsNullOrWhiteSpace($processNameToManageRaw)) {
        try { 
            $processNameToManageExpanded = [System.Environment]::ExpandEnvironmentVariables($processNameToManageRaw.Trim('"')) 
        } 
        catch { 
            Add-UserError -DefaultErrorMessage "Error expanding variables for ProcessName '{0}': {1}" -ErrorId "Error_User_VarExpansionFailed" -ErrorArgs $processNameToManageRaw, $_.Exception.Message
            $processNameToManageExpanded = $processNameToManageRaw.Trim('"')
        }
    }
    $processArgumentsToPass = Get-ConfigValue -Section "Process" -Key "ProcessArguments"
    $launchMethod = (Get-ConfigValue -Section "Process" -Key "LaunchMethod" -DefaultValue "direct").ToLower()

    if (-not [string]::IsNullOrWhiteSpace($processNameToManageExpanded)) {
        Write-UserLog -DefaultMessage "Managing user process (raw:'{0}', resolved:'{1}'). Method: {2}" -MessageId "Log_User_ManagingProcess" -MessageArgs $processNameToManageRaw, $processNameToManageExpanded, $launchMethod
        if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) { Write-UserLog -DefaultMessage "With arguments: '{0}'" -MessageId "Log_User_ProcessWithArgs" -MessageArgs $processArgumentsToPass -Level DEBUG }

        $processNameIsFilePath = Test-Path -LiteralPath $processNameToManageExpanded -PathType Leaf -ErrorAction SilentlyContinue

        if (($launchMethod -eq "direct" -and $processNameIsFilePath) -or ($launchMethod -ne "direct")) {
            $exeForStartProcess = ""; $argsForStartProcess = ""; $processBaseNameToMonitor = ""

            if ($launchMethod -eq "direct") {
                $exeForStartProcess = $processNameToManageExpanded
                $argsForStartProcess = $processArgumentsToPass
                try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) } catch { $processBaseNameToMonitor = "UnknownProcess" }
            } elseif ($launchMethod -eq "powershell") {
                $exeForStartProcess = "powershell.exe"
                $commandToRun = "& `"$processNameToManageExpanded`""
                if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) { $commandToRun += " $processArgumentsToPass" }
                $argsForStartProcess = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $commandToRun)
                try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) } catch { $processBaseNameToMonitor = "powershell" }
            } elseif ($launchMethod -eq "cmd") {
                $exeForStartProcess = "cmd.exe"
                $commandToRun = "/c `"`"$processNameToManageExpanded`" $processArgumentsToPass`""
                $argsForStartProcess = $commandToRun
                try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) } catch { $processBaseNameToMonitor = "cmd" }
            } else {
                Add-UserError -DefaultErrorMessage "LaunchMethod '{0}' not recognized. Options: direct, powershell, cmd." -ErrorId "Error_User_LaunchMethodUnknown" -ErrorArgs $launchMethod
                throw "Unhandled LaunchMethod or invalid ProcessName."
            }

            $workingDir = ""
            if ($processNameIsFilePath) {
                try { $workingDir = Split-Path -Path $processNameToManageExpanded -Parent } catch {}
            } else {
                 $workingDir = $ScriptDir
            }

            try {
                $currentUserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                $runningProcess = $null
                if (-not [string]::IsNullOrWhiteSpace($processBaseNameToMonitor)) {
                    Get-Process -Name $processBaseNameToMonitor -ErrorAction SilentlyContinue | ForEach-Object {
                        try {
                            $ownerInfo = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" | Select-Object -ExpandProperty @{Name="Owner"; Expression={ $_.GetProcessOwner() }} -ErrorAction SilentlyContinue
                            if ($ownerInfo -and $ownerInfo.SID -eq $currentUserSID) { $runningProcess = $_; break }
                        } catch {}
                    }
                }

                $startProcessSplat = @{ FilePath = $exeForStartProcess; ErrorAction = 'Stop' }
                if (($argsForStartProcess -is [array] -and $argsForStartProcess.Count -gt 0) -or ($argsForStartProcess -is [string] -and -not [string]::IsNullOrWhiteSpace($argsForStartProcess))) { $startProcessSplat.ArgumentList = $argsForStartProcess }
                if (-not [string]::IsNullOrWhiteSpace($workingDir) -and (Test-Path -LiteralPath $workingDir -PathType Container)) { $startProcessSplat.WorkingDirectory = $workingDir }

                if ($runningProcess) {
                    Write-UserLog -DefaultMessage "Process '{0}' (PID: {1}) is running. Stopping..." -MessageId "Log_User_ProcessStopping" -MessageArgs $processBaseNameToMonitor, $runningProcess.Id
                    $runningProcess | Stop-Process -Force -ErrorAction Stop
                    Add-UserAction -DefaultActionMessage "Process '{0}' stopped." -ActionId "Action_User_ProcessStopped" -ActionArgs $processBaseNameToMonitor
                }

                $logArgsForStart = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                Write-UserLog -DefaultMessage "Starting via {0}: '{1}' with args: '{2}'" -MessageId "Log_User_ProcessStarting" -MessageArgs $launchMethod, $exeForStartProcess, $logArgsForStart
                Start-Process @startProcessSplat
                Add-UserAction -DefaultActionMessage "Process '{0}' started (via {1})." -ActionId "Action_User_ProcessStarted" -ActionArgs $processBaseNameToMonitor, $launchMethod

            } catch {
                $logArgsCatch = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                Add-UserError -DefaultErrorMessage "Failed to manage process '{0}' (Method: {1}, Path: '{2}', Args: '{3}'): {4}. StackTrace: {5}" -ErrorId "Error_User_ProcessManagementFailed" -ErrorArgs $processBaseNameToMonitor, $launchMethod, $exeForStartProcess, $logArgsCatch, $_.Exception.Message, $_.ScriptStackTrace
            }
        } else {
            Add-UserError -DefaultErrorMessage "Executable file for ProcessName '{0}' (direct mode) NOT FOUND." -ErrorId "Error_User_ExeNotFound" -ErrorArgs $processNameToManageExpanded
        }
    } else {
        Write-UserLog -DefaultMessage "No ProcessName specified in [Process] or raw path is empty." -MessageId "Log_User_NoProcessSpecified"
    }

} catch {
    if ($null -ne $Global:Config) {
        Add-UserError -DefaultErrorMessage "FATAL USER SCRIPT ERROR '{0}': {1} `n{2}" -ErrorId "Error_User_FatalScriptError" -ErrorArgs $env:USERNAME, $_.Exception.Message, $_.ScriptStackTrace
    } else {
        $timestampError = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errorMsg = "$timestampError [FATAL SCRIPT USER ERROR - CONFIG NOT LOADED] - Error: $($_.Exception.Message) `nStackTrace: $($_.ScriptStackTrace)"
        try { Add-Content -Path (Join-Path $LogDirToUseUser "config_utilisateur_FATAL_ERROR.txt") -Value $errorMsg -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
        try { Add-Content -Path (Join-Path $ScriptDir "config_utilisateur_FATAL_ERROR_fallback.txt") -Value $errorMsg -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
        Write-Host $errorMsg -ForegroundColor Red
    }
} finally {
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]))) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"
        $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5

        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            $titleSuccessTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessUser" -DefaultValue ("%COMPUTERNAME% %USERNAME% " + $ScriptIdentifierUser + " OK")
            $titleErrorTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorUser" -DefaultValue ("ERROR " + $ScriptIdentifierUser + " %USERNAME% on %COMPUTERNAME%")
            
            $finalMessageTitleUser = ""
            if ($Global:UserErreursRencontrees.Count -gt 0) {
                $finalMessageTitleUser = $titleErrorTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            } else {
                $finalMessageTitleUser = $titleSuccessTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            }

            $messageBodyUser = "On $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n"
            if ($Global:UserActionsEffectuees.Count -gt 0) { $messageBodyUser += "USER Actions:`n" + ($Global:UserActionsEffectuees -join "`n") }
            else { $messageBodyUser += "No USER actions." }
            if ($Global:UserErreursRencontrees.Count -gt 0) { $messageBodyUser += "`n`nUSER Errors:`n" + ($Global:UserErreursRencontrees -join "`n") }

            $payloadUser = @{ message = $messageBodyUser; title = $finalMessageTitleUser; priority = $gotifyPriority } | ConvertTo-Json -Depth 3 -Compress
            $fullUrlUser = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"
            
            try { 
                Invoke-RestMethod -Uri $fullUrlUser -Method Post -Body $payloadUser -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
            } catch { 
                Add-UserError "Gotify (IRM) failed: $($_.Exception.Message)"
            }
        } else { Add-UserError -DefaultErrorMessage "Gotify params incomplete for user script." }
    }

    Write-UserLog -DefaultMessage "{0} ({1}) for '{2}' finished." -MessageId "Log_User_ScriptFinished" -MessageArgs $ScriptIdentifierUser, $ScriptInternalBuildUser, $env:USERNAME
    if ($Global:UserErreursRencontrees.Count -gt 0) { Write-UserLog -DefaultMessage "Errors occurred during execution." -MessageId "Log_ErrorsOccurred" -Level WARN }
}