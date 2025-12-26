#Requires -Version 5.1

<#
.SYNOPSIS
    Lanceur (Wrapper) pour l'installation de WindowsOrchestrator.
.DESCRIPTION
    Ce script agit comme une enveloppe technique pour le processus d'installation.
    Il est responsable de la demande d'élévation de privilèges (UAC) et de la gestion de
    la visibilité de la fenêtre (Mode Silencieux) avant de passer la main au script principal 'install.ps1'.
    Il lit le fichier 'config.ini' via une expression régulière légère pour déterminer le mode d'affichage.
.EXAMPLE
    PS C:\WindowsOrchestrator\management\> .\Launch-Install.ps1
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

param()

try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition } else { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path }
    $ProjectRootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path
    $targetScript = Join-Path $PSScriptRoot "install.ps1"
    $configFile = Join-Path $ProjectRootDir "config.ini"

    $silentMode = $false
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw
        if ($content -match "(?m)^SilentMode\s*=\s*true") { $silentMode = $true }
    }

    $startParams = @{
        FilePath = "powershell.exe"
        Verb = "RunAs"
        ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$targetScript`""
        WorkingDirectory = $ProjectRootDir
    }
    if ($silentMode) { $startParams.WindowStyle = "Hidden" }

    Start-Process @startParams
} catch {
    Write-Host "LAUNCHER ERROR: $($_.Exception.Message)" -ForegroundColor Red; Read-Host "Enter to exit"; exit 1
}
