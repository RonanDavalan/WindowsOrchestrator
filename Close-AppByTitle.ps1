#Requires -Version 5.1
<#
.SYNOPSIS
    Trouve une fenêtre par son titre, la met au premier plan, et lui envoie des touches.
    C'est la méthode la plus fiable pour les applications dont la fenêtre n'est pas standard.
.NOTES
    Doit être exécuté avec des privilèges égaux ou supérieurs à ceux de l'application cible.
#>

param(
    # Le titre EXACT de la fenêtre de l'application à fermer.
    [string]$WindowTitle = "AllSys-Clk",
    
    # La séquence de touches pour la fermer.
    [string]$KeysToSend = "{ESC}{ESC}x{ENTER}"
)

# Utilisation d'un nom de classe unique pour éviter tout conflit.
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
    Add-Type -TypeDefinition $code -Language CSharp
    Add-Type -AssemblyName System.Windows.Forms
    $script:foundWindowHandle = [System.IntPtr]::Zero
    $enumWindowsCallback = {
        param($hWnd, $lParam)
        if ([WindowInteraction]::IsWindowVisible($hWnd)) {
            $sb = New-Object System.Text.StringBuilder 256
            [WindowInteraction]::GetWindowText($hWnd, $sb, $sb.Capacity) | Out-Null
            if ($sb.ToString() -like "*$($WindowTitle)*") {
                $script:foundWindowHandle = $hWnd
                return $false
            }
        }
        return $true
    }

    Write-Host "Recherche de la fenêtre avec le titre '$WindowTitle'..."
    [WindowInteraction]::EnumWindows($enumWindowsCallback, [System.IntPtr]::Zero)

    if ($script:foundWindowHandle -ne [System.IntPtr]::Zero) {
        $handle = $script:foundWindowHandle
        Write-Host "Fenêtre trouvée ! Handle: $handle"
        if ([WindowInteraction]::IsIconic($handle)) {
            [WindowInteraction]::ShowWindow($handle, [WindowInteraction]::SW_RESTORE)
            Start-Sleep -Milliseconds 250
        }
        [WindowInteraction]::SetForegroundWindow($handle)
        Start-Sleep -Milliseconds 500
		# --- Envoi de la séquence de touches avec pauses ---
		Write-Host "Envoi de la première touche {ESC}..."
		[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
		Start-Sleep -Seconds 1 # Pause de 1 seconde

		Write-Host "Envoi de la deuxième touche {ESC}..."
		[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
		Start-Sleep -Seconds 1 # Pause de 1 seconde

		Write-Host "Envoi de la séquence finale 'x' et {ENTER}..."
		[System.Windows.Forms.SendKeys]::SendWait("x{ENTER}") # Pas besoin de pause ici

		Write-Host "Séquence complète envoyée avec succès."		
    } else {
        Write-Warning "ÉCHEC : Aucune fenêtre avec le titre '$WindowTitle' n'a été trouvée."
    }
} catch {
    Write-Error "Une erreur inattendue est survenue : $($_.Exception.Message)"
    exit 1
}