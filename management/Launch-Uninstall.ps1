#Requires -Version 5.1

<#
.SYNOPSIS
    Lanceur (Wrapper) pour la désinstallation de WindowsOrchestrator.
.DESCRIPTION
    Ce script agit comme une enveloppe technique pour le processus de désinstallation.
    Il est responsable de la demande d'élévation de privilèges (UAC) et de la gestion de
    la visibilité de la fenêtre (Mode Silencieux) avant de passer la main au script principal 'uninstall.ps1'.
    Il lit le fichier 'config.ini' via une expression régulière légère pour déterminer le mode d'affichage.
.EXAMPLE
    PS C:\WindowsOrchestrator\management\> .\Launch-Uninstall.ps1
.NOTES
    Projet      : WindowsOrchestrator
    Version     : 1.72
    Licence     : GNU GPLv3

    --- CRÉDITS & RÔLES ---
    Ce projet est le fruit d'une collaboration hybride Humain-IA :

    Architecte Principal & QA      : Ronan Davalan
    Architecte IA & Planification  : Google Gemini
    Développeur IA Principal       : Grok (xAI)
    Consultant Technique IA        : Claude (Anthropic)
#>

param()

try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
    else { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path }

    # Définition explicite des chemins absolus
    $ProjectRootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path
    $targetScript = Join-Path $PSScriptRoot "uninstall.ps1"
    $configFile = Join-Path $ProjectRootDir "config.ini"

    # Lecture minimale de config.ini pour SilentMode (Regex)
    $silentMode = $false
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw
        if ($content -match "(?m)^SilentMode\s*=\s*true") {
            $silentMode = $true
        }
    }

    # Configuration du processus
    $startParams = @{
        FilePath = "powershell.exe"
        Verb = "RunAs" # Élévation Administrateur
        ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$targetScript`""
        WorkingDirectory = $ProjectRootDir # CRUCIAL : On fixe le dossier de travail
    }

    if ($silentMode) {
        $startParams.WindowStyle = "Hidden"
    }

    Start-Process @startParams

} catch {
    Write-Host "LAUNCHER ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit."
    exit 1
}
