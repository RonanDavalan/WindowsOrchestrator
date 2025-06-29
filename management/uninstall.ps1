<#
.SYNOPSIS
    Uninstalls the scheduled tasks for the system and user configuration scripts.
.DESCRIPTION
    This script ensures it is run as an administrator (prompts if necessary).
    It deletes the scheduled tasks:
    - "AllSysConfig-SystemStartup" (created by install.ps1)
    - "AllSysConfig-UserLogon" (created by install.ps1)
    - "AllSys_SystemScheduledReboot" (created by config_systeme.ps1)
    - "AllSys_SystemPreRebootAction" (created by config_systeme.ps1)
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

# --- Configuration ---
function Write-StyledHost {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type.ToUpper()) {
        "INFO"{"Cyan"}; "SUCCESS"{"Green"}; "WARNING"{"Yellow"}; "ERROR"{"Red"}; default{"White"}
    }
    Write-Host "[$Type] " -ForegroundColor $color -NoNewline; Write-Host $Message
}

$OriginalErrorActionPreference = $ErrorActionPreference
# Set to SilentlyContinue for Get-ScheduledTask to not fail if a task does not exist.
# For Unregister-ScheduledTask, we will use -ErrorAction Stop inside a try/catch.
$ErrorActionPreference = "SilentlyContinue"

# Task names to delete
# Those created by install.ps1
$TaskNameSystemFromInstaller = "AllSysConfig-SystemStartup"
$TaskNameUserFromInstaller   = "AllSysConfig-UserLogon"
# Those created by config_systeme.ps1
$TaskNameSystemReboot = "AllSys_SystemScheduledReboot"
$TaskNameSystemPreReboot = "AllSys_SystemPreRebootAction"

$TasksToRemove = @(
    $TaskNameSystemFromInstaller,
    $TaskNameUserFromInstaller,
    $TaskNameSystemReboot,
    $TaskNameSystemPreReboot
)

Write-StyledHost "Starting removal of AllSysConfig scheduled tasks..." "INFO"
$anyTaskActionAttempted = $false
$tasksSuccessfullyRemoved = [System.Collections.Generic.List[string]]::new()
$tasksFoundButNotRemoved = [System.Collections.Generic.List[string]]::new()

foreach ($taskName in $TasksToRemove) {
    Write-StyledHost "Processing task '$taskName'..." -NoNewline
    $task = Get-ScheduledTask -TaskName $taskName # ErrorAction is SilentlyContinue globally

    if ($task) {
        $anyTaskActionAttempted = $true
        Write-Host " Found. Attempting to delete..." -ForegroundColor Cyan -NoNewline
        try {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
            # Re-check if it was actually deleted
            if (-not (Get-ScheduledTask -TaskName $taskName)) { # ErrorAction is SilentlyContinue globally
                Write-Host " Successfully deleted." -ForegroundColor Green
                $tasksSuccessfullyRemoved.Add($taskName)
            } else {
                Write-Host " Deletion FAILED (task '$taskName' still exists after attempt)." -ForegroundColor Red
                $tasksFoundButNotRemoved.Add($taskName)
            }
        } catch {
            Write-Host " ERROR during deletion attempt for '$taskName'." -ForegroundColor Red
            Write-StyledHost "   Error detail: $($_.Exception.Message)" "ERROR"
            $tasksFoundButNotRemoved.Add($taskName)
        }
    } else {
        Write-Host " Not found." -ForegroundColor Yellow
    }
}

Write-Host "`n"
if ($tasksSuccessfullyRemoved.Count -gt 0) {
    Write-StyledHost "Uninstallation complete. Tasks successfully removed: $($tasksSuccessfullyRemoved -join ', ')" "SUCCESS"
}

if ($tasksFoundButNotRemoved.Count -gt 0) {
    Write-StyledHost "Some tasks were found but could NOT be removed: $($tasksFoundButNotRemoved -join ', ')." "ERROR"
    Write-StyledHost "Please check the Task Scheduler and the error messages above." "ERROR"
}

if (-not $anyTaskActionAttempted -and $tasksSuccessfullyRemoved.Count -eq 0) { # If no task was found to be processed
    Write-StyledHost "None of the specified AllSysConfig tasks were found." "INFO"
}

Write-StyledHost "Note: Scripts and configuration files are not deleted by this script." "INFO"

$ErrorActionPreference = $OriginalErrorActionPrefe