<#
.SYNOPSIS
    Installs and configures scheduled tasks for the system and user configuration scripts.
.DESCRIPTION
    This script ensures it is run as an administrator (prompts if necessary).
    It creates two scheduled tasks:
    1. "AllSysConfig-SystemStartup" which runs config_systeme.ps1 at startup.
    2. "AllSysConfig-UserLogon" which runs config_utilisateur.ps1 at logon.
    At the end of the installation, it attempts to run the config_systeme.ps1 and config_utilisateur.ps1 scripts for the first time.
.NOTES
    Author: Ronan Davalan & Gemini 2.5-pro
    Version: See the project's global configuration (config.ini or documentation)
#>

# --- Self-Elevation Privilege Block ---
$currentUserPrincipal = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $currentUserPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -ErrorAction Stop
    } catch {
        Write-Warning "Failed to elevate privileges. Please run this script as an administrator."
        Read-Host "Press Enter to exit."
    }
    exit
}

# --- Preliminary Configuration and Checks ---
function Write-StyledHost {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type.ToUpper()) {
        "INFO"{"Cyan"}; "SUCCESS"{"Green"}; "WARNING"{"Yellow"}; "ERROR"{"Red"}; default{"White"}
    }
    Write-Host "[$Type] " -ForegroundColor $color -NoNewline; Write-Host $Message
}

$OriginalErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"
$errorOccurredInScript = $false

try {
    # Determine the current script directory (.../management) and go up to the project root directory
    $InstallerScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $ProjectRootDir = Split-Path -Parent $InstallerScriptDir

    # Validate that $ProjectRootDir is plausible (e.g., contains config.ini)
    if (-not (Test-Path (Join-Path $ProjectRootDir "config.ini"))) {
        Write-StyledHost "config.ini not found in the presumed parent directory ($ProjectRootDir)." "WARNING"
        $ProjectRootDirFromUser = Read-Host "Please enter the full path to the AllSysConfig scripts root directory (e.g., C:\AllSysConfig)"
        if ([string]::IsNullOrWhiteSpace($ProjectRootDirFromUser) -or -not (Test-Path $ProjectRootDirFromUser -PathType Container) -or -not (Test-Path (Join-Path $ProjectRootDirFromUser "config.ini"))) {
            throw "Invalid project root directory or config.ini not found: '$ProjectRootDirFromUser'"
        }
        $ProjectRootDir = $ProjectRootDirFromUser.TrimEnd('\')
    }
    # Ensure there is no trailing slash for consistency
    $ProjectRootDir = $ProjectRootDir.TrimEnd('\')

    $SystemScriptPath = Join-Path $ProjectRootDir "config_systeme.ps1"
    $UserScriptPath   = Join-Path $ProjectRootDir "config_utilisateur.ps1"
    # Already checked implicitly above
    $ConfigIniPath    = Join-Path $ProjectRootDir "config.ini"

    # FIXED Task Names
    $TaskNameSystem = "AllSysConfig-SystemStartup"
    $TaskNameUser   = "AllSysConfig-UserLogon"

    Write-StyledHost "Project root directory in use: $ProjectRootDir" "INFO"
}
catch {
    Write-StyledHost "Error while determining initial paths: $($_.Exception.Message)" "ERROR"
    # $ErrorActionPreference is "Stop", so the script stops here.
    # We reset the error preference for Read-Host if we reach the finally block.
    $ErrorActionPreference = "Continue"
    Read-Host "Press Enter to exit."
    exit 1
}

$filesMissing = $false
if (-not (Test-Path $SystemScriptPath)) { Write-StyledHost "Required system file missing: $SystemScriptPath" "ERROR"; $filesMissing = $true }
if (-not (Test-Path $UserScriptPath))   { Write-StyledHost "Required user file missing: $UserScriptPath" "ERROR"; $filesMissing = $true }
# config.ini has already been checked

if ($filesMissing) {
    Read-Host "Some main script files are missing in '$ProjectRootDir'. Installation cancelled. Press Enter to exit."
    exit 1
}

# Target user for the user task (the user running this installation script)
# and who provided the admin rights.
$TargetUserForUserTask = "$($env:USERDOMAIN)\$($env:USERNAME)"
Write-StyledHost "The user task will be installed for: $TargetUserForUserTask" "INFO"

# --- Beginning Installation ---
Write-StyledHost "Starting scheduled tasks configuration..." "INFO"
try {
    # Task 1: System Script
    Write-StyledHost "Creating/Updating system task '$TaskNameSystem'..." "INFO"
    $ActionSystem = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$SystemScriptPath`"" -WorkingDirectory $ProjectRootDir
    $TriggerSystem = New-ScheduledTaskTrigger -AtStartup
    $PrincipalSystem = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
    $SettingsSystem = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    Register-ScheduledTask -TaskName $TaskNameSystem -Action $ActionSystem -Trigger $TriggerSystem -Principal $PrincipalSystem -Settings $SettingsSystem -Description "AllSysConfig: Runs the system configuration script at startup." -Force
    Write-StyledHost "Task '$TaskNameSystem' configured successfully." "SUCCESS"

    # Task 2: User Script
    Write-StyledHost "Creating/Updating user task '$TaskNameUser' for '$TargetUserForUserTask'..." "INFO"
    $ActionUser = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$UserScriptPath`"" -WorkingDirectory $ProjectRootDir
    $TriggerUser = New-ScheduledTaskTrigger -AtLogOn -User $TargetUserForUserTask
    $PrincipalUser = New-ScheduledTaskPrincipal -UserId $TargetUserForUserTask -LogonType Interactive
    $SettingsUser = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)
    Register-ScheduledTask -TaskName $TaskNameUser -Action $ActionUser -Trigger $TriggerUser -Principal $PrincipalUser -Settings $SettingsUser -Description "AllSysConfig: Runs the user configuration script at logon." -Force
    Write-StyledHost "Task '$TaskNameUser' configured successfully." "SUCCESS"

    Write-Host "`n"
    Write-StyledHost "Main scheduled tasks configured." "INFO"
    Write-StyledHost "The tasks for the daily reboot ('AllSys_SystemScheduledReboot') and the pre-reboot action ('AllSys_SystemPreRebootAction') will be created/managed by '$SystemScriptPath' during its execution." "INFO"

    # --- Initial Launch of Configuration Scripts ---
    Write-Host "`n"
    Write-StyledHost "Attempting initial launch of configuration scripts..." "INFO"

    # Launch config_systeme.ps1
    try {
        Write-StyledHost "Running config_systeme.ps1 to apply initial system configurations..." "INFO"
        $processSystem = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$SystemScriptPath`"" -WorkingDirectory $ProjectRootDir -Wait -PassThru -ErrorAction Stop
        if ($processSystem.ExitCode -eq 0) {
            Write-StyledHost "config_systeme.ps1 executed successfully (exit code 0)." "SUCCESS"
        } else {
            Write-StyledHost "config_systeme.ps1 finished with an exit code: $($processSystem.ExitCode). Check the logs in '$ProjectRootDir\Logs'." "WARNING"
        }
    } catch {
        Write-StyledHost "Error during the initial execution of config_systeme.ps1: $($_.Exception.Message)" "ERROR"
        Write-StyledHost "Trace: $($_.ScriptStackTrace)" "ERROR"
        $errorOccurredInScript = $true
    }

    # Launch config_utilisateur.ps1
    # Runs in the context of the user who launched install.ps1 (and who elevated privileges)
    # This user is $TargetUserForUserTask
    # Do not attempt if an error has already occurred
    if (-not $errorOccurredInScript) {
        try {
            Write-StyledHost "Running config_utilisateur.ps1 for '$TargetUserForUserTask' to apply initial user configurations..." "INFO"
            $processUser = Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$UserScriptPath`"" -WorkingDirectory $ProjectRootDir -Wait -PassThru -ErrorAction Stop
            if ($processUser.ExitCode -eq 0) {
                Write-StyledHost "config_utilisateur.ps1 executed successfully for '$TargetUserForUserTask' (exit code 0)." "SUCCESS"
            } else {
                Write-StyledHost "config_utilisateur.ps1 for '$TargetUserForUserTask' finished with an exit code: $($processUser.ExitCode). Check the logs in '$ProjectRootDir\Logs'." "WARNING"
            }
        } catch {
            Write-StyledHost "Error during the initial execution of config_utilisateur.ps1 for '$TargetUserForUserTask': $($_.Exception.Message)" "ERROR"
            Write-StyledHost "Trace: $($_.ScriptStackTrace)" "ERROR"
            $errorOccurredInScript = $true
        }
    }

    Write-Host "`n"
    if (-not $errorOccurredInScript) {
        Write-StyledHost "Installation and initial launch completed!" "SUCCESS"
    } else {
        Write-StyledHost "Installation completed with errors during the initial script launch. Check the messages above." "WARNING"
    }

}
catch {
    Write-StyledHost "A critical error occurred during installation: $($_.Exception.Message)" "ERROR"
    Write-StyledHost "Trace: $($_.ScriptStackTrace)" "ERROR"
}
finally {
    $ErrorActionPreference = $OriginalErrorActionPreference
    Write-Host "`n"; Read-Host "Press Enter to close this window."
}