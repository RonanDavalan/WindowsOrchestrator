param()

Add-Type -AssemblyName System.Windows.Forms

<#
.SYNOPSIS
    Installe et configure les tâches planifiées pour les scripts de configuration système et utilisateur.
.DESCRIPTION
    Ce script s'assure d'être exécuté en tant qu'administrateur et utilise la méthode de chargement de langue
    qui a été prouvée fonctionnelle.
.EXAMPLE
    PS C:\Chemin\Vers\Script\> .\install.ps1

    Lance le script d'installation. Le script demandera automatiquement une élévation de privilèges si nécessaire.
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

# --- Internationalization (i18n) ---
$cultureName = (Get-Culture).Name
$lang = @{}
try {
    # La détermination du chemin du script doit gérer plusieurs environnements d'exécution (console, ISE, etc.),
    # d'où la nécessité de tester le type de commande pour trouver le chemin de manière fiable.
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }

    $modulePath = Join-Path $PSScriptRoot "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"
    Import-Module $modulePath -Force

    $lang = Set-OrchestratorLanguage -ScriptRoot $PSScriptRoot

    # --- Vérification du Mode Silencieux pour l'UI d'attente ---
    $ProjectRootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path
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
    # Ce bloc s'exécute si une des étapes ci-dessus échoue
    Write-Error "FATAL ERROR: Could not load language files. Details: $($_.Exception.Message)"
    Read-Host "Press Enter to exit."
    exit 1
}

# --- Configuration et Vérifications Préliminaires ---
$OriginalErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    $errorOccurredInScript = $false

try {
    $ScriptDir = $PSScriptRoot
    $ProjectRootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path

    if (-not (Test-Path (Join-Path $ProjectRootDir "config.ini"))) {
        throw ($lang.Install_InvalidProjectRootError -f $ProjectRootDir)
    }

    $SystemScriptPath = Join-Path $ProjectRootDir "management\config_systeme.ps1"
    $UserScriptPath   = Join-Path $ProjectRootDir "management\config_utilisateur.ps1"

    $TaskNameSystem = "WindowsOrchestrator-SystemStartup"
    $TaskNameUser   = "WindowsOrchestrator-UserLogon"

    Write-StyledHost ($lang.Install_ProjectRootUsed -f $ProjectRootDir) "INFO"
}
catch {
    Write-StyledHost ($lang.Install_PathDeterminationError -f $_.Exception.Message) "ERROR"
    $ErrorActionPreference = "Continue"
    Read-Host $lang.Install_PressEnterToExit
    exit 1
}

$filesMissing = $false
if (-not (Test-Path $SystemScriptPath)) { Write-StyledHost ($lang.Install_MissingSystemFile -f $SystemScriptPath) "ERROR"; $filesMissing = $true }
if (-not (Test-Path $UserScriptPath))   { Write-StyledHost ($lang.Install_MissingUserFile -f $UserScriptPath) "ERROR"; $filesMissing = $true }

if ($filesMissing) {
    Read-Host ($lang.Install_MissingFilesAborted -f $ProjectRootDir)
    exit 1
}

$TargetUserForUserTask = "$($env:USERDOMAIN)\$($env:USERNAME)"
Write-StyledHost ($lang.Install_UserTaskTarget -f $TargetUserForUserTask) "INFO"

# --- Consolidation de l'Utilisateur Cible dans config.ini ---
$ConfigFile = Join-Path $ProjectRootDir "config.ini"
try {
    $iniContent = Get-IniContent -FilePath $ConfigFile
    $currentConfigUser = if ($iniContent.SystemConfig.ContainsKey("AutoLoginUsername")) { $iniContent.SystemConfig.AutoLoginUsername } else { "" }

    if ([string]::IsNullOrWhiteSpace($currentConfigUser)) {
        Write-StyledHost $lang.Install_AutoLoginUserEmpty "INFO"
        Set-IniValue -FilePath $ConfigFile -Section "SystemConfig" -Key "AutoLoginUsername" -Value $env:USERNAME
        Write-StyledHost ($lang.Install_AutoLoginUserUpdated -f $env:USERNAME) "SUCCESS"
    }
}
catch {
    Write-StyledHost ($lang.Install_AutoLoginUserUpdateFailed -f $_.Exception.Message) "WARNING"
}
# --- Fin de la consolidation ---

# --- Lecture de la configuration pour la gestion de session ---
$config = Get-IniContent -FilePath (Join-Path $ProjectRootDir "config.ini")
$sessionMode = if ($config.ContainsKey("SystemConfig")) { $config["SystemConfig"]["SessionStartupMode"] } else { "Standard" }
$targetUsernameForConfig = if ($config.ContainsKey("SystemConfig")) { $config["SystemConfig"]["AutoLoginUsername"] } else { $env:USERNAME }
if ([string]::IsNullOrWhiteSpace($targetUsernameForConfig)) { $targetUsernameForConfig = $env:USERNAME }

# --- Assistant d'installation Autologon (Automatique) ---
if (($config['SystemConfig']['SessionStartupMode'] -eq 'Autologon') -and ($config['Installation']['UseAutologonAssistant'] -eq 'true')) {
    $winlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $autoLogonStatus = (Get-ItemProperty -Path $winlogonPath -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue).AutoAdminLogon

    # Lire la configuration pour savoir si on doit sauter l'EULA
    $skipEula = Get-ConfigValue -Section "Installation" -Key "SkipEulaPrompt" -DefaultValue "false"
    $skipEula = [System.Convert]::ToBoolean($skipEula)

    if ($autoLogonStatus -eq '1') {
        Write-StyledHost $lang.Install_AutologonAlreadyActive "INFO"
    } else {
        # Lit l'URL depuis config.ini, avec une valeur par défaut robuste en cas de clé manquante
        $autologonUrl = Get-ConfigValue -Section "Installation" -Key "AutologonDownloadUrl" -DefaultValue "https://live.sysinternals.com/files/AutoLogon.zip"
        $toolsDir = Join-Path -Path $ScriptDir -ChildPath "tools"
        $targetDir = Join-Path -Path $toolsDir -ChildPath "Autologon"
        $zipPath = Join-Path -Path $toolsDir -ChildPath "Autologon.zip"

        # Détection de l'architecture pour choisir le bon exécutable
        $exeName = switch ($env:PROCESSOR_ARCHITECTURE) {
            'x86'   { 'Autologon.exe' }
            'AMD64' { 'Autologon64.exe' }
            'ARM64' { 'Autologon64a.exe' }
            default { throw ($lang.Install_UnsupportedArchitectureError -f $env:PROCESSOR_ARCHITECTURE) }
        }
        $exePath = Join-Path -Path $targetDir -ChildPath $exeName

        $eulaPath = Join-Path -Path $targetDir -ChildPath "Eula.txt"

        $cleanExit = {
            param($errorMessage)
            Write-StyledHost $errorMessage "WARNING"
            if (Test-Path $targetDir) { Remove-Item -Path $targetDir -Recurse -Force -ErrorAction SilentlyContinue }
            if (Test-Path $zipPath) { Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue }
        }

        try {
            # Ne télécharger que si l'exécutable cible est manquant
            if (-not (Test-Path -Path $exePath)) {
                Write-StyledHost $lang.Install_DownloadingAutologon "INFO"
                if (-not (Test-Path -Path $toolsDir)) { New-Item -Path $toolsDir -ItemType Directory | Out-Null }
                Invoke-WebRequest -Uri $autologonUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop

                Write-StyledHost $lang.Install_ExtractingArchive "INFO"
                Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force -ErrorAction Stop
                Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
            }

            if (-not (Test-Path $exePath) -or -not (Test-Path $eulaPath)) {
                throw ($lang.Install_AutologonFilesMissing -f $exeName)
            }

            # --- CORRECTIF UI : On ferme le Splash Screen pour laisser la place aux fenêtres interactives ---
            if ($silentMode) { Stop-WaitingUI }

            if (-not $skipEula) {
                Write-StyledHost $lang.Install_PromptReviewEula "INFO"
                Start-Process notepad.exe -ArgumentList $eulaPath -Wait

                $consentMessage = $lang.Install_EulaConsentMessage
                $consentCaption = $lang.Install_EulaConsentCaption
                $consentResult = [System.Windows.Forms.MessageBox]::Show($consentMessage, $consentCaption, 'YesNo', 'Question')

                if ($consentResult -ne 'Yes') {
                    # Si refus, on relance l'UI avant de lancer l'exception pour la cohérence visuelle
                    if ($silentMode) { Start-WaitingUI -Message $lang.Install_SplashMessage }
                    throw ($lang.Install_EulaConsentRefused)
                }
            }

            Write-StyledHost $lang.Install_PromptUseAutologonTool "INFO"

            # Lancement de l'outil (qui sera maintenant au premier plan car WaitingUI est stoppé)
            Start-Process -FilePath $exePath -ArgumentList '-accepteula' -Wait

            # --- CORRECTIF UI : On relance le Splash Screen pour la fin de l'installation ---
            if ($silentMode) { Start-WaitingUI -Message $lang.Install_SplashMessage }

        } catch {
            # CAS 1: L'utilisateur a explicitement refusé la licence.
            if ($_.Exception.Message -eq $lang.Install_EulaConsentRefused) {
                Write-StyledHost $_.Exception.Message "WARNING"
                # L'installation continue sans configurer Autologon
                & $cleanExit -errorMessage "Installation continues without Autologon configuration."
            }
            # CAS 2: Une autre erreur technique est survenue (téléchargement, extraction...).
            else {
                Write-StyledHost ($lang.Install_AutologonDownloadFailed + " " + $_.Exception.Message) "ERROR"

                $continueResult = [System.Windows.Forms.MessageBox]::Show($lang.Install_ConfirmContinueWithoutAutologon, $lang.Install_AutologonDownloadFailedCaption, 'YesNo', 'Warning')

                if ($continueResult -eq 'No') {
                    & $cleanExit -errorMessage "Installation aborted by user."
                    exit 1
                }
                & $cleanExit -errorMessage "Installation continues without Autologon configuration."
            }
        }
    }
}

# --- Début de l'Installation ---
Write-StyledHost $lang.Install_StartConfiguringTasks "INFO"
try {

$finalArgumentSystem = "-NoProfile -ExecutionPolicy Bypass -File `"$SystemScriptPath`""
$finalArgumentUser   = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$UserScriptPath`""

    # --- Tâche 1: Script Système (ne change pas et ne nécessite pas de mot de passe) ---
    $ActionSystem = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $finalArgumentSystem -WorkingDirectory $ProjectRootDir
    $TriggerSystem = New-ScheduledTaskTrigger -AtStartup
    $PrincipalSystem = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
    $SettingsSystem = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    Register-ScheduledTask -TaskName $TaskNameSystem -Action $ActionSystem -Trigger $TriggerSystem -Principal $PrincipalSystem -Settings $SettingsSystem -Description $lang.Install_SystemTaskDescription -Force -ErrorAction Stop
    Write-StyledHost ($lang.Install_SystemTaskConfiguredSuccess -f $TaskNameSystem) "SUCCESS"

    # --- Tâche 2: Script Utilisateur (la logique dépend maintenant du mode de session) ---
    $ActionUser = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $finalArgumentUser -WorkingDirectory $ProjectRootDir
    $TriggerUser = New-ScheduledTaskTrigger -AtLogOn -User $TargetUserForUserTask
    $SettingsUser = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)

    # CAS A : Le mode de session standard est utilisé (PAS de mot de passe requis)
    if ($sessionMode -eq "Standard") {
        $PrincipalUser = New-ScheduledTaskPrincipal -UserId $TargetUserForUserTask -LogonType Interactive
        Register-ScheduledTask -TaskName $TaskNameUser -Action $ActionUser -Trigger $TriggerUser -Principal $PrincipalUser -Settings $SettingsUser -Description $lang.Install_UserTaskDescription -Force -ErrorAction Stop
    }
    # CAS B : Un mode de session automatique est utilisé (lancement au logon, PAS de mot de passe requis)
    else {
        try {
            # Pour une tâche qui se lance "-AtLogOn", le LogonType "Interactive" est la méthode correcte.
            # Elle utilise la session interactive déjà existante de l'utilisateur.
            # Cela ne requiert pas de mot de passe et ne déclenche pas la validation du privilège "SeBatchLogonRight".
            $PrincipalUser = New-ScheduledTaskPrincipal -UserId $TargetUserForUserTask -LogonType Interactive
            Register-ScheduledTask -TaskName $TaskNameUser -Action $ActionUser -Trigger $TriggerUser -Principal $PrincipalUser -Settings $SettingsUser -Description $lang.Install_UserTaskDescription -Force -ErrorAction Stop
        }
        catch {
            # Gère toute erreur potentielle lors de la création de la tâche
            throw ($lang.Install_CriticalErrorDuringInstallation -f $_.Exception.Message)
        }
    }

    Write-StyledHost ($lang.Install_SystemTaskConfiguredSuccess -f $TaskNameUser) "SUCCESS"

    Write-Host "`n"
    Write-StyledHost $lang.Install_MainTasksConfigured "INFO"
    Write-StyledHost ($lang.Install_DailyRebootTasksNote -f 'config_systeme.ps1') "INFO"

    # --- Lancement initial des scripts de configuration ---
    Write-Host "`n"
    Write-StyledHost $lang.Install_AttemptingInitialLaunch "INFO"

    # --- Préparation de l'environnement de journalisation ---
    try {
        $logDirectory = Join-Path $ProjectRootDir "Logs"
        if (-not (Test-Path $logDirectory)) {
            New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
        }

        # Applique des permissions permissives pour éviter les conflits entre les contextes Admin et Utilisateur
        $acl = Get-Acl $logDirectory
        $sid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::AuthenticatedUserSid, $null)
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($sid, "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($accessRule)
        Set-Acl -Path $logDirectory -AclObject $acl
    } catch {
        Write-StyledHost ($lang.Install_LogPermissionsWarning -f $_.Exception.Message) "WARNING"
    }

    Write-Host "`n"
}
catch {
    Write-StyledHost ($lang.Install_CriticalErrorDuringInstallation -f $_.Exception.Message) "ERROR"
    Write-StyledHost ($lang.Install_Trace -f $_.ScriptStackTrace) "ERROR"
    $errorOccurredInScript = $true
}
finally {
    $ErrorActionPreference = $OriginalErrorActionPreference
    Write-Host "`n"

    # --- Logique de sortie conditionnelle ---
    $config = Get-IniContent -FilePath (Join-Path $ProjectRootDir "config.ini")
    $rebootOnCompletion = $false
    if ($config -and $config.ContainsKey('Installation') -and $config['Installation']['RebootOnCompletion'] -eq 'true') {
        $rebootOnCompletion = $true
    }

    # --- Lancement initial des scripts (uniquement si aucun redémarrage n'est prévu) ---
    if (-not $rebootOnCompletion) {
        if (-not $errorOccurredInScript) {
            # Lancer config_systeme.ps1
            try {
                Write-StyledHost $lang.Install_ExecutingSystemScript "INFO"
                $startProcessParams = @{
                    FilePath = "powershell.exe"
                    ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$SystemScriptPath`""
                    WorkingDirectory = $ProjectRootDir
                    Wait = $true
                    PassThru = $true
                    ErrorAction = "Stop"
                }
                $silentMode = Get-ConfigValue -Section "Installation" -Key "SilentMode" -Type ([bool]) -DefaultValue $false
                if ($silentMode) {
                    $startProcessParams.WindowStyle = "Hidden"
                }
                $processSystem = Start-Process @startProcessParams
                if ($processSystem.ExitCode -eq 0) {
                    Write-StyledHost $lang.Install_SystemScriptSuccess "SUCCESS"
                } else {
                    Write-StyledHost ($lang.Install_SystemScriptWarning -f $processSystem.ExitCode, $ProjectRootDir) "WARNING"
                    $errorOccurredInScript = $true
                }
            } catch {
                Write-StyledHost ($lang.Install_SystemScriptError -f $_.Exception.Message) "ERROR"
                Write-StyledHost ($lang.Install_Trace -f $_.ScriptStackTrace) "ERROR"
                $errorOccurredInScript = $true
            }
        }
    }

    # --- Affichage du statut final ---
    if (-not $errorOccurredInScript) {
        Write-StyledHost $lang.Install_InstallationCompleteSuccess "SUCCESS"
    } else {
        Write-StyledHost $lang.Install_InstallationCompleteWithErrors "WARNING"
    }

    # --- Arrêt de l'UI d'attente ---
    Stop-WaitingUI

    # --- P-Invoke pour forcer le MessageBox au premier plan ---
    # Ce correctif s'applique uniquement à l'affichage du MessageBox final et non au Splash Screen.
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

        # Technique du Parent Fantôme :
        # On crée une fenêtre invisible qui force le focus et le TopMost
        $ghostParent = New-Object System.Windows.Forms.Form
        $ghostParent.TopMost = $true
        $ghostParent.TopLevel = $true
        $ghostParent.ShowInTaskbar = $false
        $ghostParent.Opacity = 0 # Totalement transparent
        $ghostParent.StartPosition = "CenterScreen"
        $ghostParent.Size = New-Object System.Drawing.Size(1, 1)
        
        # On affiche le parent pour qu'il prenne le focus Windows
        $ghostParent.Show()
        $ghostParent.Activate()

        $btn = [System.Windows.Forms.MessageBoxButtons]::OK
        
        if ($errorOccurredInScript) {
            $icon = [System.Windows.Forms.MessageBoxIcon]::Warning
            $msg = ($lang.Install_SilentMode_CompletedWithErrors).Replace('\n', "`n")
            # La MessageBox est "enfant" du ghostParent
            [System.Windows.Forms.MessageBox]::Show($ghostParent, $msg, "WindowsOrchestrator - Installation", $btn, $icon) | Out-Null
        } else {
            $icon = [System.Windows.Forms.MessageBoxIcon]::Information
            $msg = ($lang.Install_SilentMode_CompletedSuccessfully).Replace('\n', "`n")
            # La MessageBox est "enfant" du ghostParent
            [System.Windows.Forms.MessageBox]::Show($ghostParent, $msg, "WindowsOrchestrator - Installation", $btn, $icon) | Out-Null
        }

        $ghostParent.Close()
        $ghostParent.Dispose()
    }

    # --- Logique de Sortie Unifiée ---
    Invoke-ExitLogic -Config $config -Lang $lang
}
