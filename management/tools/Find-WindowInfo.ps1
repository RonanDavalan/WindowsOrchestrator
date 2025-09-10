<#
.SYNOPSIS
    Liste les fenêtres visibles et les processus qui leur sont associés.
.DESCRIPTION
    Ce script utilise les API Windows (User32) pour énumérer toutes les fenêtres de premier niveau
    actuellement visibles sur le bureau. Pour chaque fenêtre trouvée, il affiche son titre complet,
    le nom du processus propriétaire et son identifiant de processus (PID).
.EXAMPLE
    PS C:\> .\Get-VisibleWindows.ps1

    --- Liste des fenêtres visibles et de leurs processus propriétaires ---
    Titre: 'Nouveau message - Outlook'    | Processus: OUTLOOK (12345)
    Titre: 'MonProjet - Visual Studio Code' | Processus: Code (6789)
    Titre: 'PowerShell'                   | Processus: pwsh (10112)
.NOTES
    Auteur: Ronan Davalan & Gemini
    Ce script repose sur l'utilisation de P/Invoke pour appeler des fonctions non managées de l'API Windows,
    car il n'existe pas de cmdlets PowerShell natives pour cette tâche.
#>

#=======================================================================================================================
# --- Définition des Fonctions ---
#=======================================================================================================================

<#
.SYNOPSIS
    Énumère toutes les fenêtres visibles et affiche les informations sur leur processus propriétaire.
.DESCRIPTION
    Cette fonction est le cœur du script. Elle définit et charge en mémoire une classe C# pour interagir
    avec l'API User32.dll de Windows. Elle utilise ensuite la fonction `EnumWindows` pour itérer sur
    chaque fenêtre, vérifie sa visibilité, récupère son titre et identifie le processus associé
    avant d'afficher les informations dans la console.
.OUTPUTS
    Aucun. La fonction n'émet aucun objet dans le pipeline. Elle écrit les informations formatées
    directement dans la console hôte.
.EXAMPLE
    PS C:\> Get-VisibleWindowProcess

    (Produit la même sortie que l'exemple du script principal)
#>
function Get-VisibleWindowProcess {
    [CmdletBinding()]
    param()

    # --- Dépendance : API Windows via P/Invoke ---
    # PowerShell ne dispose pas de commandes natives pour lister les fenêtres via l'API Windows User32.
    # Nous injectons donc un fragment de code C# en mémoire pour accéder directement aux fonctions nécessaires
    # (EnumWindows, IsWindowVisible, etc.). Le nom de la classe est unique pour éviter les conflits
    # si le script est exécuté dans une session où d'autres types ont été chargés.
    $code = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class FindWindowUser32_Unique {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
}
"@
    Add-Type -TypeDefinition $code -Language CSharp

    # --- Logique de Rappel (Callback) ---
    # La fonction EnumWindows requiert une "fonction de rappel" (callback) qu'elle exécute pour chaque fenêtre trouvée.
    # Ce bloc de script sert de callback.
    $callback = {
        param($hWnd, $lParam)

        if ([FindWindowUser32_Unique]::IsWindowVisible($hWnd)) {
            $sb = New-Object System.Text.StringBuilder 256
            [FindWindowUser32_Unique]::GetWindowText($hWnd, $sb, $sb.Capacity) | Out-Null
            $title = $sb.ToString()

            if ($title.Length -gt 0) {
                # La variable est nommée `$windowPid` pour éviter tout conflit potentiel avec la variable
                # automatique `$pid` de PowerShell, qui contient le PID du processus PowerShell lui-même.
                $windowPid = 0
                [FindWindowUser32_Unique]::GetWindowThreadProcessId($hWnd, [ref]$windowPid) | Out-Null

                # Tente de récupérer le processus associé au PID.
                # Certains processus, notamment système ou avec des privilèges élevés, peuvent refuser l'accès.
                # `-ErrorAction SilentlyContinue` ignore ces fenêtres sans interrompre le script.
                $process = Get-Process -Id $windowPid -ErrorAction SilentlyContinue

                if ($process) {
                    Write-Host ("Titre: '{0}'`t| Processus: {1} ({2})" -f $title, $process.ProcessName, $process.Id)
                }
            }
        }
        # Il est impératif de retourner $true pour que EnumWindows continue d'énumérer les autres fenêtres.
        return $true
    }

    # --- Exécution de l'énumération ---
    Write-Host "--- Liste des fenêtres visibles et de leurs processus propriétaires ---"
    [FindWindowUser32_Unique]::EnumWindows($callback, [System.IntPtr]::Zero)
}


#=======================================================================================================================
# --- DÉBUT DU SCRIPT PRINCIPAL ---
#=======================================================================================================================

Get-VisibleWindowProcess
