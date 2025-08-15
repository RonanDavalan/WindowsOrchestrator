param(
    # Accepte un argument de langue optionnel pour forcer l'affichage
    [string]$LanguageOverride = ""
)

<#
.SYNOPSIS
    Désinstalle les tâches planifiées et restaure les paramètres système modifiés par WindowsAutoConfig.
.DESCRIPTION
    Ce script gère sa propre élévation de privilèges tout en préservant l'argument de langue.
.NOTES
    Auteur: Ronan Davalan & Gemini
    Version: i18n - Logique d'élévation Corrigée et Finalisée
#>

# --- Bloc d'auto-élévation des privilèges (Robuste) ---
$currentUserPrincipal = New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $currentUserPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Prépare les arguments pour le nouveau processus élevé
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    # Ajoute l'argument de langue SEULEMENT s'il a été fourni
    if (-not [string]::IsNullOrWhiteSpace($LanguageOverride)) {
        $arguments += " -LanguageOverride '$($LanguageOverride)'"
    }
    
    # Relance le script avec les droits admin et les arguments, puis quitte la session actuelle
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -ErrorAction Stop
    } catch {
        # Affiche une erreur basique au cas où le chargement de la langue échouerait
        Write-Warning "Elevation failed. Please run this script as an administrator."
        Read-Host "Press Enter to exit."
    }
    exit
}

# --- Internationalization (i18n) ---
# Ce bloc s'exécute maintenant avec la certitude que le script est élevé.
$lang = @{}
try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }
    
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path
    
    # Détection automatique et exclusive de la culture du système
	$cultureName = (Get-Culture).Name	

    $langFilePath = Join-Path $projectRoot "i18n\$cultureName\strings.psd1"
    if (-not (Test-Path $langFilePath)) { $langFilePath = Join-Path $projectRoot "i18n\en-US\strings.psd1" }

    if (Test-Path $langFilePath) {
        $langContent = Get-Content -Path $langFilePath -Raw -Encoding UTF8
        $lang = Invoke-Expression $langContent
    } else { throw "No valid language file found." }

    if ($null -eq $lang -or $lang.Count -eq 0) { throw "Language file '$langFilePath' is empty or invalid." }

} catch {
    Write-Error "FATAL ERROR: Could not load language files. Uninstallation cannot continue safely. Details: $($_.Exception.Message)"
    Read-Host "Press Enter to exit."
    exit 1
}

# --- Configuration et Fonctions ---
function Write-StyledHost {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type.ToUpper()) {
        "INFO"{"Cyan"}; "SUCCESS"{"Green"}; "WARNING"{"Yellow"}; "ERROR"{"Red"}; default{"White"}
    }
    Write-Host "[$Type] " -ForegroundColor $color -NoNewline; Write-Host $Message
}

$OriginalErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

# --- Début de la Désinstallation ---
Write-StyledHost $lang.Uninstall_StartMessage "INFO"
Write-Host ""

# --- Étape 1: Interaction avec l'utilisateur pour l'Auto-Logon ---
$disableAutoLogonChoice = Read-Host -Prompt $lang.Uninstall_AutoLogonQuestion
$shouldDisableAutoLogon = if ($disableAutoLogonChoice.Trim().ToLower() -eq 'o' -or $disableAutoLogonChoice.Trim().ToLower() -eq 'y') { $true } else { $false }
Write-Host ""


# --- Étape 2: Restauration des paramètres système ---
Write-StyledHost $lang.Uninstall_RestoringSettings "INFO"

# Réactiver Windows Update
try {
    $windowsUpdatePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $windowsUpdateService = "wuauserv"
    if (Test-Path $windowsUpdatePolicyKey) {
        Set-ItemProperty $windowsUpdatePolicyKey NoAutoUpdate 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty $windowsUpdatePolicyKey NoAutoRebootWithLoggedOnUsers 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Get-Service $windowsUpdateService -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic -ErrorAction SilentlyContinue
    Write-StyledHost $lang.Uninstall_WindowsUpdateReactivated "SUCCESS"
} catch {
    Write-StyledHost ($lang.Uninstall_WindowsUpdateError -f $_.Exception.Message) "ERROR"
}

# Réactiver le Démarrage Rapide (Fast Startup)
try {
    $powerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if (Test-Path $powerRegPath) {
        Set-ItemProperty $powerRegPath HiberbootEnabled 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-StyledHost $lang.Uninstall_FastStartupReactivated "SUCCESS"
} catch {
    Write-StyledHost ($lang.Uninstall_FastStartupError -f $_.Exception.Message) "ERROR"
}

# Réactiver OneDrive
try {
    $oneDrivePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if (Test-Path $oneDrivePolicyKey) {
        if (Get-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Force -ErrorAction SilentlyContinue
        }
    }
    Write-StyledHost $lang.Uninstall_OneDriveReactivated "SUCCESS"
} catch {
    Write-StyledHost ($lang.Uninstall_OneDriveError -f $_.Exception.Message) "ERROR"
}

# Gérer l'Auto-Logon selon le choix de l'utilisateur
if ($shouldDisableAutoLogon) {
    try {
        $winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Set-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -Value "0" -Type String -Force -ErrorAction SilentlyContinue
        Write-StyledHost $lang.Uninstall_AutoLogonDisabled "SUCCESS"
    } catch {
        Write-StyledHost ($lang.Uninstall_AutoLogonDisableError -f $_.Exception.Message) "ERROR"
    }
} else {
    Write-StyledHost $lang.Uninstall_AutoLogonLeftAsIs "INFO"
}
Write-Host ""


# --- Étape 3: Suppression des Tâches Planifiées ---
Write-StyledHost $lang.Uninstall_DeletingScheduledTasks "INFO"

$TasksToRemove = @(
    "WindowsAutoConfig-SystemStartup",
    "WindowsAutoConfig-UserLogon",
    "WindowsAutoConfig-SystemScheduledReboot",
    "WindowsAutoConfig-SystemPreRebootAction"
)
$tasksFoundButNotRemoved = [System.Collections.Generic.List[string]]::new()

foreach ($taskName in $TasksToRemove) {
    Write-StyledHost ($lang.Uninstall_ProcessingTask -f $taskName) -NoNewline
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($task) {
        Write-Host $lang.Uninstall_TaskFoundAttemptingDeletion -ForegroundColor Cyan -NoNewline
        try {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
            if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
                Write-Host $lang.Uninstall_TaskSuccessfullyRemoved -ForegroundColor Green
            } else {
                Write-Host $lang.Uninstall_TaskDeletionFailed -ForegroundColor Red
                $tasksFoundButNotRemoved.Add($taskName)
            }
        } catch {
            Write-Host $lang.Uninstall_TaskDeletionError -ForegroundColor Red
            Write-StyledHost ($lang.Uninstall_TaskErrorDetail -f $_.Exception.Message) "ERROR"
            $tasksFoundButNotRemoved.Add($taskName)
        }
    } else {
        Write-Host $lang.Uninstall_TaskNotFound -ForegroundColor Yellow
    }
}
Write-Host ""


# --- Résumé Final ---
Write-StyledHost $lang.Uninstall_CompletionMessage "SUCCESS"
if ($tasksFoundButNotRemoved.Count -gt 0) {
    Write-StyledHost ($lang.Uninstall_TasksNotRemovedWarning -f ($tasksFoundButNotRemoved -join ', ')) "ERROR"
    Write-StyledHost $lang.Uninstall_CheckTaskScheduler "ERROR"
}
Write-StyledHost $lang.Uninstall_FilesNotDeletedNote "INFO"

$ErrorActionPreference = $OriginalErrorActionPreference
Write-Host ""
Read-Host $lang.Uninstall_PressEnterToClose