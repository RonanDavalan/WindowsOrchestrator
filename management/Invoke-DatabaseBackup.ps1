#Requires -Version 5.1

<#
.SYNOPSIS
    Script de sauvegarde de base de données pour l'orchestrateur de pré-redémarrage.
.DESCRIPTION
    Ce script effectue la sauvegarde des fichiers de base de données modifiés récemment.
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

# --- Initialisation de l'Environnement ---
try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
    else { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path }
    $ProjectRootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path

    $modulePath = Join-Path $PSScriptRoot "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"
    Import-Module $modulePath -Force

    $Global:lang = Set-OrchestratorLanguage -ScriptRoot $PSScriptRoot
    $Global:Config = Get-IniContent -FilePath (Join-Path $ProjectRootDir "config.ini")
    if (-not $Global:Config) { throw $Global:lang.Backup_ConfigLoadError }

    # --- LIGNES À AJOUTER ---
    $TargetLogDir = Join-Path -Path $ProjectRootDir -ChildPath "Logs"
    if (-not (Test-Path $TargetLogDir -PathType Container)) { New-Item -Path $TargetLogDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null }
    $Global:LogFile = Join-Path -Path $TargetLogDir -ChildPath "Invoke-DatabaseBackup_log.txt"
    $Global:ActionsEffectuees = [System.Collections.Generic.List[string]]::new()
    $Global:ErreursRencontrees = [System.Collections.Generic.List[string]]::new()
    # --- FIN DES LIGNES À AJOUTER ---

} catch {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = Join-Path $env:TEMP "PreReboot_FATAL_INIT.log"
    Add-Content -Path $logPath -Value "$ts - $($Global:lang.Backup_InitError -f $_.Exception.Message)" -Encoding UTF8
    exit 1
}

# --- Étape : Lancement de la sauvegarde de la base de données ---
function Invoke-DatabaseBackup {
    Write-Log -DefaultMessage "Starting database backup process..." -MessageId "Log_Backup_Starting"

    if (-not (Get-ConfigValue -Section "DatabaseBackup" -Key "EnableBackup" -Type ([bool]) -DefaultValue $false)) {
        Write-Log -DefaultMessage "Backup is disabled in configuration. Step skipped."
        return
    }

    # --- WATCHDOG v1.73 : Surveillance Active ---
    $processToMonitor = $Global:Config['Process']['ProcessToMonitor']
    $monitorInterval = Get-ConfigValue -Section "Process" -Key "MonitorCheckInterval" -Type ([int]) -DefaultValue 10
    $monitorTimeout = Get-ConfigValue -Section "Process" -Key "MonitorTimeout" -Type ([int]) -DefaultValue 300
    $forceKill = Get-ConfigValue -Section "Process" -Key "ForceKillOnTimeout" -Type ([bool]) -DefaultValue $false
    $elapsed = 0

    if (-not [string]::IsNullOrWhiteSpace($processToMonitor)) {
        $processActive = Get-Process -Name $processToMonitor -ErrorAction SilentlyContinue
        if ($processActive) {
            Write-Log -DefaultMessage "Watchdog monitoring started for process '{0}' (Interval: {1}s, Timeout: {2}s)." -MessageId "Log_Backup_WatcherStarted" -MessageArgs $processToMonitor, $monitorInterval, $monitorTimeout

            while ($processActive) {
                if ($elapsed -ge $monitorTimeout) {
                    if ($forceKill) {
                        Stop-Process -Name $processToMonitor -Force -ErrorAction SilentlyContinue
                        Write-Log -DefaultMessage "Process '{0}' killed after timeout ({1}s)." -MessageId "Log_Backup_TimeoutKill" -MessageArgs $processToMonitor, $monitorTimeout -Level WARN
                        break
                    } else {
                        Add-Error -DefaultErrorMessage "Process '{0}' still running after timeout ({1}s). Backup aborted." -ErrorId "Error_Backup_TimeoutNoKill" -ErrorArgs $processToMonitor, $monitorTimeout
                        exit 1 # Arrêt d'urgence
                    }
                }
                Start-Sleep -Seconds $monitorInterval
                $elapsed += $monitorInterval
                $processActive = Get-Process -Name $processToMonitor -ErrorAction SilentlyContinue
            }
            Write-Log -DefaultMessage "Process '{0}' closed successfully." -MessageId "Log_Backup_ProcessClosed" -MessageArgs $processToMonitor
        }
    }

    $sourcePath = $Global:Config['DatabaseBackup']['DatabaseSourcePath']
    $destinationPath = $Global:Config['DatabaseBackup']['DatabaseDestinationPath']

    if (-not ([System.IO.Path]::IsPathRooted($sourcePath))) { $sourcePath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRootDir $sourcePath)) }
    if (-not ([System.IO.Path]::IsPathRooted($destinationPath))) { $destinationPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRootDir $destinationPath)) }

    if (-not (Test-Path -Path $sourcePath)) { Add-Error -DefaultErrorMessage "The backup source or destination path '{0}' was not found. Backup operation cancelled." -ErrorId "Error_Backup_PathNotFound" -ErrorArgs $sourcePath; return }
    if (-not (Test-Path -Path $destinationPath)) { New-Item -Path $destinationPath -ItemType Directory | Out-Null; Add-Action -DefaultActionMessage "Backup destination folder '{0}' did not exist and was created." -ActionId "Action_Backup_DestinationCreated" -ActionArgs $destinationPath }

    # --- Étape : Purge des anciennes sauvegardes ---
    Write-Log -DefaultMessage "Starting cleanup of old backups (> 30 days)..." -MessageId "Log_Backup_PurgeStarting"
    try {
        $keepDays = 30 # Valeur par défaut de sécurité
        if ($Global:Config['DatabaseBackup'].ContainsKey('DatabaseKeepDays') -and $Global:Config['DatabaseBackup']['DatabaseKeepDays'] -match '^\d+$') {
            $keepDays = [int]$Global:Config['DatabaseBackup']['DatabaseKeepDays']
        }
        Write-Log -DefaultMessage "Retention policy: {0} day(s)." -MessageId "Log_Backup_RetentionPolicy" -MessageArgs $keepDays
        $oldBackups = Get-ChildItem -Path $destinationPath -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$keepDays) }
        if ($oldBackups.Count -gt 0) {
            foreach ($backupFile in $oldBackups) {
                Write-Log -DefaultMessage "Purging old backup file: {0}." -MessageId "Log_Backup_PurgingFile" -MessageArgs $backupFile.Name
                Remove-Item -LiteralPath $backupFile.FullName -Force
            }
            Add-Action -DefaultActionMessage "Cleanup of {0} old backup(s) completed." -ActionId "Action_Backup_PurgeCompleted" -ActionArgs $oldBackups.Count
        } else {
            Write-Log -DefaultMessage "No old backups to clean up." -MessageId "Log_Backup_NoFilesToPurge"
        }
    } catch {
        Add-Error -DefaultErrorMessage "Error during old backup cleanup: {0}" -ErrorId "Error_Backup_PurgeFailed" -ErrorArgs $_.Exception.Message
    }

    # CORRECTIF DE ROBUSTESSE: Remplacement de -Exclude par un filtrage sur le chemin complet pour fiabiliser l'exclusion.
    $recentFiles = Get-ChildItem -Path $sourcePath -File -Recurse | Where-Object { 
        ($_.FullName -notlike "$destinationPath\*") -and ($_.LastWriteTime -gt (Get-Date).AddHours(-24))
    }

    if ($recentFiles.Count -eq 0) { Write-Log -DefaultMessage "No database files modified in the last 24 hours were found to back up." -MessageId "Log_Backup_NoFilesFound"; return }

    $baseNamesToBackup = $recentFiles | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) } | Get-Unique
    $allSourceFiles = Get-ChildItem -Path $sourcePath -File -Recurse | Where-Object { 
        $_.FullName -notlike "$destinationPath\*"
    }
    $filesToCopy = $allSourceFiles | Where-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -in $baseNamesToBackup }

    Write-Log -DefaultMessage "Found {0} files to be backed up (including paired files)." -MessageId "Log_Backup_FilesFound" -MessageArgs $filesToCopy.Count
    $timestamp = Get-Date -Format "yyyy-MM-dd"
    foreach ($file in $filesToCopy) {
        try {
            $destinationFileName = "$($file.BaseName)_$($timestamp)$($file.Extension)"
            $fullDestinationPath = Join-Path -Path $destinationPath -ChildPath $destinationFileName
            Copy-Item -LiteralPath $file.FullName -Destination $fullDestinationPath -Force -ErrorAction Stop
            Write-Log -DefaultMessage "Successfully backed up '{0}' to '{1}'." -MessageId "Log_Backup_CopyingFile" -MessageArgs $file.Name, $destinationFileName
        } catch {
            Add-Error -DefaultErrorMessage "Error copying '{0}': {1}" -ErrorId "Error_Backup_CopyFailed" -ErrorArgs $file.Name, $_.Exception.Message
        }
    }
    Add-Action -DefaultActionMessage "Backup of {0} file(s) completed." -ActionId "Action_Backup_Completed" -ActionArgs $filesToCopy.Count

}

# --- Enchaînement Système v1.73 (Domino Effect) ---
$enableReboot = Get-ConfigValue -Section "Process" -Key "EnableScheduledReboot" -Type ([bool]) -DefaultValue $true
$scheduledRebootTime = Get-ConfigValue -Section "Process" -Key "ScheduledRebootTime"

if ($enableReboot -and [string]::IsNullOrWhiteSpace($scheduledRebootTime)) {
    Write-Log -DefaultMessage "Chained reboot initiated after cycle completion." -MessageId "Log_Backup_ChainedReboot"
    # Pause de sécurité pour la clôture des fichiers logs
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}

try {
    Invoke-DatabaseBackup
} catch {
    Add-Error -DefaultErrorMessage "Critical error during backup: {0}" -ErrorId "Error_Backup_Critical" -ErrorArgs $_.Exception.Message
}
