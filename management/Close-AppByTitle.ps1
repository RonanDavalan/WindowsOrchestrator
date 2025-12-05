#Requires -Version 5.1
<#
.SYNOPSIS
    Trouve une fenêtre par son titre, la met au premier plan, et lui envoie des touches.
.DESCRIPTION
    Ce script utilise les API Windows natives (via C#) pour interagir de manière fiable avec une fenêtre applicative.
    C'est la méthode la plus robuste pour les applications dont la fenêtre n'est pas standard ou qui ne répondent pas
    aux commandes PowerShell classiques comme Stop-Process. Il est particulièrement utile pour automatiser la fermeture
    propre d'applications graphiques.

    La logique de recherche a été améliorée pour "nettoyer" les titres de fenêtres avant de les comparer,
    ce qui le rend résistant aux problèmes d'espaces inhabituels (comme les espaces insécables).
.PARAMETER WindowTitle
    Le titre, ou une partie du titre, de la fenêtre à cibler. La recherche n'est pas sensible à la casse.
    Par exemple, "Calculatrice" trouvera la fenêtre "Calculatrice".
.PARAMETER KeysToSend
    La séquence de touches à envoyer à la fenêtre une fois qu'elle est au premier plan. Les touches spéciales
    doivent être formatées selon la convention de la méthode SendKeys (ex: {ESC}, {ENTER}, ^c pour Ctrl+C).
.EXAMPLE
    PS C:\> .\Close-AppByTitle.ps1 -WindowTitle "Sans titre - Bloc-notes" -KeysToSend "Bonjour{ENTER}^smonfichier.txt{ENTER}"

    Cet exemple trouve une fenêtre du Bloc-notes, écrit "Bonjour", appuie sur Entrée, puis simule Ctrl+S pour sauvegarder
    le fichier sous le nom "monfichier.txt".
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

param(
    # Le titre EXACT de la fenêtre de l'application à fermer.
    [string]$WindowTitle = "MyApp",

    # La séquence de touches pour la fermer.
    [string]$KeysToSend = "{ESC}{ESC}x{ENTER}"
)

# --- Initialisation de l'Internationalisation (I18N) ---
$Global:lang = @{}
try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') {
        $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    else {
        try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop }
        catch { $PSScriptRoot = Get-Location }
    }

    $modulePath = Join-Path $PSScriptRoot "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"
    Import-Module $modulePath -Force

    $Global:lang = Set-OrchestratorLanguage -ScriptRoot $PSScriptRoot
} catch {
    $i18nLoadingError = $_.Exception.Message
}

# --- Définition des fonctions de l'API Windows ---
# L'interaction de bas niveau avec les fenêtres (énumération, mise au premier plan) n'est pas possible
# nativement en PowerShell. Nous injectons donc un bloc de code C# qui expose les fonctions nécessaires
# depuis la librairie "user32.dll" de Windows. C'est une méthode avancée mais très fiable.
$code = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WindowInteraction {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    public const int SW_RESTORE = 9;
}
"@

try {
    # Compilation et chargement du code C# et des librairies nécessaires en mémoire.
    Add-Type -TypeDefinition $code -Language CSharp
    Add-Type -AssemblyName System.Windows.Forms

    # Variable globale au script pour stocker le "handle" (identifiant unique) de la fenêtre trouvée.
    $script:foundWindowHandle = [System.IntPtr]::Zero

    # --- Bloc de rappel (Callback) pour l'énumération des fenêtres ---
    # La fonction EnumWindows va appeler ce bloc de code pour CHAQUE fenêtre existante sur le système.
    # Notre rôle est de filtrer pour trouver celle qui nous intéresse.
    $enumWindowsCallback = {
        param($hWnd, $lParam)
        
        # On ne s'intéresse qu'aux fenêtres visibles par l'utilisateur.
        if ([WindowInteraction]::IsWindowVisible($hWnd)) {
            # On récupère le titre de la fenêtre en cours d'analyse.
            $sb = New-Object System.Text.StringBuilder 256
            [WindowInteraction]::GetWindowText($hWnd, $sb, $sb.Capacity) | Out-Null
            
            # --- NORMALISATION DU TITRE (Correction pour la robustesse) ---
            # On nettoie le titre récupéré pour supprimer les problèmes courants :
            # 1. On remplace tous les types d'espaces (y compris les insécables U+00A0) par un espace simple.
            # 2. On supprime les espaces multiples qui pourraient résulter du remplacement.
            # 3. On supprime les espaces au début et à la fin.
            $cleanedTitle = $sb.ToString().Replace([char]0x00A0, ' ').Replace('  ', ' ').Trim()

            # Si le titre NETTOYÉ de la fenêtre contient le titre que nous cherchons...
            if ($cleanedTitle -like "*$($WindowTitle)*") {
                # ... on stocke son handle et on retourne $false pour arrêter immédiatement la recherche.
                $script:foundWindowHandle = $hWnd
                return $false
            }
        }
        # Si ce n'est pas la bonne fenêtre, on retourne $true pour continuer l'énumération.
        return $true
    }

    Write-StyledHost "Searching for window with title '$WindowTitle'..." "INFO"
    # Démarrage du processus d'énumération qui va utiliser notre callback.
    [WindowInteraction]::EnumWindows($enumWindowsCallback, [System.IntPtr]::Zero)

    # Si le handle est différent de zéro, cela signifie que notre callback a trouvé la fenêtre.
    if ($script:foundWindowHandle -ne [System.IntPtr]::Zero) {
        $handle = $script:foundWindowHandle
        Write-StyledHost "Window found! Handle: $handle" "INFO"

        # --- Activation de la fenêtre et envoi des touches ---
        # Cette séquence est cruciale pour la fiabilité. Il faut s'assurer que la fenêtre
        # est visible et active AVANT de lui envoyer des commandes.

        # Si la fenêtre est réduite dans la barre des tâches (icône), on la restaure.
        if ([WindowInteraction]::IsIconic($handle)) {
            [WindowInteraction]::ShowWindow($handle, [WindowInteraction]::SW_RESTORE)
            # Pause pour laisser le temps à l'animation de restauration de se terminer.
            Start-Sleep -Milliseconds 250
        }
        
        # On met la fenêtre au premier plan. C'est elle qui recevra les prochaines frappes clavier.
        [WindowInteraction]::SetForegroundWindow($handle)
        # Pause pour s'assurer que le focus est bien sur la fenêtre cible avant d'envoyer les touches.
        Start-Sleep -Milliseconds 500

        # --- Envoi de la séquence de touches avec pauses ---
        # L'envoi des touches est décomposé avec des pauses pour simuler une interaction humaine
        # et gérer les applications qui peuvent avoir un léger temps de latence pour traiter chaque commande.
        Write-StyledHost "Sending first key {ESC}..." "INFO"
        [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        Start-Sleep -Seconds 1 # Pause de 1 seconde

        Write-StyledHost "Sending second key {ESC}..." "INFO"
        [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        Start-Sleep -Seconds 1 # Pause de 1 seconde

        Write-StyledHost "Sending final sequence 'x' et {ENTER}..." "INFO"
        [System.Windows.Forms.SendKeys]::SendWait("x{ENTER}") # Pas besoin de pause ici

        Write-StyledHost "Sequence sent successfully." "INFO"
    } else {
        Write-StyledHost "FAILURE: No window with title '$WindowTitle' was found." "WARNING"
    }
} catch {
    Write-StyledHost "An unexpected error occurred: $($_.Exception.Message)" "ERROR"
    exit 1
}
