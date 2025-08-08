# Ce script va trouver tous les fichiers .ps1 et .psd1 du projet
# et les ré-enregistrer avec l'encodage UTF-8 with BOM,
# ce qui est nécessaire pour la compatibilité avec PowerShell 5.1.

$ErrorActionPreference = 'Stop'
Write-Host "Début de la correction de l'encodage des fichiers..."

try {
    # Obtenir le chemin du répertoire où se trouve ce script
    $projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # Lister tous les fichiers à corriger
    $filesToFix = Get-ChildItem -Path $projectRoot -Recurse -Include *.ps1, *.psd1

    if ($filesToFix.Count -eq 0) {
        Write-Warning "Aucun fichier .ps1 ou .psd1 trouvé."
        return
    }

    Write-Host ("{0} fichiers trouvés. Conversion en UTF-8 avec BOM en cours..." -f $filesToFix.Count)

    foreach ($file in $filesToFix) {
        Write-Host " - Correction de : $($file.FullName)"
        $content = Get-Content -Path $file.FullName -Raw
        # Ré-écriture du fichier avec le bon encodage
        Out-File -FilePath $file.FullName -InputObject $content -Encoding utf8BOM -Force
    }

    Write-Host "`n[SUCCÈS] Tous les fichiers ont été convertis avec succès." -ForegroundColor Green

} catch {
    Write-Error "Une erreur est survenue durant le processus : $($_.Exception.Message)"
}

Read-Host "Appuyez sur Entrée pour terminer."
