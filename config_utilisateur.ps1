#Requires -Version 5.1
# No need for -RunAsAdministrator here, it runs in the logged-on user's context.

<#
.SYNOPSIS
    Automated USER configuration script.
.DESCRIPTION
    Reads parameters from config.ini, applies user-specific configurations
    (mainly managing a defined application process), and sends a Gotify notification.
    Its log rotation is managed by the config_systeme.ps1 script.
.NOTES
    Author: Ronan Davalan & Gemini 2.5-pro
    Version: See the project's global configuration (config.ini or documentation)
#>

# --- NO Rotate-LogFile FUNCTION HERE (managed by config_systeme.ps1) ---

# --- Global Configuration ---
$ScriptIdentifierUser = "AllSysConfig-Utilisateur"
$ScriptInternalBuildUser = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
} else {
    try { $ScriptDir = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop }
    catch { $ScriptDir = Get-Location }
}

$TargetLogDirUser = Join-Path -Path $ScriptDir -ChildPath "Logs"
$LogDirToUseUser = $ScriptDir # Fallback

if (Test-Path $TargetLogDirUser -PathType Container) {
    $LogDirToUseUser = $TargetLogDirUser
} else {
    try { New-Item -Path $TargetLogDirUser -ItemType Directory -Force -ErrorAction Stop | Out-Null; $LogDirToUseUser = $TargetLogDirUser } catch {}
}

$LogFileUserBaseName = "config_utilisateur_log"
$LogFileUser = Join-Path -Path $LogDirToUseUser -ChildPath "$($LogFileUserBaseName).txt"

$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"

$Global:UserActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:UserErreursRencontrees = [System.Collections.Generic.List[string]]::new()
# Will be populated by Get-IniContent
$Global:Config = $null

# --- Utility Functions ---
# Get-IniContent must be defined early
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
                    $key = $matches[1].Trim(); $value = $matches[2].Trim() # No inline comment handling here
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
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO",
        [switch]$NoConsole
    )
    process {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp [$Level] [UserScript:$($env:USERNAME)] - $Message"

        $LogParentDirUser = Split-Path $LogFileUser -Parent
        if (-not (Test-Path -Path $LogParentDirUser -PathType Container)) {
            try { New-Item -Path $LogParentDirUser -ItemType Directory -Force -ErrorAction Stop | Out-Null } catch {}
        }

        try { Add-Content -Path $LogFileUser -Value $logEntry -ErrorAction Stop }
        catch {
            $fallbackLogDir = "C:\ProgramData\StartupScriptLogs"
            if (-not (Test-Path -Path $fallbackLogDir -PathType Container)) {
                try { New-Item -Path $fallbackLogDir -ItemType Directory -Force -ErrorAction Stop | Out-Null } catch {}
            }
            $fallbackLogFile = Join-Path -Path $fallbackLogDir -ChildPath "config_utilisateur_FATAL_LOG_ERROR.txt"
            $fallbackMessage = "$timestamp [FATAL_USER_LOG_ERROR] - Unable to write to '$LogFileUser': $($_.Exception.Message). Original message: $logEntry"
            Write-Host $fallbackMessage -ForegroundColor Red
            try { Add-Content -Path $fallbackLogFile -Value $fallbackMessage -ErrorAction Stop } catch {}
        }
        if (-not $NoConsole -and ($Host.Name -eq "ConsoleHost" -or $PSEdition -eq "Core")) {
            Write-Host $logEntry
        }
    }
}

function Add-UserAction {
    param([string]$ActionMessage)
    $Global:UserActionsEffectuees.Add($ActionMessage)
    Write-UserLog -Message "ACTION: $ActionMessage" -Level "INFO" -NoConsole
}

function Add-UserError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message
    )
    $detailedErrorMessage = $Message
    if ([string]::IsNullOrWhiteSpace($detailedErrorMessage)) {
        if ($global:Error.Count -gt 0) {
            $lastError = $global:Error[0]
            $detailedErrorMessage = "Unspecified user error. PowerShell: $($lastError.Exception.Message) - StackTrace: $($lastError.ScriptStackTrace) - InvocationInfo: $($lastError.InvocationInfo.Line)"
        } else {
            $detailedErrorMessage = "Unspecified user error, and no additional PowerShell error information available."
        }
    }
    $Global:UserErreursRencontrees.Add($detailedErrorMessage)
    Write-UserLog -Message "ERROR CAPTURED: $detailedErrorMessage" -Level "ERROR"
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
    if ([string]::IsNullOrWhiteSpace($value) -and $Type -eq ([bool])) {
        if ($null -ne $DefaultValue) { return $DefaultValue }; return $false
    }
    try { return [System.Convert]::ChangeType($value, $Type) }
    catch {
        Add-UserError "Invalid config value for [$($Section)]$($Key): '$value'. Expected type '$($Type.Name)'. Using default/empty value."
        if ($null -ne $DefaultValue) { return $DefaultValue }
        if ($Type -eq ([bool])) { return $false }; if ($Type -eq ([int])) { return 0 }; return $null
    }
}
# --- END Utility Functions ---

# --- User Script Start ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) {
         Write-UserLog -Message "Unable to read or parse '$ConfigFile'. Stopping user configurations." -Level ERROR
         throw "Critical failure: Unable to load config.ini for the user script."
    }

    Write-UserLog -Message "Starting $ScriptIdentifierUser ($ScriptInternalBuildUser) for '$($env:USERNAME)'..."
    Write-UserLog -Message "Executing configured user actions for '$($env:USERNAME)'..."

    # --- Manage specified process ---
    $processNameToManageRaw = Get-ConfigValue -Section "Process" -Key "ProcessName"
    $processNameToManageExpanded = ""
    if (-not [string]::IsNullOrWhiteSpace($processNameToManageRaw)) {
        try {
            $processNameToManageExpanded = [System.Environment]::ExpandEnvironmentVariables($processNameToManageRaw.Trim('"'))
        } catch {
            Add-UserError "Error expanding variables for ProcessName '$processNameToManageRaw': $($_.Exception.Message)"
            $processNameToManageExpanded = $processNameToManageRaw.Trim('"')
        }
    }
    $processArgumentsToPass = Get-ConfigValue -Section "Process" -Key "ProcessArguments"
    $launchMethod = (Get-ConfigValue -Section "Process" -Key "LaunchMethod" -DefaultValue "direct").ToLower()

    if (-not [string]::IsNullOrWhiteSpace($processNameToManageExpanded)) {
        Write-UserLog -Message "Managing user process (raw:'$processNameToManageRaw', resolved:'$processNameToManageExpanded'). Method: $launchMethod"
        if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) { Write-UserLog -Message "With arguments: '$processArgumentsToPass'" -Level DEBUG }

        $processNameIsFilePath = Test-Path -LiteralPath $processNameToManageExpanded -PathType Leaf -ErrorAction SilentlyContinue

        if (($launchMethod -eq "direct" -and $processNameIsFilePath) -or ($launchMethod -ne "direct")) {
            $exeForStartProcess = ""
            $argsForStartProcess = ""
            $processBaseNameToMonitor = ""

            if ($launchMethod -eq "direct") {
                $exeForStartProcess = $processNameToManageExpanded
                $argsForStartProcess = $processArgumentsToPass
                try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) }
                catch { Write-UserLog "Error extracting base name from '$processNameToManageExpanded' (direct)." -L WARN; $processBaseNameToMonitor = "UnknownProcess" }
            } elseif ($launchMethod -eq "powershell") {
                $exeForStartProcess = "powershell.exe"
                $commandToRun = "& `"$processNameToManageExpanded`""
                if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) { $commandToRun += " $processArgumentsToPass" }
                $argsForStartProcess = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $commandToRun)
                try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) }
                catch { $processBaseNameToMonitor = "powershell" }
            } elseif ($launchMethod -eq "cmd") {
                $exeForStartProcess = "cmd.exe"
                $commandToRun = "/c `"$processNameToManageExpanded`""
                if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) { $commandToRun += " $processArgumentsToPass" }
                $argsForStartProcess = $commandToRun
                try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) }
                catch { $processBaseNameToMonitor = "cmd" }
            } else {
                Add-UserError "LaunchMethod '$launchMethod' not recognized. Options: direct, powershell, cmd."
                if ([string]::IsNullOrWhiteSpace($exeForStartProcess)) { throw "LaunchMethod not handled or ProcessName invalid." }
            }

            if ($launchMethod -ne "direct") {
                $interpreterPath = (Get-Command $exeForStartProcess -ErrorAction SilentlyContinue).Source
                if (-not (Test-Path -LiteralPath $interpreterPath -PathType Leaf)) {
                    Add-UserError "Interpreter '$exeForStartProcess' not found for LaunchMethod '$launchMethod'."
                    throw "Interpreter for LaunchMethod not found."
                }
            }

            $workingDir = ""
            if ($processNameIsFilePath) {
                try { $workingDir = Split-Path -Path $processNameToManageExpanded -Parent } catch {}
            } elseif ($launchMethod -ne "direct") {
                 $workingDir = $ScriptDir
                 Write-UserLog "ProcessName '$processNameToManageExpanded' is not a file path; WorkingDir='$ScriptDir' for '$launchMethod'." -L WARN
            }
            if (-not [string]::IsNullOrWhiteSpace($workingDir) -and (-not (Test-Path -LiteralPath $workingDir -PathType Container))) {
                Write-UserLog "Working directory '$workingDir' not found. WorkingDirectory not set." -L WARN
                $workingDir = ""
            }

            try {
                $currentUserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                $runningProcess = $null
                if (-not [string]::IsNullOrWhiteSpace($processBaseNameToMonitor)) {
                    Get-Process -Name $processBaseNameToMonitor -ErrorAction SilentlyContinue | ForEach-Object {
                        try {
                            $ownerInfo = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" | Select-Object -ExpandProperty @{Name="Owner"; Expression={ $_.GetProcessOwner() }} -ErrorAction SilentlyContinue
                            if ($ownerInfo -and $ownerInfo.SID -eq $currentUserSID) { $runningProcess = $_; break } # break exits ForEach-Object here
                        } catch {}
                    }
                } else { Write-UserLog "Base name of the process to monitor is empty." -L WARN }

                $startProcessSplat = @{ FilePath = $exeForStartProcess; ErrorAction = 'Stop' }
                if (($argsForStartProcess -is [array] -and $argsForStartProcess.Count -gt 0) -or
                    ($argsForStartProcess -is [string] -and -not [string]::IsNullOrWhiteSpace($argsForStartProcess))) {
                    $startProcessSplat.ArgumentList = $argsForStartProcess
                }
                if (-not [string]::IsNullOrWhiteSpace($workingDir)) { $startProcessSplat.WorkingDirectory = $workingDir }

                if ($runningProcess) {
                    Write-UserLog "Process '$processBaseNameToMonitor' (PID: $($runningProcess.Id)) is running. Stopping..."
                    $runningProcess | Stop-Process -Force -ErrorAction Stop
                    Add-UserAction "Process '$processBaseNameToMonitor' stopped."
                    $logArgsForRestart = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                    Write-UserLog "Restarting via $launchMethod : '$exeForStartProcess' with args: '$logArgsForRestart'"
                    Start-Process @startProcessSplat
                    Add-UserAction "Process '$processBaseNameToMonitor' restarted (via $launchMethod)."
                } else {
                    $logArgsForStart = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                    Write-UserLog "Process '$processBaseNameToMonitor' not found. Starting via $launchMethod : '$exeForStartProcess' with args: '$logArgsForStart'"
                    Start-Process @startProcessSplat
                    Add-UserAction "Process '$processBaseNameToMonitor' started (via $launchMethod)."
                }
            } catch {
                $logArgsCatch = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                Add-UserError "Failed to manage process '$processBaseNameToMonitor' (Method: $launchMethod, Path: '$exeForStartProcess', Args: '$logArgsCatch'): $($_.Exception.Message). StackTrace: $($_.ScriptStackTrace)"
            }
        } else {
            Add-UserError "Executable file for ProcessName '$processNameToManageExpanded' (direct mode) NOT FOUND."
        }
    } else {
        Write-UserLog -Message "No ProcessName specified in [Process] or raw path is empty."
    }

} catch {
    # Using $null -ne $Global:Config like in config_systeme.ps1
    if ($null -ne $Global:Config) {
        Add-UserError -Message "FATAL USER SCRIPT ERROR '$($env:USERNAME)': $($_.Exception.Message) `n$($_.ScriptStackTrace)"
    } else {
        $timestampError = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errorMsg = "$timestampError [FATAL SCRIPT USER ERROR - CONFIG NOT INITIALIZED/LOADED] - Error: $($_.Exception.Message) `nStackTrace: $($_.ScriptStackTrace)"
        try { Add-Content -Path (Join-Path $LogDirToUseUser "config_utilisateur_FATAL_ERROR.txt") -Value $errorMsg -ErrorAction SilentlyContinue } catch {}
        try { Add-Content -Path (Join-Path $ScriptDir "config_utilisateur_FATAL_ERROR_fallback.txt") -Value $errorMsg -ErrorAction SilentlyContinue } catch {}
        Write-Host $errorMsg -ForegroundColor Red
    }
} finally {
    # --- Gotify Notification ---
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]) -DefaultValue $false)) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"
        $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5

        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            Write-UserLog -Message "Preparing Gotify notification for the user script..."

            $titleSuccessTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessUser" -DefaultValue ("%COMPUTERNAME% %USERNAME% " + $ScriptIdentifierUser + " OK")
            $titleErrorTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorUser" -DefaultValue ("ERROR " + $ScriptIdentifierUser + " %USERNAME% on %COMPUTERNAME%")

            $finalMessageTitleUser = ""
            if ($Global:UserErreursRencontrees.Count -gt 0) {
                $finalMessageTitleUser = $titleErrorTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            } else {
                $finalMessageTitleUser = $titleSuccessTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            }

            #$messageBodyUser = "Script '$ScriptIdentifierUser' (Build: $ScriptInternalBuildUser) for $($env:USERNAME) on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n`n"
            #$messageBodyUser = "'$ScriptIdentifierUser' on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n`n"
            $messageBodyUser = "On $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').`n"
            if ($Global:UserActionsEffectuees.Count -gt 0) { $messageBodyUser += "USER Actions:`n" + ($Global:UserActionsEffectuees -join "`n") }
            else { $messageBodyUser += "No USER actions." }
            if ($Global:UserErreursRencontrees.Count -gt 0) { $messageBodyUser += "`n`nUSER Errors:`n" + ($Global:UserErreursRencontrees -join "`n") }

            $payloadUser = @{ message = $messageBodyUser; title = $finalMessageTitleUser; priority = $gotifyPriority } | ConvertTo-Json -Depth 3 -Compress
            $fullUrlUser = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"
            Write-UserLog -Message "Sending Gotify (user) to $fullUrlUser..."
            try { Invoke-RestMethod -Uri $fullUrlUser -Method Post -Body $payloadUser -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
                Write-UserLog -Message "Gotify (user) sent."
            } catch { Add-UserError "Gotify failure (IRM): $($_.Exception.Message)"; $curlUserPath=Get-Command curl -ErrorAction SilentlyContinue
                if ($curlUserPath) { Write-UserLog "Falling back to curl for Gotify (user)..."; $tempJsonFileUser = Join-Path $env:TEMP "gotify_user_$($PID)_$((Get-Random).ToString()).json"
                    try { $payloadUser|Out-File $tempJsonFileUser -Encoding UTF8 -ErrorAction Stop; $curlArgsUser="-s -k -X POST `"$fullUrlUser`" -H `"Content-Type: application/json`" -d `@`"$tempJsonFileUser`""
                        Invoke-Expression "curl $($curlArgsUser -join ' ')"|Out-Null; Write-UserLog "Gotify (user - curl) sent."
                    } catch { Add-UserError "Gotify failure (curl): $($_.Exception.Message)" }
                    finally { if (Test-Path $tempJsonFileUser) { Remove-Item $tempJsonFileUser -ErrorAction SilentlyContinue } }
                } else { Add-UserError "curl.exe not found for Gotify fallback (user)." }
            }
        } else { Add-UserError "Incomplete Gotify params for user script." }
    }

    Write-UserLog -Message "$ScriptIdentifierUser ($ScriptInternalBuildUser) for '$($env:USERNAME)' finished."
    if ($Global:UserErreursRencontrees.Count -gt 0) { Write-UserLog -Message "Some errors occurred." -Level WARN }
}