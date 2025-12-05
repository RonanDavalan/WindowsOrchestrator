#Requires -Version 5.1
<#
.SYNOPSIS
    Affiche une interface d'attente (Splash Screen) pour WindowsOrchestrator en mode silencieux.
.DESCRIPTION
    Ce script crée une fenêtre graphique simple avec un indicateur de progression pour rassurer
    l'utilisateur pendant les opérations longues en mode silencieux.
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

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Création de la fenêtre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Orchestrator"
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

# Label principal
$labelMain = New-Object System.Windows.Forms.Label
$labelMain.Text = "Windows Orchestrator"
$labelMain.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$labelMain.Location = New-Object System.Drawing.Point(10, 10)
$labelMain.Size = New-Object System.Drawing.Size(380, 30)
$labelMain.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelMain)

# Label secondaire
$labelSecondary = New-Object System.Windows.Forms.Label
$labelSecondary.Text = "Opération en cours, veuillez patienter..."
$labelSecondary.Location = New-Object System.Drawing.Point(10, 50)
$labelSecondary.Size = New-Object System.Drawing.Size(380, 20)
$labelSecondary.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelSecondary)

# ProgressBar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 80)
$progressBar.Size = New-Object System.Drawing.Size(380, 20)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
$form.Controls.Add($progressBar)

# Affichage de la fenêtre (boucle jusqu'à fermeture externe)
$form.ShowDialog() | Out-Null
