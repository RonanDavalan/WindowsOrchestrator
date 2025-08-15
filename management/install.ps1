param()

<#
.SYNOPSIS
    Installe et configure les tâches planifiées pour les scripts de configuration système et utilisateur.
.DESCRIPTION
    Ce script s'assure d'être exécuté en tant qu'administrateur et utilise la méthode de chargement de langue
    qui a été prouvée fonctionnelle.
.NOTES
    Auteur: Ronan Davalan & Gemini
    Version: i18n - Logique de chargement Corrigée
#>

# --- Internationalization (i18n) ---
$lang = @{}
try {
    # Définition des chemins de base
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition } 
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path
    
    # Détection automatique et exclusive de la culture du système.
    $cultureName = (Get-Culture).Name

    # Construction du chemin vers le fichier de langue
    $langFilePath = Join-Path $projectRoot "i18n\$cultureName\strings.psd1"
    if (-not (Test-Path $langFilePath)) { 
        # Si le fichier de la langue système n'existe pas, on se rabat sur l'anglais.
        $langFilePath = Join-Path $projectRoot "i18n\en-US\strings.psd1" 
    }

    # Chargement du fichier de langue
    if (Test-Path $langFilePath) {
        $langContent = Get-Content -Path $langFilePath -Raw -Encoding UTF8
        $lang = Invoke-Expression $langContent
    } else { 
        # Erreur si même le fichier anglais est introuvable
        throw "Aucun fichier de langue valide trouvé, y compris le fichier de secours en-US." 
    }

    # Vérification que le fichier chargé n'est pas vide
    if ($null -eq $lang -or $lang.Count -eq 0) { 
        throw "Le fichier de langue '$langFilePath' est vide ou invalide." 
    }

} catch {
    # Ce bloc s'exécute si une des étapes ci-dessus échoue
    Write-Error "FATAL ERROR: Could not load language files. Details: $($_.Exception.Message)"
    Read-Host "Press Enter to exit."
    exit 1
}

# --- Bloc d'auto-élévation ---
$currentUserPrincipal = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $currentUserPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -ErrorAction Stop
    } catch {
        Write-Warning $lang.Install_ElevationWarning
        Read-Host $lang.Install_PressEnterToExit
    }
    exit
}


# --- Configuration et Vérifications Préliminaires ---
function Write-StyledHost {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type.ToUpper()) { "INFO"{"Cyan"}; "SUCCESS"{"Green"}; "WARNING"{"Yellow"}; "ERROR"{"Red"}; default{"White"} }
    Write-Host "[$Type] " -ForegroundColor $color -NoNewline; Write-Host $Message
}

$OriginalErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"
$errorOccurredInScript = $false

try {
    $InstallerScriptDir = $PSScriptRoot
    $ProjectRootDir = $projectRoot

    if (-not (Test-Path (Join-Path $ProjectRootDir "config.ini"))) {
        throw ($lang.Install_InvalidProjectRootError -f $ProjectRootDir)
    }
    
    $SystemScriptPath = Join-Path $ProjectRootDir "config_systeme.ps1"
    $UserScriptPath   = Join-Path $ProjectRootDir "config_utilisateur.ps1"
    
    $TaskNameSystem = "WindowsAutoConfig-SystemStartup"
    $TaskNameUser   = "WindowsAutoConfig-UserLogon"

    Write-StyledHost ($lang.Install_ProjectRootUsed -f $ProjectRootDir) "INFO"
}
catch {
    Write-StyledHost ($lang.Install_PathDeterminationError -f $_.Exception.Message) "ERROR"
    $ErrorActionPreference = "Continue"
    Read-Host $lang.Install_PressEnterToExit
    exit 1
}

$filesMissing = $false
if (-not (Test-Path $SystemScriptPath)) { Write-StyledHost ($lang.Install_MissingSystemFile -f $SystemScriptPath) "ERROR"; $filesMissing = $true }
if (-not (Test-Path $UserScriptPath))   { Write-StyledHost ($lang.Install_MissingUserFile -f $UserScriptPath) "ERROR"; $filesMissing = $true }

if ($filesMissing) {
    Read-Host ($lang.Install_MissingFilesAborted -f $ProjectRootDir)
    exit 1
}

$TargetUserForUserTask = "$($env:USERDOMAIN)\$($env:USERNAME)"
Write-StyledHost ($lang.Install_UserTaskTarget -f $TargetUserForUserTask) "INFO"

# --- Début de l'Installation ---
Write-StyledHost $lang.Install_StartConfiguringTasks "INFO"

# --- Préparation des arguments pour les tâches en fonction de la langue ---
# La variable $cultureName (ex: "fr-FR") est déjà définie par le bloc i18n en début de script.
# Nous l'injectons directement dans la commande pour forcer la culture de la tâche planifiée.
$finalArgumentSystem = "-NoProfile -ExecutionPolicy Bypass -Command `"& { [System.Threading.Thread]::CurrentThread.CurrentUICulture = '$cultureName'; . '$SystemScriptPath' }`""
$finalArgumentUser = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"& { [System.Threading.Thread]::CurrentThread.CurrentUICulture = '$cultureName'; . '$UserScriptPath' }`""
# --- Fin de la préparation ---

try {
    # Tâche 1: Script Système
    Write-StyledHost ($lang.Install_CreatingSystemTask -f $TaskNameSystem) "INFO"
    $ActionSystem = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $finalArgumentSystem -WorkingDirectory $ProjectRootDir
    $TriggerSystem = New-ScheduledTaskTrigger -AtStartup
    $PrincipalSystem = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
    $SettingsSystem = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    Register-ScheduledTask -TaskName $TaskNameSystem -Action $ActionSystem -Trigger $TriggerSystem -Principal $PrincipalSystem -Settings $SettingsSystem -Description $lang.Install_SystemTaskDescription -Force
    Write-StyledHost ($lang.Install_SystemTaskConfiguredSuccess -f $TaskNameSystem) "SUCCESS"

    # Tâche 2: Script Utilisateur
    Write-StyledHost ($lang.Install_CreatingUserTask -f $TaskNameUser, $TargetUserForUserTask) "INFO"
    $ActionUser = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $finalArgumentUser -WorkingDirectory $ProjectRootDir
    $TriggerUser = New-ScheduledTaskTrigger -AtLogOn -User $TargetUserForUserTask
    $PrincipalUser = New-ScheduledTaskPrincipal -UserId $TargetUserForUserTask -LogonType Interactive
    $SettingsUser = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)
    Register-ScheduledTask -TaskName $TaskNameUser -Action $ActionUser -Trigger $TriggerUser -Principal $PrincipalUser -Settings $SettingsUser -Description $lang.Install_UserTaskDescription -Force
    Write-StyledHost ($lang.Install_SystemTaskConfiguredSuccess -f $TaskNameUser) "SUCCESS"

    Write-Host "`n"
    Write-StyledHost $lang.Install_MainTasksConfigured "INFO"
    Write-StyledHost ($lang.Install_DailyRebootTasksNote -f 'config_systeme.ps1') "INFO"

    # --- Lancement initial des scripts de configuration ---
    Write-Host "`n"
    Write-StyledHost $lang.Install_AttemptingInitialLaunch "INFO"

    # Lancer config_systeme.ps1
    try {
        Write-StyledHost $lang.Install_ExecutingSystemScript "INFO"
        $processSystem = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$SystemScriptPath`"" -WorkingDirectory $ProjectRootDir -Wait -PassThru -ErrorAction Stop
        if ($processSystem.ExitCode -eq 0) {
            Write-StyledHost $lang.Install_SystemScriptSuccess "SUCCESS"
        } else {
            Write-StyledHost ($lang.Install_SystemScriptWarning -f $processSystem.ExitCode, $ProjectRootDir) "WARNING"
            $errorOccurredInScript = $true
        }
    } catch {
        Write-StyledHost ($lang.Install_SystemScriptError -f $_.Exception.Message) "ERROR"
        Write-StyledHost ($lang.Install_Trace -f $_.ScriptStackTrace) "ERROR"
        $errorOccurredInScript = $true
    }

    # Lancer config_utilisateur.ps1
    if (-not $errorOccurredInScript) {
        try {
            Write-StyledHost ($lang.Install_ExecutingUserScript -f $TargetUserForUserTask) "INFO"
            $processUser = Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$UserScriptPath`"" -WorkingDirectory $ProjectRootDir -Wait -PassThru -ErrorAction Stop
            if ($processUser.ExitCode -eq 0) {
                Write-StyledHost ($lang.Install_UserScriptSuccess -f $TargetUserForUserTask) "SUCCESS"
            } else {
                Write-StyledHost ($lang.Install_UserScriptWarning -f $TargetUserForUserTask, $processUser.ExitCode, $ProjectRootDir) "WARNING"
            }
        } catch {
            Write-StyledHost ($lang.Install_UserScriptError -f $TargetUserForUserTask, $_.Exception.Message) "ERROR"
            Write-StyledHost ($lang.Install_Trace -f $_.ScriptStackTrace) "ERROR"
            $errorOccurredInScript = $true
        }
    }

    Write-Host "`n"
    if (-not $errorOccurredInScript) {
        Write-StyledHost $lang.Install_InstallationCompleteSuccess "SUCCESS"
    } else {
        Write-StyledHost $lang.Install_InstallationCompleteWithErrors "WARNING"
    }

}
catch {
    Write-StyledHost ($lang.Install_CriticalErrorDuringInstallation -f $_.Exception.Message) "ERROR"
    Write-StyledHost ($lang.Install_Trace -f $_.ScriptStackTrace) "ERROR"
}
finally {
    $ErrorActionPreference = $OriginalErrorActionPreference
    Write-Host "`n"; Read-Host $lang.Install_PressEnterToClose
}