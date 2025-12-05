param(
    # Accepte un argument de langue optionnel pour forcer l'affichage
    [string]$LanguageOverride = ""
)

<#
.SYNOPSIS
    Désinstalle les tâches planifiées et restaure les paramètres système modifiés par WindowsOrchestrator.
.DESCRIPTION
    Ce script gère sa propre élévation de privilèges tout en préservant l'argument de langue.
    Il supprime les tâches planifiées créées par l'installeur et propose de restaurer plusieurs
    paramètres système (Windows Update, Démarrage Rapide, OneDrive, Auto-Logon) à leurs valeurs par défaut.
.EXAMPLE
    PS C:\Chemin\Vers\Script\> .\uninstall.ps1

    Lance le script de désinstallation. Le script demandera automatiquement une élévation de privilèges
    si nécessaire et utilisera la langue détectée du système.
.EXAMPLE
    PS C:\Chemin\ver\Script\> .\uninstall.ps1 -LanguageOverride "en-US"

    DEPRECATED: Force le script à s'exécuter en anglais. La langue est maintenant détectée
    automatiquement. Ce paramètre sera supprimé dans une future version.
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

# --- Bloc d'auto-élévation des privilèges (Robuste) ---
$currentUserPrincipal = New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $currentUserPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Prépare les arguments pour le nouveau processus élevé
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    # L'argument de langue doit être préservé lors de la relance avec élévation pour garantir que
    # le choix de l'utilisateur n'est pas perdu après la demande de privilèges.
    if (-not [string]::IsNullOrWhiteSpace($LanguageOverride)) {
        $arguments += " -LanguageOverride '$($LanguageOverride)'"
    }
    
    # Relance le script avec les droits admin et les arguments, puis quitte la session actuelle
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -ErrorAction Stop
    } catch {
        # Affiche une erreur basique au cas où le chargement de la langue échouerait
        Write-Warning "Elevation failed. Please run this script as an administrator."
        Read-Host "Press Enter to exit."
    }
    exit
}

# --- Internationalization (i18n) ---
# Ce bloc s'exécute maintenant avec la certitude que le script est élevé.
$lang = @{}
try {
    # La détermination du chemin du script doit gérer plusieurs environnements d'exécution (console, ISE, etc.),
    # d'où la nécessité de tester le type de commande pour trouver le chemin de manière fiable.
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }
    $ScriptDir = $PSScriptRoot

    $modulePath = Join-Path $ScriptDir "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"
    Import-Module $modulePath -Force
    
    $lang = Set-OrchestratorLanguage -ScriptRoot $ScriptDir

    # --- Vérification du Mode Silencieux pour l'UI d'attente ---
    $ProjectRootDir = (Resolve-Path (Join-Path $ScriptDir "..\")).Path
    $ConfigFile = Join-Path $ProjectRootDir "config.ini"
    $silentMode = $false
    if (Test-Path $ConfigFile) {
        $config = Get-IniContent -FilePath $ConfigFile
        $silentMode = Get-ConfigValue -Section "Installation" -Key "SilentMode" -Type ([bool]) -DefaultValue $false
    }
    if ($silentMode) {
        Start-WaitingUI -Message $lang.Install_SplashMessage
    }
} catch {
    Write-Error "FATAL ERROR: Could not load language files. Uninstallation cannot continue safely. Details: $($_.Exception.Message)"
    Read-Host "Press Enter to exit."
    exit
}



# --- Configuration et Fonctions ---




$ProjectRootDir = (Resolve-Path (Join-Path $ScriptDir "..\")).Path
$OriginalErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

# --- Début de la Désinstallation ---
Write-StyledHost $lang.Uninstall_StartMessage "INFO"
Write-Host ""

# --- Étape 1: Restauration des paramètres système ---
Write-StyledHost $lang.Uninstall_RestoringSettings "INFO"

# Réactiver Windows Update
try {
    $windowsUpdatePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $windowsUpdateService = "wuauserv"
    if (Test-Path $windowsUpdatePolicyKey) {
        Set-ItemProperty $windowsUpdatePolicyKey NoAutoUpdate 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty $windowsUpdatePolicyKey NoAutoRebootWithLoggedOnUsers 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Get-Service $windowsUpdateService -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic -ErrorAction SilentlyContinue
    Write-StyledHost $lang.Uninstall_WindowsUpdateReactivated "SUCCESS"
} catch {
    Write-StyledHost ($lang.Uninstall_WindowsUpdateError -f $_.Exception.Message) "ERROR"
}

# Réactiver le Démarrage Rapide (Fast Startup)
try {
    $powerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if (Test-Path $powerRegPath) {
        Set-ItemProperty $powerRegPath HiberbootEnabled 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-StyledHost $lang.Uninstall_FastStartupReactivated "SUCCESS"
} catch {
    Write-StyledHost ($lang.Uninstall_FastStartupError -f $_.Exception.Message) "ERROR"
}

# Réactiver OneDrive
try {
    $oneDrivePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if (Test-Path $oneDrivePolicyKey) {
        if (Get-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Force -ErrorAction SilentlyContinue
        }
    }
    Write-StyledHost $lang.Uninstall_OneDriveReactivated "SUCCESS"
} catch {
    Write-StyledHost ($lang.Uninstall_OneDriveError -f $_.Exception.Message) "ERROR"
}

# --- Gestion de l'Auto-Logon (Logique Interactive avec Vérification) ---
$winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$autoLogonStatus = (Get-ItemProperty -Path $winlogonKey -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue).AutoAdminLogon

if ($autoLogonStatus -eq '1') {
    $autologonExeName = switch($env:PROCESSOR_ARCHITECTURE) {
        'x86'   { 'Autologon.exe' }
        'AMD64' { 'Autologon64.exe' }
        'ARM64' { 'Autologon64a.exe' }
        default { 'Autologon64.exe' }
    }
    $autologonCleanerPath = Join-Path $ScriptDir "tools\Autologon\$autologonExeName"

    if (Test-Path $autologonCleanerPath) {
        try {
            Write-StyledHost $lang.Uninstall_AutologonDisablePrompt "INFO"

            # --- CORRECTIF UI : Arrêt temporaire de l'UI pour voir la fenêtre Autologon ---
            if ($silentMode) { Stop-WaitingUI }

            Start-Process -FilePath $autologonCleanerPath -ArgumentList "-accepteula" -Wait -ErrorAction Stop

            # --- CORRECTIF UI : Redémarrage de l'UI pour la fin du script ---
            if ($silentMode) { Start-WaitingUI -Message $lang.Install_SplashMessage }

            Write-StyledHost "Autologon tool executed. LSA secrets should be cleaned." "SUCCESS"

            # --- VÉRIFICATION POST-ACTION ---
            # On relit la valeur du Registre APRÈS que l'utilisateur a fermé l'outil.
            $newAutoLogonStatus = (Get-ItemProperty -Path $winlogonKey -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue).AutoAdminLogon
            
            # Si la clé est passée à "0", l'utilisateur a bien cliqué sur "Disable".
            if ($newAutoLogonStatus -ne '1') {
                Write-StyledHost $lang.Uninstall_AutoLogonDisabled "SUCCESS"
            } else {
            # Sinon, il a fermé la fenêtre, donc on le signale comme tel.
                Write-StyledHost $lang.Uninstall_AutoLogonLeftAsIs "INFO"
            }
        } catch {
            Write-StyledHost ($lang.Uninstall_AutoLogonDisableError -f $_.Exception.Message) "ERROR"
        }
    } else {
        # L'outil est absent : on informe l'utilisateur et on ne fait RIEN.
        Write-StyledHost $lang.Uninstall_AutologonToolNotFound_Interactive "WARNING"
    }
}
Write-Host ""


# --- Étape 3: Suppression des Tâches Planifiées ---
Write-StyledHost $lang.Uninstall_DeletingScheduledTasks "INFO"

$TasksToRemove = @(
    "WindowsOrchestrator-SystemStartup",
    "WindowsOrchestrator-UserLogon",
    "WindowsOrchestrator-SystemScheduledReboot",
    "WindowsOrchestrator-SystemBackup",
    "WindowsOrchestrator-System-CloseApp",
    "WindowsOrchestrator-User-CloseApp"
)
$tasksFoundButNotRemoved = [System.Collections.Generic.List[string]]::new()

foreach ($taskName in $TasksToRemove) {
    Write-StyledHost ($lang.Uninstall_ProcessingTask -f $taskName) -NoNewline
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($task) {
        Write-Host $lang.Uninstall_TaskFoundAttemptingDeletion -ForegroundColor Cyan -NoNewline
        try {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
            # Après la suppression, une vérification explicite est faite pour s'assurer que la tâche
            # n'existe plus, car Unregister-ScheduledTask ne retourne pas toujours une erreur fiable.
            if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
                Write-Host $lang.Uninstall_TaskSuccessfullyRemoved -ForegroundColor Green
            } else {
                Write-Host $lang.Uninstall_TaskDeletionFailed -ForegroundColor Red
                $tasksFoundButNotRemoved.Add($taskName)
            }
        } catch {
            Write-Host $lang.Uninstall_TaskDeletionError -ForegroundColor Red
            Write-StyledHost ($lang.Uninstall_TaskErrorDetail -f $_.Exception.Message) "ERROR"
            $tasksFoundButNotRemoved.Add($taskName)
        }
    } else {
        Write-Host $lang.Uninstall_TaskNotFound -ForegroundColor Yellow
    }
}
Write-Host ""


# --- Résumé Final ---
Write-StyledHost $lang.Uninstall_CompletionMessage "SUCCESS"
if ($tasksFoundButNotRemoved.Count -gt 0) {
    Write-StyledHost ($lang.Uninstall_TasksNotRemovedWarning -f ($tasksFoundButNotRemoved -join ', ')) "ERROR"
    Write-StyledHost $lang.Uninstall_CheckTaskScheduler "ERROR"
}
Write-StyledHost $lang.Uninstall_FilesNotDeletedNote "INFO"

$ErrorActionPreference = $OriginalErrorActionPreference
Write-Host ""

# --- Arrêt de l'UI d'attente ---
Stop-WaitingUI

    # --- P-Invoke pour forcer le MessageBox au premier plan ---
    # Ce code est identique à celui inséré dans install.ps1
    Add-Type @"
        using System; 
        using System.Runtime.InteropServices; 
        public class MessageBoxFixer { 
            [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd); 
            [DllImport("user32.dll")] public static extern IntPtr GetLastActivePopup(IntPtr hWnd); 
            [DllImport("user32.dll", SetLastError = true)] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId); 
            [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); 
            [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow(); 
            [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach); 
            [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId(); 
            public const int SW_RESTORE = 9; 
            public const int SW_SHOW = 5;

            public static void ForceForeground() { 
                uint currentThread = GetCurrentThreadId(); 
                uint lpdwProcessId = 0; // Nouvelle variable pour la compatibilité
                uint foregroundThread = GetWindowThreadProcessId(GetForegroundWindow(), out lpdwProcessId); // Appel corrigé
                IntPtr targetHwnd = GetForegroundWindow(); 

                if (targetHwnd != IntPtr.Zero && currentThread != foregroundThread) { 
                    AttachThreadInput(currentThread, foregroundThread, true); 
                    ShowWindow(targetHwnd, SW_RESTORE); 
                    SetForegroundWindow(targetHwnd); 
                    AttachThreadInput(currentThread, foregroundThread, false); 
                } else if (targetHwnd == IntPtr.Zero) { 
                    // Dans le contexte Admin/SYSTEM, la fenêtre peut ne pas être active 
                } 
            } 
        } 
"@

    # Appel au correctif juste avant le MessageBox (n'a un effet que sur la prochaine fenêtre)
    [MessageBoxFixer]::ForceForeground()

    # --- Notification Mode Silencieux ---
    $silentMode = Get-ConfigValue -Section "Installation" -Key "SilentMode" -Type ([bool]) -DefaultValue $false

    # =========================================================================
    # NOTIFICATION FINALE EN MODE SILENCIEUX (Correction Freeze)
    # =========================================================================
    if ($silentMode) {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        # Technique du Parent Fantôme
        $ghostParent = New-Object System.Windows.Forms.Form
        $ghostParent.TopMost = $true
        $ghostParent.TopLevel = $true
        $ghostParent.ShowInTaskbar = $false
        $ghostParent.Opacity = 0
        $ghostParent.StartPosition = "CenterScreen"
        $ghostParent.Size = New-Object System.Drawing.Size(1, 1)
        
        $ghostParent.Show()
        $ghostParent.Activate()

        $btn = [System.Windows.Forms.MessageBoxButtons]::OK
        
        $hasErrors = ($tasksFoundButNotRemoved.Count -gt 0) -or ($Global:ErreursRencontrees.Count -gt 0)

        if ($hasErrors) {
            $icon = [System.Windows.Forms.MessageBoxIcon]::Warning
            $msg = ($lang.Uninstall_SilentMode_CompletedWithErrors).Replace('\n', "`n")
            [System.Windows.Forms.MessageBox]::Show($ghostParent, $msg, "WindowsOrchestrator - Uninstallation", $btn, $icon) | Out-Null
        } else {
            $icon = [System.Windows.Forms.MessageBoxIcon]::Information
            $msg = ($lang.Uninstall_SilentMode_CompletedSuccessfully).Replace('\n', "`n")
            [System.Windows.Forms.MessageBox]::Show($ghostParent, $msg, "WindowsOrchestrator - Uninstallation", $btn, $icon) | Out-Null
        }

        $ghostParent.Close()
        $ghostParent.Dispose()
    }

# --- Logique de Sortie Hiérarchique ---
$ConfigFile = Join-Path $ProjectRootDir "config.ini"
$config = Get-IniContent -FilePath $ConfigFile

Invoke-ExitLogic -Config $config -Lang $lang -RebootMessageKey "Uninstall_RebootMessage" -PressEnterKey "Uninstall_PressEnterToClose"
