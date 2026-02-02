#Requires -Version 5.1

<#
.SYNOPSIS
    Module de réduction de logs (Log Trimming) pour WindowsOrchestrator v1.74.
.DESCRIPTION
    Ce script tronque une liste de fichiers journaux pour ne conserver que les N dernières lignes.
    Il supporte les caractères génériques (Wildcards, ex: *.log).
.PARAMETER BaseDir
    Le répertoire racine où se trouvent les logs (peut être relatif).
.PARAMETER Files
    Une liste de motifs séparés par des virgules (ex: "server.log, error_*.log").
.PARAMETER LinesToKeep
    Le nombre de lignes à conserver (Défaut: 1000).
.NOTES
    Projet      : WindowsOrchestrator
    Version     : 1.74
    Licence     : GNU GPLv3

    --- CRÉDITS & RÔLES ---
    Ce projet est le fruit d'une collaboration hybride Humain-IA :

    Direction Produit & Spécifications  : Ronan Davalan
    Architecte Principal & QA           : Ronan Davalan
    Architecte IA & Planification       : Google Gemini
    Développeur IA Principal            : Grok (xAI)
    Consultant Technique IA             : Claude (Anthropic)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$BaseDir,

    [Parameter(Mandatory=$true)]
    [string]$Files,

    [int]$LinesToKeep = 1000
)

# 1. Résolution du chemin racine absolu
$CurrentScriptDir = $PSScriptRoot
if (-not [System.IO.Path]::IsPathRooted($BaseDir)) {
    $TargetDir = Join-Path -Path $CurrentScriptDir -ChildPath $BaseDir
    $TargetDir = [System.IO.Path]::GetFullPath($TargetDir)
} else {
    $TargetDir = $BaseDir
}

# Vérification du dossier souche
if (-not (Test-Path -LiteralPath $TargetDir -PathType Container)) {
    Write-Output "ERROR: Target directory not found: '$TargetDir'"
    exit 1
}

# 2. Traitement de la liste de fichiers (Supporte les Wildcards)
$FilePatterns = $Files -split ','

foreach ($Pattern in $FilePatterns) {
    # Nettoyage du motif
    $CleanPattern = $Pattern.Trim().Trim('"').Trim("'")
    if ([string]::IsNullOrWhiteSpace($CleanPattern)) { continue }

    # Recherche des fichiers correspondants au motif dans le dossier cible
    # On utilise Get-ChildItem pour résoudre les étoiles (*)
    $Matches = Get-ChildItem -Path $TargetDir -Filter $CleanPattern -File -ErrorAction SilentlyContinue

    if ($Matches.Count -eq 0) {
        Write-Output "SKIP: No files found matching '$CleanPattern' in target directory."
        continue
    }

    foreach ($FileItem in $Matches) {
        $FileName = $FileItem.Name
        $FullPath = $FileItem.FullName

        # 3. Opération de Réduction
        try {
            # Lecture optimisée des N dernières lignes
            $Content = Get-Content -LiteralPath $FullPath -Tail $LinesToKeep -ErrorAction Stop

            # Réécriture du fichier (Écrase l'ancien contenu)
            $Content | Set-Content -LiteralPath $FullPath -Encoding UTF8 -Force -ErrorAction Stop

            Write-Output "SUCCESS: Reduced '$FileName' (kept last $LinesToKeep lines)."
        }
        catch {
            Write-Output "ERROR: Failed to reduce '$FileName'. Details: $($_.Exception.Message)"
        }
    }
}

# Fin normale
exit 0
