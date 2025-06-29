#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Automated SYSTEM configuration script for Windows.
.DESCRIPTION
    Reads parameters from config.ini and applies SYSTEM configurations.
    Manages the rotation of its own logs and the user script's logs.
    Manages a scheduled action before system reboot, targeting the
    autologon user for %USERPROFILE% in PreRebootActionCommand.
    Sends its own Gotify notification.
.NOTES
    Author: Ronan Davalan & Gemini 2.5-pro
    Version: See the project's global configuration (config.ini or documentation)
#>

# --- Log Rotation Function ---
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

# --- Get-IniContent (must be defined early for rotation) ---
function Get-IniContent {
    [CmdletBinding()] param ([Parameter(Mandatory=$true)][string]$FilePath)
    $ini = @{}; $currentSection = ""
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) { return $null }
    try {
        Get-Content $FilePath -ErrorAction Stop | ForEach-Object {
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

# --- Global Configuration & Early Log Initialization ---
$ScriptIdentifier = "AllSysConfig-Systeme"
$ScriptInternalBuild = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition }
else { try { $ScriptDir = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $ScriptDir = Get-Location } }

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

# --- Utility Functions (Write-Log, Add-Action, Add-Error, Get-ConfigValue) ---
function Write-Log {
    [CmdletBinding()] param ([string]$Message, [ValidateSet("INFO","WARN","ERROR","DEBUG")][string]$Level="INFO", [switch]$NoConsole)
    process {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] - $Message"
        $LogParentDir = Split-Path $LogFile -Parent
        if (-not (Test-Path -Path $LogParentDir -PathType Container)) { try { New-Item -Path $LogParentDir -ItemType Directory -Force -ErrorAction Stop | Out-Null } catch {}}
        try { Add-Content -Path $LogFile -Value $logEntry -ErrorAction Stop }
        catch {
            $fallbackLogDir = "C:\ProgramData\StartupScriptLogs"
            if (-not (Test-Path $fallbackLogDir)) { try { New-Item $fallbackLogDir -ItemType Directory -Force -EA Stop | Out-Null } catch {}}
            $fallbackLogFile = Join-Path $fallbackLogDir "config_systeme_ps_FATAL_LOG_ERROR.txt"
            $fallbackMessage = "$timestamp [FATAL_LOG_ERROR] - Error writing to '$LogFile': $($_.Exception.Message). Original: $logEntry"
            Write-Host $fallbackMessage -ForegroundColor Red; try { Add-Content $fallbackLogFile $fallbackMessage -EA Stop } catch {}
        }
        if (-not $NoConsole -and ($Host.Name -eq "ConsoleHost" -or $PSEdition -eq "Core")) { Write-Host $logEntry }
    }
}
function Add-Action { param([string]$ActionMessage) $Global:ActionsEffectuees.Add($ActionMessage); Write-Log -Message "ACTION: $ActionMessage" -Level "INFO" -NoConsole }
function Add-Error {
    [CmdletBinding()] param ([Parameter(Mandatory=$true,Position=0)][string]$Message)
    $detailedErrorMessage = $Message; if ([string]::IsNullOrWhiteSpace($detailedErrorMessage)) { if ($global:Error.Count -gt 0) { $lastError = $global:Error[0]; $detailedErrorMessage = "Unspecified PowerShell error: $($lastError.Exception.Message) - Stack: $($lastError.ScriptStackTrace) - Invocation: $($lastError.InvocationInfo.Line)"} else { $detailedErrorMessage = "Unspecified error and no PowerShell info available." } }
    $Global:ErreursRencontrees.Add($detailedErrorMessage); Write-Log -Message "ERROR CAPTURED: $detailedErrorMessage" -Level "ERROR"
}
function Get-ConfigValue {
    param([string]$Section, [string]$Key, [object]$DefaultValue=$null, [System.Type]$Type=([string]), [bool]$KeyMustExist=$false)
    $value = $null; $keyExists = $false; if ($null -ne $Global:Config) { $keyExists = $Global:Config.ContainsKey($Section) -and $Global:Config[$Section].ContainsKey($Key); if ($keyExists) { $value = $Global:Config[$Section][$Key] } }
    if ($KeyMustExist -and (-not $keyExists)) { return [pscustomobject]@{ Undefined = $true } }
    if (-not $keyExists) { if ($null -ne $DefaultValue) { return $DefaultValue }; if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null }
    if ([string]::IsNullOrWhiteSpace($value) -and $Type -eq ([bool])) { if ($null -ne $DefaultValue) { return $DefaultValue }; return $false }
    try { return [System.Convert]::ChangeType($value, $Type) }
    catch { Add-Error "Invalid config value for [$($Section)]$($Key): '$value'. Expected type '$($Type.Name)'. Using default/empty value."; if ($null -ne $DefaultValue) { return $DefaultValue }; if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null }
}
# --- END Utility Functions ---

# --- Main Script Start ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) { $tsInitErr = Get-Date -F "yyyy-MM-dd HH:mm:ss"; try { Add-Content $LogFile "$tsInitErr [ERROR] - Unable to read '$ConfigFile'. Aborting." } catch {}; throw "Critical failure: config.ini."}

    if ($rotationEnabledByConfig) {
        $maxSysLogs = Get-ConfigValue -Section "Logging" -Key "MaxSystemLogsToKeep" -Type ([int]) -DefaultValue $DefaultMaxLogs; if($maxSysLogs -lt 1){Write-Log "MaxSystemLogsToKeep ($maxSysLogs) is invalid." -L WARN} Write-Log "System log rotation active. Max(cfg):$maxSysLogs. Init($DefaultMaxLogs)." -L INFO
        $maxUserLogs = Get-ConfigValue -Section "Logging" -Key "MaxUserLogsToKeep" -Type ([int]) -DefaultValue $DefaultMaxLogs; if($maxUserLogs -lt 1){Write-Log "MaxUserLogsToKeep ($maxUserLogs) is invalid." -L WARN} Write-Log "User log rotation active. Max(cfg):$maxUserLogs. Init($DefaultMaxLogs)." -L INFO
    } else { Write-Log "Log rotation disabled. Initial ($DefaultMaxLogs) if applicable." -L INFO }

    Write-Log -Message "Starting $ScriptIdentifier ($ScriptInternalBuild)..."
    $networkReady = $false; Write-Log "Checking network connectivity..."; for ($i = 0; $i -lt 6; $i++) { if (Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue) { Write-Log "Network connectivity detected."; $networkReady = $true; break }; if ($i -lt 5) { Write-Log "Network unavailable, trying again in 10s..."; Start-Sleep -Seconds 10 }}; if (-not $networkReady) { Write-Log "Network not established. Gotify might fail." -Level "WARN" }
    Write-Log "Executing configured SYSTEM actions..."

    # Determine target user for configurations that require it (Autologon, PreRebootAction %USERPROFILE%)
    $targetUsernameForConfiguration = Get-ConfigValue -Section "SystemConfig" -Key "AutoLoginUsername"
    if ([string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
        Write-Log "AutoLoginUsername not specified. Attempting to read DefaultUserName from Registry." -L INFO
        try {
            $winlogonKeyForDefaultUser = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
            $regDefaultUser = (Get-ItemProperty -Path $winlogonKeyForDefaultUser -Name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
            if (-not [string]::IsNullOrWhiteSpace($regDefaultUser)) {
                $targetUsernameForConfiguration = $regDefaultUser
                Write-Log "Registry DefaultUserName used as target user: $targetUsernameForConfiguration." -L INFO
            } else { Write-Log "Registry DefaultUserName not found or empty. No default target user." -L WARN }
        } catch { Write-Log "Error reading DefaultUserName from Registry: $($_.Exception.Message)" -L WARN }
    } else { Write-Log "AutoLoginUsername from config.ini used as target user: $targetUsernameForConfiguration." -L INFO }

    # --- Manage Fast Startup ---
    $disableFastStartup = Get-ConfigValue -Section "SystemConfig" -Key "DisableFastStartup" -Type ([bool]) -KeyMustExist $true
    if ($disableFastStartup -is [pscustomobject] -and $disableFastStartup.Undefined) { Write-Log "Param 'DisableFastStartup' not specified." -L INFO }
    else {
        $powerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
        if (-not(Test-Path $powerRegPath)){ Add-Error "Power Reg key not found: $powerRegPath" }
        else {
            $currentHiberboot = (Get-ItemProperty -Path $powerRegPath -Name HiberbootEnabled -ErrorAction SilentlyContinue).HiberbootEnabled
            if($disableFastStartup){ Write-Log "Cfg: Disabling FastStartup."
                if($currentHiberboot -ne 0){ try{Set-ItemProperty $powerRegPath HiberbootEnabled 0 -Force -EA Stop;Add-Action "FastStartup disabled."}catch{Add-Error "Failed to disable FastStartup: $($_.Exception.Message)"} }
                else{ Write-Log "FastStartup already disabled." -L INFO;Add-Action "FastStartup checked (already disabled)." }
            } else { Write-Log "Cfg: Enabling FastStartup."
                if($currentHiberboot -ne 1){ try{Set-ItemProperty $powerRegPath HiberbootEnabled 1 -Force -EA Stop;Add-Action "FastStartup enabled."}catch{Add-Error "Failed to enable FastStartup: $($_.Exception.Message)"} }
                else{ Write-Log "FastStartup already enabled." -L INFO;Add-Action "FastStartup checked (already enabled)." }
            }
        }
    }

    # --- Disable machine sleep ---
    if (Get-ConfigValue "SystemConfig" "DisableSleep" -Type ([bool]) -DefaultValue $false) { Write-Log "Disabling machine sleep..."; try {
        powercfg /change standby-timeout-ac 0 | Out-Null; powercfg /change standby-timeout-dc 0 | Out-Null
        powercfg /change hibernate-timeout-ac 0 | Out-Null; powercfg /change hibernate-timeout-dc 0 | Out-Null
        Add-Action "Machine sleep (S3/S4) disabled." } catch { Add-Error "Failed to disable machine sleep: $($_.Exception.Message)" }}

    # --- Disable screen sleep ---
    if (Get-ConfigValue "SystemConfig" "DisableScreenSleep" -Type ([bool]) -DefaultValue $false) { Write-Log "Disabling screen sleep..."; try {
        powercfg /change monitor-timeout-ac 0 | Out-Null; powercfg /change monitor-timeout-dc 0 | Out-Null
        Add-Action "Screen sleep disabled." } catch { Add-Error "Failed to disable screen sleep: $($_.Exception.Message)" }}

    # --- Manage AutoLogin ---
    $enableAutoLogin = Get-ConfigValue "SystemConfig" "EnableAutoLogin" -Type ([bool]) -DefaultValue $false
    $winlogonKeyForAutologon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" # distinct variable
    if ($enableAutoLogin) { Write-Log "Checking/Enabling AutoLogin..."
        if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) { try {
            Set-ItemProperty -Path $winlogonKeyForAutologon -Name AutoAdminLogon -Value "1" -Type String -Force -ErrorAction Stop; Add-Action "AutoAdminLogon enabled."
            Set-ItemProperty -Path $winlogonKeyForAutologon -Name DefaultUserName -Value $targetUsernameForConfiguration -Type String -Force -ErrorAction Stop; Add-Action "DefaultUserName: $targetUsernameForConfiguration."
            } catch { Add-Error "Failed to configure AutoLogin: $($_.Exception.Message)" }}
        else { Write-Log "EnableAutoLogin=true but target user could not be determined." -L WARN; Add-Error "AutoLogin enabled but target user could not be determined."}
    } else { Write-Log "Disabling AutoLogin..."; try {
        Set-ItemProperty -Path $winlogonKeyForAutologon -Name AutoAdminLogon -Value "0" -Type String -Force -ErrorAction Stop; Add-Action "AutoAdminLogon disabled."
        } catch { Add-Error "Failed to disable AutoAdminLogon: $($_.Exception.Message)" }}

    # --- Manage Windows Update ---
    $disableWindowsUpdate = Get-ConfigValue "SystemConfig" "DisableWindowsUpdate" -Type ([bool]) -DefaultValue $false
    $windowsUpdatePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; $windowsUpdateService = "wuauserv"
    try { if(-not(Test-Path $windowsUpdatePolicyKey)){New-Item $windowsUpdatePolicyKey -Force -EA Stop|Out-Null}
        if($disableWindowsUpdate){ Write-Log "Disabling Win Update..."; Set-ItemProperty $windowsUpdatePolicyKey NoAutoUpdate 1 -Type DWord -Force -EA Stop
            Get-Service $windowsUpdateService -EA Stop|Set-Service -StartupType Disabled -PassThru -EA Stop|Stop-Service -Force -EA SilentlyContinue; Add-Action "Win Updates disabled."}
        else{ Write-Log "Enabling Win Update..."; Set-ItemProperty $windowsUpdatePolicyKey NoAutoUpdate 0 -Type DWord -Force -EA Stop
            Get-Service $windowsUpdateService -EA Stop|Set-Service -StartupType Automatic -PassThru -EA Stop|Start-Service -EA SilentlyContinue; Add-Action "Win Updates enabled."}
    } catch { Add-Error "Failed to manage Win Update: $($_.Exception.Message)"}

    # --- Disable auto-reboots (WU) ---
    if(Get-ConfigValue "SystemConfig" "DisableAutoReboot" -Type ([bool]) -DefaultValue $false){ Write-Log "Disabling auto-reboot (WU)..."; try {
        if(-not(Test-Path $windowsUpdatePolicyKey)){New-Item $windowsUpdatePolicyKey -Force -EA Stop|Out-Null}
        Set-ItemProperty $windowsUpdatePolicyKey NoAutoRebootWithLoggedOnUsers 1 -Type DWord -Force -EA Stop; Add-Action "Auto-reboot (WU) disabled."
        } catch { Add-Error "Failed to disable auto-reboot: $($_.Exception.Message)"}}

    # --- Configure scheduled reboot ---
    $rebootTime = Get-ConfigValue "SystemConfig" "ScheduledRebootTime"
    $rebootTaskName = "AllSys_SystemScheduledReboot"
    if (-not [string]::IsNullOrWhiteSpace($rebootTime)) { Write-Log "Configuring scheduled reboot at $rebootTime...";
        $shutdownPath = Join-Path $env:SystemRoot "System32\shutdown.exe"
        $rebootDesc = "Daily reboot by AllSysConfig (Build: $ScriptInternalBuild)"
        $rebootAction = New-ScheduledTaskAction -Execute $shutdownPath -Argument "/r /f /t 60 /c `"$rebootDesc`""
        try {
            $rebootTrigger = New-ScheduledTaskTrigger -Daily -At $rebootTime -ErrorAction Stop
            $rebootPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest
            $rebootSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 2) -Compatibility Win8
            Unregister-ScheduledTask -TaskName $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
            Register-ScheduledTask -TaskName $rebootTaskName -Action $rebootAction -Trigger $rebootTrigger -Principal $rebootPrincipal -Settings $rebootSettings -Description $rebootDesc -Force -ErrorAction Stop
            Add-Action "Scheduled reboot at $rebootTime (Task: $rebootTaskName)."
        } catch { Add-Error "Failed to configure scheduled reboot ($rebootTime) task '$rebootTaskName': $($_.Exception.Message)." }}
    else { Write-Log "ScheduledRebootTime not specified. Deleting task '$rebootTaskName'." -L INFO; Unregister-ScheduledTask $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue }

    # --- Configure pre-reboot action (Candidate v1.4) ---
    Write-Log -Message "Starting configuration of pre-reboot action..." -Level DEBUG

    $preRebootActionTime = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionTime"
    $preRebootCmdFromFile = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionCommand"
    $preRebootArgsFromFile = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionArguments"
    $preRebootLaunchMethodFromFile = (Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionLaunchMethod" -DefaultValue "direct").ToLower()

    $preRebootTaskName = "AllSys_SystemPreRebootAction"

    if ((-not [string]::IsNullOrWhiteSpace($preRebootActionTime)) -and (-not [string]::IsNullOrWhiteSpace($preRebootCmdFromFile))) {
        Write-Log -Message "Valid PreReboot parameters detected: Time='$preRebootActionTime', Command='$preRebootCmdFromFile', Args='$preRebootArgsFromFile', Method='$preRebootLaunchMethodFromFile'."

        # Raw path from config.ini, without outer quotes
        $programToExecute = $preRebootCmdFromFile.Trim('"')

        if ($programToExecute -match "%USERPROFILE%") {
            if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
                $userProfilePathTarget = $null
                try {
                    $userAccount = New-Object System.Security.Principal.NTAccount($targetUsernameForConfiguration)
                    $userSid = $userAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
                    $userProfilePathTarget = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSid" -Name ProfileImagePath -ErrorAction Stop).ProfileImagePath
                } catch {
                    Add-Error -Message "Could not determine profile path for '$targetUsernameForConfiguration' via SID for PreRebootAction. Error: $($_.Exception.Message)"
                    $userProfilePathTarget = "C:\Users\$targetUsernameForConfiguration" # Heuristic fallback
                    Write-Log -Message "Using constructed path '$userProfilePathTarget' as a fallback for the profile of '$targetUsernameForConfiguration'." -Level WARN
                }

                if (-not [string]::IsNullOrWhiteSpace($userProfilePathTarget) -and (Test-Path $userProfilePathTarget -PathType Container)) {
                    $programToExecute = $programToExecute -replace "%USERPROFILE%", [regex]::Escape($userProfilePathTarget)
                    Write-Log -Message "%USERPROFILE% in PreRebootActionCommand replaced with '$userProfilePathTarget'. Resulting path: '$programToExecute'" -Level INFO
                } else {
                    Add-Error -Message "Profile '$userProfilePathTarget' for target user '$targetUsernameForConfiguration' not found/invalid. %USERPROFILE% not resolved."
                    # Leave $programToExecute with %USERPROFILE%, expansion by SYSTEM will be the risky fallback
                    Write-Log -Message "Leaving %USERPROFILE% for expansion by SYSTEM for PreRebootActionCommand: '$programToExecute'" -Level WARN
                }
            } else {
                Add-Error -Message "%USERPROFILE% detected in PreRebootActionCommand, but target user (AutoLoginUsername) not determined. %USERPROFILE% will not be resolved to a specific user."
                # Leave $programToExecute with %USERPROFILE%
                Write-Log -Message "Leaving %USERPROFILE% for expansion by SYSTEM for PreRebootActionCommand: '$programToExecute'" -Level WARN
            }
        }

        # ----- START OF MODIFICATION FOR PROJECT-RELATIVE PATHS -----
        # If $programToExecute is not an absolute path, not an env variable, and not a simple command in the PATH,
        # we try to resolve it relative to $ScriptDir (project root directory).
        if (($programToExecute -notmatch '^[a-zA-Z]:\\') -and `
            ($programToExecute -notmatch '^\\\\') -and `
            ($programToExecute -notmatch '^%') -and `
            (-not (Get-Command $programToExecute -CommandType Application,ExternalScript -ErrorAction SilentlyContinue)) ) {

            $potentialProjectPath = ""
            try {
                # Ensure $ScriptDir is an absolute path before Join-Path
                if (-not [System.IO.Path]::IsPathRooted($ScriptDir)) {
                    # This should not happen if $ScriptDir is correctly initialized
                    Add-Error -Message "The script root directory (\$ScriptDir='$ScriptDir') is not an absolute path. Cannot resolve relative path '$programToExecute'."
                } else {
                    $potentialProjectPath = Join-Path -Path $ScriptDir -ChildPath $programToExecute -Resolve -ErrorAction SilentlyContinue
                }
            } catch {
                 Add-Error -Message "Error while attempting Join-Path for '$ScriptDir' and '$programToExecute': $($_.Exception.Message)"
            }

            if (-not [string]::IsNullOrWhiteSpace($potentialProjectPath) -and (Test-Path -LiteralPath $potentialProjectPath -PathType Leaf)) {
                Write-Log -Message "PreRebootActionCommand '$preRebootCmdFromFile' (interpreted as '$programToExecute') resolved to project-relative path: '$potentialProjectPath'" -Level DEBUG
                $programToExecute = $potentialProjectPath
            } elseif (-not [string]::IsNullOrWhiteSpace($potentialProjectPath)) {
                 Write-Log -Message "PreRebootActionCommand '$preRebootCmdFromFile' (interpreted as '$programToExecute') looks like a project-relative path, but '$potentialProjectPath' was not found or is not a file." -Level WARN
            } else {
                 Write-Log -Message "PreRebootActionCommand '$preRebootCmdFromFile' (interpreted as '$programToExecute') could not be resolved as a project-relative path. $potentialProjectPath is empty." -Level WARN
            }
        }
        # ----- END OF MODIFICATION FOR PROJECT-RELATIVE PATHS -----

        # Final expansion of other environment variables (e.g., %SystemRoot%)
        try {
            $programToExecute = [System.Environment]::ExpandEnvironmentVariables($programToExecute)
        } catch {
            Add-Error -Message "Error during final environment variable expansion for PreRebootActionCommand '$programToExecute': $($_.Exception.Message)"
            # $programToExecute remains as is if expansion fails
        }
        Write-Log -Message "Program to execute for PreReboot (after all processing): '$programToExecute'" -Level DEBUG

        $exeForTaskScheduler = ""
        $argumentStringForTaskScheduler = ""
        $workingDirectoryForTask = "" # Initialization

        if ($preRebootLaunchMethodFromFile -eq "direct") {
            $exeForTaskScheduler = $programToExecute
            $argumentStringForTaskScheduler = $preRebootArgsFromFile
            if (Test-Path -LiteralPath $exeForTaskScheduler -PathType Leaf) {
                try { $workingDirectoryForTask = Split-Path -Path $exeForTaskScheduler -Parent } catch {}
            }
        } elseif ($preRebootLaunchMethodFromFile -eq "powershell") {
            $exeForTaskScheduler = "powershell.exe"
            $psCommand = "& `"$programToExecute`""
            if (-not [string]::IsNullOrWhiteSpace($preRebootArgsFromFile)) { $psCommand += " $preRebootArgsFromFile" }
            $argumentStringForTaskScheduler = "-NoProfile -ExecutionPolicy Bypass -Command `"$($psCommand.Replace('"', '\"'))`""
            if (Test-Path -LiteralPath $programToExecute -PathType Leaf) { # If it's a .ps1 script
                try { $workingDirectoryForTask = Split-Path -Path $programToExecute -Parent } catch {}
            }
        } elseif ($preRebootLaunchMethodFromFile -eq "cmd") {
            $exeForTaskScheduler = "cmd.exe"
            $cmdCommand = "/c `"$programToExecute`""
            if (-not [string]::IsNullOrWhiteSpace($preRebootArgsFromFile)) { $cmdCommand += " $preRebootArgsFromFile" }
            $argumentStringForTaskScheduler = $cmdCommand
            if (Test-Path -LiteralPath $programToExecute -PathType Leaf) { # If it's a .bat or .exe
                try { $workingDirectoryForTask = Split-Path -Path $programToExecute -Parent } catch {}
            }
        } else {
            Add-Error -Message "PreRebootActionLaunchMethod '$preRebootLaunchMethodFromFile' not recognized. Task not created."
            $exeForTaskScheduler = "" # Force task creation failure
        }

        # If workingDirectoryForTask is empty and it's not a simple command, use $ScriptDir as a fallback
        if ([string]::IsNullOrWhiteSpace($workingDirectoryForTask) -and `
            ($exeForTaskScheduler -notmatch '^[a-zA-Z]:\\') -and `
            ($exeForTaskScheduler -notmatch '^\\\\') -and `
            (Test-Path -LiteralPath (Join-Path $ScriptDir $exeForTaskScheduler) -ErrorAction SilentlyContinue) ) {
            # Do not do this for simple PATH commands (e.g., taskkill.exe)
        } elseif ([string]::IsNullOrWhiteSpace($workingDirectoryForTask) -and (-not (Get-Command $exeForTaskScheduler -ErrorAction SilentlyContinue))) {
             # If it's not a PATH command and the working dir was not set (e.g., project-relative path to non-file?)
             $workingDirectoryForTask = $ScriptDir
             Write-Log -Message "WorkingDirectory for PreRebootAction not determined from '$programToExecute', using '$ScriptDir' as default." -Level DEBUG
        }

        Write-Log -Message "For the PreReboot task: Exe='$exeForTaskScheduler', Args='$argumentStringForTaskScheduler', WorkDir='$workingDirectoryForTask'" -Level DEBUG

        $canProceedWithTaskCreation = $false
        if (-not [string]::IsNullOrWhiteSpace($exeForTaskScheduler)) {
            if ($exeForTaskScheduler -eq "powershell.exe" -or $exeForTaskScheduler -eq "cmd.exe") {
                # For interpreters, we check that the script/program they need to run ($programToExecute) exists
                if (Test-Path -LiteralPath $programToExecute -PathType Leaf -ErrorAction SilentlyContinue) {
                    $canProceedWithTaskCreation = $true
                } elseif (Get-Command $programToExecute -ErrorAction SilentlyContinue -CommandType Application,ExternalScript) {
                    Write-Log -Message "Program '$programToExecute' for PreRebootAction (via $preRebootLaunchMethodFromFile) appears to be a PATH command." -Level WARN
                    $canProceedWithTaskCreation = $true
                } else {
                    Add-Error -Message "Script/Program '$programToExecute' for PreRebootAction (via $preRebootLaunchMethodFromFile) is not found."
                }
            } elseif (Test-Path -LiteralPath $exeForTaskScheduler -PathType Leaf -ErrorAction SilentlyContinue) {
                $canProceedWithTaskCreation = $true
            } elseif (Get-Command $exeForTaskScheduler -ErrorAction SilentlyContinue -CommandType Application,ExternalScript) {
                 Write-Log -Message "Program '$exeForTaskScheduler' (direct) appears to be a PATH command." -Level WARN
                 $canProceedWithTaskCreation = $true
            } else {
                Add-Error -Message "Main executable '$exeForTaskScheduler' for PreRebootAction is not found."
            }
        } else {
             Add-Error -Message "No executable determined for PreRebootAction. Task not created."
        }

        if ($canProceedWithTaskCreation) {
            try {
                $taskAction = New-ScheduledTaskAction -Execute $exeForTaskScheduler
                if (-not [string]::IsNullOrWhiteSpace($argumentStringForTaskScheduler)) {
                    $taskAction.Arguments = $argumentStringForTaskScheduler
                }
                # Set the working directory for the task action
                if (-not [string]::IsNullOrWhiteSpace($workingDirectoryForTask) -and (Test-Path -LiteralPath $workingDirectoryForTask -PathType Container)) {
                    $taskAction.WorkingDirectory = $workingDirectoryForTask
                } elseif (-not [string]::IsNullOrWhiteSpace($workingDirectoryForTask)) {
                    Write-Log -Message "Working directory '$workingDirectoryForTask' for PreRebootAction is specified but does not exist or is not a container. Not applied." -Level WARN
                }


                $taskTrigger = New-ScheduledTaskTrigger -Daily -At $preRebootActionTime -ErrorAction Stop
                $taskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest
                $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
                $taskDescription = "Preparatory action before reboot by AllSysConfig (Build: $ScriptInternalBuild)"

                Unregister-ScheduledTask -TaskName $preRebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
                Register-ScheduledTask -TaskName $preRebootTaskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings -Description $taskDescription -Force -ErrorAction Stop
                Add-Action "Pre-reboot action at '$preRebootActionTime' configured (Task: $preRebootTaskName)."
                Write-Log -Message "Task '$preRebootTaskName' created/updated to execute: '$($taskAction.Execute)' with args: '$($taskAction.Arguments)' and WorkDir: '$($taskAction.WorkingDirectory)'" -Level INFO
            } catch {
                Add-Error -Message "Failed to create/update task '$preRebootTaskName' for PreRebootAction: $($_.Exception.Message)"
            }
        } else {
            Write-Log -Message "Program validation for PreRebootAction failed. Task '$preRebootTaskName' not created/updated." -Level ERROR
        }
    } else {
        Write-Log -Message "PreRebootActionTime or PreRebootActionCommand not specified in config.ini. Deleting task '$preRebootTaskName' if it exists." -Level INFO
        Unregister-ScheduledTask -TaskName $preRebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }
    Write-Log -Message "End of pre-reboot action configuration." -Level DEBUG

    # --- Manage OneDrive (system policy) ---
    $oneDrivePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if(Get-ConfigValue -Section "SystemConfig" -Key "DisableOneDrive" -Type ([bool]) -DefaultValue $false){ Write-Log -Message "Disabling OneDrive (policy)..."; try {
        if (-not(Test-Path $oneDrivePolicyKey)){New-Item -Path $oneDrivePolicyKey -Force -ErrorAction Stop | Out-Null}
        Set-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Value 1 -Type DWord -Force -ErrorAction Stop
        Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; Add-Action "OneDrive disabled (policy)."}
        catch { Add-Error -Message "Failed to disable OneDrive: $($_.Exception.Message)"}}
    else { Write-Log -Message "Enabling/Maintaining OneDrive (policy)..."; try {
        if(Test-Path $oneDrivePolicyKey){ If(Get-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -ErrorAction SilentlyContinue){ Remove-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Force -ErrorAction Stop }}
        Add-Action "OneDrive allowed (policy)."} catch { Add-Error -Message "Failed to enable OneDrive: $($_.Exception.Message)"}}

} catch {
    if ($null -ne $Global:Config) { Add-Error -Message "FATAL SCRIPT ERROR (main block): $($_.Exception.Message) `n$($_.ScriptStackTrace)" }
    else { $tsErr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $errMsg = "$tsErr [FATAL SCRIPT ERROR - CONFIG NOT INITIALIZED/LOADED] - Error: $($_.Exception.Message) `nStackTrace: $($_.ScriptStackTrace)"; try { Add-Content -Path (Join-Path $LogDirToUse "config_systeme_ps_FATAL_ERROR.txt") -Value $errMsg -ErrorAction SilentlyContinue } catch {}; try { Add-Content -Path (Join-Path $ScriptDir "config_systeme_ps_FATAL_ERROR_fallback.txt") -Value $errMsg -ErrorAction SilentlyContinue } catch {}; Write-Host $errMsg -ForegroundColor Red }
} finally {
    # --- Gotify Notification ---
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]) -DefaultValue $false)) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"; $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5
        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            $networkReadyForGotify = $false; if($networkReady){$networkReadyForGotify=$true} else { Write-Log -Message "Re-checking net for Gotify..." -Level WARN; if(Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue){Write-Log -Message "Net for Gotify OK.";$networkReadyForGotify=$true}else{Write-Log -Message "Net for Gotify still down." -Level WARN}}
            if($networkReadyForGotify){ Write-Log -Message "Preparing Gotify notification (system)..."
                $titleSuccessTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessSystem" -DefaultValue ("%COMPUTERNAME% " + $ScriptIdentifier + " OK")
                $titleErrorTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorSystem" -DefaultValue ("ERROR " + $ScriptIdentifier + " on %COMPUTERNAME%")
                $finalMessageTitle = if($Global:ErreursRencontrees.Count -gt 0){$titleErrorTemplate -replace "%COMPUTERNAME%",$env:COMPUTERNAME}else{$titleSuccessTemplate -replace "%COMPUTERNAME%",$env:COMPUTERNAME}
                #$messageBody = "Script '$ScriptIdentifier' (Build: $ScriptInternalBuild) on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n`n"
                #$messageBody = "'$ScriptIdentifier' on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n`n"
                $messageBody = "On $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n"
                if($Global:ActionsEffectuees.Count -gt 0){$messageBody += "SYSTEM Actions:`n" + ($Global:ActionsEffectuees -join "`n")}else{$messageBody += "No SYSTEM actions."}
                if($Global:ErreursRencontrees.Count -gt 0){$messageBody += "`n`nSYSTEM Errors:`n" + ($Global:ErreursRencontrees -join "`n")}
                $payload = @{message=$messageBody; title=$finalMessageTitle; priority=$gotifyPriority} | ConvertTo-Json -Depth 3 -Compress
                $fullUrl = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"
                Write-Log "Sending Gotify (system) to $fullUrl..."; try { Invoke-RestMethod -Uri $fullUrl -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop; Write-Log -Message "Gotify (system) sent."}
                catch {Add-Error "Gotify failure (IRM): $($_.Exception.Message)"; $curlPath=Get-Command curl -ErrorAction SilentlyContinue
                    if($curlPath){ Write-Log "Falling back to curl for Gotify..."; $tempJsonFile = Join-Path $env:TEMP "gotify_sys_$($PID)_$((Get-Random).ToString()).json"
                        try{$payload|Out-File $tempJsonFile -Encoding UTF8 -ErrorAction Stop; $cArgs="-s -k -X POST `"$fullUrl`" -H `"Content-Type: application/json`" -d `@`"$tempJsonFile`""
                            Invoke-Expression "curl $($cArgs -join ' ')"|Out-Null;Write-Log "Gotify (curl) sent."}
                        catch{Add-Error "Gotify failure (curl): $($_.Exception.Message)"}finally{if(Test-Path $tempJsonFile){Remove-Item $tempJsonFile -ErrorAction SilentlyContinue}}}
                    else{Add-Error "curl.exe not found."}}}
            else {Add-Error "Network unavailable for system Gotify."}}
        else {Add-Error "Incomplete Gotify params."}}

    Write-Log -Message "$ScriptIdentifier ($ScriptInternalBuild) finished."
    if ($Global:ErreursRencontrees.Count -gt 0) { Write-Log -Message "Some errors occurred." -Level WARN }
    if ($Host.Name -eq "ConsoleHost" -and $Global:ErreursRencontrees.Count -gt 0 -and (-not $env:TF_BUILD)) {
        Write-Warning "Errors occurred (system script). Log: $LogFile"
    }
}